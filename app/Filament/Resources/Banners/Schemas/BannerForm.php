<?php

namespace App\Filament\Resources\Banners\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class BannerForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('محتوى البنر')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                TextInput::make('title')
                                    ->label('العنوان')
                                    ->required()->maxLength(255),
                                TextInput::make('link')
                                    ->label('الرابط')->url()->maxLength(500),
                                TextInput::make('sort_order')
                                    ->label('الترتيب')->numeric()->integer()->default(0),
                                Toggle::make('is_active')->label('نشط')->default(true),
                            ]),
                        FileUpload::make('image')
                            ->label('صورة البنر')
                            ->image()->directory('banners')
                            ->columnSpanFull(),
                        FileUpload::make('video')
                            ->label('فيديو البنر (اختياري - إن وُجد يُعرض بدل الصورة)')
                            ->acceptedFileTypes(['video/mp4', 'video/webm', 'video/quicktime'])
                            ->directory('banners/videos')
                            ->maxSize(50 * 1024)
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
