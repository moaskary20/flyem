<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Shipment extends Model
{
    protected $fillable = [
        'user_id',
        'title',
        'description',
        'product_link',
        'quantity',
        'price_min',
        'currency_id',
        'from_country_id',
        'from_city_id',
        'to_country_id',
        'to_city_id',
        'weight',
        'weight_unit',
        'type',
        'deadline_date',
        'status',
        'images',
    ];

    protected $casts = [
        'images' => 'array',
        'price_min' => 'decimal:2',
        'weight' => 'decimal:2',
        'quantity' => 'integer',
        'deadline_date' => 'date',
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
