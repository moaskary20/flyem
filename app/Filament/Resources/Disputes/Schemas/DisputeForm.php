<?php

namespace App\Filament\Resources\Disputes\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class DisputeForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات النزاع')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('request_id')
                                    ->label('الطلب')
                                    ->relationship('request', 'id')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('opened_by')
                                    ->label('فُتح بواسطة')
                                    ->relationship('openedBy', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'open' => 'مفتوح',
                                        'under_review' => 'قيد المراجعة',
                                        'resolved' => 'محلول',
                                        'closed' => 'مغلق',
                                    ])
                                    ->default('open')
                                    ->required(),
                                Select::make('resolved_by')
                                    ->label('حُلَّ بواسطة')
                                    ->relationship('resolvedBy', 'name')
                                    ->searchable()
                                    ->preload(),
                            ]),
                        Textarea::make('reason')
                            ->label('سبب النزاع')
                            ->required()
                            ->rows(4)
                            ->columnSpanFull(),
                        Textarea::make('admin_resolution')
                            ->label('قرار الأدمن')
                            ->rows(4)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
