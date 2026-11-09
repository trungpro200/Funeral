import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

class FuneralApp extends StatefulWidget {
  const FuneralApp({super.key});
  @override
  State<FuneralApp> createState() => _FuneralAppState();
}

class _FuneralAppState extends State<FuneralApp> {
  bool ready = false;
  Map<String, dynamic>? user;
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    api.token = p.getString('token');
    if (api.token != null) {
      try {
        user = Map<String, dynamic>.from(await api.call('me'));
      } catch (_) {
        await p.remove('token');
        api.token = null;
      }
    }
    setState(() => ready = true);
  }

  Future<void> _signedIn(Map data) async {
    api.token = data['token'];
    user = Map<String, dynamic>.from(data['user']);
    final p = await SharedPreferences.getInstance();
    await p.setString('token', api.token!);
    setState(() {});
  }

  Future<void> _signedOut() async {
    try {
      await api.call('logout', method: 'POST');
    } catch (_) {}
    final p = await SharedPreferences.getInstance();
    await p.remove('token');
    api.token = null;
    setState(() => user = null);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Funeral Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315b50)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xfff7f7f3)),
      home: !ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : user == null
              ? LoginPage(onSignedIn: _signedIn)
              : HomePage(user: user!, onSignOut: _signedOut));
}
