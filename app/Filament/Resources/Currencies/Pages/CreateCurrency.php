<?php

namespace App\Filament\Resources\Currencies\Pages;

use App\Filament\Resources\Currencies\CurrencyResource;
use App\Models\Currency;
use Filament\Resources\Pages\CreateRecord;

class CreateCurrency extends CreateRecord
{
    protected static string $resource = CurrencyResource::class;

    protected function afterCreate(): void
    {
        if ($this->record->is_default) {
            Currency::query()->where('id', '<>', $this->record->id)->update(['is_default' => false]);
        } elseif (! Currency::query()->where('is_default', true)->exists()) {
            $this->record->update(['is_default' => true]);
        }
    }
}
