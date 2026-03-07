<?php

namespace App\Filament\Resources\UserVerifications;

use App\Filament\Resources\UserVerifications\Pages\CreateUserVerification;
use App\Filament\Resources\UserVerifications\Pages\EditUserVerification;
use App\Filament\Resources\UserVerifications\Pages\ListUserVerifications;
use App\Filament\Resources\UserVerifications\Schemas\UserVerificationForm;
use App\Filament\Resources\UserVerifications\Tables\UserVerificationsTable;
use App\Models\UserVerification;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class UserVerificationResource extends Resource
{
    protected static ?string $model = UserVerification::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedIdentification;

    protected static ?string $navigationLabel = 'توثيق المستخدمين';

    protected static string|\UnitEnum|null $navigationGroup = 'إدارة المستخدمين';

    protected static ?string $modelLabel = 'طلب توثيق';

    protected static ?string $pluralModelLabel = 'توثيق المستخدمين';

    protected static ?int $navigationSort = 2;

    public static function form(Schema $schema): Schema
    {
        return UserVerificationForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return UserVerificationsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUserVerifications::route('/'),
            'create' => CreateUserVerification::route('/create'),
            'edit' => EditUserVerification::route('/{record}/edit'),
        ];
    }
}
