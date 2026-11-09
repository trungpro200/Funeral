# Funeral Care MVP

Flutter mobile client with a Laravel 12 REST API and MySQL persistence. Scope follows the workbook's **MVP** sheet and includes account registration/login, funeral service catalog and booking, casket search/details/customization, orders, and staff workflows for bookings, quotes, orders, services, and caskets.

## Run locally

1. MySQL is configured at `127.0.0.1:3306`, database `funeral_booking`. Backend `.env` is local and ignored; `.env.example` is the template.
2. Start the API from `Backend`: `php artisan serve --host=0.0.0.0`.
3. Start the mobile client from `Frontend`: `flutter run`.

The Android emulator uses `10.0.2.2:8000`. Override the API URL with `--dart-define=API_BASE=http://HOST:8000/api/v1`. Use HTTPS and restrict CORS/cleartext settings before deployment.

## Demo staff accounts

- Admin: `admin@example.com` / `password`
- Staff: `staff@example.com` / `password`

Change these seeded credentials before sharing or deploying the app.

See [Backend/README.md](Backend/README.md) for API/setup details and [Frontend/README.md](Frontend/README.md) for Flutter device configuration.
