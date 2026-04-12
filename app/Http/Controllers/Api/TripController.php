<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Request as RequestModel;
use App\Models\Setting;
use App\Models\Trip;
use App\Models\User;
use App\Services\PayPalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TripController extends Controller
{
    /**
     * قائمة الرحلات: مع user_id = رحلات المستخدم (شاشة رحلاتي)، بدون user_id = كل الرحلات النشطة (شاشة البحث).
     */
    public function index(Request $request): JsonResponse
    {
        $query = Trip::query()
            ->with([
                'user:id,name',
                'fromCountry:id,code,name_ar',
                'fromCity:id,name_ar',
                'toCountry:id,code,name_ar',
                'toCity:id,name_ar',
                'currency:id,symbol,code',
            ])
            ->orderByDesc('departure_date');

        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        } else {
            $query->where('status', 'active');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
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
        if ($request->filled('departure_after')) {
            $query->whereDate('departure_date', '>=', $request->departure_after);
        }
        if ($request->filled('currency_id')) {
            $query->where('currency_id', $request->currency_id);
        }

        $perPage = (int) $request->input('per_page', 20);
        $trips = $query->paginate($perPage);

        $data = $trips->getCollection()->map(function (Trip $t) {
            return [
                'id' => $t->id,
                'user_id' => $t->user_id,
                'user_name' => $t->user?->name ?? '',
                'travel_method' => $t->travel_method,
                'from_country' => $t->fromCountry?->name_ar ?? '',
                'from_city' => $t->fromCity?->name_ar ?? '',
                'to_country' => $t->toCountry?->name_ar ?? '',
                'to_city' => $t->toCity?->name_ar ?? '',
                'departure_date' => $t->departure_date?->format('Y-m-d H:i'),
                'departure_formatted' => $t->departure_date ? $t->departure_date->locale('ar')->translatedFormat('D, d M g:i A') : null,
                'price_per_kg' => (float) ($t->price_per_kg ?? 0),
                'currency_symbol' => $t->currency?->symbol ?? '$',
                'notes' => $t->notes,
                'can_pickup_in_current_country' => (bool) $t->can_pickup_in_current_country,
                'can_deliver_in_other_country' => (bool) $t->can_deliver_in_other_country,
                'can_return_on_cancel' => (bool) $t->can_return_on_cancel,
                'return_before_days' => $t->return_before_days !== null ? (int) $t->return_before_days : null,
                'status' => $t->status,
                'confirmed_deals' => $t->requests()->where('status', 'accepted')->count(),
            ];
        });

        return response()->json([
            'data' => $data,
            'total' => $trips->total(),
            'current_page' => $trips->currentPage(),
            'per_page' => $trips->perPage(),
        ]);
    }

    /**
     * تفاصيل رحلة واحدة.
     * إذا كان الطلب مصحوباً بمصادقة، يُعاد user_has_requested و existing_request_id عند وجود طلب سابق من المستخدم.
     */
    public function show(Request $request, Trip $trip): JsonResponse
    {
        $trip->load([
            'user:id,name',
            'fromCountry:id,code,name_ar',
            'fromCity:id,name_ar',
            'toCountry:id,code,name_ar',
            'toCity:id,name_ar',
            'currency:id,symbol,code',
        ]);

        $payload = [
            'id' => $trip->id,
            'user_id' => $trip->user_id,
            'user_name' => $trip->user?->name ?? '',
            'travel_method' => $trip->travel_method,
            'from_country_id' => $trip->from_country_id,
            'from_country' => $trip->fromCountry?->name_ar ?? '',
            'from_city_id' => $trip->from_city_id,
            'from_city' => $trip->fromCity?->name_ar ?? '',
            'to_country_id' => $trip->to_country_id,
            'to_country' => $trip->toCountry?->name_ar ?? '',
            'to_city_id' => $trip->to_city_id,
            'to_city' => $trip->toCity?->name_ar ?? '',
            'departure_date' => $trip->departure_date?->format('Y-m-d H:i'),
            'return_date' => $trip->return_date?->format('Y-m-d H:i'),
            'available_weight' => (float) ($trip->available_weight ?? 0),
            'weight_unit' => $trip->weight_unit ?? 'kg',
            'price_per_kg' => (float) ($trip->price_per_kg ?? 0),
            'currency_id' => $trip->currency_id,
            'currency_symbol' => $trip->currency?->symbol ?? '$',
            'notes' => $trip->notes,
            'can_pickup_in_current_country' => (bool) $trip->can_pickup_in_current_country,
            'can_deliver_in_other_country' => (bool) $trip->can_deliver_in_other_country,
            'can_return_on_cancel' => (bool) $trip->can_return_on_cancel,
            'return_before_days' => $trip->return_before_days !== null ? (int) $trip->return_before_days : null,
            'status' => $trip->status,
        ];

        $token = $request->bearerToken();
        if ($token) {
            $hashed = hash('sha256', $token);
            $user = User::where('api_token', $hashed)->first();
            if ($user) {
                $existing = RequestModel::where('trip_id', $trip->id)->where('requester_id', $user->id)->first();
                $ownerId = (int) $trip->user_id;
                $blockedByOtherListing = $existing === null
                    && RequestModel::hasBlockingRequestWithListingOwner((int) $user->id, $ownerId);
                $payload['user_has_requested'] = (bool) $existing || $blockedByOtherListing;
                $payload['existing_request_id'] = $existing?->id;
            }
        }

        return response()->json($payload);
    }

    /**
     * تحديث رحلة (لصاحب الرحلة من تطبيق الموبايل).
     */
    public function update(Request $request, Trip $trip): JsonResponse
    {
        $validated = $request->validate([
            'travel_method' => ['required', 'string', 'in:flight,car,train,bus,ship,other'],
            'from_country_id' => ['required', 'integer', 'exists:countries,id'],
            'from_city_id' => ['required', 'integer', 'exists:cities,id'],
            'to_country_id' => ['required', 'integer', 'exists:countries,id'],
            'to_city_id' => ['required', 'integer', 'exists:cities,id'],
            'departure_date' => ['required', 'date'],
            'return_date' => ['nullable', 'date'],
            'available_weight' => ['nullable', 'numeric', 'min:0'],
            'weight_unit' => ['nullable', 'string', 'in:kg,g,lb'],
            'price_per_kg' => ['nullable', 'numeric', 'min:0'],
            'currency_id' => ['nullable', 'integer', 'exists:currencies,id'],
            'notes' => ['nullable', 'string'],
            'can_pickup_in_current_country' => ['nullable', 'boolean'],
            'can_deliver_in_other_country' => ['nullable', 'boolean'],
            'can_return_on_cancel' => ['nullable', 'boolean'],
            'return_before_days' => ['nullable', 'integer', 'min:1', 'max:30'],
        ]);

        $trip->update([
            'travel_method' => $validated['travel_method'],
            'from_country_id' => $validated['from_country_id'],
            'from_city_id' => $validated['from_city_id'],
            'to_country_id' => $validated['to_country_id'],
            'to_city_id' => $validated['to_city_id'],
            'departure_date' => $validated['departure_date'],
            'return_date' => $validated['return_date'] ?? null,
            'available_weight' => $validated['available_weight'] ?? null,
            'weight_unit' => $validated['weight_unit'] ?? 'kg',
            'price_per_kg' => $validated['price_per_kg'] ?? null,
            'currency_id' => $validated['currency_id'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'can_pickup_in_current_country' => (bool) ($validated['can_pickup_in_current_country'] ?? false),
            'can_deliver_in_other_country' => (bool) ($validated['can_deliver_in_other_country'] ?? false),
            'can_return_on_cancel' => (bool) ($validated['can_return_on_cancel'] ?? false),
            'return_before_days' => isset($validated['return_before_days']) ? (int) $validated['return_before_days'] : null,
        ]);

        return response()->json(['message' => 'updated', 'id' => $trip->id]);
    }

    /**
     * إنشاء رحلة جديدة (من تطبيق الموبايل).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'travel_method' => ['required', 'string', 'in:flight,car,train,bus,ship,other'],
            'from_country_id' => ['required', 'integer', 'exists:countries,id'],
            'from_city_id' => ['required', 'integer', 'exists:cities,id'],
            'to_country_id' => ['required', 'integer', 'exists:countries,id'],
            'to_city_id' => ['required', 'integer', 'exists:cities,id'],
            'departure_date' => ['required', 'date'],
            'return_date' => ['nullable', 'date'],
            'price_per_kg' => ['nullable', 'numeric', 'min:0'],
            'currency_id' => ['nullable', 'integer', 'exists:currencies,id'],
            'notes' => ['nullable', 'string'],
            'can_pickup_in_current_country' => ['nullable', 'boolean'],
            'can_deliver_in_other_country' => ['nullable', 'boolean'],
            'can_return_on_cancel' => ['nullable', 'boolean'],
            'return_before_days' => ['nullable', 'integer', 'min:1', 'max:30'],
        ]);

        $trip = Trip::create([
            'user_id' => $validated['user_id'],
            'travel_method' => $validated['travel_method'],
            'from_country_id' => $validated['from_country_id'],
            'from_city_id' => $validated['from_city_id'],
            'to_country_id' => $validated['to_country_id'],
            'to_city_id' => $validated['to_city_id'],
            'departure_date' => $validated['departure_date'],
            'return_date' => $validated['return_date'] ?? null,
            'price_per_kg' => $validated['price_per_kg'] ?? null,
            'currency_id' => $validated['currency_id'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'can_pickup_in_current_country' => (bool) ($validated['can_pickup_in_current_country'] ?? false),
            'can_deliver_in_other_country' => (bool) ($validated['can_deliver_in_other_country'] ?? false),
            'can_return_on_cancel' => (bool) ($validated['can_return_on_cancel'] ?? false),
            'return_before_days' => isset($validated['return_before_days']) ? (int) $validated['return_before_days'] : null,
            'status' => 'active',
        ]);

        return response()->json(['message' => 'created', 'id' => $trip->id], 201);
    }

    /**
     * حذف رحلة.
     */
    public function destroy(Trip $trip): JsonResponse
    {
        $trip->delete();
        return response()->json(['message' => 'deleted']);
    }

    /**
     * إرسال طلب على رحلة + دفع + إنشاء/فتح محادثة مع صاحب الرحلة.
     * يتطلب مصادقة. بعد نجاح الدفع يُعاد conversation_id لفتح المحادثة في التطبيق.
     */
    public function sendRequest(Request $request, Trip $trip): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $trip->user_id === (int) $user->id) {
            return response()->json(['message' => 'لا يمكن إرسال طلب على رحلتك.'], 422);
        }

        if (RequestModel::where('trip_id', $trip->id)->where('requester_id', $user->id)->exists()) {
            return response()->json(['message' => 'لقد أرسلت طلباً على هذه الرحلة مسبقاً.'], 422);
        }

        if (RequestModel::hasBlockingRequestWithListingOwner((int) $user->id, (int) $trip->user_id)) {
            return response()->json([
                'message' => 'لديك طلب مفتوح مع صاحب هذه الرحلة على إعلان آخر؛ أنهِ الطلب السابق أو انتظر حتى يُرفض قبل إرسال طلب جديد لنفس الشخص.',
            ], 422);
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

        if ($paymentMethod->code === 'paypal' && ! app(PayPalService::class)->isReady()) {
            return response()->json(['message' => 'PayPal غير متاح حالياً.'], 422);
        }

        $minTripPriceSetting = Setting::where('key', 'min_trip_price')->first();
        $minTripPrice = $minTripPriceSetting && filled($minTripPriceSetting->value)
            ? (float) $minTripPriceSetting->value
            : null;

        $amount = (float) ($trip->price_per_kg ?? 0);
        if ($minTripPrice !== null && $minTripPrice > 0) {
            $amount = $amount > 0 ? max($amount, $minTripPrice) : $minTripPrice;
        }
        if ($amount <= 0) {
            $amount = 1;
        }

        $transactionReference = '';
        if ($paymentMethod->code === 'paypal') {
            $request->validate([
                'paypal_order_id' => 'required|string|max:120',
            ], [], [
                'paypal_order_id' => 'رقم طلب PayPal',
            ]);
            $capture = app(PayPalService::class)->captureOrder($request->paypal_order_id);
            if (! ($capture['ok'] ?? false)) {
                return response()->json(['message' => $capture['message'] ?? 'فشل التحقق من دفع PayPal'], 422);
            }
            $transactionReference = $capture['capture_id'] ?? $request->paypal_order_id;
        }

        $req = RequestModel::create([
            'trip_id' => $trip->id,
            'requester_id' => $user->id,
            'price' => $amount,
            'currency_id' => $trip->currency_id,
            'message' => $request->message,
            'status' => 'pending',
        ]);

        if ($paymentMethod->code !== 'paypal') {
            $transactionReference = 'req-'.$req->id.'-'.time();
        }

        Payment::create([
            'request_id' => $req->id,
            'user_id' => $user->id,
            'amount' => $amount,
            'currency_id' => $trip->currency_id,
            'payment_method' => $paymentMethod->code,
            'payment_status' => 'paid',
            'transaction_reference' => $transactionReference,
        ]);

        $conversation = Conversation::where('trip_id', $trip->id)
            ->where(function ($q) use ($user, $trip) {
                $q->where('sender_id', $user->id)->where('receiver_id', $trip->user_id)
                    ->orWhere('sender_id', $trip->user_id)->where('receiver_id', $user->id);
            })
            ->first();

        if (! $conversation) {
            $conversation = Conversation::create([
                'sender_id' => $user->id,
                'receiver_id' => $trip->user_id,
                'trip_id' => $trip->id,
            ]);
        }

        $trip->load('user:id,name');
        $otherName = $trip->user?->name ?? '';

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
