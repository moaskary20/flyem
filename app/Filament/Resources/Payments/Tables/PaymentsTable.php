<?php

namespace App\Filament\Resources\Payments\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class PaymentsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('user.name')->label('المستخدم')->searchable()->sortable(),
                TextColumn::make('request_id')->label('رقم الطلب'),
                TextColumn::make('amount')->label('المبلغ')->money()->sortable(),
                TextColumn::make('currency.symbol')->label('العملة'),
                TextColumn::make('payment_method')
                    ->label('طريقة الدفع')
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'wallet' => 'المحفظة',
                        'card' => 'بطاقة ائتمانية',
                        'bank_transfer' => 'تحويل بنكي',
                        'cash' => 'نقدًا',
                        default => $state,
                    }),
                BadgeColumn::make('payment_status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'paid',
                        'info' => 'refunded',
                        'danger' => 'failed',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد الانتظار',
                        'paid' => 'مدفوع',
                        'refunded' => 'مسترد',
                        'failed' => 'فشل',
                        default => $state,
                    }),
                TextColumn::make('transaction_reference')->label('رقم المرجع')->copyable()->toggleable(),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('payment_status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد الانتظار',
                        'paid' => 'مدفوع',
                        'refunded' => 'مسترد',
                        'failed' => 'فشل',
                    ]),
                SelectFilter::make('payment_method')
                    ->label('طريقة الدفع')
                    ->options([
                        'wallet' => 'المحفظة',
                        'card' => 'بطاقة ائتمانية',
                        'bank_transfer' => 'تحويل بنكي',
                        'cash' => 'نقدًا',
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
