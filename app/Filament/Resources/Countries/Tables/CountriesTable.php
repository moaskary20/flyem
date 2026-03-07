<?php

namespace App\Filament\Resources\Countries\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class CountriesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('flag')->label('العلم'),
                TextColumn::make('name_ar')->label('الاسم بالعربية')->searchable()->sortable(),
                TextColumn::make('name_en')->label('الاسم بالإنجليزية')->searchable()->sortable()->toggleable(),
                TextColumn::make('code')->label('الرمز')->searchable()->badge(),
                TextColumn::make('phone_code')->label('كود الهاتف'),
                TextColumn::make('cities_count')->label('عدد المدن')->counts('cities'),
                IconColumn::make('is_active')->label('نشطة')->boolean(),
            ])
            ->filters([
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
