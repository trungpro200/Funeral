# Flutter app

The app provides customer sign-in/registration, funeral service browsing and booking, casket search/customization requests/orders, booking/order history, and a basic staff booking queue.

## Run

1. Ensure the Laravel API is reachable from the device. Android defaults to `http://192.168.1.53:8000/api/v1`; change it with `--dart-define=API_BASE=http://HOST:8000/api/v1` when using another address. Android emulator users can set `HOST` to `10.0.2.2`.
2. From this directory run `flutter pub get`, then `flutter run`.
3. The local PHP development server uses plain HTTP. Use HTTPS with a trusted certificate for deployment.

Keep the phone and computer on the same network and allow inbound connections to port 8000.
