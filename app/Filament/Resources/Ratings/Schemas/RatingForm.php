<?php

namespace App\Filament\Resources\Ratings\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class RatingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات التقييم')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('from_user_id')
                                    ->label('من مستخدم')
                                    ->relationship('fromUser', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('to_user_id')
                                    ->label('إلى مستخدم')
                                    ->relationship('toUser', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('request_id')
                                    ->label('الطلب المرتبط')
                                    ->relationship('request', 'id')
                                    ->searchable()
                                    ->preload(),
                                Select::make('rating')
                                    ->label('التقييم')
                                    ->options([
                                        1 => '⭐ (1)',
                                        2 => '⭐⭐ (2)',
                                        3 => '⭐⭐⭐ (3)',
                                        4 => '⭐⭐⭐⭐ (4)',
                                        5 => '⭐⭐⭐⭐⭐ (5)',
                                    ])
                                    ->required(),
                            ]),
                        Textarea::make('comment')
                            ->label('التعليق')
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
