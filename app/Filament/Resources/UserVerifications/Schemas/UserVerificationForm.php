<?php

namespace App\Filament\Resources\UserVerifications\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserVerificationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
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
            ]);
    }
}
