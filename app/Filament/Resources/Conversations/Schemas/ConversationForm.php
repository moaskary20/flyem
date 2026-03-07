<?php

namespace App\Filament\Resources\Conversations\Schemas;

use Filament\Forms\Components\Select;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ConversationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات المحادثة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('sender_id')
                                    ->label('المُرسِل')
                                    ->relationship('sender', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('receiver_id')
                                    ->label('المُستقبِل')
                                    ->relationship('receiver', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('request_id')
                                    ->label('الطلب المرتبط')
                                    ->relationship('request', 'id')
                                    ->searchable()
                                    ->preload(),
                            ]),
                    ]),
            ]);
    }
}
