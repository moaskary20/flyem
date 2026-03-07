<?php

namespace App\Filament\Resources\Payments\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class PaymentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الدفعة')
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
                                    ->label('المبلغ')
                                    ->numeric()
                                    ->step(0.01)
                                    ->required(),
                                Select::make('currency_id')
                                    ->label('العملة')
                                    ->relationship('currency', 'name')
                                    ->searchable()
                                    ->preload(),
                                Select::make('payment_method')
                                    ->label('طريقة الدفع')
                                    ->options([
                                        'wallet' => 'المحفظة',
                                        'card' => 'بطاقة ائتمانية',
                                        'bank_transfer' => 'تحويل بنكي',
                                        'cash' => 'نقدًا',
                                    ])
                                    ->default('wallet')
                                    ->required(),
                                Select::make('payment_status')
                                    ->label('حالة الدفع')
                                    ->options([
                                        'pending' => 'قيد الانتظار',
                                        'paid' => 'مدفوع',
                                        'refunded' => 'مسترد',
                                        'failed' => 'فشل',
                                    ])
                                    ->default('pending')
                                    ->required(),
                                TextInput::make('transaction_reference')
                                    ->label('رقم المرجع')
                                    ->maxLength(255),
                            ]),
                        Textarea::make('notes')
                            ->label('ملاحظات')
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
