<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Rating;
use App\Models\Request as RequestModel;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppRequestController extends Controller
{
    /**
     * قائمة الطلبات (تطابقات): طلباتي المرسلة + الطلبات الواردة على شحناتي.
     * للشحنات فقط.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $query = RequestModel::query()
            ->whereNotNull('shipment_id')
            ->where(function ($q) use ($user) {
                $q->where('requester_id', $user->id)
                    ->orWhereHas('shipment', fn ($s) => $s->where('user_id', $user->id));
            })
            ->with([
                'shipment:id,title,user_id,price_min,currency_id',
                'shipment.user:id,name',
                'shipment.currency:id,symbol',
                'requester:id,name',
                'ratings',
            ])
            ->orderByDesc('created_at');

        $perPage = (int) $request->input('per_page', 20);
        $requests = $query->paginate($perPage);

        $data = $requests->getCollection()->map(function (RequestModel $req) use ($user) {
            $shipment = $req->shipment;
            $isRequester = (int) $req->requester_id === (int) $user->id;
            $otherUser = $isRequester
                ? $shipment?->user
                : $req->requester;
            $otherUserId = $otherUser?->id;
            $canRate = in_array($req->status, ['accepted', 'delivered', 'in_progress'], true) && $otherUserId && (int) $otherUserId !== (int) $user->id;
            $alreadyRated = $canRate && $req->ratings->contains('from_user_id', $user->id);

            return [
                'id' => $req->id,
                'shipment_id' => $req->shipment_id,
                'shipment_title' => $shipment?->title ?? '',
                'requester' => [
                    'id' => $req->requester?->id,
                    'name' => $req->requester?->name ?? '',
                ],
                'owner' => $shipment?->user ? [
                    'id' => $shipment->user->id,
                    'name' => $shipment->user->name ?? '',
                ] : null,
                'status' => $req->status,
                'price' => (float) ($req->price ?? 0),
                'currency_symbol' => $shipment?->currency?->symbol ?? '$',
                'created_at' => $req->created_at->toIso8601String(),
                'is_requester' => $isRequester,
                'other_user_name' => $otherUser?->name ?? '',
                'other_user_id' => $otherUserId,
                'can_rate' => $canRate,
                'already_rated' => $alreadyRated,
            ];
        });

        return response()->json([
            'data' => $data,
            'total' => $requests->total(),
            'current_page' => $requests->currentPage(),
            'per_page' => $requests->perPage(),
        ]);
    }

    /**
     * قبول طلب (صاحب الشحنة فقط).
     */
    public function accept(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $req->load('shipment');
        if (! $req->shipment || (int) $req->shipment->user_id !== (int) $user->id) {
            return response()->json(['message' => 'غير مصرح بقبول هذا الطلب.'], 403);
        }

        if ($req->status !== 'pending') {
            return response()->json(['message' => 'الطلب غير قيد الانتظار.'], 422);
        }

        $req->update(['status' => 'accepted']);

        return response()->json([
            'data' => ['message' => 'تم قبول الطلب.'],
        ]);
    }

    /**
     * رفض طلب (صاحب الشحنة فقط).
     */
    public function reject(Request $request, RequestModel $req): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $req->load('shipment');
        if (! $req->shipment || (int) $req->shipment->user_id !== (int) $user->id) {
            return response()->json(['message' => 'غير مصرح برفض هذا الطلب.'], 403);
        }

        if ($req->status !== 'pending') {
            return response()->json(['message' => 'الطلب غير قيد الانتظار.'], 422);
        }

        $req->update(['status' => 'rejected']);

        return response()->json([
            'data' => ['message' => 'تم رفض الطلب.'],
        ]);
    }

    /**
     * دفع لطلب مقبول وإنشاء المحادثة.
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

        $req->load('shipment');
        $shipment = $req->shipment;
        if (! $shipment) {
            return response()->json(['message' => 'الشحنة غير موجودة.'], 404);
        }

        $amount = (float) ($req->price ?? $shipment->price_min ?? 1);
        if ($amount <= 0) {
            $amount = 1;
        }

        Payment::create([
            'request_id' => $req->id,
            'user_id' => $user->id,
            'amount' => $amount,
            'currency_id' => $shipment->currency_id ?? $req->currency_id,
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
                'message' => 'تم الدفع وفتح المحادثة.',
            ],
        ], 201);
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

        $req->load(['shipment', 'ratings']);
        $shipment = $req->shipment;
        if (! $shipment) {
            return response()->json(['message' => 'الطلب غير موجود.'], 404);
        }

        $isRequester = (int) $req->requester_id === (int) $user->id;
        $isOwner = (int) $shipment->user_id === (int) $user->id;
        if (! $isRequester && ! $isOwner) {
            return response()->json(['message' => 'غير مصرح بتقييم هذا الطلب.'], 403);
        }

        if (! in_array($req->status, ['accepted', 'in_progress', 'delivered'], true)) {
            return response()->json(['message' => 'يمكن التقييم فقط بعد قبول الطلب أو إتمامه.'], 422);
        }

        $toUserId = $isRequester ? $shipment->user_id : $req->requester_id;
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
}
