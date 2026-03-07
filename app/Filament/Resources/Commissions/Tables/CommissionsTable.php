<?php

namespace App\Filament\Resources\Commissions\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CommissionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('user.name')->label('المستخدم')->searchable()->sortable(),
                TextColumn::make('request_id')->label('رقم الطلب'),
                TextColumn::make('amount')->label('مبلغ العمولة')->money()->sortable(),
                TextColumn::make('rate')->label('النسبة (%)')->suffix('%')->sortable(),
                TextColumn::make('currency.symbol')->label('العملة'),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'collected',
                        'info' => 'refunded',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'collected' => 'محصَّلة',
                        'refunded' => 'مستردة',
                        default => $state,
                    }),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'collected' => 'محصَّلة',
                        'refunded' => 'مستردة',
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
