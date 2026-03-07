<?php

namespace App\Filament\Resources\Countries\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CountryForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الدولة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('name_ar')
                                    ->label('الاسم بالعربية')
                                    ->required()
                                    ->maxLength(100),
                                TextInput::make('name_en')
                                    ->label('الاسم بالإنجليزية')
                                    ->required()
                                    ->maxLength(100),
                                TextInput::make('code')
                                    ->label('الرمز (ISO)')
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->maxLength(5)
                                    ->placeholder('SA, US, EG...'),
                                TextInput::make('phone_code')
                                    ->label('كود الهاتف')
                                    ->maxLength(10)
                                    ->placeholder('+966'),
                                TextInput::make('flag')
                                    ->label('رمز العلم (Emoji)')
                                    ->maxLength(10)
                                    ->placeholder('🇸🇦'),
                                Toggle::make('is_active')
                                    ->label('نشطة')
                                    ->default(true),
                            ]),
                    ]),
            ]);
    }
}
