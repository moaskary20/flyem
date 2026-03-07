<?php

namespace Database\Seeders;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Database\Seeder;

class ConversationSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'user')->limit(4)->get();
        if ($users->count() < 2) {
            return;
        }

        $c1 = Conversation::firstOrCreate(
            [
                'sender_id' => $users[0]->id,
                'receiver_id' => $users[1]->id,
            ],
            ['last_message_at' => now()]
        );

        Message::firstOrCreate(
            [
                'conversation_id' => $c1->id,
                'sender_id' => $users[0]->id,
                'message' => 'مرحباً، هل يمكنك نقل شحنة من القاهرة إلى نيويورك؟',
                'created_at' => now()->subMinutes(30),
            ],
            ['type' => 'text', 'is_read' => false]
        );
        Message::firstOrCreate(
            [
                'conversation_id' => $c1->id,
                'sender_id' => $users[1]->id,
                'message' => 'نعم، لدي رحلة الأسبوع القادم. ما الوزن التقريبي؟',
                'created_at' => now()->subMinutes(25),
            ],
            ['type' => 'text', 'is_read' => true]
        );
        Message::firstOrCreate(
            [
                'conversation_id' => $c1->id,
                'sender_id' => $users[0]->id,
                'message' => 'حوالي 2 كيلو. جهاز لابتوب.',
                'created_at' => now()->subMinutes(20),
            ],
            ['type' => 'text', 'is_read' => false]
        );

        $c2 = Conversation::firstOrCreate(
            [
                'sender_id' => $users[1]->id,
                'receiver_id' => $users[2]->id,
            ],
            ['last_message_at' => now()->subHours(2)]
        );

        Message::firstOrCreate(
            [
                'conversation_id' => $c2->id,
                'sender_id' => $users[1]->id,
                'message' => 'هل رحلتك إلى إسطنبول ما زالت متاحة؟',
                'created_at' => now()->subHours(2),
            ],
            ['type' => 'text', 'is_read' => true]
        );
        Message::firstOrCreate(
            [
                'conversation_id' => $c2->id,
                'sender_id' => $users[2]->id,
                'message' => 'نعم، الخميس القادم. كم الوزن المطلوب؟',
                'created_at' => now()->subHours(1)->subMinutes(55),
            ],
            ['type' => 'text', 'is_read' => false]
        );
    }
}
