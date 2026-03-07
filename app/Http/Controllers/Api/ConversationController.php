<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    /**
     * قائمة محادثات المستخدم الحالي (مرسل أو مستقبل).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $query = Conversation::query()
            ->where(function ($q) use ($user) {
                $q->where('sender_id', $user->id)->orWhere('receiver_id', $user->id);
            })
            ->with(['sender:id,name', 'receiver:id,name'])
            ->withCount('messages')
            ->with(['messages' => fn ($q) => $q->latest()->limit(1)])
            ->orderByDesc('last_message_at');

        $perPage = (int) $request->input('per_page', 20);
        $conversations = $query->paginate($perPage);

        $conversationIds = $conversations->pluck('id')->toArray();
        // رسائل لم يرسلها المستخدم الحالي = وردت عليه؛ نعدّ غير المقروءة منها
        $unreadCounts = Message::query()
            ->whereIn('conversation_id', $conversationIds)
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->selectRaw('conversation_id, count(*) as c')
            ->groupBy('conversation_id')
            ->pluck('c', 'conversation_id');

        $data = $conversations->getCollection()->map(function (Conversation $c) use ($user, $unreadCounts) {
            $other = $c->sender_id === $user->id ? $c->receiver : $c->sender;
            $lastMessage = $c->relationLoaded('messages') && $c->messages->isNotEmpty()
                ? $c->messages->first()
                : null;

            return [
                'id' => $c->id,
                'other_user' => [
                    'id' => $other?->id,
                    'name' => $other?->name ?? '',
                ],
                'last_message' => $lastMessage ? [
                    'message' => $lastMessage->message,
                    'type' => $lastMessage->type ?? 'text',
                    'created_at' => $lastMessage->created_at->toIso8601String(),
                    'is_mine' => (int) $lastMessage->sender_id === (int) $user->id,
                ] : null,
                'last_message_at' => $c->last_message_at?->toIso8601String(),
                'messages_count' => $c->messages_count ?? 0,
                'unread_count' => $unreadCounts->get($c->id, 0),
            ];
        });

        return response()->json([
            'data' => $data,
            'total' => $conversations->total(),
            'current_page' => $conversations->currentPage(),
            'per_page' => $conversations->perPage(),
        ]);
    }

    /**
     * عرض محادثة واحدة مع رسائلها (صفحة).
     */
    public function show(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $conversation->sender_id !== (int) $user->id && (int) $conversation->receiver_id !== (int) $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $conversation->load(['sender:id,name', 'receiver:id,name']);
        $other = $conversation->sender_id === $user->id ? $conversation->receiver : $conversation->sender;

        $perPage = (int) $request->input('per_page', 50);
        $messages = $conversation->messages()
            ->with('sender:id,name')
            ->orderByDesc('created_at')
            ->paginate($perPage);

        $messagesList = $messages->getCollection()->map(fn (Message $m) => [
            'id' => $m->id,
            'message' => $m->message,
            'type' => $m->type ?? 'text',
            'sender_id' => $m->sender_id,
            'sender_name' => $m->sender?->name ?? '',
            'is_mine' => (int) $m->sender_id === (int) $user->id,
            'is_read' => $m->is_read,
            'created_at' => $m->created_at->toIso8601String(),
        ])->values();

        return response()->json([
            'data' => [
                'id' => $conversation->id,
                'other_user' => [
                    'id' => $other?->id,
                    'name' => $other?->name ?? '',
                ],
                'messages' => $messagesList,
                'messages_total' => $messages->total(),
                'current_page' => $messages->currentPage(),
                'per_page' => $messages->perPage(),
            ],
        ]);
    }

    /**
     * إرسال رسالة في محادثة.
     */
    public function sendMessage(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ((int) $conversation->sender_id !== (int) $user->id && (int) $conversation->receiver_id !== (int) $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $request->validate([
            'message' => 'required|string|max:5000',
            'type' => 'nullable|in:text,image,file',
        ], [], ['message' => 'الرسالة']);

        $message = $conversation->messages()->create([
            'sender_id' => $user->id,
            'message' => $request->message,
            'type' => $request->input('type', 'text'),
            'is_read' => false,
        ]);

        $conversation->update(['last_message_at' => $message->created_at]);

        $message->load('sender:id,name');

        return response()->json([
            'data' => [
                'id' => $message->id,
                'message' => $message->message,
                'type' => $message->type,
                'sender_id' => $message->sender_id,
                'sender_name' => $message->sender?->name ?? '',
                'is_mine' => true,
                'is_read' => $message->is_read,
                'created_at' => $message->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * إنشاء محادثة جديدة (مع المستلم فقط؛ يمكن لاحقاً ربطها بشحنة/رحلة).
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $request->validate([
            'receiver_id' => 'required|exists:users,id',
            'shipment_id' => 'nullable|exists:shipments,id',
            'trip_id' => 'nullable|exists:trips,id',
        ], [], [
            'receiver_id' => 'المستلم',
        ]);

        $receiverId = (int) $request->receiver_id;
        if ($receiverId === $user->id) {
            return response()->json(['message' => 'Cannot start conversation with yourself.'], 422);
        }

        $existing = Conversation::where('sender_id', $user->id)
            ->where('receiver_id', $receiverId)
            ->when($request->filled('shipment_id'), fn ($q) => $q->where('shipment_id', $request->shipment_id))
            ->when($request->filled('trip_id'), fn ($q) => $q->where('trip_id', $request->trip_id))
            ->when(! $request->filled('shipment_id') && ! $request->filled('trip_id'), function ($q) use ($receiverId) {
                $q->whereNull('shipment_id')->whereNull('trip_id');
            })
            ->first();

        if ($existing) {
            $existing->load(['sender:id,name', 'receiver:id,name']);
            $other = $existing->receiver;
            return response()->json([
                'data' => [
                    'id' => $existing->id,
                    'other_user' => ['id' => $other->id, 'name' => $other->name],
                    'last_message_at' => $existing->last_message_at?->toIso8601String(),
                    'messages_count' => 0,
                ],
            ]);
        }

        $conversation = Conversation::create([
            'sender_id' => $user->id,
            'receiver_id' => $receiverId,
            'shipment_id' => $request->shipment_id,
            'trip_id' => $request->trip_id,
        ]);

        $conversation->load('receiver:id,name');
        $other = $conversation->receiver;

        return response()->json([
            'data' => [
                'id' => $conversation->id,
                'other_user' => ['id' => $other->id, 'name' => $other->name],
                'last_message_at' => null,
                'messages_count' => 0,
            ],
        ], 201);
    }
}
