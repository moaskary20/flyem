<?php

namespace App\Filament\Resources\Faqs\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class FaqForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('السؤال والجواب')
                    ->schema([
                        Textarea::make('question')
                            ->label('السؤال')->required()->rows(3)->columnSpanFull(),
                        Textarea::make('answer')
                            ->label('الجواب')->required()->rows(5)->columnSpanFull(),
                        Grid::make(2)
                            ->schema([
                                TextInput::make('sort_order')
                                    ->label('الترتيب')->numeric()->integer()->default(0),
                                Toggle::make('is_active')->label('نشط')->default(true),
                            ]),
                    ]),
            ]);
    }
}
