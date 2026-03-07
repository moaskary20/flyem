<?php

namespace App\Filament\Resources\Ratings\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class RatingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('fromUser.name')->label('من')->searchable()->sortable(),
                TextColumn::make('toUser.name')->label('إلى')->searchable()->sortable(),
                TextColumn::make('request_id')->label('رقم الطلب'),
                TextColumn::make('rating')
                    ->label('التقييم')
                    ->formatStateUsing(fn (int $state) => str_repeat('⭐', $state) . " ({$state})")
                    ->sortable(),
                TextColumn::make('comment')->label('التعليق')->limit(50)->toggleable(),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('rating')
                    ->label('التقييم')
                    ->options([
                        1 => '1 نجمة',
                        2 => '2 نجمتان',
                        3 => '3 نجوم',
                        4 => '4 نجوم',
                        5 => '5 نجوم',
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
