import 'package:flutter/material.dart';
import '../services/api.dart';
import '../utils/formatters.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> orders = [];
  bool loading = true;
  String? loadError;
  String filter = 'All';

  Future<void> load() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final responses = await Future.wait([
        api.call('bookings'),
        api.call('orders'),
      ]);
      bookings = List<Map<String, dynamic>>.from(responses[0]['data'] ?? []);
      orders = List<Map<String, dynamic>>.from(responses[1]['data'] ?? []);
    } catch (e) {
      loadError = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Date to be confirmed';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year} · $hour:$minute';
  }

  List<Map<String, dynamic>> get visibleRecords {
    final records = <Map<String, dynamic>>[
      if (filter != 'Casket orders')
        ...bookings.map((item) => {'type': 'Service booking', 'item': item}),
      if (filter != 'Service bookings')
        ...orders.map((item) => {'type': 'Casket order', 'item': item}),
    ];
    records.sort((a, b) {
      final aItem = a['item'] as Map<String, dynamic>;
      final bItem = b['item'] as Map<String, dynamic>;
      final aDate = DateTime.tryParse(
              '${aItem['requested_at'] ?? aItem['created_at'] ?? ''}') ??
          DateTime(1970);
      final bDate = DateTime.tryParse(
              '${bItem['requested_at'] ?? bItem['created_at'] ?? ''}') ??
          DateTime(1970);
      return bDate.compareTo(aDate);
    });
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = [
      ...bookings.map((item) => item['status']),
      ...orders.map((item) => item['status']),
    ]
        .where((status) =>
            !['completed', 'cancelled', 'rejected'].contains(status))
        .length;

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text('Your requests',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Keep track of service bookings and casket orders in one place.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Icon(Icons.track_changes_outlined,
                    size: 30, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '$activeCount active ${activeCount == 1 ? 'request' : 'requests'}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        const Text('Pull down to refresh the latest updates.'),
                      ]),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: _RequestCountCard(
                  icon: Icons.event_available_outlined,
                  label: 'Service bookings',
                  count: bookings.length),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RequestCountCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Casket orders',
                  count: orders.length),
            ),
          ]),
          const SizedBox(height: 20),
          Text('Request history',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final option in ['All', 'Service bookings', 'Casket orders'])
              ChoiceChip(
                label: Text(option),
                selected: filter == option,
                onSelected: (_) => setState(() => filter = option),
              ),
          ]),
          const SizedBox(height: 8),
          if (loading && bookings.isEmpty && orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (loadError != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: const Text('Could not load your requests'),
                subtitle: Text(loadError!),
                trailing: IconButton(
                    onPressed: load, icon: const Icon(Icons.refresh)),
              ),
            )
          else if (visibleRecords.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(children: [
                  Icon(
                    filter == 'Service bookings'
                        ? Icons.event_note_outlined
                        : filter == 'Casket orders'
                            ? Icons.shopping_bag_outlined
                            : Icons.inbox_outlined,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    filter == 'All'
                        ? 'Your request history will appear here'
                        : 'No ${filter.toLowerCase()} yet',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Browse Services to request a service or Caskets to place an order.',
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            )
          else
            ...visibleRecords.map(_requestCard),
        ],
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> record) {
    final item = record['item'] as Map<String, dynamic>;
    final isBooking = record['type'] == 'Service booking';
    final title = isBooking
        ? (item['service']?['name'] ?? 'Service booking #${item['id']}')
        : (item['casket']?['name'] ?? 'Casket order #${item['id']}');
    final status = (item['status'] ?? 'pending').toString();
    final details = isBooking
        ? [
            _date(item['requested_at']),
            if (item['proposed_at'] != null)
              'New time proposed: ${_date(item['proposed_at'])}',
            if (item['location'] != null) item['location'].toString(),
          ]
        : [
            'Placed ${_date(item['created_at'])}',
            'Quantity: ${item['quantity'] ?? 1} · ${formatMoney(item['total_estimate'])} VND',
          ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child:
              Icon(isBooking ? Icons.event_note : Icons.inventory_2_outlined),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${record['type']} · ${details.join('\n')}'),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 10, color: Color(0xff548071)),
            const SizedBox(height: 4),
            Text(status, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _RequestCountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const _RequestCountCard(
      {required this.icon, required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text('$count', style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

class RequestListPage extends StatefulWidget {
  final String type;
  const RequestListPage({super.key, required this.type});
  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  List items = [];
  bool loading = true;
  Future<void> load() async {
    try {
      final r = await api.call(widget.type);
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

  @override
  Widget build(BuildContext context) => loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: load,
          child: items.isEmpty
              ? ListView(children: [
                  const SizedBox(height: 180),
                  Center(child: Text('No ${widget.type} yet'))
                ])
              : ListView(
                  children: items
                      .map((e) => Card(
                          child: ListTile(
                              title: Text(e['service']?['name'] ??
                                  e['casket']?['name'] ??
                                  'Request #${e['id']}'),
                              subtitle: Text(
                                  '${e['requested_at'] ?? ''}\nStatus: ${e['status']}${e['proposed_at'] == null ? '' : '\nProposed: ${e['proposed_at']}'}'),
                              isThreeLine: true)))
                      .toList()));
}
