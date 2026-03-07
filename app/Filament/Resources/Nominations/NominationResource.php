<?php

namespace App\Filament\Resources\Nominations;

use App\Filament\Resources\Nominations\Pages\CreateNomination;
use App\Filament\Resources\Nominations\Pages\EditNomination;
use App\Filament\Resources\Nominations\Pages\ListNominations;
use App\Filament\Resources\Nominations\Schemas\NominationForm;
use App\Filament\Resources\Nominations\Tables\NominationsTable;
use App\Models\Nomination;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class NominationResource extends Resource
{
    protected static ?string $model = Nomination::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedHandThumbUp;

    protected static ?string $navigationLabel = 'الترشيحات';

    protected static string|\UnitEnum|null $navigationGroup = 'إدارة الشحنات';

    protected static ?string $modelLabel = 'ترشيح';

    protected static ?string $pluralModelLabel = 'الترشيحات';

    protected static ?int $navigationSort = 4;

    public static function form(Schema $schema): Schema
    {
        return NominationForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return NominationsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListNominations::route('/'),
            'create' => CreateNomination::route('/create'),
            'edit' => EditNomination::route('/{record}/edit'),
        ];
    }
}
