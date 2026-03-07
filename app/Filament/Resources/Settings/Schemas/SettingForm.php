<?php

namespace App\Filament\Resources\Settings\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class SettingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الإعداد')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('key')
                                    ->label('المفتاح')->required()->unique(ignoreRecord: true)->maxLength(100),
                                Select::make('group')
                                    ->label('المجموعة')
                                    ->options([
                                        'general' => 'عام',
                                        'contact' => 'التواصل',
                                        'payment' => 'الدفع',
                                        'notification' => 'الإشعارات',
                                    ])->default('general')->required(),
                                Select::make('type')
                                    ->label('نوع القيمة')
                                    ->options([
                                        'text' => 'نص',
                                        'number' => 'رقم',
                                        'boolean' => 'نعم/لا',
                                        'image' => 'صورة',
                                    ])->default('text')->required(),
                                TextInput::make('label_ar')
                                    ->label('التسمية بالعربية')->maxLength(255),
                            ]),
                        Textarea::make('value')->label('القيمة')->rows(3)->columnSpanFull(),
                    ]),
            ]);
    }
}
