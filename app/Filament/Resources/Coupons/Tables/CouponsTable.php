<?php

namespace App\Filament\Resources\Coupons\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CouponsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('code')->label('الكود')->searchable()->sortable()->copyable(),
                TextColumn::make('discount_type')
                    ->label('النوع')
                    ->formatStateUsing(fn (string $state) => $state === 'percentage' ? 'نسبة مئوية' : 'مبلغ ثابت'),
                TextColumn::make('discount_value')->label('القيمة')->sortable(),
                TextColumn::make('used_count')->label('مرات الاستخدام')->sortable(),
                TextColumn::make('usage_limit')->label('الحد الأقصى'),
                TextColumn::make('expiry_date')->label('الانتهاء')->date('d/m/Y')->sortable(),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'secondary' => 'inactive',
                        'danger' => 'expired',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                        'expired' => 'منتهي الصلاحية',
                        default => $state,
                    }),
            ])
            ->filters([
                SelectFilter::make('status')->label('الحالة')
                    ->options(['active' => 'نشط', 'inactive' => 'غير نشط', 'expired' => 'منتهي الصلاحية']),
            ])
            ->recordActions([EditAction::make()->label('تعديل')])
            ->toolbarActions([
                BulkActionGroup::make([DeleteBulkAction::make()->label('حذف المحدد')]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
