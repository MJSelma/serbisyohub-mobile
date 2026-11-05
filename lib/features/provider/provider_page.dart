import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/show_message.dart';
import '../../widgets/page_title.dart';
import '../../widgets/status_tag.dart';
import '../../widgets/info_panel.dart';
import '../../widgets/error_notice.dart';
import '../../widgets/metric_tile.dart';
import '../auth/auth_page.dart';
import 'add_service_page.dart';
import 'quote_dialog.dart';

class ProviderPage extends StatefulWidget {
  const ProviderPage({super.key, required this.session});
  final AppSession session;
  @override
  State<ProviderPage> createState() => _ProviderPageState();
}

class _ProviderPageState extends State<ProviderPage> {
  Map<String, dynamic> dashboard = {};
  List<Map<String, dynamic>> services = [], bookings = [];
  bool busy = false;
  String? error;
  bool lastProvider = false;
  @override
  void initState() {
    super.initState();
    lastProvider = widget.session.provider;
    widget.session.addListener(onSessionChange);
    load();
  }

  void onSessionChange() {
    if (lastProvider == widget.session.provider) return;
    lastProvider = widget.session.provider;
    if (lastProvider) {
      load();
    } else {
      setState(() {
        services = [];
        bookings = [];
        dashboard = {};
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(onSessionChange);
    super.dispose();
  }

  Future<void> load() async {
    if (!widget.session.provider) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final results = await Future.wait([
        widget.session.api.request('/provider/dashboard'),
        widget.session.api.request('/provider/services'),
        widget.session.api.request('/bookings'),
      ]);
      if (mounted)
        setState(() {
          dashboard = obj(results[0]);
          services = listOf(results[1]);
          bookings = listOf(obj(results[2])['data']);
        });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> sendQuote(Map<String, dynamic> booking) async {
    final price = await showDialog<String>(
      context: context,
      builder: (_) => const QuoteDialog(),
    );
    if (!mounted || price == null) return;

    try {
      await widget.session.api.request(
        '/provider/bookings/${booking['id']}/quote',
        method: 'POST',
        body: {'quoted_price': price},
      );
      if (mounted) await load();
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    }
  }

  Future<void> advance(Map<String, dynamic> booking, String status) async {
    try {
      await widget.session.api.request(
        '/provider/bookings/${booking['id']}/status',
        method: 'POST',
        body: {'status': status},
      );
      await load();
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.session.provider)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 55, color: green),
              const SizedBox(height: 12),
              const Text(
                'Grow your service business with SerbisyoHub.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthPage(session: widget.session),
                  ),
                ),
                child: const Text('Create a provider account'),
              ),
            ],
          ),
        ),
      );
    final profile = obj(dashboard['profile']);
    final subscription = obj(dashboard['subscription']);
    final approved = profile['verified_at'] != null;
    final canPublish = approved && subscription.isNotEmpty;
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PageTitle(
            'Provider dashboard',
            subtitle: '${profile['display_name'] ?? 'Manage your services'}',
          ),
          const SizedBox(height: 17),
          if (busy) const Center(child: CircularProgressIndicator()),
          if (error != null) ErrorNotice(error!),
          if (!approved)
            const InfoPanel(
              icon: Icons.verified_user_outlined,
              text:
                  'Your provider profile is pending manual verification. Public listings require approval.',
            ),
          if (subscription.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: InfoPanel(
                icon: Icons.workspace_premium_outlined,
                text:
                    'An active provider subscription is required before publishing services. Billing is not yet integrated in this starter.',
              ),
            ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  title: 'My services',
                  value: '${services.length}',
                  icon: Icons.home_repair_service_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(
                  title: 'Requests',
                  value: '${bookings.length}',
                  icon: Icons.event_note_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: canPublish
                ? () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddServicePage(session: widget.session),
                      ),
                    );
                    await load();
                  }
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Post a service'),
          ),
          const SizedBox(height: 25),
          const Text(
            'Incoming bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (!busy && bookings.isEmpty) const Text('No booking requests yet.'),
          ...bookings.map(
            (b) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${obj(b['service'])['title']}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Requested by ${obj(b['customer'])['name'] ?? 'Customer'}',
                    ),
                    const SizedBox(height: 8),
                    StatusTag('${b['status']}'),
                    const SizedBox(height: 7),
                    Text('Address: ${b['service_address']}'),
                    if (b['status'] == 'requested')
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => sendQuote(b),
                          child: const Text('Send quote'),
                        ),
                      ),
                    if (b['status'] == 'confirmed')
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => advance(b, 'in_progress'),
                          child: const Text('Start job'),
                        ),
                      ),
                    if (b['status'] == 'in_progress')
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => advance(b, 'completed'),
                          child: const Text('Mark complete'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'My published services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          ...services.map(
            (s) => ListTile(
              title: Text('${s['title']}'),
              subtitle: Text('${s['city']} · ${pesos(s['starting_price'])}'),
              leading: const Icon(Icons.check_circle_outline, color: green),
            ),
          ),
        ],
      ),
    );
  }
}
