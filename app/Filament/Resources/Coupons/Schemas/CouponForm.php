<?php

namespace App\Filament\Resources\Coupons\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CouponForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات الكوبون')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('code')
                                    ->label('كود الكوبون')
                                    ->required()->unique(ignoreRecord: true)->maxLength(50),
                                Select::make('discount_type')
                                    ->label('نوع الخصم')
                                    ->options([
                                        'percentage' => 'نسبة مئوية (%)',
                                        'fixed' => 'مبلغ ثابت',
                                    ])->default('percentage')->required(),
                                TextInput::make('discount_value')
                                    ->label('قيمة الخصم')
                                    ->numeric()->step(0.01)->required(),
                                DatePicker::make('expiry_date')
                                    ->label('تاريخ الانتهاء'),
                                TextInput::make('usage_limit')
                                    ->label('الحد الأقصى للاستخدام')
                                    ->numeric()->integer(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'active' => 'نشط',
                                        'inactive' => 'غير نشط',
                                        'expired' => 'منتهي الصلاحية',
                                    ])->default('active')->required(),
                            ]),
                    ]),
            ]);
    }
}
