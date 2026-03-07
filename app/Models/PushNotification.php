<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PushNotification extends Model
{
    protected $table = 'push_notifications';

    protected $fillable = [
        'title',
        'body',
        'type',
        'target',
        'target_ids',
        'is_sent',
        'sent_at',
    ];

    protected $casts = [
        'target_ids' => 'array',
        'is_sent' => 'boolean',
        'sent_at' => 'datetime',
    ];
}
