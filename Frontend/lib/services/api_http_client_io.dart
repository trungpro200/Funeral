import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

Future<http.Client> createApiHttpClient() async {
  if (!kDebugMode) return http.Client();

  final certificate = await rootBundle.load('assets/certs/funeral_dev_root_ca.pem');
  final context = SecurityContext(withTrustedRoots: true)
    ..setTrustedCertificatesBytes(certificate.buffer.asUint8List(
      certificate.offsetInBytes,
      certificate.lengthInBytes,
    ));
  return IOClient(HttpClient(context: context));
}
