<?php

namespace App\Filament\Resources\UserVerifications\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class UserVerificationsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('user.name')->label('المستخدم')->searchable()->sortable(),
                ImageColumn::make('id_document')->label('وثيقة الهوية')->circular(false),
                ImageColumn::make('selfie_image')->label('السيلفي')->circular(),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'pending',
                        'success' => 'approved',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'pending' => 'قيد المراجعة',
                        'approved' => 'موافق عليه',
                        'rejected' => 'مرفوض',
                        default => $state,
                    }),
                TextColumn::make('reviewer.name')->label('راجعه')->toggleable(),
                TextColumn::make('reviewed_at')->label('تاريخ المراجعة')->dateTime('d/m/Y')->toggleable(),
                TextColumn::make('created_at')->label('تاريخ الطلب')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'pending' => 'قيد المراجعة',
                        'approved' => 'موافق عليه',
                        'rejected' => 'مرفوض',
                    ]),
            ])
            ->recordActions([
                EditAction::make()->label('مراجعة'),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make()->label('حذف المحدد'),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
