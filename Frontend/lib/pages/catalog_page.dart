import 'package:flutter/material.dart';
import '../services/api.dart';
import '../utils/formatters.dart';

class CatalogPage extends StatefulWidget {
  final String type;
  const CatalogPage({super.key, required this.type});
  @override
  State<CatalogPage> createState() => _CatalogState();
}

class _CatalogState extends State<CatalogPage> {
  List items = [];
  bool loading = true;
  String search = '';
  Future<void> load() async {
    setState(() => loading = true);
    try {
      final result = await api.call(
          widget.type == 'services'
              ? 'services'
              : 'caskets${search.isEmpty ? '' : '?search=${Uri.encodeQueryComponent(search)}'}',
          auth: false);
      items = List.from(result['data'] ?? []);
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

  @override
  Widget build(BuildContext context) {
    if (widget.type == 'services') return _buildServicesPage();
    return _buildCasketsPage();
  }

  Widget _buildCasketsPage() => RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Text('Casket collection',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
                'Browse the available styles and find an option that feels right for your family.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            const SizedBox(height: 22),
            Text('Available caskets',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search caskets',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                search = value;
                load();
              },
            ),
            const SizedBox(height: 12),
            if (loading && items.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()))
            else if (items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No caskets found. Try another search.'),
                ),
              )
            else
              ...items.map((item) => _casketProductCard(context, item)),
          ],
        ),
      );

  Widget _casketProductCard(BuildContext context, Map item) => Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 14),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            height: 210,
            child: item['image_url'] is String &&
                    (item['image_url'] as String).isNotEmpty
                ? _casketImage(item['image_url'] as String, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.inventory_2_outlined, size: 56)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (item['material'] != null)
                        Text(
                            '${item['material']} · ${item['category'] ?? 'Casket'}',
                            style: Theme.of(context).textTheme.bodySmall),
                    ]),
              ),
              const SizedBox(width: 8),
              Text('${formatMoney(item['price'])} VND',
                  style: Theme.of(context).textTheme.titleSmall),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(item['description'] ?? '',
                maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
          OverflowBar(alignment: MainAxisAlignment.end, spacing: 8, children: [
            TextButton.icon(
              onPressed: () => _customizeDialog(context, item),
              icon: const Icon(Icons.tune),
              label: const Text('Customize'),
            ),
            FilledButton.icon(
              onPressed: () => _orderDialog(context, item),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Order'),
            ),
          ]),
        ]),
      );

  Widget _casketImage(String path, {required BoxFit fit}) {
    final imageUri = path.startsWith('http://') || path.startsWith('https://')
        ? Uri.parse(path)
        : Uri.parse(apiBase).replace(
            path: '/${path.replaceFirst(RegExp(r'^/+'), '')}',
            query: null,
            fragment: null,
          );
    return Image.network(
      imageUri.toString(),
      fit: fit,
      errorBuilder: (context, error, stack) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.inventory_2_outlined, size: 48),
      ),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildServicesPage() => RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xff315b50), Color(0xff548071)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.volunteer_activism,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 16),
                  Text('Here for you, every step of the way',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                  const SizedBox(height: 8),
                  Text(
                    'Explore caring support and arrange the services that feel right for your family.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: .9)),
                  ),
                  const SizedBox(height: 18),
                  const Wrap(spacing: 8, runSpacing: 8, children: [
                    _ServiceTag(
                        icon: Icons.favorite_outline,
                        text: 'Compassionate care'),
                    _ServiceTag(
                        icon: Icons.support_agent, text: 'Guidance throughout'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('How we can help',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Row(children: [
              Expanded(
                  child: _ServiceFeature(
                      icon: Icons.event_available,
                      title: 'Plan a service',
                      detail: 'Choose a service and request a time.')),
              SizedBox(width: 10),
              Expanded(
                  child: _ServiceFeature(
                      icon: Icons.handshake_outlined,
                      title: 'We coordinate',
                      detail: 'Our team will follow up on your request.')),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: Text('Available services',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              if (!loading)
                Text('${items.length} options',
                    style: Theme.of(context).textTheme.labelLarge),
            ]),
            const SizedBox(height: 8),
            if (loading && items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    const Icon(Icons.event_note_outlined, size: 36),
                    const SizedBox(height: 8),
                    const Text('Service options are being updated.'),
                    TextButton(onPressed: load, child: const Text('Try again')),
                  ]),
                ),
              )
            else
              ...items.map((item) => _itemCard(context, item, 'services')),
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Need help choosing?'),
                subtitle: Text(
                    'You can submit a booking request and our team will help with the next steps.'),
              ),
            ),
          ],
        ),
      );
}

