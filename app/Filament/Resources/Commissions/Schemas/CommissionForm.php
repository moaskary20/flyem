<?php

namespace App\Filament\Resources\Commissions\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CommissionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات العمولة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('request_id')
                                    ->label('الطلب')
                                    ->relationship('request', 'id')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('user_id')
                                    ->label('المستخدم')
                                    ->relationship('user', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                TextInput::make('amount')
                                    ->label('مبلغ العمولة')
                                    ->numeric()
                                    ->step(0.01)
                                    ->required(),
                                TextInput::make('rate')
                                    ->label('نسبة العمولة (%)')
                                    ->numeric()
                                    ->step(0.01)
                                    ->default(10.00),
                                Select::make('currency_id')
                                    ->label('العملة')
                                    ->relationship('currency', 'name')
                                    ->searchable()
                                    ->preload(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'collected' => 'محصَّلة',
                                        'refunded' => 'مستردة',
                                    ])
                                    ->default('pending')
                                    ->required(),
                            ]),
                    ]),
            ]);
    }
}
