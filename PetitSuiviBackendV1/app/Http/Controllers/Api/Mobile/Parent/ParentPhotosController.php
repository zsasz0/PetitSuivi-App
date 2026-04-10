<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/**
 * @group Mobile - Parent Photos
 *
 * APIs for viewing and downloading photos shared by teachers for a specific child.
 */
class ParentPhotosController extends Controller
{
    private function normalizeStoredPhotoPath(?string $storedPath): array
    {
        $rawPath = trim((string) $storedPath);
        $parsedUrlPath = parse_url($rawPath, PHP_URL_PATH);
        $pathOnly = is_string($parsedUrlPath) && $parsedUrlPath !== '' ? $parsedUrlPath : $rawPath;
        $relativePublicPath = ltrim(preg_replace('#^/?storage/#', '', $pathOnly), '/');
        $legacyLocalPath = 'public/' . $relativePublicPath;
        $publicAbsolutePath = public_path(ltrim($pathOnly, '/'));

        return [
            'public_disk' => $relativePublicPath,
            'legacy_local' => $legacyLocalPath,
            'public_absolute' => $publicAbsolutePath,
        ];
    }

    /**
     * List Child Photos
     *
     * Retrieves all non-expired photos shared for a specific child via the Childphotorecipient pivot.
     *
     * @authenticated
     * @urlParam childId int required The ID of the child (ChildID). Example: 45
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "file_path": "/storage/photos/class_abc.jpg",
     *       "expires_at": "2026-05-01",
     *       "downloaded": false,
     *       "created_at": null
     *     }
     *   ]
     * }
     */
    public function index($childId): JsonResponse
    {
        $photos = DB::table('Childphotorecipient')
            ->join('Childphoto', 'Childphotorecipient.ChildphotoID', '=', 'Childphoto.ChildphotoID')
            ->where('Childphotorecipient.ChildID', $childId)
            ->where(function ($query) {
                $query->whereNull('Childphoto.Expiresat')
                      ->orWhere('Childphoto.Expiresat', '>=', now()->toDateString());
            })
            ->select(
                'Childphoto.ChildphotoID as id',
                'Childphoto.Filepath as file_path',
                'Childphoto.Expiresat as expires_at',
                'Childphoto.TeacherID as teacher_id',
                'Childphotorecipient.Downloadtime as download_time'
            )
            ->orderByDesc('Childphoto.ChildphotoID')
            ->get();

        $data = $photos->map(function($photo) {
            $daysRemaining = 0;
            if ($photo->expires_at) {
                // Carbon parse to get days difference
                $daysRemaining = \Carbon\Carbon::now()->startOfDay()->diffInDays(\Carbon\Carbon::parse($photo->expires_at)->startOfDay(), false);
            }

            $teacher = DB::table('Account')
                ->where('PersonID', $photo->teacher_id)
                ->where('RoleID', 1)
                ->first();
            
            return [
                'id'             => $photo->id,
                'file_path'      => $photo->file_path,
                'expires_at'     => $photo->expires_at,
                'days_remaining' => (int) $daysRemaining,
                'downloaded'     => !empty($photo->download_time),
                'teacher'        => $teacher ? [
                    'firstName' => $teacher->Firstname,
                    'lastName'  => $teacher->Lastname,
                ] : null,
                'created_at'     => null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Download Photo
     *
     * Streams a photo file to the parent and records the download timestamp.
     *
     * @authenticated
     * @urlParam photoId int required The ID of the photo (ChildphotoID). Example: 1
     *
     * @response 200 (binary file stream)
     */
    public function download(Request $request, $photoId)
    {
        $photo = DB::table('Childphoto')
            ->where('ChildphotoID', $photoId)
            ->first();

        if (!$photo) {
            return response()->json([
                'success' => false,
                'message' => 'Photo not found.',
            ], 404);
        }

        // Record download timestamp for the recipient
        $user = $request->user();
        if ($user) {
            DB::table('Childphotorecipient')
                ->where('ChildphotoID', $photoId)
                ->whereNull('Downloadtime')
                ->update(['Downloadtime' => now()]);
        }

        $normalizedPaths = $this->normalizeStoredPhotoPath($photo->Filepath);

        // New correct location on the public disk.
        if (Storage::disk('public')->exists($normalizedPaths['public_disk'])) {
            return Storage::disk('public')->download($normalizedPaths['public_disk']);
        }

        // Legacy location created when uploads used the default local disk.
        if (Storage::disk('local')->exists($normalizedPaths['legacy_local'])) {
            return response()->download(Storage::disk('local')->path($normalizedPaths['legacy_local']));
        }

        if (file_exists($normalizedPaths['public_absolute'])) {
            return response()->download($normalizedPaths['public_absolute']);
        }

        return response()->json([
            'success' => false,
            'message' => 'File not found on server.',
        ], 404);
    }
}
