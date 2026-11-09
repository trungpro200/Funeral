import 'package:flutter/material.dart';
import 'catalog_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'staff_pages.dart';

class HomePage extends StatefulWidget {
  final Map user;
  final VoidCallback onSignOut;
  const HomePage({super.key, required this.user, required this.onSignOut});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final staffTabs = ['Bookings', 'Orders', 'Custom', 'Services', 'Caskets'];
  bool get staff => ['staff', 'admin'].contains(widget.user['role']);
  @override
  Widget build(BuildContext context) {
    final titles = staff
        ? staffTabs
        : ['Services', 'Caskets', 'Orders', 'Custom', 'Profile'];
    final pages = staff
        ? [
            const StaffBookingsPage(),
            const StaffOrdersPage(),
            const StaffCustomizationsPage(),
            const ManageCatalogPage(type: 'services'),
            const ManageCatalogPage(type: 'caskets')
          ]
        : [
            const CatalogPage(type: 'services'),
            const CatalogPage(type: 'caskets'),
            const OrdersPage(),
            const RequestListPage(type: 'customization-requests'),
            ProfilePage(user: widget.user, onSignOut: widget.onSignOut)
          ];
    return Scaffold(
        appBar: AppBar(title: Text(titles[tab]), actions: [
          if (staff)
            IconButton(
                onPressed: widget.onSignOut, icon: const Icon(Icons.logout))
        ]),
        body: pages[tab],
        bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: titles
                .map((t) =>
                    NavigationDestination(icon: Icon(_icon(t)), label: t))
                .toList()));
  }

  IconData _icon(String t) => switch (t) {
        'Services' => Icons.spa_outlined,
        'Caskets' => Icons.inventory_2_outlined,
        'Bookings' => Icons.event_note,
        'Orders' => Icons.shopping_bag_outlined,
        'Custom' => Icons.tune,
        _ => Icons.person_outline
      };
}
