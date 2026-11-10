import 'package:flutter/material.dart';
import 'app.dart';
import 'services/api_http_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureApiHttpOverrides();
  runApp(const FuneralApp());
}
