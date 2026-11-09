# Flutter app

The app provides customer sign-in/registration, funeral service browsing and booking, casket search/customization requests/orders, booking/order history, and a basic staff booking queue.

## Run

1. Ensure the Laravel API is reachable from the device/emulator. Android emulator uses `10.0.2.2` to access the host machine.
2. From this directory run `flutter pub get`, then `flutter run`.
3. To use another API host, pass `--dart-define=API_BASE=http://HOST:8000/api/v1`.

For a physical Android device, use the computer's LAN IP and allow inbound connections to port 8000. Plain HTTP is intended for local development; use HTTPS for deployment.
