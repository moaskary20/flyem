<?php

namespace App\Filament\Resources\Notifications\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class NotificationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('title')->label('العنوان')->searchable()->sortable(),
                TextColumn::make('body')->label('النص')->limit(60),
                BadgeColumn::make('type')
                    ->label('النوع')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'general' => 'عام',
                        'promotional' => 'ترويجي',
                        'system' => 'نظام',
                        'alert' => 'تنبيه',
                        default => $state,
                    }),
                TextColumn::make('target')
                    ->label('الجمهور')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'all' => 'الجميع',
                        'users' => 'المستخدمون',
                        'specific' => 'محددون',
                        default => $state,
                    }),
                IconColumn::make('is_sent')->label('أُرسل')->boolean(),
                TextColumn::make('sent_at')->label('وقت الإرسال')->dateTime('d/m/Y H:i')->toggleable(),
                TextColumn::make('created_at')->label('تاريخ الإنشاء')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                TernaryFilter::make('is_sent')
                    ->label('حالة الإرسال')
                    ->trueLabel('تم الإرسال')
                    ->falseLabel('لم يُرسل'),
                SelectFilter::make('target')
                    ->label('الجمهور')
                    ->options([
                        'all' => 'الجميع',
                        'users' => 'المستخدمون',
                        'specific' => 'محددون',
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
