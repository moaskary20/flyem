<?php

namespace App\Filament\Resources\Currencies\Pages;

use App\Filament\Resources\Currencies\CurrencyResource;
use App\Models\Currency;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditCurrency extends EditRecord
{
    protected static string $resource = CurrencyResource::class;

    protected function afterSave(): void
    {
        if ($this->record->is_default) {
            Currency::query()->where('id', '<>', $this->record->id)->update(['is_default' => false]);
        }
        if (! Currency::query()->where('is_default', true)->exists()) {
            $this->record->update(['is_default' => true]);
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
