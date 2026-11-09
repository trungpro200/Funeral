import 'package:flutter/material.dart';
import '../services/api.dart';

class LoginPage extends StatefulWidget {
  final Function(Map) onSignedIn;
  const LoginPage({super.key, required this.onSignedIn});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  bool registering = false, busy = false;
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final data = await api.call(registering ? 'register' : 'login',
          method: 'POST',
          auth: false,
          data: {
            'email': email.text.trim(),
            'password': password.text,
            ...(registering
                ? {
                    'password_confirmation': password.text,
                    'name': name.text.trim(),
                    'phone': phone.text.trim()
                  }
                : {})
          });
      widget.onSignedIn(Map<String, dynamic>.from(data));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.volunteer_activism,
                          size: 56, color: Color(0xff315b50)),
                      const SizedBox(height: 12),
                      Text(registering ? 'Create your account' : 'Funeral Care',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      if (registering) ...[
                        TextFormField(
                            controller: name,
                            decoration:
                                const InputDecoration(labelText: 'Full name'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null),
                        TextFormField(
                            controller: phone,
                            decoration:
                                const InputDecoration(labelText: 'Phone')),
                      ],
                      TextFormField(
                          controller: email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Enter a valid email'
                              : null),
                      TextFormField(
                          controller: password,
                          obscureText: true,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          validator: (v) => v == null || v.length < 8
                              ? 'At least 8 characters'
                              : null),
                      const SizedBox(height: 18),
                      FilledButton(
                          onPressed: busy ? null : submit,
                          child: Text(busy
                              ? 'Please wait...'
                              : registering
                                  ? 'Register'
                                  : 'Sign in')),
                      TextButton(
                          onPressed: () =>
                              setState(() => registering = !registering),
                          child: Text(registering
                              ? 'Already registered? Sign in'
                              : 'Create an account')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
