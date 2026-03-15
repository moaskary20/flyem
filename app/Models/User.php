<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable implements FilamentUser
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'home_phone',
        'travel_phone',
        'api_token',
        'profile_photo',
        'country_id',
        'city_id',
        'home_country_id',
        'home_city_id',
        'travel_country_id',
        'travel_city_id',
        'bank_iban',
        'bank_name',
        'bank_account_holder',
        'role',
        'status',
        'verification_status',
        'phone_verified',
        'rating',
        'wallet_balance',
        'last_seen_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'api_token',
    ];

    /**
     * عند القراءة: إزالة المسافات والأسطر من مسار الصورة لتفادي روابط مقطوعة.
     */
    protected function profilePhoto(): \Illuminate\Database\Eloquent\Casts\Attribute
    {
        return \Illuminate\Database\Eloquent\Casts\Attribute::make(
            get: function (?string $value) {
                if ($value === null || $value === '') {
                    return $value;
                }
                $cleaned = trim(preg_replace('/\s+/', '', $value));
                return $cleaned !== '' ? $cleaned : null;
            },
        );
    }

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified' => 'boolean',
            'password' => 'hashed',
            'last_seen_at' => 'datetime',
            'rating' => 'decimal:2',
            'wallet_balance' => 'decimal:2',
        ];
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->role === 'admin';
    }

    public function country(): BelongsTo
    {
        return $this->belongsTo(Country::class);
    }

    public function city(): BelongsTo
    {
        return $this->belongsTo(City::class);
    }

    public function homeCountry(): BelongsTo
    {
        return $this->belongsTo(Country::class, 'home_country_id');
    }

    public function homeCity(): BelongsTo
    {
        return $this->belongsTo(City::class, 'home_city_id');
    }

    public function travelCountry(): BelongsTo
    {
        return $this->belongsTo(Country::class, 'travel_country_id');
    }

    public function travelCity(): BelongsTo
    {
        return $this->belongsTo(City::class, 'travel_city_id');
    }

    public function shipments(): HasMany
    {
        return $this->hasMany(Shipment::class);
    }

    public function trips(): HasMany
    {
        return $this->hasMany(Trip::class);
    }

    public function requests(): HasMany
    {
        return $this->hasMany(Request::class, 'requester_id');
    }

    public function sentConversations(): HasMany
    {
        return $this->hasMany(Conversation::class, 'sender_id');
    }

    public function receivedConversations(): HasMany
    {
        return $this->hasMany(Conversation::class, 'receiver_id');
    }

    public function supportTickets(): HasMany
    {
        return $this->hasMany(SupportTicket::class);
    }

    public function verification(): HasOne
    {
        return $this->hasOne(UserVerification::class);
    }

    public function ratingsReceived(): HasMany
    {
        return $this->hasMany(Rating::class, 'to_user_id');
    }

    public function ratingsGiven(): HasMany
    {
        return $this->hasMany(Rating::class, 'from_user_id');
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }
}
