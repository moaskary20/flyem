<?php

namespace App\Filament\Resources\SupportTickets\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class SupportTicketForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات التذكرة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('user_id')
                                    ->label('المستخدم')
                                    ->relationship('user', 'name')
                                    ->searchable()->preload()->required(),
                                TextInput::make('subject')
                                    ->label('الموضوع')->required()->maxLength(255),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'open' => 'مفتوحة',
                                        'in_progress' => 'قيد المعالجة',
                                        'resolved' => 'محلولة',
                                        'closed' => 'مغلقة',
                                    ])->default('open')->required(),
                            ]),
                        Textarea::make('message')->label('الرسالة')->required()->rows(4)->columnSpanFull(),
                        Textarea::make('admin_reply')->label('رد الأدمن')->rows(4)->columnSpanFull(),
                    ]),
            ]);
    }
}
