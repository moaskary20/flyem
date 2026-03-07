<?php

namespace App\Filament\Resources\UserVerifications\Pages;

use App\Filament\Resources\UserVerifications\UserVerificationResource;
use Filament\Resources\Pages\CreateRecord;

class CreateUserVerification extends CreateRecord
{
    protected static string $resource = UserVerificationResource::class;
}
