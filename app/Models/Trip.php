<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Trip extends Model
{
    protected $fillable = [
        'user_id',
        'travel_method',
        'from_country_id',
        'from_city_id',
        'to_country_id',
        'to_city_id',
        'departure_date',
        'return_date',
        'available_weight',
        'weight_unit',
        'price_per_kg',
        'currency_id',
        'notes',
        'can_pickup_in_current_country',
        'can_deliver_in_other_country',
        'can_return_on_cancel',
        'return_before_days',
        'status',
    ];

    protected $casts = [
        'departure_date' => 'datetime',
        'return_date' => 'datetime',
        'available_weight' => 'decimal:2',
        'price_per_kg' => 'decimal:2',
        'can_pickup_in_current_country' => 'boolean',
        'can_deliver_in_other_country' => 'boolean',
        'can_return_on_cancel' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function fromCountry(): BelongsTo
    {
        return $this->belongsTo(Country::class, 'from_country_id');
    }

    public function fromCity(): BelongsTo
    {
        return $this->belongsTo(City::class, 'from_city_id');
    }

    public function toCountry(): BelongsTo
    {
        return $this->belongsTo(Country::class, 'to_country_id');
    }

    public function toCity(): BelongsTo
    {
        return $this->belongsTo(City::class, 'to_city_id');
    }

    public function currency(): BelongsTo
    {
        return $this->belongsTo(Currency::class);
    }

    public function requests(): HasMany
    {
        return $this->hasMany(Request::class);
    }

    public function nominations(): HasMany
    {
        return $this->hasMany(Nomination::class);
    }

    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class);
    }
}
