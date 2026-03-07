<?php

namespace App\Filament\Resources\Currencies\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CurrencyForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات العملة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('name')
                                    ->label('اسم العملة')
                                    ->required()->maxLength(100),
                                TextInput::make('code')
                                    ->label('الرمز (ISO)')
                                    ->required()->unique(ignoreRecord: true)->maxLength(5)
                                    ->placeholder('USD, SAR, EGP...'),
                                TextInput::make('symbol')
                                    ->label('الرمز المختصر')
                                    ->required()->maxLength(10)
                                    ->placeholder('$, ﷼, ج.م'),
                                TextInput::make('exchange_rate')
                                    ->label('سعر الصرف')
                                    ->numeric()->step(0.000001)->default(1),
                                Toggle::make('is_default')->label('العملة الافتراضية'),
                                Toggle::make('is_active')->label('نشطة')->default(true),
                            ]),
                    ]),
            ]);
    }
}
