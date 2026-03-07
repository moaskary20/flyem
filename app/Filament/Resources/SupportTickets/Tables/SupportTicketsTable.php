<?php

namespace App\Filament\Resources\SupportTickets\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class SupportTicketsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('#')->sortable(),
                TextColumn::make('user.name')->label('المستخدم')->searchable()->sortable(),
                TextColumn::make('subject')->label('الموضوع')->searchable()->limit(50),
                BadgeColumn::make('status')
                    ->label('الحالة')
                    ->colors([
                        'warning' => 'open',
                        'primary' => 'in_progress',
                        'success' => 'resolved',
                        'secondary' => 'closed',
                    ])
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'open' => 'مفتوحة',
                        'in_progress' => 'قيد المعالجة',
                        'resolved' => 'محلولة',
                        'closed' => 'مغلقة',
                        default => $state,
                    }),
                TextColumn::make('created_at')->label('التاريخ')->dateTime('d/m/Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('status')->label('الحالة')
                    ->options(['open' => 'مفتوحة', 'in_progress' => 'قيد المعالجة', 'resolved' => 'محلولة', 'closed' => 'مغلقة']),
            ])
            ->recordActions([EditAction::make()->label('رد / تعديل')])
            ->toolbarActions([
                BulkActionGroup::make([DeleteBulkAction::make()->label('حذف المحدد')]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
