<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Actions;
use Filament\Schemas\Components\Component;
use Filament\Schemas\Components\EmbeddedSchema;
use Filament\Schemas\Components\Form;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\Facades\Cache;

/**
 * صفحة الحد الأدنى للسعر (تحت إدارة المعاملات).
 * تمكن من تحديد حد أدنى لمكافأة المسافر.
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
        $data = [
            'min_traveler_reward' => $minTraveler?->value ?? '',
        ];
        $this->form->fill($data);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->statePath('data')
            ->components([
                Section::make('الحد الأدنى لمكافأة المسافر')
                    ->description('يمكن ترك الحقل فارغاً إن لم يكن هناك حد أدنى للمكافأة على الشحنات.')
                    ->schema([
                        TextInput::make('min_traveler_reward')
                            ->label('الحد الأدنى لمكافأة المسافر')
                            ->numeric()
                            ->step(0.01)
                            ->minValue(0)
                            ->placeholder('مثال: 1.5'),
                    ])
                    ->columns(1),
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

        Setting::updateOrCreate(
            ['key' => 'min_traveler_reward'],
            [
                'value' => filled($minTraveler) ? (string) $minTraveler : null,
                'group' => 'payment',
                'type' => 'number',
                'label_ar' => 'الحد الأدنى لمكافأة المسافر',
            ]
        );

        Cache::forget('api_settings');

        Notification::make()
            ->success()
            ->title('تم الحفظ')
            ->send();
    }
}
