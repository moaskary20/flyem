<?php

namespace App\Filament\Resources\Nominations\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class NominationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الترشيح')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('shipment_id')
                                    ->label('الشحنة')
                                    ->relationship('shipment', 'title')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('trip_id')
                                    ->label('الرحلة')
                                    ->relationship('trip', 'id')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('proposer_id')
                                    ->label('مقدِّم الترشيح')
                                    ->relationship('proposer', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                TextInput::make('proposed_price')
                                    ->label('السعر المقترح')
                                    ->numeric()
                                    ->step(0.01),
                                Select::make('currency_id')
                                    ->label('العملة')
                                    ->relationship('currency', 'name')
                                    ->searchable()
                                    ->preload(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'accepted' => 'مقبول',
                                        'rejected' => 'مرفوض',
                                        'expired' => 'منتهي الصلاحية',
                                    ])
                                    ->default('pending')
                                    ->required(),
                                DateTimePicker::make('expires_at')
                                    ->label('ينتهي في'),
                            ]),
                        Textarea::make('note')
                            ->label('ملاحظة')
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
