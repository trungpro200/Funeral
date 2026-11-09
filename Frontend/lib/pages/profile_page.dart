import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Map user;
  final VoidCallback onSignOut;
  const ProfilePage({super.key, required this.user, required this.onSignOut});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool confirmSignOut = true;

  Future<void> _signOut() async {
    if (confirmSignOut) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign out?'),
          content: const Text('You can sign back in any time.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stay signed in')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sign out')),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    widget.onSignOut();
  }

  void _showDetails(String title, List<Widget> content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    (widget.user['name'] ?? 'U').toString().trim().isEmpty
                        ? 'U'
                        : (widget.user['name'] as String)
                            .trim()[0]
                            .toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(widget.user['name'] ?? 'Welcome',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(widget.user['email'] ?? '',
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Chip(
                          label: Text((widget.user['role'] ?? 'customer')
                              .toString()
                              .toUpperCase()),
                          visualDensity: VisualDensity.compact),
                    ])),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          Text('Your account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
              child: Column(children: [
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Account details'),
              subtitle: const Text('Review your profile information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDetails('Account details', [
                _ProfileDetail(label: 'Name', value: widget.user['name']),
                _ProfileDetail(label: 'Email', value: widget.user['email']),
                _ProfileDetail(label: 'Phone', value: widget.user['phone']),
                _ProfileDetail(
                    label: 'Account type',
                    value: widget.user['role'] ?? 'customer'),
              ]),
            ),
            const Divider(height: 1, indent: 56),
            SwitchListTile(
              secondary: const Icon(Icons.verified_user_outlined),
              title: const Text('Confirm before signing out'),
              subtitle: const Text('Ask before ending your session'),
              value: confirmSignOut,
              onChanged: (value) => setState(() => confirmSignOut = value),
            ),
          ])),
          const SizedBox(height: 18),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
              child: Column(children: [
            ListTile(
              leading: const Icon(Icons.volunteer_activism_outlined),
              title: const Text('About Funeral Care'),
              subtitle: const Text('Our approach to supporting families'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDetails('About Funeral Care', [
                Text(
                    'We help families explore funeral services, request arrangements, and keep track of their bookings in one place.',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                    'Our goal is to make each step easier to understand, with clear service information and a team that follows up on every request.',
                    style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('How it works'),
              subtitle: const Text('Services, bookings, and order updates'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDetails('How it works', [
                const _HelpStep(
                    number: '1',
                    title: 'Browse',
                    detail: 'Review available services and caskets.'),
                const _HelpStep(
                    number: '2',
                    title: 'Send a request',
                    detail:
                        'Choose a time or submit an order from its details.'),
                const _HelpStep(
                    number: '3',
                    title: 'Follow progress',
                    detail: 'Check your Bookings and Orders tabs for updates.'),
              ]),
            ),
          ])),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          const SizedBox(height: 16),
          Center(
              child: Text('Funeral Care · Version 1.0',
                  style: Theme.of(context).textTheme.bodySmall)),
        ],
      );
}

class _ProfileDetail extends StatelessWidget {
  final String label;
  final dynamic value;
  const _ProfileDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value?.toString().isNotEmpty == true
              ? value.toString()
              : 'Not provided'),
        ]),
      );
}

class _HelpStep extends StatelessWidget {
  final String number;
  final String title;
  final String detail;
  const _HelpStep(
      {required this.number, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 14, child: Text(number)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(detail),
              ])),
        ]),
      );
}
