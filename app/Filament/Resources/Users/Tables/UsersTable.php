<?php

namespace App\Filament\Resources\Users\Tables;

use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('profile_photo')
                    ->label('الصورة')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&color=7F9CF5&background=EBF4FF'),
                TextColumn::make('name')->label('الاسم')->searchable()->sortable(),
                TextColumn::make('email')->label('البريد الإلكتروني')->searchable()->sortable(),
                TextColumn::make('phone')->label('الهاتف')->searchable(),
                TextColumn::make('country.name_ar')->label('الدولة')->sortable(),
                BadgeColumn::make('verification_status')
                    ->label('التوثيق')
                    ->colors([
                        'secondary' => 'unverified',
                        'warning' => 'pending',
                        'success' => 'verified',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'unverified' => 'غير موثق',
                        'pending' => 'قيد المراجعة',
                        'verified' => 'موثق',
                        'rejected' => 'مرفوض',
                        default => $state,
                    }),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'success' => 'active',
                        'warning' => 'inactive',
                        'danger' => 'banned',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                        'banned' => 'محظور',
                        default => $state,
                    }),
                TextColumn::make('rating')
                    ->label('التقييم')
                    ->formatStateUsing(fn ($state) => $state > 0 ? "⭐ {$state}" : '-')
                    ->sortable(),
                TextColumn::make('wallet_balance')
                    ->label('رصيد المحفظة')
                    ->money()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('shipments_count')->label('شحناته')->counts('shipments')->sortable()->toggleable(),
                TextColumn::make('trips_count')->label('رحلاته')->counts('trips')->sortable()->toggleable(),
                TextColumn::make('created_at')->label('تاريخ التسجيل')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'active' => 'نشط',
                        'inactive' => 'غير نشط',
                        'banned' => 'محظور',
                    ]),
                SelectFilter::make('verification_status')
                    ->label('التوثيق')
                    ->options([
                        'unverified' => 'غير موثق',
                        'pending' => 'قيد المراجعة',
                        'verified' => 'موثق',
                        'rejected' => 'مرفوض',
                    ]),
                SelectFilter::make('role')
                    ->label('الدور')
                    ->options([
                        'admin' => 'مدير',
                        'user' => 'مستخدم',
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
