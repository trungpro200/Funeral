<?php
use App\Http\Controllers\ApiController;
use Illuminate\Support\Facades\Route;
Route::prefix('v1')->group(function () {
    Route::post('register', [ApiController::class, 'register']);
    Route::post('login', [ApiController::class, 'login']);
    Route::get('services', [ApiController::class, 'services']);
    Route::get('services/{service}', [ApiController::class, 'service']);
    Route::get('caskets', [ApiController::class, 'caskets']);
    Route::get('caskets/{casket}', [ApiController::class, 'casket']);
    Route::get('casket-images/{filename}', [ApiController::class, 'casketImage']);
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [ApiController::class, 'logout']);
        Route::get('me', [ApiController::class, 'me']);
        Route::get('bookings', [ApiController::class, 'bookings']);
        Route::post('bookings', [ApiController::class, 'createBooking']);
        Route::get('orders', [ApiController::class, 'orders']);
        Route::post('orders', [ApiController::class, 'createOrder']);
        Route::post('customization-requests', [ApiController::class, 'customization']);
        Route::get('customization-requests', [ApiController::class, 'myCustomizations']);
        Route::middleware('role:staff,admin')->group(function () {
            Route::get('staff/bookings', [ApiController::class, 'staffBookings']);
            Route::patch('staff/bookings/{booking}', [ApiController::class, 'updateBooking']);
            Route::get('staff/orders', [ApiController::class, 'staffOrders']);
            Route::get('staff/customization-requests', [ApiController::class, 'staffCustomizations']);
            Route::patch('staff/customization-requests/{request}', [ApiController::class, 'reviewCustomization']);
            Route::post('staff/services', [ApiController::class, 'createService']);
            Route::patch('staff/services/{service}', [ApiController::class, 'updateService']);
            Route::delete('staff/services/{service}', [ApiController::class, 'deleteService']);
            Route::post('staff/caskets', [ApiController::class, 'createCasket']);
            Route::patch('staff/caskets/{casket}', [ApiController::class, 'updateCasket']);
            Route::delete('staff/caskets/{casket}', [ApiController::class, 'deleteCasket']);
            Route::patch('staff/orders/{order}', [ApiController::class, 'updateOrder']);
        });
    });
});
