<?php

namespace App\Filament\Resources\Currencies\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CurrenciesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')->label('اسم العملة')->searchable()->sortable(),
                TextColumn::make('code')->label('الرمز')->badge()->searchable(),
                TextColumn::make('symbol')->label('الرمز المختصر'),
                TextColumn::make('exchange_rate')->label('سعر الصرف')->sortable(),
                IconColumn::make('is_default')->label('افتراضية')->boolean(),
                IconColumn::make('is_active')->label('نشطة')->boolean(),
            ])
            ->recordActions([EditAction::make()->label('تعديل')])
            ->toolbarActions([
                BulkActionGroup::make([DeleteBulkAction::make()->label('حذف المحدد')]),
            ])
            ->defaultSort('name');
    }
}
