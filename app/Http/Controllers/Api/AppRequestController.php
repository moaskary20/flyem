<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Rating;
use App\Models\Request as RequestModel;
use App\Models\User;
use App\Services\FcmPushService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppRequestController extends Controller
{
    /**
     * قائمة الطلبات: شحنات ورحلات، مرسلة أو واردة على إعلاناتي.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $query = RequestModel::query()
            ->where(function ($q) {
                $q->whereNotNull('shipment_id')->orWhereNotNull('trip_id');
            })
            ->where(function ($q) use ($user) {
                $q->where('requester_id', $user->id)
                    ->orWhereHas('shipment', fn ($s) => $s->where('user_id', $user->id))
                    ->orWhereHas('trip', fn ($t) => $t->where('user_id', $user->id));
            })
            ->with([
                'shipment:id,title,user_id,price_min,currency_id',
                'shipment.user:id,name',
                'shipment.currency:id,symbol',
                'trip:id,user_id,from_city_id,to_city_id,price_per_kg,currency_id',
                'trip.user:id,name',
                'trip.fromCity:id,name_ar',
                'trip.toCity:id,name_ar',
                'trip.currency:id,symbol',
                'requester:id,name',
                'ratings',
                'payment',
            ])
            ->orderByDesc('created_at');

        $perPage = (int) $request->input('per_page', 20);
        $requests = $query->paginate($perPage);

        $data = $requests->getCollection()->map(fn (RequestModel $req) => $this->serializeRequest($req, $user));

        return response()->json([
            'data' => $data,
            'total' => $requests->total(),
            'current_page' => $requests->currentPage(),
            'per_page' => $requests->perPage(),
        ]);
    }

    public function counterparty(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if (! $this->isParty($req, $user)) {
            return response()->json(['message' => 'غير مصرح.'], 403);
        }

        $req->load('payment');
        if (! $req->payment || $req->payment->payment_status !== 'paid') {
            return response()->json(['message' => 'لا يمكن عرض بيانات الطرف قبل إتمام الدفع.'], 422);
        }

        if (! in_array($req->status, ['in_progress', 'delivered'], true)) {
            return response()->json(['message' => 'غير متاح لهذه الحالة.'], 422);
        }

        $otherId = (int) $user->id === (int) $req->requester_id
            ? $this->listingOwnerUserId($req)
            : (int) $req->requester_id;

        if (! $otherId) {
            return response()->json(['message' => 'الطرف الآخر غير معروف.'], 404);
        }

        $other = User::query()->find($otherId);
        if (! $other) {
            return response()->json(['message' => 'المستخدم غير موجود.'], 404);
        }

        $phone = trim((string) ($other->travel_phone ?: $other->phone ?: ''));
        $photoPath = trim((string) ($other->getRawOriginal('profile_photo') ?? $other->profile_photo ?? ''));
        $photoUrl = $photoPath !== '' ? url('storage/'.ltrim($photoPath, '/')) : null;

        return response()->json([
            'data' => [
                'id' => $other->id,
                'name' => $other->name ?? '',
                'phone' => $phone !== '' ? $phone : null,
                'profile_photo_url' => $photoUrl,
            ],
        ]);
    }

    /**
     * قبول طلب (صاحب الإعلان: شحنة أو رحلة).
     */
    public function accept(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $req->load(['shipment', 'trip']);
        if ((int) $this->listingOwnerUserId($req) !== (int) $user->id) {
            return response()->json(['message' => 'غير مصرح بقبول هذا الطلب.'], 403);
        }

        if ($req->status !== 'pending') {
            return response()->json(['message' => 'الطلب غير قيد الانتظار.'], 422);
        }

        $req->update(['status' => 'accepted']);

        app(FcmPushService::class)->sendToUser(
            (int) $req->requester_id,
            'تم قبول طلبك',
            'يمكنك إتمام الدفع من تبويب الطلبات — قيد الدفع.',
            [
                'type' => 'request_accepted',
                'request_id' => (string) $req->id,
                'tab' => 'requests',
            ]
        );

        return response()->json([
            'data' => ['message' => 'تم قبول الطلب.'],
        ]);
    }

    /**
     * رفض طلب (صاحب الإعلان).
     */
    public function reject(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $req->load(['shipment', 'trip']);
        if ((int) $this->listingOwnerUserId($req) !== (int) $user->id) {
            return response()->json(['message' => 'غير مصرح برفض هذا الطلب.'], 403);
        }

        if ($req->status !== 'pending') {
            return response()->json(['message' => 'الطلب غير قيد الانتظار.'], 422);
        }

        $req->update(['status' => 'rejected']);

        app(FcmPushService::class)->sendToUser(
            (int) $req->requester_id,
            'تم رفض الطلب',
            'قام صاحب الإعلان برفض طلبك.',
            [
                'type' => 'request_rejected',
                'request_id' => (string) $req->id,
                'tab' => 'requests',
            ]
        );

        return response()->json([
            'data' => ['message' => 'تم رفض الطلب.'],
        ]);
    }

    /**
     * دفع لطلب مقبول وإنشاء/ربط المحادثة.
     */
    public function payRequest(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $req->requester_id !== (int) $user->id) {
            return response()->json(['message' => 'غير مصرح بالدفع لهذا الطلب.'], 403);
        }

        if ($req->status !== 'accepted') {
            return response()->json(['message' => 'يجب أن يكون الطلب مقبولاً قبل الدفع.'], 422);
        }

        $request->validate([
            'payment_method_id' => 'required|exists:payment_methods,id',
        ], [], [
            'payment_method_id' => 'وسيلة الدفع',
        ]);

        $paymentMethod = PaymentMethod::find($request->payment_method_id);
        if (! $paymentMethod || ! $paymentMethod->is_active) {
            return response()->json(['message' => 'وسيلة الدفع غير متاحة.'], 422);
        }

        $req->load(['shipment.currency', 'trip.currency', 'payment']);
        if ($req->payment && $req->payment->payment_status === 'paid') {
            return response()->json(['message' => 'تم الدفع مسبقاً لهذا الطلب.'], 422);
        }

        $shipment = $req->shipment;
        $trip = $req->trip;

        if ($req->shipment_id && ! $shipment) {
            return response()->json(['message' => 'الشحنة غير موجودة.'], 404);
        }
        if ($req->trip_id && ! $trip) {
            return response()->json(['message' => 'الرحلة غير موجودة.'], 404);
        }

        $currencyId = $shipment?->currency_id ?? $trip?->currency_id ?? $req->currency_id;
        $amount = (float) ($req->price ?? $shipment?->price_min ?? $trip?->price_per_kg ?? 1);
        if ($amount <= 0) {
            $amount = 1;
        }

        Payment::create([
            'request_id' => $req->id,
            'user_id' => $user->id,
            'amount' => $amount,
            'currency_id' => $currencyId,
            'payment_method' => $paymentMethod->code,
            'payment_status' => 'paid',
            'transaction_reference' => 'req-'.$req->id.'-'.time(),
        ]);

        $ownerId = $this->listingOwnerUserId($req);
        $conversation = Conversation::where('request_id', $req->id)->first();

        if (! $conversation) {
            $conversation = Conversation::query()
                ->where('sender_id', $user->id)
                ->where('receiver_id', $ownerId)
                ->when($req->shipment_id, fn ($q) => $q->where('shipment_id', $req->shipment_id))
                ->when($req->trip_id, fn ($q) => $q->where('trip_id', $req->trip_id))
                ->first();

            if (! $conversation) {
                $conversation = Conversation::query()
                    ->where('sender_id', $ownerId)
                    ->where('receiver_id', $user->id)
                    ->when($req->shipment_id, fn ($q) => $q->where('shipment_id', $req->shipment_id))
                    ->when($req->trip_id, fn ($q) => $q->where('trip_id', $req->trip_id))
                    ->first();
            }
        }

        if (! $conversation) {
            $conversation = Conversation::create([
                'sender_id' => $user->id,
                'receiver_id' => $ownerId,
                'shipment_id' => $req->shipment_id,
                'trip_id' => $req->trip_id,
                'request_id' => $req->id,
            ]);
        } else {
            $conversation->forceFill([
                'request_id' => $req->id,
                'shipment_id' => $conversation->shipment_id ?? $req->shipment_id,
                'trip_id' => $conversation->trip_id ?? $req->trip_id,
            ])->save();
        }

        $req->update([
            'status' => 'in_progress',
            'custody_confirmed_at' => null,
            'delivery_confirmed_at' => null,
        ]);

        $req->load(['shipment.user:id,name', 'trip.user:id,name']);
        $otherName = $req->shipment?->user?->name ?? $req->trip?->user?->name ?? '';

        if ($ownerId) {
            app(FcmPushService::class)->sendToUser(
                (int) $ownerId,
                'تم استلام الدفع',
                'أتم مرسل الطلب الدفع لهذا الطلب. يمكنك التواصل من تبويب الطلبات — مدفوع.',
                [
                    'type' => 'request_paid',
                    'request_id' => (string) $req->id,
                    'tab' => 'requests',
                ]
            );
        }

        return response()->json([
            'data' => [
                'request_id' => $req->id,
                'conversation_id' => $conversation->id,
                'other_user_name' => $otherName,
                'message' => 'تم الدفع وفتح المحادثة.',
            ],
        ], 201);
    }

    /**
     * إلغاء الطلب (سحب من المرسل إن كان معلقاً؛ أو إلغاء الاتفاق لأي طرف عند القبول/قيد التنفيذ).
     */
    public function cancel(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $req->load(['shipment', 'trip', 'payment']);
        $ownerId = $this->listingOwnerUserId($req);

        if ($req->status === 'pending') {
            if ((int) $user->id !== (int) $req->requester_id) {
                return response()->json(['message' => 'فقط مرسل الطلب يمكنه الإلغاء في هذه المرحلة.'], 403);
            }
        } elseif (in_array($req->status, ['accepted', 'in_progress'], true)) {
            if (! $this->isParty($req, $user)) {
                return response()->json(['message' => 'غير مصرح.'], 403);
            }
            if ($req->status === 'accepted' && $req->payment && $req->payment->payment_status === 'paid') {
                return response()->json(['message' => 'استخدم خيارات أخرى بعد الدفع.'], 422);
            }
            if ($req->status === 'in_progress' && (! $req->payment || $req->payment->payment_status !== 'paid')) {
                return response()->json(['message' => 'حالة الطلب غير متسقة.'], 422);
            }
        } else {
            return response()->json(['message' => 'لا يمكن إلغاء الطلب في هذه الحالة.'], 422);
        }

        $notifyUserId = $req->status === 'pending'
            ? (int) ($ownerId ?? 0)
            : (((int) $user->id === (int) $req->requester_id) ? (int) ($ownerId ?? 0) : (int) $req->requester_id);

        $req->update(['status' => 'cancelled']);

        if ($notifyUserId > 0 && $notifyUserId !== (int) $user->id) {
            app(FcmPushService::class)->sendToUser(
                $notifyUserId,
                'تم إلغاء الطلب',
                'ألغى الطرف الآخر الطلب.',
                [
                    'type' => 'request_cancelled',
                    'request_id' => (string) $req->id,
                    'tab' => 'requests',
                ]
            );
        }

        return response()->json([
            'data' => ['message' => 'تم إلغاء الطلب.'],
        ]);
    }

    /**
     * حذف الطلب نهائياً (يختفي لدى الطرفين).
     */
    public function destroy(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if (! $this->isParty($req, $user)) {
            return response()->json(['message' => 'غير مصرح.'], 403);
        }

        $req->load('payment');
        if (in_array($req->status, ['in_progress', 'delivered'], true)) {
            return response()->json(['message' => 'لا يمكن حذف طلب قيد التنفيذ أو المكتمل.'], 422);
        }
        if ($req->payment && $req->payment->payment_status === 'paid') {
            return response()->json(['message' => 'لا يمكن حذف طلب تم دفعه.'], 422);
        }

        $req->delete();

        return response()->json([
            'data' => ['message' => 'تم حذف الطلب.'],
        ]);
    }

    /**
     * تأكيد استلام الشحنة في عهدة المسافر.
     */
    public function confirmCustody(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $tid = $this->travelerUserId($req);
        if (! $tid || (int) $tid !== (int) $user->id) {
            return response()->json(['message' => 'فقط المسافر يمكنه تأكيد الاستلام.'], 403);
        }

        if ($req->status !== 'in_progress') {
            return response()->json(['message' => 'الطلب ليس قيد التنفيذ.'], 422);
        }

        $req->load('payment');
        if (! $req->payment || $req->payment->payment_status !== 'paid') {
            return response()->json(['message' => 'يجب إتمام الدفع أولاً.'], 422);
        }

        if ($req->custody_confirmed_at) {
            return response()->json(['message' => 'تم التأكيد مسبقاً.'], 422);
        }

        $req->update(['custody_confirmed_at' => now()]);
        $this->maybeMarkDelivered($req);

        $senderId = $this->senderUserId($req);
        if ($senderId && (int) $senderId !== (int) $user->id) {
            app(FcmPushService::class)->sendToUser(
                (int) $senderId,
                'تأكيد استلام الشحنة',
                'أكد المسافر استلام الشحنة في عهدته.',
                [
                    'type' => 'request_custody_confirmed',
                    'request_id' => (string) $req->id,
                    'tab' => 'requests',
                ]
            );
        }

        return response()->json(['data' => ['message' => 'تم تأكيد الاستلام.']]);
    }

    /**
     * تأكيد تسليم/توصيل الشحنة من الراسل.
     */
    public function confirmDelivery(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $sid = $this->senderUserId($req);
        if (! $sid || (int) $sid !== (int) $user->id) {
            return response()->json(['message' => 'فقط الراسل يمكنه تأكيد التسليم.'], 403);
        }

        if ($req->status !== 'in_progress') {
            return response()->json(['message' => 'الطلب ليس قيد التنفيذ.'], 422);
        }

        $req->load('payment');
        if (! $req->payment || $req->payment->payment_status !== 'paid') {
            return response()->json(['message' => 'يجب إتمام الدفع أولاً.'], 422);
        }

        if ($req->delivery_confirmed_at) {
            return response()->json(['message' => 'تم التأكيد مسبقاً.'], 422);
        }

        $req->update(['delivery_confirmed_at' => now()]);
        $this->maybeMarkDelivered($req);

        $travelerId = $this->travelerUserId($req);
        if ($travelerId && (int) $travelerId !== (int) $user->id) {
            app(FcmPushService::class)->sendToUser(
                (int) $travelerId,
                'تأكيد تسليم الشحنة',
                'أكد الراسل تم التوصيل.',
                [
                    'type' => 'request_delivery_confirmed',
                    'request_id' => (string) $req->id,
                    'tab' => 'requests',
                ]
            );
        }

        return response()->json(['data' => ['message' => 'تم تأكيد التسليم.']]);
    }

    /**
     * تقييم الطرف الآخر بعد إتمام الاتفاق (طلب مقبول أو منفذ).
     */
    public function rate(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $req->load(['shipment', 'trip', 'ratings']);
        $ownerId = $this->listingOwnerUserId($req);
        if (! $ownerId) {
            return response()->json(['message' => 'الطلب غير موجود.'], 404);
        }

        $isRequester = (int) $req->requester_id === (int) $user->id;
        $isOwner = (int) $ownerId === (int) $user->id;
        if (! $isRequester && ! $isOwner) {
            return response()->json(['message' => 'غير مصرح بتقييم هذا الطلب.'], 403);
        }

        if (! in_array($req->status, ['accepted', 'in_progress', 'delivered'], true)) {
            return response()->json(['message' => 'يمكن التقييم فقط بعد قبول الطلب أو إتمامه.'], 422);
        }

        $toUserId = $isRequester ? $ownerId : (int) $req->requester_id;
        if ((int) $toUserId === (int) $user->id) {
            return response()->json(['message' => 'لا يمكن تقييم نفسك.'], 422);
        }

        $alreadyRated = $req->ratings->where('from_user_id', $user->id)->isNotEmpty();
        if ($alreadyRated) {
            return response()->json(['message' => 'تم التقييم مسبقاً لهذا الطلب.'], 422);
        }

        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ], [], [
            'rating' => 'التقييم',
            'comment' => 'التعليق',
        ]);

        Rating::create([
            'from_user_id' => $user->id,
            'to_user_id' => $toUserId,
            'request_id' => $req->id,
            'rating' => (int) $request->rating,
            'comment' => $request->comment,
        ]);

        return response()->json([
            'data' => ['message' => 'تم إرسال التقييم بنجاح.'],
        ], 201);
    }

    private function maybeMarkDelivered(RequestModel $req): void
    {
        $req->refresh();
        if ($req->custody_confirmed_at && $req->delivery_confirmed_at && $req->status === 'in_progress') {
            $req->update(['status' => 'delivered']);
        }
    }

    private function serializeRequest(RequestModel $req, User $user): array
    {
        $shipment = $req->shipment;
        $trip = $req->trip;
        $listingType = $req->shipment_id ? 'shipment' : 'trip';

        $listingTitle = '';
        if ($shipment) {
            $listingTitle = $shipment->title ?? '';
        }
        if ($trip) {
            $from = $trip->fromCity?->name_ar ?? '';
            $to = $trip->toCity?->name_ar ?? '';
            $listingTitle = $from !== '' || $to !== '' ? trim($from.' → '.$to) : 'رحلة #'.$trip->id;
        }

        $isRequester = (int) $req->requester_id === (int) $user->id;
        $ownerUser = $shipment?->user ?? $trip?->user;
        $requesterUser = $req->requester;

        $otherUser = $isRequester ? $ownerUser : $requesterUser;
        $otherUserId = $otherUser?->id;

        $hasPaid = $req->payment && $req->payment->payment_status === 'paid';

        $travelerUserId = $this->travelerUserId($req);
        $senderUserId = $this->senderUserId($req);

        $canRate = in_array($req->status, ['accepted', 'delivered', 'in_progress'], true)
            && $otherUserId
            && (int) $otherUserId !== (int) $user->id;
        $alreadyRated = $canRate && $req->ratings->contains('from_user_id', $user->id);

        $conversation = Conversation::where('request_id', $req->id)->first();

        $viewerIsTraveler = $travelerUserId && (int) $travelerUserId === (int) $user->id;
        $viewerIsSender = $senderUserId && (int) $senderUserId === (int) $user->id;

        return [
            'id' => $req->id,
            'listing_type' => $listingType,
            'shipment_id' => $req->shipment_id,
            'trip_id' => $req->trip_id,
            'listing_title' => $listingTitle,
            'shipment_title' => $shipment?->title ?? $listingTitle,
            'requester' => [
                'id' => $requesterUser?->id,
                'name' => $requesterUser?->name ?? '',
            ],
            'owner' => $ownerUser ? [
                'id' => $ownerUser->id,
                'name' => $ownerUser->name ?? '',
            ] : null,
            'traveler' => $travelerUserId ? [
                'id' => $travelerUserId,
                'name' => $travelerUserId === (int) ($requesterUser?->id ?? 0)
                    ? ($requesterUser?->name ?? '')
                    : ($ownerUser?->name ?? ''),
            ] : null,
            'sender' => $senderUserId ? [
                'id' => $senderUserId,
                'name' => $senderUserId === (int) ($requesterUser?->id ?? 0)
                    ? ($requesterUser?->name ?? '')
                    : ($ownerUser?->name ?? ''),
            ] : null,
            'viewer_is_traveler' => $viewerIsTraveler,
            'viewer_is_sender' => $viewerIsSender,
            'status' => $req->status,
            'price' => (float) ($req->price ?? 0),
            'currency_symbol' => $shipment?->currency?->symbol ?? $trip?->currency?->symbol ?? '$',
            'created_at' => $req->created_at->toIso8601String(),
            'is_requester' => $isRequester,
            'other_user_name' => $otherUser?->name ?? '',
            'other_user_id' => $otherUserId,
            'has_paid' => $hasPaid,
            'conversation_id' => $conversation?->id,
            'custody_confirmed_at' => $req->custody_confirmed_at?->toIso8601String(),
            'delivery_confirmed_at' => $req->delivery_confirmed_at?->toIso8601String(),
            'can_rate' => $canRate,
            'already_rated' => $alreadyRated,
        ];
    }

    private function isParty(RequestModel $req, User $user): bool
    {
        $ownerId = $this->listingOwnerUserId($req);

        return (int) $req->requester_id === (int) $user->id
            || ($ownerId !== null && (int) $ownerId === (int) $user->id);
    }

    private function listingOwnerUserId(RequestModel $req): ?int
    {
        if ($req->shipment_id && $req->relationLoaded('shipment') && $req->shipment) {
            return (int) $req->shipment->user_id;
        }
        if ($req->shipment_id && ! $req->relationLoaded('shipment')) {
            $req->load('shipment:id,user_id');

            return $req->shipment ? (int) $req->shipment->user_id : null;
        }
        if ($req->trip_id && $req->relationLoaded('trip') && $req->trip) {
            return (int) $req->trip->user_id;
        }
        if ($req->trip_id && ! $req->relationLoaded('trip')) {
            $req->load('trip:id,user_id');

            return $req->trip ? (int) $req->trip->user_id : null;
        }

        return null;
    }

    private function travelerUserId(RequestModel $req): ?int
    {
        if ($req->shipment_id) {
            return (int) $req->requester_id;
        }
        if ($req->trip_id) {
            return $this->listingOwnerUserId($req);
        }

        return null;
    }

    private function senderUserId(RequestModel $req): ?int
    {
        if ($req->shipment_id) {
            return $this->listingOwnerUserId($req);
        }
        if ($req->trip_id) {
            return (int) $req->requester_id;
        }

        return null;
    }
}
