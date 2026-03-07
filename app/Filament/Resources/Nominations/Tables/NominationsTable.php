<?php

namespace App\Filament\Resources\Nominations\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class NominationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('proposer.name')->label('مقدِّم الترشيح')->searchable()->sortable(),
                TextColumn::make('shipment.title')->label('الشحنة')->searchable(),
                TextColumn::make('trip.id')->label('رقم الرحلة'),
                TextColumn::make('proposed_price')->label('السعر المقترح')->money(),
                TextColumn::make('currency.symbol')->label('العملة'),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'accepted',
                        'danger' => 'rejected',
                        'secondary' => 'expired',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'expired' => 'منتهي الصلاحية',
                        default => $state,
                    }),
                TextColumn::make('expires_at')->label('ينتهي في')->dateTime('d/m/Y H:i')->toggleable(),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'accepted' => 'مقبول',
                        'rejected' => 'مرفوض',
                        'expired' => 'منتهي الصلاحية',
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
