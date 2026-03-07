<?php

namespace App\Filament\Resources\Cities\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CityForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات المدينة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('country_id')
                                    ->label('الدولة')
                                    ->relationship('country', 'name_ar')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Toggle::make('is_active')
                                    ->label('نشطة')
                                    ->default(true),
                                TextInput::make('name_ar')
                                    ->label('الاسم بالعربية')
                                    ->required()
                                    ->maxLength(100),
                                TextInput::make('name_en')
                                    ->label('الاسم بالإنجليزية')
                                    ->required()
                                    ->maxLength(100),
                            ]),
                    ]),
            ]);
    }
}
