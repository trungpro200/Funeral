# Laravel API

REST API for the funeral service booking and casket ordering MVP. API prefix: `/api/v1`. Sanctum bearer tokens protect customer and staff endpoints; staff/admin routes enforce roles.

## Setup

1. Create a MySQL database named `funeral_booking` (MySQL host `127.0.0.1`, port `3306` by default).
2. Copy `.env.example` to `.env` and set the database credentials.
3. Install dependencies with Composer, generate the app key, and migrate/seed:

   ```powershell
   composer install
   php artisan key:generate
   php artisan migrate --seed
   php artisan serve --host=0.0.0.0
   ```

The demo accounts are `admin@example.com` / `password` and `staff@example.com` / `password`. Replace these before deployment.

For local phone testing, use the Laragon Apache HTTPS virtual host described in the project root README. `php artisan serve` provides HTTP only. The included local CA is development-only; use a publicly trusted certificate for deployment.

## Backend feature tests

Run `composer test` or `vendor/bin/phpunit`. PHPUnit uses an in-memory SQLite database, so the suite does not modify the local MySQL demo data.

## Main endpoints

- Public: `POST register`, `POST login`, `GET services`, `GET services/{id}`, `GET caskets`, `GET caskets/{id}`.
- Customer: `GET me`, `POST logout`, `GET/POST bookings`, `GET/POST orders`, `GET/POST customization-requests`.
- Staff/admin: booking and order queues with status updates, customization review/quotes, and service/casket create, update, and deactivate endpoints.

All request and response bodies use JSON. Booking statuses: `new`, `confirmed`, `proposed`, `in_progress`, `completed`, `cancelled`. Order statuses: `new`, `confirmed`, `preparing`, `completed`, `cancelled`.

## Environment note

This source scaffold targets Laravel 12 and Sanctum 4. The backend dependencies have been installed and `composer.lock` pins the resolved versions.
