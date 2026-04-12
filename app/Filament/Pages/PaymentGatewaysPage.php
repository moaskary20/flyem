<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
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
 * إعدادات بوابات الدفع (PayPal) — لا تُعرض الأسرار في واجهة التطبيق العامة.
 *
 * @property-read Schema $form
 */
class PaymentGatewaysPage extends Page
{
    protected static string|\BackedEnum|null $navigationIcon = Heroicon::OutlinedCreditCard;

    protected static ?string $navigationLabel = 'بوابات الدفع';

    protected static ?string $title = 'بوابات الدفع';

    protected static string|\UnitEnum|null $navigationGroup = 'بوابات الدفع';

    protected static ?int $navigationSort = 1;

    /**
     * @var array<string, mixed>|null
     */
    public ?array $data = [];

    public static function getRelativeRouteName(\Filament\Panel $panel): string
    {
        return 'payment-gateways';
    }

    public function mount(): void
    {
        $bool = static fn (?string $v): bool => $v === '1' || $v === 'true';

        $this->form->fill([
            'paypal_enabled' => $bool(Setting::where('key', 'paypal_enabled')->first()?->value),
            'paypal_mode' => Setting::where('key', 'paypal_mode')->first()?->value ?: 'sandbox',
            'paypal_client_id' => Setting::where('key', 'paypal_client_id')->first()?->value ?? '',
            'paypal_client_secret' => Setting::where('key', 'paypal_client_secret')->first()?->value ?? '',
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->statePath('data')
            ->components([
                Section::make('PayPal')
                    ->description('معرّف العميل والسر من لوحة مطوري PayPal. وضع Sandbox للاختبار. يجب أن يكون APP_URL في ملف .env للخادم عنواناً عاماً (HTTPS) حتى يقبل PayPal روابط العودة بعد الدفع من تطبيق الموبايل.')
                    ->schema([
                        Toggle::make('paypal_enabled')
                            ->label('تفعيل PayPal')
                            ->default(false),
                        Select::make('paypal_mode')
                            ->label('البيئة')
                            ->options([
                                'sandbox' => 'Sandbox (اختبار)',
                                'live' => 'Live (إنتاج)',
                            ])
                            ->required()
                            ->native(false),
                        TextInput::make('paypal_client_id')
                            ->label('Client ID')
                            ->maxLength(500)
                            ->placeholder('معرّف العميل من PayPal'),
                        TextInput::make('paypal_client_secret')
                            ->label('Client Secret')
                            ->password()
                            ->revealable()
                            ->maxLength(500)
                            ->placeholder('السر من PayPal'),
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

        $enabled = ! empty($data['paypal_enabled']);
        $mode = $data['paypal_mode'] ?? 'sandbox';
        if (! in_array($mode, ['sandbox', 'live'], true)) {
            $mode = 'sandbox';
        }

        Setting::updateOrCreate(
            ['key' => 'paypal_enabled'],
            [
                'value' => $enabled ? '1' : '0',
                'group' => 'payment_gateways',
                'type' => 'boolean',
                'label_ar' => 'تفعيل PayPal',
            ]
        );

        Setting::updateOrCreate(
            ['key' => 'paypal_mode'],
            [
                'value' => $mode,
                'group' => 'payment_gateways',
                'type' => 'text',
                'label_ar' => 'بيئة PayPal',
            ]
        );

        Setting::updateOrCreate(
            ['key' => 'paypal_client_id'],
            [
                'value' => isset($data['paypal_client_id']) ? trim((string) $data['paypal_client_id']) : '',
                'group' => 'payment_gateways',
                'type' => 'text',
                'label_ar' => 'PayPal Client ID',
            ]
        );

        Setting::updateOrCreate(
            ['key' => 'paypal_client_secret'],
            [
                'value' => isset($data['paypal_client_secret']) ? trim((string) $data['paypal_client_secret']) : '',
                'group' => 'payment_gateways',
                'type' => 'password',
                'label_ar' => 'PayPal Client Secret',
            ]
        );

        Cache::forget('api_settings');

        Notification::make()
            ->success()
            ->title('تم الحفظ')
            ->send();
    }
}
