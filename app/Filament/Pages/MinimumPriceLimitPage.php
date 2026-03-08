<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Actions\Action;
use Illuminate\Support\Facades\Cache;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Actions;
use Filament\Schemas\Components\Component;
use Filament\Schemas\Components\EmbeddedSchema;
use Filament\Schemas\Components\Form;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Illuminate\Contracts\Support\Htmlable;

/**
 * صفحة الحد الأدنى للسعر (تحت إدارة المعاملات).
 * تمكن من تحديد حد أدنى لمكافأة المسافر والحد الأدنى لسعر الرحلة.
 *
 * @property-read Schema $form
 */
class MinimumPriceLimitPage extends Page
{
    protected static string|\BackedEnum|null $navigationIcon = Heroicon::OutlinedCurrencyDollar;

    protected static ?string $navigationLabel = 'الحد الأدنى للسعر';

    protected static ?string $title = 'الحد الأدنى للسعر';

    protected static string|\UnitEnum|null $navigationGroup = 'إدارة المعاملات';

    protected static ?int $navigationSort = 10;

    /**
     * @var array<string, mixed>|null
     */
    public ?array $data = [];

    public static function getRelativeRouteName(\Filament\Panel $panel): string
    {
        return 'minimum-price-limit';
    }

    public function mount(): void
    {
        $minTraveler = Setting::where('key', 'min_traveler_reward')->first();
        $minTrip = Setting::where('key', 'min_trip_price')->first();
        $data = [
            'min_traveler_reward' => $minTraveler?->value ?? '',
            'min_trip_price' => $minTrip?->value ?? '',
        ];
        $this->form->fill($data);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->statePath('data')
            ->components([
                Section::make('الحدود الدنيا للأسعار')
                    ->description('تحديد الحد الأدنى لمكافأة المسافر وسعر الرحلة (يمكن تركها فارغة إن لم يكن هناك حد).')
                    ->schema([
                        TextInput::make('min_traveler_reward')
                            ->label('الحد الأدنى لمكافأة المسافر')
                            ->numeric()
                            ->step(0.01)
                            ->minValue(0)
                            ->placeholder('مثال: 1.5'),
                        TextInput::make('min_trip_price')
                            ->label('الحد الأدنى لسعر الرحلة')
                            ->numeric()
                            ->step(0.01)
                            ->minValue(0)
                            ->placeholder('مثال: 2'),
                    ])
                    ->columns(2),
            ]);
    }

    public function content(Schema $schema): Schema
    {
        return $schema
            ->components([
                $this->getFormContentComponent(),
            ]);
    }

    protected function getFormContentComponent(): Component
    {
        return Form::make([EmbeddedSchema::make('form')])
            ->id('form')
            ->livewireSubmitHandler('save')
            ->footer([
                Actions::make([
                    Action::make('save')
                        ->label('حفظ')
                        ->submit('save')
                        ->keyBindings(['mod+s']),
                ])
                    ->key('form-actions'),
            ]);
    }

    public function getTitle(): string|Htmlable
    {
        return static::$title ?? '';
    }

    public function save(): void
    {
        $data = $this->form->getState();
        $minTraveler = $data['min_traveler_reward'] ?? null;
        $minTrip = $data['min_trip_price'] ?? null;

        Setting::updateOrCreate(
            ['key' => 'min_traveler_reward'],
            [
                'value' => filled($minTraveler) ? (string) $minTraveler : null,
                'group' => 'payment',
                'type' => 'number',
                'label_ar' => 'الحد الأدنى لمكافأة المسافر',
            ]
        );

        Setting::updateOrCreate(
            ['key' => 'min_trip_price'],
            [
                'value' => filled($minTrip) ? (string) $minTrip : null,
                'group' => 'payment',
                'type' => 'number',
                'label_ar' => 'الحد الأدنى لسعر الرحلة',
            ]
        );

        Cache::forget('api_settings');

        Notification::make()
            ->success()
            ->title('تم الحفظ')
            ->send();
    }
}
