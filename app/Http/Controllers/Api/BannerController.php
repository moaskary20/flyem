<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class BannerController extends Controller
{
    /**
     * قائمة البنرات الإعلانية النشطة (للسلايدر في شاشة البحث).
     * رابط الصورة يشير إلى مسار API يخدم الملف من التخزين (عام أو خاص).
     */
    public function index(Request $request): JsonResponse
    {
        $banners = Banner::where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['id', 'title', 'image', 'video', 'link', 'sort_order']);

        $baseUrl = $request->getSchemeAndHttpHost();

        $data = $banners->map(function (Banner $b) use ($baseUrl) {
            $imageUrl = $this->resolveMediaUrl($b->image, $baseUrl, $b->id, 'image');
            $videoUrl = $this->resolveMediaUrl($b->video, $baseUrl, $b->id, 'video');

            return [
                'id' => $b->id,
                'title' => $b->title,
                'image_url' => $imageUrl,
                'video_url' => $videoUrl,
                'link' => $b->link,
                'sort_order' => (int) $b->sort_order,
            ];
        });

        return response()->json(['data' => $data]);
    }

    private function resolveMediaUrl(mixed $raw, string $baseUrl, int $bannerId, string $type): ?string
    {
        if (! $raw) {
            return null;
        }
        $path = $raw;
        if (is_string($raw) && str_starts_with(trim($raw), '[')) {
            $decoded = json_decode($raw, true);
            $path = is_array($decoded) && isset($decoded[0]) ? $decoded[0] : $raw;
        }
        $path = ltrim(preg_replace('#^public/#', '', (string) $path), '/');
        if (str_starts_with($path, 'http')) {
            return $path;
        }

        return rtrim($baseUrl, '/').'/api/banners/'.$bannerId.'/'.$type;
    }

    /**
     * خدمة صورة البانر من التخزين.
     */
    public function image(Request $request, Banner $banner): StreamedResponse|\Illuminate\Http\Response
    {
        return $this->serveBannerFile($banner, $banner->image);
    }

    /**
     * خدمة فيديو البانر من التخزين.
     */
    public function video(Request $request, Banner $banner): StreamedResponse|\Illuminate\Http\Response
    {
        return $this->serveBannerFile($banner, $banner->video);
    }

    private function serveBannerFile(Banner $banner, mixed $raw): StreamedResponse|\Illuminate\Http\Response
    {
        if (! $raw) {
            abort(404);
        }
        $path = $raw;
        if (is_string($raw) && str_starts_with(trim($raw), '[')) {
            $decoded = json_decode($raw, true);
            $path = is_array($decoded) && isset($decoded[0]) ? $decoded[0] : $raw;
        }
        $path = ltrim(preg_replace('#^public/#', '', (string) $path), '/');

        foreach (['local', 'public'] as $disk) {
            if (Storage::disk($disk)->exists($path)) {
                $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
                $mime = match ($ext) {
                    'png' => 'image/png',
                    'jpg', 'jpeg' => 'image/jpeg',
                    'gif' => 'image/gif',
                    'webp' => 'image/webp',
                    'mp4' => 'video/mp4',
                    'webm' => 'video/webm',
                    'mov' => 'video/quicktime',
                    default => 'application/octet-stream',
                };

                return response()->stream(function () use ($disk, $path) {
                    $stream = Storage::disk($disk)->readStream($path);
                    fpassthru($stream);
                    fclose($stream);
                }, 200, [
                    'Content-Type' => $mime,
                    'Cache-Control' => 'public, max-age=3600',
                ]);
            }
        }

        abort(404);
    }
}
