<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function afterSave(): void
    {
        $user = $this->getRecord()->fresh();
        if (
            $user
            && ($user->verification_status ?? '') === 'verified'
            && ($user->status ?? '') !== 'banned'
            && ($user->status ?? '') !== 'active'
        ) {
            $user->forceFill(['status' => 'active'])->saveQuietly();
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
