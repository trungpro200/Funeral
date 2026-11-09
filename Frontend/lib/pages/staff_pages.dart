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
  Future<void> load() async {
    try {
      final r = await api.call('staff/bookings');
      items = List.from(r['data'] ?? []);
    } catch (e) {
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
  Widget build(BuildContext context) => loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: load,
          child: ListView(
              children: items
                  .map((b) => Card(
                      child: ListTile(
                          title: Text(b['service']?['name'] ?? 'Booking'),
                          subtitle: Text(
                              '${b['user']?['name'] ?? ''} · ${b['requested_at']}\n${b['location']} · ${b['status']}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                              onSelected: (s) => update(b, s),
                              itemBuilder: (c) => const [
                                    PopupMenuItem(
                                        value: 'confirmed',
                                        child: Text('Confirm')),
                                    PopupMenuItem(
                                        value: 'proposed',
                                        child: Text('Propose new time')),
                                    PopupMenuItem(
                                        value: 'completed',
                                        child: Text('Complete')),
                                    PopupMenuItem(
                                        value: 'cancelled',
                                        child: Text('Cancel'))
                                  ]))))
                  .toList()));
}

class StaffOrdersPage extends StatefulWidget {
  const StaffOrdersPage({super.key});
  @override
  State<StaffOrdersPage> createState() => _StaffOrdersPageState();
}

class _StaffOrdersPageState extends State<StaffOrdersPage> {
  List items = [];
  bool loading = true;
  Future<void> load() async {
    try {
      final r = await api.call('staff/orders');
      items = List.from(r['data'] ?? []);
    } catch (e) {
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
  Widget build(BuildContext context) => loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: load,
          child: ListView(
              children: items
                  .map((o) => Card(
                          child: ListTile(
                        title:
                            Text(o['casket']?['name'] ?? 'Order #${o['id']}'),
                        subtitle: Text(
                            '${o['user']?['name'] ?? ''} - ${o['total_estimate']} VND\n${o['status']}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                            onSelected: (s) => update(o, s),
                            itemBuilder: (c) => const [
                                  PopupMenuItem(
                                      value: 'confirmed',
                                      child: Text('Confirm')),
                                  PopupMenuItem(
                                      value: 'preparing',
                                      child: Text('Preparing')),
                                  PopupMenuItem(
                                      value: 'completed',
                                      child: Text('Complete')),
                                  PopupMenuItem(
                                      value: 'cancelled',
                                      child: Text('Cancel')),
                                ]),
                      )))
                  .toList()),
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
  Future<void> load() async {
    try {
      final r = await api.call('staff/customization-requests');
      items = List.from(r['data'] ?? []);
    } catch (e) {
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
  Widget build(BuildContext context) => loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: load,
          child: ListView(
              children: items
                  .map((r) => Card(
                          child: ListTile(
                        title: Text(r['casket']?['name'] ??
                            'Customization #${r['id']}'),
                        subtitle: Text(
                            '${r['user']?['name'] ?? ''} · ${r['status']}\n${jsonEncode(r['configuration'] ?? {})} ${r['notes'] ?? ''}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                            onSelected: (s) => review(r, s),
                            itemBuilder: (c) => const [
                                  PopupMenuItem(
                                      value: 'confirmed',
                                      child: Text('Confirm and quote')),
                                  PopupMenuItem(
                                      value: 'rejected',
                                      child: Text('Decline')),
                                ]),
                      )))
                  .toList()),
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
  String get path => widget.type;
  Future<void> load() async {
    try {
      final r = await api.call(path, auth: false);
      items = List.from(r['data'] ?? []);
    } catch (e) {
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
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () => edit(), child: const Icon(Icons.add)),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: load,
                child: ListView(
                    children: items
                        .map((item) => Card(
                                child: ListTile(
                              title: Text(item['name'] ?? ''),
                              subtitle: Text(
                                  '${item['description'] ?? ''}\n${formatMoney(item[widget.type == 'services' ? 'price_from' : 'price'])} VND'),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                  onSelected: (v) =>
                                      v == 'edit' ? edit(item) : disable(item),
                                  itemBuilder: (c) => const [
                                        PopupMenuItem(
                                            value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(
                                            value: 'disable',
                                            child: Text('Mark unavailable')),
                                      ]),
                            )))
                        .toList()),
              ),
      );
}
