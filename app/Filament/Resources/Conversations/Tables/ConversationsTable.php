<?php

namespace App\Filament\Resources\Conversations\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ConversationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('sender.name')->label('المُرسِل')->searchable()->sortable(),
                TextColumn::make('receiver.name')->label('المُستقبِل')->searchable()->sortable(),
                TextColumn::make('messages_count')
                    ->label('عدد الرسائل')
                    ->counts('messages'),
                TextColumn::make('last_message_at')
                    ->label('آخر رسالة')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                TextColumn::make('created_at')->label('تاريخ البدء')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([])
            ->recordActions([
                EditAction::make()->label('تعديل'),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make()->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('last_message_at', 'desc');
    }
}
