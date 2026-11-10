import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../utils/formatters.dart';

class StaffBookingsPage extends StatefulWidget {
  const StaffBookingsPage({super.key});
  @override
  State<StaffBookingsPage> createState() => _StaffBookingsPageState();
}

class _StaffBookingsPageState extends State<StaffBookingsPage> {
  List items = [];
  bool loading = true;
  String? loadError;
  Future<void> load() async {
    try {
      final r = await api.call('staff/bookings');
      items = List.from(r['data'] ?? []);
      loadError = null;
    } catch (e) {
      loadError = '$e';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> update(Map b, String status) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (status == 'proposed') {
        final day = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (day == null || !mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time == null || !mounted) return;
        final proposed =
            DateTime(day.year, day.month, day.day, time.hour, time.minute);
        if (!proposed.isAfter(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choose a future time')),
          );
          return;
        }
        data['proposed_at'] = proposed.toIso8601String();
      }
      await api.call('staff/bookings/${b['id']}', method: 'PATCH', data: data);
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => _StaffPageLayout(
        title: 'Service booking desk',
        description:
            'Coordinate service requests, confirm arrangements, and propose a new time when needed.',
        icon: Icons.event_available_outlined,
        count: items.length,
        countLabel: 'requests',
        loading: loading,
        error: loadError,
        onRefresh: load,
        emptyIcon: Icons.event_note_outlined,
        emptyTitle: 'No service bookings yet',
        emptyMessage:
            'New customer booking requests will appear here for review.',
        children: [
          for (final b in items)
            Card(
                child: ListTile(
              title: Text(b['service']?['name'] ?? 'Booking'),
              subtitle: Text(
                  '${b['user']?['name'] ?? ''} | ${b['requested_at']}\n${b['location']} | ${b['status']}'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (status) => update(b, status),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                  PopupMenuItem(
                      value: 'proposed', child: Text('Propose new time')),
                  PopupMenuItem(value: 'completed', child: Text('Complete')),
                  PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                ],
              ),
            )),
        ],
      );
}

class StaffOrdersPage extends StatefulWidget {
  const StaffOrdersPage({super.key});
  @override
  State<StaffOrdersPage> createState() => _StaffOrdersPageState();
}

class _StaffOrdersPageState extends State<StaffOrdersPage> {
  List items = [];
  bool loading = true;
  String? loadError;
  Future<void> load() async {
    try {
      final r = await api.call('staff/orders');
      items = List.from(r['data'] ?? []);
      loadError = null;
    } catch (e) {
      loadError = '$e';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> update(Map order, String status) async {
    try {
      await api.call('staff/orders/${order['id']}',
          method: 'PATCH', data: {'status': status});
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => _StaffPageLayout(
        title: 'Casket order desk',
        description:
            'Track customer purchases from confirmation through preparation and completion.',
        icon: Icons.inventory_2_outlined,
        count: items.length,
        countLabel: 'orders',
        loading: loading,
        error: loadError,
        onRefresh: load,
        emptyIcon: Icons.shopping_bag_outlined,
        emptyTitle: 'No casket orders yet',
        emptyMessage:
            'Customer orders will appear here with their selected casket and contact details.',
        children: [
          for (final order in items)
            Card(
                child: ListTile(
              title: Text(order['casket']?['name'] ?? 'Order #${order['id']}'),
              subtitle: Text(
                  '${order['user']?['name'] ?? ''} | ${formatMoney(order['total_estimate'])} VND\nStatus: ${order['status']}'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (status) => update(order, status),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                  PopupMenuItem(value: 'preparing', child: Text('Preparing')),
                  PopupMenuItem(value: 'completed', child: Text('Complete')),
                  PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                ],
              ),
            )),
        ],
      );
}

class StaffCustomizationsPage extends StatefulWidget {
  const StaffCustomizationsPage({super.key});
  @override
  State<StaffCustomizationsPage> createState() =>
      _StaffCustomizationsPageState();
}

class _StaffCustomizationsPageState extends State<StaffCustomizationsPage> {
  List items = [];
  bool loading = true;
  String? loadError;
  Future<void> load() async {
    try {
      final r = await api.call('staff/customization-requests');
      items = List.from(r['data'] ?? []);
      loadError = null;
    } catch (e) {
      loadError = '$e';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> review(Map request, String status) async {
    final price =
        TextEditingController(text: '${request['casket']?['price'] ?? ''}');
    final days = TextEditingController(text: '7');
    final accepted = status == 'confirmed';
    if (accepted) {
      final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Confirm configuration'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: price,
                      decoration:
                          const InputDecoration(labelText: 'Final price (VND)'),
                      keyboardType: TextInputType.number),
                  TextField(
                      controller: days,
                      decoration:
                          const InputDecoration(labelText: 'Lead time (days)'),
                      keyboardType: TextInputType.number),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Confirm'))
                ],
              ));
      if (ok != true) return;
    }
    try {
      await api.call('staff/customization-requests/${request['id']}',
          method: 'PATCH',
          data: {
            'status': status,
            if (accepted) 'quoted_price': num.tryParse(price.text),
            if (accepted) 'lead_time_days': int.tryParse(days.text)
          });
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => _StaffPageLayout(
        title: 'Customization review',
        description:
            'Review requested options, prepare a quote, and set a lead time for the family.',
        icon: Icons.tune,
        count: items.length,
        countLabel: 'requests',
        loading: loading,
        error: loadError,
        onRefresh: load,
        emptyIcon: Icons.design_services_outlined,
        emptyTitle: 'No custom requests to review',
        emptyMessage:
            'Customer casket configurations will appear here when submitted.',
        children: [
          for (final request in items)
            Card(
                child: ListTile(
              title: Text(request['casket']?['name'] ??
                  'Customization #${request['id']}'),
              subtitle: Text(
                  '${request['user']?['name'] ?? ''} | ${request['status']}\n${jsonEncode(request['configuration'] ?? {})} ${request['notes'] ?? ''}'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (status) => review(request, status),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                      value: 'confirmed', child: Text('Confirm and quote')),
                  PopupMenuItem(value: 'rejected', child: Text('Decline')),
                ],
              ),
            )),
        ],
      );
}

class ManageCatalogPage extends StatefulWidget {
  final String type;
  const ManageCatalogPage({super.key, required this.type});
  @override
  State<ManageCatalogPage> createState() => _ManageCatalogPageState();
}

class _ManageCatalogPageState extends State<ManageCatalogPage> {
  List items = [];
  bool loading = true;
  String? loadError;
  String get path => widget.type;
  Future<void> load() async {
    try {
      final r = await api.call(path, auth: false);
      items = List.from(r['data'] ?? []);
      loadError = null;
    } catch (e) {
      loadError = '$e';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> edit([Map? item]) async {
    final service = widget.type == 'services';
    final name = TextEditingController(text: item?['name'] ?? '');
    final description = TextEditingController(text: item?['description'] ?? '');
    final price = TextEditingController(
        text: '${item?[service ? 'price_from' : 'price'] ?? ''}');
    final category = TextEditingController(text: item?['category'] ?? 'Wood');
    final material = TextEditingController(text: item?['material'] ?? '');
    final form = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(
                  '${item == null ? 'Add' : 'Edit'} ${service ? 'service' : 'casket'}'),
              content: Form(
                  key: form,
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null),
                    TextFormField(
                        controller: description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null),
                    if (!service) ...[
                      TextFormField(
                          controller: category,
                          decoration:
                              const InputDecoration(labelText: 'Category')),
                      TextFormField(
                          controller: material,
                          decoration:
                              const InputDecoration(labelText: 'Material')),
                    ],
                    TextFormField(
                        controller: price,
                        decoration:
                            const InputDecoration(labelText: 'Price (VND)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => num.tryParse(v ?? '') == null
                            ? 'Enter a price'
                            : null),
                  ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Save'))
              ],
            ));
    if (saved != true || !form.currentState!.validate()) return;
    final data = service
        ? {
            'name': name.text.trim(),
            'description': description.text.trim(),
            'price_from': num.parse(price.text)
          }
        : {
            'name': name.text.trim(),
            'description': description.text.trim(),
            'category': category.text.trim(),
            'material': material.text.trim(),
            'price': num.parse(price.text),
            'available': true,
            'options': {
              'material': ['Oak', 'Pine'],
              'color': ['Natural', 'Dark'],
              'size': ['Standard']
            }
          };
    try {
      await api.call('staff/$path${item == null ? '' : '/${item['id']}'}',
          method: item == null ? 'POST' : 'PATCH', data: data);
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> disable(Map item) async {
    try {
      await api.call('staff/$path/${item['id']}', method: 'DELETE');
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isService = widget.type == 'services';
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => edit(),
        icon: const Icon(Icons.add),
        label: Text(isService ? 'Add service' : 'Add casket'),
      ),
      body: _StaffPageLayout(
        title: isService ? 'Service catalog' : 'Casket catalog',
        description: isService
            ? 'Keep descriptions and starting prices up to date for families.'
            : 'Manage casket details and pricing shown in the customer catalog.',
        icon: isService ? Icons.spa_outlined : Icons.inventory_2_outlined,
        count: items.length,
        countLabel: isService ? 'services' : 'caskets',
        loading: loading,
        error: loadError,
        onRefresh: load,
        emptyIcon: isService ? Icons.spa_outlined : Icons.inventory_2_outlined,
        emptyTitle: isService
            ? 'No services in the catalog'
            : 'No caskets in the catalog',
        emptyMessage: isService
            ? 'Add a service to make it available to customers.'
            : 'Add a casket to make it available to customers.',
        children: [
          for (final item in items)
            Card(
                child: ListTile(
              leading: isService
                  ? const CircleAvatar(child: Icon(Icons.spa_outlined))
                  : _StaffCasketThumbnail(imagePath: item['image_url']),
              title: Text(item['name'] ?? ''),
              subtitle: Text(
                  '${item['description'] ?? ''}\n${formatMoney(item[isService ? 'price_from' : 'price'])} VND'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (action) =>
                    action == 'edit' ? edit(item) : disable(item),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                      value: 'disable', child: Text('Mark unavailable')),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _StaffPageLayout extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int count;
  final String countLabel;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final List<Widget> children;

  const _StaffPageLayout({
    required this.title,
    required this.description,
    required this.icon,
    required this.count,
    required this.countLabel,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(icon, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(description),
                      ])),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            Card(
                child: ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: Text('$count $countLabel'),
              subtitle: const Text('Pull down to refresh the latest activity.'),
              trailing: IconButton(
                  tooltip: 'Refresh',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh)),
            )),
            const SizedBox(height: 16),
            if (loading && children.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null && children.isEmpty)
              Card(
                  child: ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: const Text('Could not load this page'),
                subtitle: Text(error!),
                trailing: IconButton(
                    onPressed: onRefresh, icon: const Icon(Icons.refresh)),
              ))
            else if (children.isEmpty)
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Icon(emptyIcon,
                      size: 42, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 10),
                  Text(emptyTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(emptyMessage, textAlign: TextAlign.center),
                ]),
              ))
            else ...[
              Text('Recent activity',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...children,
            ],
          ],
        ),
      );
}

class _StaffCasketThumbnail extends StatelessWidget {
  final String? imagePath;
  const _StaffCasketThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.inventory_2_outlined));
    }
    final uri = Uri.parse(apiBase).replace(
      path: '/${imagePath!.replaceFirst(RegExp(r'^/+'), '')}',
      query: null,
      fragment: null,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          uri.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              const Icon(Icons.inventory_2_outlined),
        ),
      ),
    );
  }
}
