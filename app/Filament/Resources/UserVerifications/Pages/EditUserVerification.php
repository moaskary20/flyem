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
        $record->loadMissing([
            'user.homeCountry',
            'user.homeCity',
            'user.travelCountry',
            'user.travelCity',
        ]);
        $u = $record->user;
        $data['phone_verified'] = $u?->phone_verified ?? false;
        $data['uv_full_name'] = $u?->name ?? '';
        $data['uv_email'] = $u?->email ?? '';
        $data['uv_phone'] = $u?->phone ?? '';
        $data['uv_home_phone'] = $u?->home_phone ?? '';
        $data['uv_travel_phone'] = $u?->travel_phone ?? '';
        $hc = $u?->homeCountry?->name_ar ?? $u?->homeCountry?->name_en ?? '';
        $hct = $u?->homeCity?->name_ar ?? $u?->homeCity?->name_en ?? '';
        $data['uv_home_location'] = trim($hc.(($hc !== '' && $hct !== '') ? ' — ' : '').$hct);
        $tc = $u?->travelCountry?->name_ar ?? $u?->travelCountry?->name_en ?? '';
        $tct = $u?->travelCity?->name_ar ?? $u?->travelCity?->name_en ?? '';
        $data['uv_travel_location'] = trim($tc.(($tc !== '' && $tct !== '') ? ' — ' : '').$tct);
        $bankLine = array_filter([
            $u?->bank_name,
            $u?->bank_iban,
            $u?->bank_account_holder,
        ], fn ($v) => filled($v));
        $data['uv_bank'] = $bankLine !== [] ? implode(' | ', $bankLine) : '';

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
            if ($record->status === 'approved' && $user->status !== 'banned') {
                $user->status = 'active';
            }
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
