<?php

namespace App\Filament\Resources\Settings\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class SettingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('key')->label('المفتاح')->searchable()->sortable()->copyable(),
                TextColumn::make('label_ar')->label('التسمية')->searchable(),
                TextColumn::make('value')->label('القيمة')->limit(50)->searchable(),
                TextColumn::make('group')
                    ->label('المجموعة')->badge()
                    ->formatStateUsing(fn (string $state) => match ($state) {
                        'general' => 'عام',
                        'contact' => 'التواصل',
                        'payment' => 'الدفع',
                        'notification' => 'الإشعارات',
                        default => $state,
                    }),
            ])
            ->filters([
                SelectFilter::make('group')->label('المجموعة')
                    ->options(['general' => 'عام', 'contact' => 'التواصل', 'payment' => 'الدفع', 'notification' => 'الإشعارات']),
            ])
            ->recordActions([EditAction::make()->label('تعديل')])
            ->toolbarActions([
                BulkActionGroup::make([DeleteBulkAction::make()->label('حذف المحدد')]),
            ])
            ->defaultSort('group');
    }
}
