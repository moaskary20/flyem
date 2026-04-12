<?php

namespace App\Support;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

trait StoresBase64ImageToPublicDisk
{
    /**
     * يحفظ سلسلة base64 (مع أو بدون بادئة data:image/...) في القرص العام ويعيد المسار النسبي.
     *
     * @throws ValidationException
     */
    protected function storeBase64ImageToPublicDisk(
        ?string $raw,
        string $directory,
        string $errorKey = 'image',
        int $maxBytes = 5_242_880,
    ): ?string {
        if ($raw === null || trim($raw) === '') {
            return null;
        }

        $payload = trim($raw);
        if (str_starts_with($payload, 'data:')) {
            $parts = explode(',', $payload, 2);
            $payload = $parts[1] ?? '';
        }

        $binary = base64_decode($payload, true);
        if ($binary === false) {
            throw ValidationException::withMessages([
                $errorKey => ['صورة غير صالحة.'],
            ]);
        }

        if (strlen($binary) > $maxBytes) {
            throw ValidationException::withMessages([
                $errorKey => ['حجم الصورة يتجاوز الحد المسموح.'],
            ]);
        }

        $directory = trim($directory, '/');
        $path = $directory.'/'.Str::uuid()->toString().'.jpg';
        Storage::disk('public')->put($path, $binary);

        return $path;
    }
}
