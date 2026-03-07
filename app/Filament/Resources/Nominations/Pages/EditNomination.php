<?php

namespace App\Filament\Resources\Nominations\Pages;

use App\Filament\Resources\Nominations\NominationResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditNomination extends EditRecord
{
    protected static string $resource = NominationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()->label('حذف'),
        ];
    }
}
