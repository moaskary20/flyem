<?php

namespace App\Filament\Resources\Shipments\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ShipmentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الشحنة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('user_id')
                                    ->label('صاحب الشحنة')
                                    ->relationship('user', 'name')
                                    ->searchable()->preload()->required(),
                                TextInput::make('title')
                                    ->label('عنوان الشحنة')
                                    ->required()->maxLength(255),
                            ]),
                        Textarea::make('description')->label('الوصف')->rows(3)->columnSpanFull(),
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
                Section::make('التفاصيل والسعر')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextInput::make('weight')->label('الوزن (كجم)')->numeric()->step(0.01),
                                Select::make('type')
                                    ->label('نوع الشحنة')
                                    ->options([
                                        'documents' => 'وثائق',
                                        'fragile' => 'قابل للكسر',
                                        'electronics' => 'إلكترونيات',
                                        'clothing' => 'ملابس',
                                        'food' => 'طعام',
                                        'other' => 'أخرى',
                                    ])->default('other'),
                                DatePicker::make('deadline_date')->label('الموعد النهائي'),
                                TextInput::make('price_min')->label('الحد الأدنى للسعر')->numeric()->step(0.01),
                                Select::make('currency_id')
                                    ->label('العملة')
                                    ->relationship('currency', 'name')
                                    ->searchable()->preload(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'active' => 'نشطة',
                                        'in_progress' => 'قيد التنفيذ',
                                        'delivered' => 'تم التسليم',
                                        'cancelled' => 'ملغية',
                                    ])->default('pending')->required(),
                            ]),
                        FileUpload::make('images')
                            ->label('صور الشحنة')
                            ->image()->multiple()->directory('shipments')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
