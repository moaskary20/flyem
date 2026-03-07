<?php

namespace App\Filament\Resources\Requests\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class RequestsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('requester.name')->label('مقدِّم الطلب')->searchable()->sortable(),
                TextColumn::make('shipment.title')->label('الشحنة')->searchable(),
                TextColumn::make('trip.id')->label('رقم الرحلة'),
                TextColumn::make('price')->label('السعر المقترح')->money(),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'accepted',
                        'danger' => 'rejected',
                        'primary' => 'in_progress',
                        'info' => 'delivered',
                        'secondary' => 'cancelled',
                        'danger' => 'disputed',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'in_progress' => 'قيد التنفيذ',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        'disputed' => 'متنازع عليه',
                        default => $state,
                    }),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'in_progress' => 'قيد التنفيذ',
                        'delivered' => 'تم التسليم',
                        'cancelled' => 'ملغي',
                        'disputed' => 'متنازع عليه',
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
