<?php

namespace App\Filament\Resources\UserVerifications\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserVerificationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('بيانات المستخدم (للمراجعة)')
                    ->description('تُعرض تلقائياً عند فتح طلب موجود؛ الحقول للقراءة فقط.')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('uv_full_name')
                                    ->label('الاسم الكامل')
                                    ->disabled()
                                    ->dehydrated(false),
                                TextInput::make('uv_email')
                                    ->label('البريد الإلكتروني')
                                    ->disabled()
                                    ->dehydrated(false),
                                TextInput::make('uv_phone')
                                    ->label('الهاتف الأساسي')
                                    ->disabled()
                                    ->dehydrated(false),
                                TextInput::make('uv_home_phone')
                                    ->label('هاتف الدولة الأم')
                                    ->disabled()
                                    ->dehydrated(false),
                                TextInput::make('uv_travel_phone')
                                    ->label('هاتف دولة السفر')
                                    ->disabled()
                                    ->dehydrated(false),
                                TextInput::make('uv_home_location')
                                    ->label('الأم: دولة ومدينة')
                                    ->disabled()
                                    ->dehydrated(false)
                                    ->columnSpanFull(),
                                TextInput::make('uv_travel_location')
                                    ->label('السفر: دولة ومدينة')
                                    ->disabled()
                                    ->dehydrated(false)
                                    ->columnSpanFull(),
                                TextInput::make('uv_bank')
                                    ->label('البنك / IBAN / صاحب الحساب')
                                    ->disabled()
                                    ->dehydrated(false)
                                    ->columnSpanFull(),
                            ]),
                    ])
                    ->collapsed()
                    ->columnSpanFull(),
                Section::make('بيانات طلب التوثيق')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('user_id')
                                    ->label('المستخدم')
                                    ->relationship('user', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->required(),
                                Select::make('status')
                                    ->label('الحالة')
                                    ->options([
                                        'pending' => 'قيد المراجعة',
                                        'approved' => 'موافق عليه',
                                        'rejected' => 'مرفوض',
                                    ])
                                    ->default('pending')
                                    ->required(),
                                Select::make('reviewed_by')
                                    ->label('راجعه')
                                    ->relationship('reviewer', 'name')
                                    ->searchable()
                                    ->preload(),
                            ]),
                        FileUpload::make('id_document')
                            ->label('وثيقة الهوية')
                            ->image()
                            ->directory('verifications/id')
                            ->columnSpanFull(),
                        FileUpload::make('selfie_image')
                            ->label('صورة السيلفي')
                            ->image()
                            ->directory('verifications/selfie')
                            ->columnSpanFull(),
                        Textarea::make('admin_notes')
                            ->label('ملاحظات الأدمن')
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),
                Section::make('توثيق الهاتف')
                    ->description('تم التحقق من الهاتف يظهر للمستخدم في الصفحة الشخصية بالتطبيق.')
                    ->schema([
                        Toggle::make('phone_verified')
                            ->label('تم التحقق من الهاتف')
                            ->default(false),
                    ]),
            ]);
    }
}
