<?php

namespace App\Filament\Resources\Messages\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class MessagesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('sender.name')->label('المُرسِل')->searchable()->sortable(),
                TextColumn::make('conversation_id')->label('المحادثة #'),
                TextColumn::make('message')->label('الرسالة')->limit(50),
                BadgeColumn::make('type')
                    ->label('النوع')
                    ->colors([
                        'primary' => 'text',
                        'success' => 'image',
                        'info' => 'file',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'text' => 'نص',
                        'image' => 'صورة',
                        'file' => 'ملف',
                        default => $state,
                    }),
                IconColumn::make('is_read')->label('مقروءة')->boolean(),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y H:i')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('type')
                    ->label('النوع')
                    ->options([
                        'text' => 'نص',
                        'image' => 'صورة',
                        'file' => 'ملف',
                    ]),
            ])
            ->recordActions([
                EditAction::make()->label('تعديل'),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make()->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
