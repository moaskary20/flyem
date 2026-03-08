<?php

namespace App\Observers;

use App\Models\Rating;
use App\Models\User;

class RatingObserver
{
    public static function updateUserRating(User $user): void
    {
        $avg = $user->ratingsReceived()->avg('rating');
        $user->update([
            'rating' => $avg ? round((float) $avg, 2) : 0,
        ]);
    }

    public function created(Rating $rating): void
    {
        $rating->load('toUser');
        if ($rating->toUser) {
            self::updateUserRating($rating->toUser);
        }
    }

    public function updated(Rating $rating): void
    {
        $rating->load('toUser');
        if ($rating->toUser) {
            self::updateUserRating($rating->toUser);
        }
    }

    public function deleted(Rating $rating): void
    {
        $toUserId = $rating->to_user_id;
        $user = User::find($toUserId);
        if ($user) {
            self::updateUserRating($user);
        }
    }
}
