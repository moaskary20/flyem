<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\ConversationController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\CurrencyController;
use App\Http\Controllers\Api\PlaceController;
use App\Http\Controllers\Api\SupportTicketController;
use App\Http\Controllers\Api\CountryController;
use App\Http\Controllers\Api\FaqController;
use App\Http\Controllers\Api\AppRequestController;
use App\Http\Controllers\Api\PaymentMethodController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\ShipmentController;
use App\Http\Controllers\Api\TripController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::middleware('auth.api_token')->group(function () {
    Route::get('/user', [AuthController::class, 'me']);
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/conversations', [ConversationController::class, 'index']);
    Route::post('/conversations', [ConversationController::class, 'store']);
    Route::get('/conversations/{conversation}', [ConversationController::class, 'show']);
    Route::post('/conversations/{conversation}/messages', [ConversationController::class, 'sendMessage']);
    Route::post('/trips/{trip}/send-request', [TripController::class, 'sendRequest']);
    Route::post('/shipments/{shipment}/request', [ShipmentController::class, 'createRequest']);
    Route::post('/shipments/{shipment}/send-request', [ShipmentController::class, 'sendRequest']);
    Route::get('/requests', [AppRequestController::class, 'index']);
    Route::patch('/requests/{req}/accept', [AppRequestController::class, 'accept']);
    Route::patch('/requests/{req}/reject', [AppRequestController::class, 'reject']);
    Route::post('/requests/{req}/pay', [AppRequestController::class, 'payRequest']);
    Route::post('/requests/{req}/rate', [AppRequestController::class, 'rate']);
    Route::post('/support-tickets', [SupportTicketController::class, 'store']);
});

Route::get('/banners', [BannerController::class, 'index']);
Route::get('/banners/{banner}/image', [BannerController::class, 'image']);
Route::get('/banners/{banner}/video', [BannerController::class, 'video']);
Route::get('/places', [PlaceController::class, 'index']);
Route::get('/countries', [CountryController::class, 'index']);
Route::get('/currencies', [CurrencyController::class, 'index']);
Route::get('/cities', [CityController::class, 'index']);
Route::get('/shipments', [ShipmentController::class, 'index']);
Route::post('/shipments', [ShipmentController::class, 'store']);
Route::get('/shipments/{shipment}', [ShipmentController::class, 'show']);
Route::put('/shipments/{shipment}', [ShipmentController::class, 'update']);
Route::post('/shipments/{shipment}/update', [ShipmentController::class, 'update']);
Route::delete('/shipments/{shipment}', [ShipmentController::class, 'destroy']);

Route::get('/trips', [TripController::class, 'index']);
Route::post('/trips', [TripController::class, 'store']);
Route::get('/trips/{trip}', [TripController::class, 'show']);
Route::put('/trips/{trip}', [TripController::class, 'update']);
Route::delete('/trips/{trip}', [TripController::class, 'destroy']);

Route::get('/faqs', [FaqController::class, 'index']);
Route::get('/settings', [SettingController::class, 'index']);
Route::get('/payment-methods', [PaymentMethodController::class, 'index']);
