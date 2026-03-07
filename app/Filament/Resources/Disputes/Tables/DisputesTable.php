<?php

namespace App\Filament\Resources\Disputes\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class DisputesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('request_id')->label('رقم الطلب'),
                TextColumn::make('openedBy.name')->label('فُتح بواسطة')->searchable()->sortable(),
                TextColumn::make('reason')->label('السبب')->limit(50),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'danger' => 'open',
                        'warning' => 'under_review',
                        'success' => 'resolved',
                        'secondary' => 'closed',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'open' => 'مفتوح',
                        'under_review' => 'قيد المراجعة',
                        'resolved' => 'محلول',
                        'closed' => 'مغلق',
                        default => $state,
                    }),
                TextColumn::make('resolvedBy.name')->label('حُلَّ بواسطة')->toggleable(),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options([
                        'open' => 'مفتوح',
                        'under_review' => 'قيد المراجعة',
                        'resolved' => 'محلول',
                        'closed' => 'مغلق',
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
