<?php

namespace App\Filament\Resources\Shipments\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class ShipmentsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('title')->label('العنوان')->searchable()->sortable(),
                TextColumn::make('user.name')->label('المُرسِل')->searchable()->sortable(),
                TextColumn::make('fromCountry.name_ar')->label('من'),
                TextColumn::make('toCountry.name_ar')->label('إلى'),
                TextColumn::make('type')
                    ->label('النوع')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'documents' => 'وثائق',
                        'fragile' => 'قابل للكسر',
                        'electronics' => 'إلكترونيات',
                        'clothing' => 'ملابس',
                        'food' => 'طعام',
                        default => 'أخرى',
                    }),
                TextColumn::make('price_min')->label('الحد الأدنى للسعر')->money(),
                TextColumn::make('deadline_date')->label('الموعد النهائي')->date('d/m/Y'),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'active',
                        'primary' => 'in_progress',
                        'info' => 'delivered',
                        'danger' => 'cancelled',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'active' => 'نشطة',
                        'in_progress' => 'قيد التنفيذ',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغية',
                        default => $state,
                    }),
                TextColumn::make('created_at')->label('تاريخ النشر')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'active' => 'نشطة',
                        'in_progress' => 'قيد التنفيذ',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغية',
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
