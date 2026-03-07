<?php

namespace App\Filament\Resources\Messages\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class MessageForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الرسالة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('conversation_id')
                                    ->label('المحادثة')
                                    ->relationship('conversation', 'id')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('sender_id')
                                    ->label('المُرسِل')
                                    ->relationship('sender', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('type')
                                    ->label('نوع الرسالة')
                                    ->options([
                                        'text' => 'نص',
                                        'image' => 'صورة',
                                        'file' => 'ملف',
                                    ])
                                    ->default('text')
                                    ->required(),
                            ]),
                        Textarea::make('message')
                            ->label('نص الرسالة')
                            ->required()
                            ->rows(4)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
