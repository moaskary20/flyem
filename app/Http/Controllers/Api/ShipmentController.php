<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Currency;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Request as RequestModel;
use App\Models\Shipment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ShipmentController extends Controller
{
    /**
     * List shipments for search (mobile). Optional filters: from_country_id, to_country_id, etc.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Shipment::query()
            ->with(['user:id,name,profile_photo,rating', 'fromCountry:id,code,name_ar', 'toCountry:id,code,name_ar', 'currency:id,symbol,code']);

        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        } else {
            $query->where('status', 'active');
        }

        if ($request->filled('from_country_id')) {
            $query->where('from_country_id', $request->from_country_id);
        }
        if ($request->filled('to_country_id')) {
            $query->where('to_country_id', $request->to_country_id);
        }
        if ($request->filled('from_city_id')) {
            $query->where('from_city_id', $request->from_city_id);
        }
        if ($request->filled('to_city_id')) {
            $query->where('to_city_id', $request->to_city_id);
        }
        if ($request->filled('deadline_after')) {
            $query->whereDate('deadline_date', '>=', $request->deadline_after);
        }
        if ($request->filled('currency_id')) {
            $query->where('currency_id', $request->currency_id);
        }

        $shipments = $query->orderByDesc('created_at')->paginate($request->input('per_page', 20));

        $data = $shipments->getCollection()->map(function (Shipment $s) {
            $images = $s->images ?? [];
            $firstImage = is_array($images) && count($images) > 0 ? $images[0] : null;
            $imageUrl = null;
            if ($firstImage) {
                if (str_starts_with($firstImage, 'http')) {
                    $imageUrl = $firstImage;
                } elseif (Storage::disk('public')->exists($firstImage)) {
                    $imageUrl = asset('storage/'.$firstImage);
                } else {
                    $imageUrl = asset('images/'.$firstImage);
                }
            }

            return [
                'id' => $s->id,
                'title' => $s->title,
                'from_code' => $s->fromCountry?->code ?? '',
                'from_name' => $s->fromCountry?->name_ar ?? '',
                'to_code' => $s->toCountry?->code ?? '',
                'to_name' => $s->toCountry?->name_ar ?? '',
                'deadline_date' => $s->deadline_date?->format('Y-m-d'),
                'deadline_formatted' => $s->deadline_date ? $s->deadline_date->locale('ar')->translatedFormat('l، d F') : null,
                'user' => [
                    'id' => $s->user?->id,
                    'name' => $s->user?->name ?? '',
                    'initials' => $s->user ? mb_substr($s->user->name, 0, 1).'.' : '?',
                    'profile_photo' => $s->user?->profile_photo ? url('storage/'.$s->user->profile_photo) : null,
                    'rating' => (float) ($s->user?->rating ?? 0),
                ],
                'price_min' => (float) ($s->price_min ?? 0),
                'currency_symbol' => $s->currency?->symbol ?? '$',
                'image_url' => $imageUrl,
            ];
        });

        return response()->json([
            'data' => $data,
            'total' => $shipments->total(),
            'current_page' => $shipments->currentPage(),
            'per_page' => $shipments->perPage(),
        ]);
    }

    /**
     * Single shipment details for trip/shipment details screen.
     * إذا كان الطلب مصحوباً بمصادقة، يُعاد user_has_requested و existing_request_id عند وجود طلب سابق من المستخدم.
     */
    public function show(Request $request, Shipment $shipment): JsonResponse
    {
        $shipment->load(['user:id,name,profile_photo,rating', 'fromCountry:id,code,name_ar', 'fromCity:id,name_ar,name_en', 'toCountry:id,code,name_ar', 'toCity:id,name_ar,name_en', 'currency:id,symbol,code']);

        $images = $shipment->images ?? [];
        $firstImage = is_array($images) && count($images) > 0 ? $images[0] : null;
        $imageUrl = null;
        if ($firstImage) {
            if (str_starts_with($firstImage, 'http')) {
                $imageUrl = $firstImage;
            } elseif (Storage::disk('public')->exists($firstImage)) {
                $imageUrl = asset('storage/'.$firstImage);
            } else {
                $imageUrl = asset('images/'.$firstImage);
            }
        }

        $typeLabels = [
            'documents' => 'مستندات',
            'fragile' => 'قابل للكسر',
            'electronics' => 'إلكترونيات - لابتوب',
            'clothing' => 'ملابس',
            'food' => 'طعام',
            'other' => 'أخرى',
        ];
        $typeEn = [
            'documents' => 'Documents',
            'fragile' => 'Fragile',
            'electronics' => 'Electronics - Laptop',
            'clothing' => 'Clothing',
            'food' => 'Food',
            'other' => 'Other',
        ];

        $payload = [
            'id' => $shipment->id,
            'title' => $shipment->title,
            'description' => $shipment->description,
            'product_link' => $shipment->product_link,
            'quantity' => (int) ($shipment->quantity ?? 1),
            'type' => $shipment->type ?? 'other',
            'type_label' => $typeLabels[$shipment->type ?? 'other'] ?? 'أخرى',
            'type_label_en' => $typeEn[$shipment->type ?? 'other'] ?? 'Other',
            'from_country_id' => $shipment->from_country_id,
            'from_city_id' => $shipment->from_city_id,
            'to_country_id' => $shipment->to_country_id,
            'to_city_id' => $shipment->to_city_id,
            'from_code' => $shipment->fromCountry?->code ?? '',
            'from_name' => $shipment->fromCountry?->name_ar ?? '',
            'from_city' => $shipment->fromCity?->name_ar ?? '',
            'to_code' => $shipment->toCountry?->code ?? '',
            'to_name' => $shipment->toCountry?->name_ar ?? '',
            'to_city' => $shipment->toCity?->name_ar ?? '',
            'deadline_date' => $shipment->deadline_date?->format('Y-m-d'),
            'deadline_formatted' => $shipment->deadline_date ? $shipment->deadline_date->locale('ar')->translatedFormat('l، d F') : null,
            'user' => [
                'id' => $shipment->user?->id,
                'name' => $shipment->user?->name ?? '',
                'profile_photo' => $shipment->user?->profile_photo ? asset('storage/'.$shipment->user->profile_photo) : null,
                'rating' => (float) ($shipment->user?->rating ?? 0),
            ],
            'price_min' => (float) ($shipment->price_min ?? 0),
            'currency_symbol' => $shipment->currency?->symbol ?? '$',
            'image_url' => $imageUrl,
        ];

        $token = $request->bearerToken();
        if ($token) {
            $hashed = hash('sha256', $token);
            $user = User::where('api_token', $hashed)->first();
            if ($user) {
                $existing = RequestModel::where('shipment_id', $shipment->id)->where('requester_id', $user->id)->first();
                $payload['user_has_requested'] = (bool) $existing;
                $payload['existing_request_id'] = $existing?->id;
            }
        }

        return response()->json($payload);
    }

    /**
     * Create a new shipment (my shipments - add).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'from_country_id' => ['required', 'integer', 'exists:countries,id'],
            'from_city_id' => ['required', 'integer', 'exists:cities,id'],
            'to_country_id' => ['required', 'integer', 'exists:countries,id'],
            'to_city_id' => ['required', 'integer', 'exists:cities,id'],
            'deadline_date' => ['nullable', 'date'],
            'quantity' => ['nullable', 'integer', 'min:1'],
            'product_link' => ['nullable', 'string', 'max:500'],
            'type' => ['nullable', Rule::in(['documents', 'fragile', 'electronics', 'clothing', 'food', 'other'])],
            'price_min' => ['nullable', 'numeric', 'min:0'],
        ]);

        $currency = Currency::where('is_default', true)->first() ?? Currency::first();
        $shipment = Shipment::create([
            'user_id' => $validated['user_id'],
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'from_country_id' => $validated['from_country_id'],
            'from_city_id' => $validated['from_city_id'],
            'to_country_id' => $validated['to_country_id'],
            'to_city_id' => $validated['to_city_id'],
            'deadline_date' => $validated['deadline_date'] ?? null,
            'quantity' => $validated['quantity'] ?? 1,
            'product_link' => $validated['product_link'] ?? null,
            'type' => $validated['type'] ?? 'other',
            'price_min' => $validated['price_min'] ?? null,
            'currency_id' => $currency?->id,
            'status' => 'active',
            'images' => ['default_shipment.png'],
        ]);

        return response()->json(['message' => 'created', 'id' => $shipment->id], 201);
    }

    /**
     * Update a shipment (تعديل الشحنة).
     */
    public function update(Request $request, Shipment $shipment): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'from_country_id' => ['required', 'integer', 'exists:countries,id'],
            'from_city_id' => ['required', 'integer', 'exists:cities,id'],
            'to_country_id' => ['required', 'integer', 'exists:countries,id'],
            'to_city_id' => ['required', 'integer', 'exists:cities,id'],
            'deadline_date' => ['nullable', 'date'],
            'quantity' => ['nullable', 'integer', 'min:1'],
            'product_link' => ['nullable', 'string', 'max:500'],
            'type' => ['nullable', Rule::in(['documents', 'fragile', 'electronics', 'clothing', 'food', 'other'])],
            'price_min' => ['nullable', 'numeric', 'min:0'],
        ]);

        $shipment->update([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'from_country_id' => $validated['from_country_id'],
            'from_city_id' => $validated['from_city_id'],
            'to_country_id' => $validated['to_country_id'],
            'to_city_id' => $validated['to_city_id'],
            'deadline_date' => array_key_exists('deadline_date', $validated) ? $validated['deadline_date'] : $shipment->deadline_date,
            'quantity' => $validated['quantity'] ?? $shipment->quantity,
            'product_link' => $validated['product_link'] ?? $shipment->product_link,
            'type' => $validated['type'] ?? $shipment->type,
            'price_min' => $validated['price_min'] ?? $shipment->price_min,
        ]);

        return response()->json(['message' => 'updated', 'id' => $shipment->id]);
    }

    /**
     * Delete a shipment (حذف الشحنة).
     */
    public function destroy(Shipment $shipment): JsonResponse
    {
        $shipment->delete();
        return response()->json(['message' => 'deleted']);
    }

    /**
     * إنشاء طلب على شحنة فقط (بدون دفع). يظهر في تطابقات حتى يقبل صاحب الشحنة.
     */
    public function createRequest(Request $request, Shipment $shipment): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $shipment->user_id === (int) $user->id) {
            return response()->json(['message' => 'لا يمكن إرسال طلب على شحنتك.'], 422);
        }

        if (RequestModel::where('shipment_id', $shipment->id)->where('requester_id', $user->id)->exists()) {
            return response()->json(['message' => 'لقد أرسلت طلباً على هذه الشحنة مسبقاً.'], 422);
        }

        $request->validate([
            'message' => 'nullable|string|max:500',
        ]);

        $amount = (float) ($shipment->price_min ?? 1);
        if ($amount <= 0) {
            $amount = 1;
        }

        $req = RequestModel::create([
            'shipment_id' => $shipment->id,
            'requester_id' => $user->id,
            'price' => $amount,
            'currency_id' => $shipment->currency_id,
            'message' => $request->message,
            'status' => 'pending',
        ]);

        return response()->json([
            'data' => [
                'request_id' => $req->id,
                'message' => 'تم إرسال الطلب. ستظهر في تطابقات حتى يقبل صاحب الشحنة.',
            ],
        ], 201);
    }

    /**
     * إرسال طلب على شحنة + دفع + إنشاء/فتح محادثة مع صاحب الشحنة.
     * يتطلب مصادقة. نفس آلية send-request للرحلات.
     */
    public function sendRequest(Request $request, Shipment $shipment): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $shipment->user_id === (int) $user->id) {
            return response()->json(['message' => 'لا يمكن إرسال طلب على شحنتك.'], 422);
        }

        if (RequestModel::where('shipment_id', $shipment->id)->where('requester_id', $user->id)->exists()) {
            return response()->json(['message' => 'لقد أرسلت طلباً على هذه الشحنة مسبقاً.'], 422);
        }

        $request->validate([
            'payment_method_id' => 'required|exists:payment_methods,id',
            'message' => 'nullable|string|max:500',
        ], [], [
            'payment_method_id' => 'وسيلة الدفع',
        ]);

        $paymentMethod = PaymentMethod::find($request->payment_method_id);
        if (! $paymentMethod || ! $paymentMethod->is_active) {
            return response()->json(['message' => 'وسيلة الدفع غير متاحة.'], 422);
        }

        $amount = (float) ($shipment->price_min ?? 1);
        if ($amount <= 0) {
            $amount = 1;
        }

        $req = RequestModel::create([
            'shipment_id' => $shipment->id,
            'requester_id' => $user->id,
            'price' => $amount,
            'currency_id' => $shipment->currency_id,
            'message' => $request->message,
            'status' => 'pending',
        ]);

        Payment::create([
            'request_id' => $req->id,
            'user_id' => $user->id,
            'amount' => $amount,
            'currency_id' => $shipment->currency_id,
            'payment_method' => $paymentMethod->code,
            'payment_status' => 'paid',
            'transaction_reference' => 'req-' . $req->id . '-' . time(),
        ]);

        $conversation = Conversation::where('shipment_id', $shipment->id)
            ->where(function ($q) use ($user, $shipment) {
                $q->where('sender_id', $user->id)->where('receiver_id', $shipment->user_id)
                    ->orWhere('sender_id', $shipment->user_id)->where('receiver_id', $user->id);
            })
            ->first();

        if (! $conversation) {
            $conversation = Conversation::create([
                'sender_id' => $user->id,
                'receiver_id' => $shipment->user_id,
                'shipment_id' => $shipment->id,
            ]);
        }

        $shipment->load('user:id,name');
        $otherName = $shipment->user?->name ?? '';

        return response()->json([
            'data' => [
                'request_id' => $req->id,
                'conversation_id' => $conversation->id,
                'other_user_name' => $otherName,
                'message' => 'تم إرسال الطلب وفتح المحادثة.',
            ],
        ], 201);
    }
}
