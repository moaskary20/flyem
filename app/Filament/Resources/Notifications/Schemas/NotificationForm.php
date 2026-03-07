<?php

namespace App\Filament\Resources\Notifications\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class NotificationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('محتوى الإشعار')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('title')
                                    ->label('العنوان')
                                    ->required()
                                    ->maxLength(255),
                                Select::make('type')
                                    ->label('النوع')
                                    ->options([
                                        'general' => 'عام',
                                        'promotional' => 'ترويجي',
                                        'system' => 'نظام',
                                        'alert' => 'تنبيه',
                                    ])
                                    ->default('general')
                                    ->required(),
                            ]),
                        Textarea::make('body')
                            ->label('نص الإشعار')
                            ->required()
                            ->rows(4)
                            ->columnSpanFull(),
                    ]),
                Section::make('إعدادات الإرسال')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('target')
                                    ->label('الجمهور المستهدف')
                                    ->options([
                                        'all' => 'جميع المستخدمين',
                                        'users' => 'المستخدمون فقط',
                                        'specific' => 'مستخدمون محددون',
                                    ])
                                    ->default('all')
                                    ->required(),
                                Toggle::make('is_sent')
                                    ->label('تم الإرسال')
                                    ->default(false),
                            ]),
                    ]),
            ]);
    }
}
