<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::view('/paypal/return', 'paypal-return', [
    'message' => 'إذا أكملت الدفع في PayPal، ارجع إلى تطبيق فلاي إم واضغط «إتمام الدفع» مرة أخرى لإنهاء الطلب.',
])->name('paypal.return');

Route::view('/paypal/cancel', 'paypal-return', [
    'message' => 'تم إلغاء الدفع. يمكنك العودة إلى تطبيق فلاي إم.',
])->name('paypal.cancel');
