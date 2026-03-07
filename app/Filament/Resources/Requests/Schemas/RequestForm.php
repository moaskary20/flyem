<?php

namespace App\Filament\Resources\Requests\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class RequestForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الطلب')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('requester_id')
                                    ->label('مقدِّم الطلب')
                                    ->relationship('requester', 'name')
                                    ->searchable()->preload()->required(),
                                Select::make('shipment_id')
                                    ->label('الشحنة')
                                    ->relationship('shipment', 'title')
                                    ->searchable()->preload(),
                                Select::make('trip_id')
                                    ->label('الرحلة')
                                    ->relationship('trip', 'id')
                                    ->searchable()->preload(),
                                TextInput::make('price')
                                    ->label('السعر المقترح')
                                    ->numeric()->step(0.01),
                                Select::make('currency_id')
                                    ->label('العملة')
                                    ->relationship('currency', 'name')
                                    ->searchable()->preload(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'accepted' => 'مقبول',
                                        'rejected' => 'مرفوض',
                                        'in_progress' => 'قيد التنفيذ',
                                        'delivered' => 'تم التسليم',
                                        'cancelled' => 'ملغي',
                                        'disputed' => 'متنازع عليه',
                                    ])->default('pending')->required(),
                            ]),
                        Textarea::make('message')
                            ->label('الرسالة')->rows(3)->columnSpanFull(),
                    ]),
            ]);
    }
}
