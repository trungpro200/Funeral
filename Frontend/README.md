# Flutter app

The app provides customer sign-in/registration, funeral service browsing and booking, casket search/customization requests/orders, booking/order history, and a basic staff booking queue.

## Run

1. Ensure the Laragon Apache backend is reachable from the device. Android defaults to `https://192.168.1.53/api/v1`; override it with `--dart-define=API_BASE=https://HOST/api/v1`. The Flutter debug HTTP client trusts the local development CA in `assets/certs`; this certificate is only for local development. Rebuild/reinstall the debug app after TLS changes. Android emulator users can set `HOST` to `10.0.2.2` after issuing a matching local certificate.
2. From this directory run `flutter pub get`, then `flutter run`.
3. For local HTTPS, see the Laragon TLS setup in the project root README. Release builds trust system CAs only. Use a publicly trusted certificate for deployment.

Keep the phone and computer on the same network and allow inbound connections to port 443.
