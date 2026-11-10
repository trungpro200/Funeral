import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

SecurityContext? _localDevelopmentContext;

Future<SecurityContext> _getLocalDevelopmentContext() async {
  if (_localDevelopmentContext != null) return _localDevelopmentContext!;

  final certificate =
      await rootBundle.load('assets/certs/funeral_dev_root_ca.pem');
  return _localDevelopmentContext = SecurityContext(withTrustedRoots: true)
    ..setTrustedCertificatesBytes(certificate.buffer.asUint8List(
      certificate.offsetInBytes,
      certificate.lengthInBytes,
    ));
}

Future<void> configureApiHttpOverrides() async {
  if (kDebugMode) {
    HttpOverrides.global = _LocalDevelopmentHttpOverrides(
      await _getLocalDevelopmentContext(),
    );
  }
}

Future<http.Client> createApiHttpClient() async {
  if (!kDebugMode) return http.Client();

  return IOClient(HttpClient(context: await _getLocalDevelopmentContext()));
}

class _LocalDevelopmentHttpOverrides extends HttpOverrides {
  final SecurityContext context;

  _LocalDevelopmentHttpOverrides(this.context);

  @override
  HttpClient createHttpClient(SecurityContext? _) =>
      super.createHttpClient(context);
}
