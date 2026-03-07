<?php

namespace App\Filament\Resources\PaymentMethods\Schemas;

use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class PaymentMethodForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات وسيلة الدفع')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('name_ar')
                                    ->label('الاسم (عربي)')
                                    ->required()->maxLength(100),
                                TextInput::make('name_en')
                                    ->label('الاسم (إنجليزي)')
                                    ->required()->maxLength(100),
                                TextInput::make('code')
                                    ->label('الرمز (فريد)')
                                    ->required()->unique(ignoreRecord: true)->maxLength(50)
                                    ->placeholder('card, wallet, bank_transfer'),
                                TextInput::make('sort_order')
                                    ->label('ترتيب العرض')
                                    ->numeric()->default(0),
                                Toggle::make('is_active')->label('نشطة')->default(true),
                            ]),
                        Textarea::make('settings')
                            ->label('الإعدادات (JSON اختياري)')
                            ->rows(4)
                            ->placeholder('{"api_key":"..."}')
                            ->formatStateUsing(fn ($state) => is_array($state) ? json_encode($state, \JSON_PRETTY_PRINT | \JSON_UNESCAPED_UNICODE) : $state)
                            ->dehydrateStateUsing(fn ($state) => is_string($state) ? json_decode($state, true) : $state)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
