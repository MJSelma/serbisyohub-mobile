import 'package:flutter/material.dart';
import '../api.dart';
import '../features/explore/explore_page.dart';
import '../features/bookings/bookings_page.dart';
import '../features/provider/provider_page.dart';
import '../features/account/account_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.session});
  final AppSession session;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      ExplorePage(session: widget.session),
      BookingsPage(session: widget.session),
      ProviderPage(session: widget.session),
      AccountPage(session: widget.session),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Provider',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
