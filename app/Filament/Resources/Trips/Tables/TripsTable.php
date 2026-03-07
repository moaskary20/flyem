<?php

namespace App\Filament\Resources\Trips\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class TripsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('user.name')->label('المسافر')->searchable()->sortable(),
                TextColumn::make('travel_method')
                    ->label('وسيلة التنقل')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'flight' => 'طيران ✈️',
                        'car' => 'سيارة 🚗',
                        'train' => 'قطار 🚂',
                        'bus' => 'حافلة 🚌',
                        'ship' => 'سفينة 🚢',
                        default => 'أخرى',
                    }),
                TextColumn::make('fromCountry.name_ar')->label('من'),
                TextColumn::make('toCountry.name_ar')->label('إلى'),
                TextColumn::make('departure_date')->label('المغادرة')->dateTime('d/m/Y H:i')->sortable(),
                TextColumn::make('return_date')->label('العودة')->dateTime('d/m/Y H:i')->toggleable(),
                TextColumn::make('available_weight')->label('الوزن المتاح')->suffix(' كجم'),
                TextColumn::make('price_per_kg')->label('السعر/كجم')->money(),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'info' => 'completed',
                        'danger' => 'cancelled',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'active' => 'نشطة',
                        'completed' => 'مكتملة',
                        'cancelled' => 'ملغية',
                        default => $state,
                    }),
                TextColumn::make('created_at')->label('تاريخ النشر')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشطة',
                        'completed' => 'مكتملة',
                        'cancelled' => 'ملغية',
                    ]),
                SelectFilter::make('travel_method')
                    ->label('وسيلة التنقل')
                    ->options([
                        'flight' => 'طيران',
                        'car' => 'سيارة',
                        'train' => 'قطار',
                        'bus' => 'حافلة',
                        'ship' => 'سفينة',
                        'other' => 'أخرى',
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
            ->defaultSort('departure_date', 'desc');
    }
}
