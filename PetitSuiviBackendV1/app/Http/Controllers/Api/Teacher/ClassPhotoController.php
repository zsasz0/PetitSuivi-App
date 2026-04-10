<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\Childphoto;
use App\Models\Childphotorecipient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Teacher — Photo Sharing
 *
 * Endpoints for uploading, listing, and revoking photos shared
 * with specific children's parents.
 *
 * Photos are stored with an optional expiration date; expired
 * photos are automatically excluded from parent-facing views.
 */
class ClassPhotoController extends Controller
{
    private function normalizeStoredPhotoPath(?string $storedPath): array
    {
        $rawPath = trim((string) $storedPath);
        $parsedUrlPath = parse_url($rawPath, PHP_URL_PATH);
        $pathOnly = is_string($parsedUrlPath) && $parsedUrlPath !== '' ? $parsedUrlPath : $rawPath;
        $relativePublicPath = ltrim(preg_replace('#^/?storage/#', '', $pathOnly), '/');

        return [
            'public_disk' => $relativePublicPath,
            'public_url' => '/storage/' . $relativePublicPath,
            'legacy_local' => 'public/' . $relativePublicPath,
        ];
    }

    /**
     * List teacher's shared photos.
     *
     * Returns all photos uploaded by the authenticated teacher, with
     * nested recipient (child) information and expiration status.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Photos retrieved.",
     *   "data": [
     *     {
     *       "id": 1,
     *       "file_path": "/storage/photos/class_abc.jpg",
     *       "created_at": "2026-03-05T10:00:00",
     *       "expired": false,
     *       "recipients": [
     *         { "child_id": 8, "child_name": "Sami Ben Ali", "downloaded": false }
     *       ]
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $teacherId = $user->PersonID;

        $photos = \Illuminate\Support\Facades\DB::table('Childphoto')
            ->where('TeacherID', $teacherId)
            ->get();

        $photoIds = $photos->pluck('ChildphotoID')->toArray();

        $recipients = \Illuminate\Support\Facades\DB::table('Childphotorecipient')
            ->join('Child', 'Childphotorecipient.ChildID', '=', 'Child.ChildID')
            ->whereIn('ChildphotoID', $photoIds)
            ->select('Childphotorecipient.ChildphotoID', 'Child.ChildID', 'Child.Firstname', 'Child.Lastname', 'Childphotorecipient.Downloadtime')
            ->get();

        $formatted = [];
        $now = \Carbon\Carbon::now();

        foreach ($photos as $p) {
            $normalizedPaths = $this->normalizeStoredPhotoPath($p->Filepath);
            $photoRecipients = [];
            foreach ($recipients as $r) {
                if ($r->ChildphotoID == $p->ChildphotoID) {
                    $photoRecipients[] = [
                        'child_id' => $r->ChildID,
                        'child_name' => $r->Firstname . ' ' . $r->Lastname,
                        'download_time' => $r->Downloadtime
                    ];
                }
            }

            $expires = $p->Expiresat ? \Carbon\Carbon::parse($p->Expiresat) : null;
            $expired = $expires ? $now->greaterThan($expires) : false;

            $formatted[] = [
                'id' => $p->ChildphotoID,
                'file_path' => url($normalizedPaths['public_url']),
                'created_at' => null, // schema lacks created_at
                'expired' => $expired,
                'recipients' => $photoRecipients
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Photos retrieved.',
            'data' => $formatted
        ]);
    }

    /**
     * Upload a class photo.
     *
     * Accepts a multipart form upload, stores the photo, and creates
     * Childphotorecipient records for each targeted child.
     *
     * @bodyParam photo file required The image file (JPEG/PNG, max 5MB). No-example
     * @bodyParam child_ids array required List of ChildIDs to share the photo with. Example: [8, 9]
     * @bodyParam expires_in_days integer optional Days until photo expires. Example: 30
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Class photo uploaded and recipients defined.",
     *   "data": {
     *     "id": 2,
     *     "file_path": "/storage/photos/new_photo.jpg"
     *   }
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Validation failed.",
     *   "errors": { "photo": ["The photo field is required."] }
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'photo' => 'required|image|max:5120',
            'child_ids' => 'required|array',
            'child_ids.*' => 'integer',
            'expires_in_days' => 'nullable|integer|min:1'
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            $fileInfo = $request->file('photo');
            $path = $fileInfo->store('child_photos', 'public');
            $storedPath = '/storage/' . ltrim($path, '/');

            $expiresDays = isset($validated['expires_in_days'])
                ? (int) $validated['expires_in_days']
                : null;

            $expiresAt = $expiresDays !== null
                ? \Carbon\Carbon::now()->addDays($expiresDays)->toDateString()
                : null;

            $photoId = \Illuminate\Support\Facades\DB::table('Childphoto')->insertGetId([
                'Filepath' => $storedPath,
                'TeacherID' => $user->PersonID,
                'Expiresat' => $expiresAt
            ]);

            foreach ($validated['child_ids'] as $cId) {
                \Illuminate\Support\Facades\DB::table('Childphotorecipient')->insert([
                    'ChildphotoID' => $photoId,
                    'ChildID' => $cId,
                    'Downloadtime' => null
                ]);
            }

            $targetChildren = \Illuminate\Support\Facades\DB::table('Child')
                ->whereIn('ChildID', $validated['child_ids'])
                ->get(['ChildID', 'Firstname', 'Lastname', 'ParentID']);

            $parentsByCin = [];
            foreach ($targetChildren as $child) {
                if (!$child->ParentID) {
                    continue;
                }

                $parentAccount = \Illuminate\Support\Facades\DB::table('Account')
                    ->where('PersonID', $child->ParentID)
                    ->where('RoleID', 3)
                    ->first(['Cin']);

                if (!$parentAccount || empty($parentAccount->Cin)) {
                    continue;
                }

                $cinKey = (string) $parentAccount->Cin;
                $parentsByCin[$cinKey] ??= [];
                $parentsByCin[$cinKey][] = trim(($child->Firstname ?? '') . ' ' . ($child->Lastname ?? ''));
            }

            foreach ($parentsByCin as $parentCin => $childNames) {
                $childNames = array_values(array_filter(array_unique($childNames)));
                $message = count($childNames) === 1
                    ? 'Une nouvelle photo a ete partagee pour ' . $childNames[0] . '.'
                    : 'De nouvelles photos ont ete partagees pour vos enfants.';

                \Illuminate\Support\Facades\DB::table('Notification')->insert([
                    'Recipientcin' => (int) $parentCin,
                    'Recipientrole' => 'parent',
                    'Type' => 'photo',
                    'Title' => 'Nouvelle photo disponible',
                    'Message' => $message,
                    'Data' => json_encode([
                        'photo_id' => $photoId,
                        'child_ids' => $validated['child_ids'],
                        'child_names' => $childNames,
                        'expires_at' => $expiresAt,
                    ]),
                    'Isread' => 0,
                ]);
            }

            \Illuminate\Support\Facades\DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Class photo uploaded and recipients defined.',
                'data' => [
                    'id' => $photoId,
                    'file_path' => url($storedPath)
                ]
            ], 201);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload photo.'
            ], 500);
        }
    }

    /**
     * Revoke (delete) a shared photo.
     *
     * Permanently removes the photo from storage and deletes all
     * associated Childphotorecipient records.
     *
     * @urlParam id integer required The ChildphotoID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Photo revoked."
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Photo not found."
     * }
     */
    public function destroy(int $id): JsonResponse
    {
        $photo = \Illuminate\Support\Facades\DB::table('Childphoto')->where('ChildphotoID', $id)->first();

        if (!$photo) {
            return response()->json([
                'success' => false,
                'message' => 'Photo not found.'
            ], 404);
        }

        if ($photo->Filepath) {
            $normalizedPaths = $this->normalizeStoredPhotoPath($photo->Filepath);
            if (\Illuminate\Support\Facades\Storage::disk('public')->exists($normalizedPaths['public_disk'])) {
                \Illuminate\Support\Facades\Storage::disk('public')->delete($normalizedPaths['public_disk']);
            }
            if (\Illuminate\Support\Facades\Storage::disk('local')->exists($normalizedPaths['legacy_local'])) {
                \Illuminate\Support\Facades\Storage::disk('local')->delete($normalizedPaths['legacy_local']);
            }
        }

        \Illuminate\Support\Facades\DB::table('Childphotorecipient')->where('ChildphotoID', $id)->delete();
        \Illuminate\Support\Facades\DB::table('Childphoto')->where('ChildphotoID', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Photo revoked.',
            'data' => null
        ]);
    }
}
