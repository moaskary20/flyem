<?php

namespace App\Filament\Resources\Nominations\Pages;

use App\Filament\Resources\Nominations\NominationResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListNominations extends ListRecords
{
    protected static string $resource = NominationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('إضافة جديد'),
        ];
    }
}
