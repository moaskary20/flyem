<?php

namespace App\Filament\Resources\Trips\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class TripForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الرحلة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('user_id')
                                    ->label('المسافر')
                                    ->relationship('user', 'name')
                                    ->searchable()->preload()->required(),
                                Select::make('travel_method')
                                    ->label('وسيلة التنقل')
                                    ->options([
                                        'flight' => 'طيران ✈️',
                                        'car' => 'سيارة 🚗',
                                        'train' => 'قطار 🚂',
                                        'bus' => 'حافلة 🚌',
                                        'ship' => 'سفينة 🚢',
                                        'other' => 'أخرى',
                                    ])->default('flight')->required(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'active' => 'نشطة',
                                        'completed' => 'مكتملة',
                                        'cancelled' => 'ملغية',
                                    ])->default('active')->required(),
                            ]),
                    ]),
                Section::make('من - إلى')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('from_country_id')
                                    ->label('من دولة')
                                    ->relationship('fromCountry', 'name_ar')
                                    ->searchable()->preload()->required(),
                                Select::make('from_city_id')
                                    ->label('من مدينة')
                                    ->relationship('fromCity', 'name_ar')
                                    ->searchable()->preload()->required(),
                                Select::make('to_country_id')
                                    ->label('إلى دولة')
                                    ->relationship('toCountry', 'name_ar')
                                    ->searchable()->preload()->required(),
                                Select::make('to_city_id')
                                    ->label('إلى مدينة')
                                    ->relationship('toCity', 'name_ar')
                                    ->searchable()->preload()->required(),
                            ]),
                    ]),
                Section::make('تفاصيل الرحلة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                DateTimePicker::make('departure_date')
                                    ->label('تاريخ المغادرة')->required(),
                                DateTimePicker::make('return_date')
                                    ->label('تاريخ العودة'),
                                TextInput::make('price_per_kg')
                                    ->label('السعر/كجم')->numeric()->step(0.01),
                                Select::make('currency_id')
                                    ->label('العملة')
                                    ->relationship('currency', 'name')
                                    ->searchable()->preload(),
                            ]),
                        Textarea::make('notes')->label('ملاحظات')->rows(3)->columnSpanFull(),
                    ]),
                Section::make('جواز السفر وتذكرة الطيران')
                    ->schema([
                        FileUpload::make('passport_image')
                            ->label('صورة جواز السفر')
                            ->image()
                            ->directory('trips/verification')
                            ->visibility('public'),
                        FileUpload::make('flight_ticket_image')
                            ->label('صورة تذكرة الطيران')
                            ->image()
                            ->directory('trips/verification')
                            ->visibility('public'),
                    ])
                    ->columns(2),
            ]);
    }
}