class _ServiceTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ServiceTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ),
      );
}

class _ServiceFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  const _ServiceFeature(
      {required this.icon, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

Widget _itemCard(BuildContext context, Map item, String type) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
            child: Icon(type == 'services' ? Icons.spa : Icons.inventory_2)),
        title: Text(item['name'] ?? ''),
        subtitle: Text(
            '${item['description'] ?? ''}\n${type == 'services' ? 'From ' : ''}${formatMoney(item[type == 'services' ? 'price_from' : 'price'])} VND',
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        trailing: type == 'services'
            ? IconButton(
                icon: const Icon(Icons.event_available),
                tooltip: 'Book',
                onPressed: () => _bookDialog(context, item))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Request customization',
                    onPressed: () => _customizeDialog(context, item)),
                IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    tooltip: 'Order',
                    onPressed: () => _orderDialog(context, item)),
              ]),
      ),
    );
Future<void> _bookDialog(BuildContext context, Map service) async {
  final location = TextEditingController();
  final phone = TextEditingController();
  final contact = TextEditingController();
  final notes = TextEditingController();
  DateTime? when;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: Text('Book ${service['name']}'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: contact,
                decoration: const InputDecoration(labelText: 'Contact name')),
            TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
                controller: location,
                decoration:
                    const InputDecoration(labelText: 'Service location')),
            TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Notes')),
            TextButton.icon(
              onPressed: () async {
                final day = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: DateTime.now().add(const Duration(days: 1)));
                if (day == null) return;
                if (!ctx.mounted) return;
                final time = await showTimePicker(
                    context: ctx, initialTime: TimeOfDay.now());
                if (time != null) {
                  set(() => when = DateTime(
                      day.year, day.month, day.day, time.hour, time.minute));
                }
              },
              icon: const Icon(Icons.calendar_month),
              label:
                  Text(when == null ? 'Choose date and time' : when.toString()),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: when == null
                ? null
                : () async {
                    try {
                      await api.call('bookings', method: 'POST', data: {
                        'funeral_service_id': service['id'],
                        'requested_at': when!.toIso8601String(),
                        'location': location.text,
                        'contact_name': contact.text,
                        'contact_phone': phone.text,
                        'notes': notes.text
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Booking request sent')));
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx)
                            .showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _customizeDialog(BuildContext context, Map casket) async {
  final notes = TextEditingController();
  final rawOptions = casket['options'] is Map
      ? Map<String, dynamic>.from(casket['options'])
      : <String, dynamic>{};
  final selected = <String, String>{};
  for (final entry in rawOptions.entries) {
    final values = List<String>.from(entry.value as List);
    if (values.isNotEmpty) selected[entry.key] = values.first;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
              title: Text('Customize ${casket['name']}'),
              content: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Estimated base price: ${formatMoney(casket['price'])} VND. Staff will confirm the final price.'),
                  ...rawOptions.entries.map((entry) {
                    final values = List<String>.from(entry.value as List);
                    return DropdownButtonFormField<String>(
                      initialValue: selected[entry.key],
                      decoration: InputDecoration(labelText: entry.key),
                      items: values
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          set(() => selected[entry.key] = value);
                        }
                      },
                    );
                  }),
                  TextField(
                      controller: notes,
                      decoration: const InputDecoration(
                          labelText: 'Additional requests')),
                ],
              )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      try {
                        await api.call('customization-requests',
                            method: 'POST',
                            data: {
                              'casket_id': casket['id'],
                              'configuration': selected,
                              'notes': notes.text
                            });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Request sent for staff confirmation')));
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx)
                              .showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    child: const Text('Request quote')),
              ],
            )),
  );
}

Future<void> _orderDialog(BuildContext context, Map casket) async {
  final address = TextEditingController(), phone = TextEditingController();
  await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
              title: Text('Order ${casket['name']}'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Estimated price: ${formatMoney(casket['price'])} VND'),
                TextField(
                    controller: address,
                    decoration:
                        const InputDecoration(labelText: 'Delivery address')),
                TextField(
                    controller: phone,
                    decoration:
                        const InputDecoration(labelText: 'Contact phone'),
                    keyboardType: TextInputType.phone)
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      try {
                        await api.call('orders', method: 'POST', data: {
                          'casket_id': casket['id'],
                          'quantity': 1,
                          'delivery_address': address.text,
                          'contact_phone': phone.text
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order submitted')));
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx)
                              .showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    child: const Text('Submit order'))
              ]));
}
