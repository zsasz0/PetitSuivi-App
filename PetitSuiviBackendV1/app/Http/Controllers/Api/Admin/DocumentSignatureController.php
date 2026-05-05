<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class DocumentSignatureController extends Controller
{
    private const PARAMETER_NAME = 'document_signature_path';
    private const DEFAULT_SIGNATURE_DISK_PATH = 'signatures/default-signature.png';

    public function show(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Document signature retrieved.',
            'data' => $this->resolveSignatureData(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'signature' => 'required|image|max:5120',
        ]);

        $currentPath = $this->getStoredSignaturePath();
        if ($currentPath && $currentPath !== $this->getDefaultSignaturePath()) {
            $this->deleteStoredFile($currentPath);
        }

        $storedDiskPath = $validated['signature']->store('signatures', 'public');
        $storedPublicPath = '/storage/' . ltrim($storedDiskPath, '/');

        DB::table('Parameter')->updateOrInsert(
            ['Name' => self::PARAMETER_NAME],
            ['Value' => $storedPublicPath]
        );

        return response()->json([
            'success' => true,
            'message' => 'Document signature uploaded successfully.',
            'data' => $this->resolveSignatureData($storedPublicPath),
        ], 201);
    }

    public function destroy(): JsonResponse
    {
        $currentPath = $this->getStoredSignaturePath();
        if ($currentPath && $currentPath !== $this->getDefaultSignaturePath()) {
            $this->deleteStoredFile($currentPath);
        }

        DB::table('Parameter')->updateOrInsert(
            ['Name' => self::PARAMETER_NAME],
            ['Value' => '']
        );

        return response()->json([
            'success' => true,
            'message' => 'Document signature restored to default.',
            'data' => $this->resolveSignatureData(),
        ]);
    }

    private function getStoredSignaturePath(): ?string
    {
        $value = DB::table('Parameter')
            ->where('Name', self::PARAMETER_NAME)
            ->value('Value');

        return is_string($value) && trim($value) !== '' ? $value : null;
    }

    private function resolveSignatureData(?string $path = null): array
    {
        $resolvedPath = $path ?: $this->getStoredSignaturePath();
        $defaultPath = $this->getDefaultSignaturePath();

        if (!$resolvedPath || !$this->storedFileExists($resolvedPath)) {
            $resolvedPath = $defaultPath;
        }

        return [
            'path' => $resolvedPath,
            'url' => url($resolvedPath),
            'is_default' => $resolvedPath === $defaultPath,
        ];
    }

    private function getDefaultSignaturePath(): string
    {
        return '/storage/' . self::DEFAULT_SIGNATURE_DISK_PATH;
    }

    private function storedFileExists(string $publicPath): bool
    {
        $diskPath = ltrim(str_replace('/storage/', '', $publicPath), '/');

        return $diskPath !== '' && Storage::disk('public')->exists($diskPath);
    }

    private function deleteStoredFile(string $publicPath): void
    {
        $diskPath = ltrim(str_replace('/storage/', '', $publicPath), '/');

        if ($diskPath !== '' && Storage::disk('public')->exists($diskPath)) {
            Storage::disk('public')->delete($diskPath);
        }
    }
}
