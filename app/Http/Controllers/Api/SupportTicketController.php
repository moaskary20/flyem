<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SupportTicket;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SupportTicketController extends Controller
{
    /**
     * إنشاء تذكرة دعم فني (تظهر في لوحة التحكم - تذاكر الدعم).
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $request->validate([
            'subject' => 'required|string|max:255',
            'message' => 'required|string|max:5000',
        ], [], [
            'subject' => 'الموضوع',
            'message' => 'الرسالة',
        ]);

        $ticket = SupportTicket::create([
            'user_id' => $user->id,
            'subject' => $request->subject,
            'message' => $request->message,
            'status' => 'open',
        ]);

        return response()->json([
            'data' => [
                'id' => $ticket->id,
                'message' => 'تم إرسال رسالتك للدعم الفني.',
            ],
        ], 201);
    }
}
