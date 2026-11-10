import 'package:http/http.dart' as http;
import 'api_http_client_stub.dart'
    if (dart.library.io) 'api_http_client_io.dart' as platform;

Future<http.Client> createApiHttpClient() => platform.createApiHttpClient();

Future<void> configureApiHttpOverrides() =>
    platform.configureApiHttpOverrides();
