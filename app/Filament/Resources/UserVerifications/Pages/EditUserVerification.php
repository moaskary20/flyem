<?php

namespace App\Filament\Resources\UserVerifications\Pages;

use App\Filament\Resources\UserVerifications\UserVerificationResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditUserVerification extends EditRecord
{
    protected static string $resource = UserVerificationResource::class;

    protected function mutateFormDataBeforeFill(array $data): array
    {
        $record = $this->getRecord();
        $record->loadMissing('user');
        $data['phone_verified'] = $record->user?->phone_verified ?? false;

        return $data;
    }

    protected function afterSave(): void
    {
        $record = $this->getRecord();
        $user = $record->user;
        if ($user) {
            $user->verification_status = match ($record->status) {
                'approved' => 'verified',
                'rejected' => 'rejected',
                default => 'pending',
            };
            $formState = $this->form->getState();
            if (array_key_exists('phone_verified', $formState)) {
                $user->phone_verified = (bool) $formState['phone_verified'];
            }
            $user->save();
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()->label('حذف'),
        ];
    }
}
