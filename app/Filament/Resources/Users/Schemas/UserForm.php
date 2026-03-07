<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('البيانات الأساسية')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('name')
                                    ->label('الاسم الكامل')
                                    ->required()
                                    ->maxLength(255),
                                TextInput::make('email')
                                    ->label('البريد الإلكتروني')
                                    ->email()
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->maxLength(255),
                                TextInput::make('phone')
                                    ->label('رقم الهاتف')
                                    ->tel()
                                    ->maxLength(20),
                                TextInput::make('home_phone')
                                    ->label('رقم الهاتف (الدولة الأم)')
                                    ->tel()
                                    ->maxLength(50),
                                TextInput::make('travel_phone')
                                    ->label('رقم الهاتف (الدولة السفر)')
                                    ->tel()
                                    ->maxLength(50),
                                TextInput::make('password')
                                    ->label('كلمة المرور')
                                    ->password()
                                    ->revealable()
                                    ->dehydrateStateUsing(fn ($state) => filled($state) ? bcrypt($state) : null)
                                    ->dehydrated(fn ($state) => filled($state))
                                    ->required(fn (string $operation) => $operation === 'create'),
                            ]),
                        FileUpload::make('profile_photo')
                            ->label('صورة الملف الشخصي')
                            ->image()
                            ->directory('profiles')
                            ->columnSpanFull(),
                    ]),
                Section::make('الدولة والمدينة (الأم)')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('home_country_id')
                                    ->label('الدولة')
                                    ->relationship('homeCountry', 'name_ar')
                                    ->searchable()
                                    ->preload()
                                    ->live(),
                                Select::make('home_city_id')
                                    ->label('المدينة')
                                    ->relationship(
                                        'homeCity',
                                        'name_ar',
                                        modifyQueryUsing: fn ($query, $get) => $get('home_country_id')
                                            ? $query->where('country_id', $get('home_country_id'))
                                            : $query->whereRaw('1 = 0')
                                    )
                                    ->searchable()
                                    ->preload(),
                            ]),
                    ]),
                Section::make('الدولة والمدينة (السفر)')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('travel_country_id')
                                    ->label('الدولة')
                                    ->relationship('travelCountry', 'name_ar')
                                    ->searchable()
                                    ->preload()
                                    ->live(),
                                Select::make('travel_city_id')
                                    ->label('المدينة')
                                    ->relationship(
                                        'travelCity',
                                        'name_ar',
                                        modifyQueryUsing: fn ($query, $get) => $get('travel_country_id')
                                            ? $query->where('country_id', $get('travel_country_id'))
                                            : $query->whereRaw('1 = 0')
                                    )
                                    ->searchable()
                                    ->preload(),
                            ]),
                    ]),
                Section::make('بيانات السحاب البنكي')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('bank_iban')
                                    ->label('IBAN')
                                    ->maxLength(50),
                                TextInput::make('bank_name')
                                    ->label('اسم البنك')
                                    ->maxLength(255),
                                TextInput::make('bank_account_holder')
                                    ->label('اسم العميل بالبنك')
                                    ->maxLength(255)
                                    ->columnSpanFull(),
                            ]),
                    ]),
                Section::make('الموقع والحالة')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Select::make('country_id')
                                    ->label('الدولة')
                                    ->relationship('country', 'name_ar')
                                    ->searchable()
                                    ->preload(),
                                Select::make('city_id')
                                    ->label('المدينة')
                                    ->relationship('city', 'name_ar')
                                    ->searchable()
                                    ->preload(),
                                Select::make('role')
                                    ->label('الدور')
                                    ->options([
                                        'admin' => 'مدير',
                                        'user' => 'مستخدم',
                                    ])
                                    ->default('user')
                                    ->required(),
                                Select::make('status')
                                    ->label('حالة الحساب')
                                    ->options([
                                        'active' => 'نشط',
                                        'inactive' => 'غير نشط',
                                        'banned' => 'محظور',
                                    ])
                                    ->default('active')
                                    ->required(),
                                Select::make('verification_status')
                                    ->label('حالة التوثيق')
                                    ->options([
                                        'unverified' => 'غير موثق',
                                        'pending' => 'قيد المراجعة',
                                        'verified' => 'موثق',
                                        'rejected' => 'مرفوض',
                                    ])
                                    ->default('unverified'),
                                TextInput::make('rating')
                                    ->label('التقييم')
                                    ->numeric()
                                    ->step(0.01)
                                    ->minValue(0)
                                    ->maxValue(5)
                                    ->default(0),
                                TextInput::make('wallet_balance')
                                    ->label('رصيد المحفظة')
                                    ->numeric()
                                    ->step(0.01)
                                    ->default(0),
                            ]),
                    ]),
            ]);
    }
}
