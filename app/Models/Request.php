<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Request extends Model
{
    /**
     * حالات تمنع إرسال طلب جديد لنفس صاحب الإعلان (شحنة أو رحلة) حتى يُغلق الطلب السابق.
     */
    public const BLOCKING_COUNTERPARTY_STATUSES = ['pending', 'accepted', 'in_progress', 'disputed'];

    protected $fillable = [
        'shipment_id',
        'trip_id',
        'requester_id',
        'price',
        'currency_id',
        'message',
        'status',
    ];

    protected $casts = [
        'price' => 'decimal:2',
    ];

    public function requester(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requester_id');
    }

    public function shipment(): BelongsTo
    {
        return $this->belongsTo(Shipment::class);
    }

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }

    public function currency(): BelongsTo
    {
        return $this->belongsTo(Currency::class);
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    public function dispute(): HasOne
    {
        return $this->hasOne(Dispute::class);
    }

    public function ratings(): HasMany
    {
        return $this->hasMany(Rating::class);
    }

    public function commission(): HasOne
    {
        return $this->hasOne(Commission::class);
    }

    /**
     * هل يوجد طلب نشط من المستخدم كمُرسِل تجاه أي إعلان (شحنة أو رحلة) لصاحب الحساب المحدد؟
     */
    public static function hasBlockingRequestWithListingOwner(int $requesterUserId, int $listingOwnerUserId): bool
    {
        return static::query()
            ->where('requester_id', $requesterUserId)
            ->whereIn('status', self::BLOCKING_COUNTERPARTY_STATUSES)
            ->where(function ($q) use ($listingOwnerUserId) {
                $q->whereHas('shipment', fn ($s) => $s->where('user_id', $listingOwnerUserId))
                    ->orWhereHas('trip', fn ($t) => $t->where('user_id', $listingOwnerUserId));
            })
            ->exists();
    }
}
