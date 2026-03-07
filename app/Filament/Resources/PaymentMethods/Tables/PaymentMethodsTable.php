<?php

namespace App\Filament\Resources\PaymentMethods\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PaymentMethodsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name_ar')->label('الاسم (عربي)')->searchable()->sortable(),
                TextColumn::make('name_en')->label('الاسم (إنجليزي)')->searchable(),
                TextColumn::make('code')->label('الرمز')->badge()->searchable(),
                TextColumn::make('sort_order')->label('الترتيب')->sortable(),
                IconColumn::make('is_active')->label('نشطة')->boolean(),
            ])
            ->recordActions([EditAction::make()->label('تعديل')])
            ->toolbarActions([
                BulkActionGroup::make([DeleteBulkAction::make()->label('حذف المحدد')]),
            ])
            ->defaultSort('sort_order');
    }
}
