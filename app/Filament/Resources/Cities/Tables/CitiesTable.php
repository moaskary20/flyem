<?php

namespace App\Filament\Resources\Cities\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class CitiesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name_ar')->label('الاسم بالعربية')->searchable()->sortable(),
                TextColumn::make('name_en')->label('الاسم بالإنجليزية')->searchable()->sortable()->toggleable(),
                TextColumn::make('country.name_ar')->label('الدولة')->searchable()->sortable(),
                IconColumn::make('is_active')->label('نشطة')->boolean(),
            ])
            ->filters([
                SelectFilter::make('country_id')
                    ->label('الدولة')
                    ->relationship('country', 'name_ar')
                    ->searchable()
                    ->preload(),
                TernaryFilter::make('is_active')
                    ->label('الحالة')
                    ->trueLabel('نشطة')
                    ->falseLabel('غير نشطة'),
            ])
            ->recordActions([
                EditAction::make()->label('تعديل'),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make()->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('name_ar');
    }
}
