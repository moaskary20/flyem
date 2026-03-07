<?php

namespace App\Filament\Resources\Banners\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class BannersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')->label('الصورة'),
                TextColumn::make('title')->label('العنوان')->searchable()->sortable(),
                TextColumn::make('link')->label('الرابط')->limit(30)->toggleable(),
                TextColumn::make('sort_order')->label('الترتيب')->sortable(),
                IconColumn::make('is_active')->label('نشط')->boolean(),
                TextColumn::make('created_at')->label('تاريخ الإضافة')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                TernaryFilter::make('is_active')->label('الحالة')
                    ->trueLabel('نشط')->falseLabel('غير نشط'),
            ])
            ->recordActions([EditAction::make()->label('تعديل')])
            ->toolbarActions([
                BulkActionGroup::make([DeleteBulkAction::make()->label('حذف المحدد')]),
            ])
            ->defaultSort('sort_order');
    }
}
