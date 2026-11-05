import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/show_message.dart';
import '../../widgets/page_title.dart';
import '../../widgets/status_tag.dart';
import '../../widgets/info_panel.dart';
import '../../widgets/error_notice.dart';
import '../auth/auth_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key, required this.session});
  final AppSession session;
  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<Map<String, dynamic>> bookings = [];
  bool busy = false;
  String? error;
  bool lastLoggedIn = false;
  @override
  void initState() {
    super.initState();
    lastLoggedIn = widget.session.loggedIn;
    widget.session.addListener(onSessionChange);
    load();
  }

  void onSessionChange() {
    if (lastLoggedIn == widget.session.loggedIn) return;
    lastLoggedIn = widget.session.loggedIn;
    if (lastLoggedIn) {
      load();
    } else {
      setState(() => bookings = []);
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(onSessionChange);
    super.dispose();
  }

  Future<void> load() async {
    if (!widget.session.loggedIn) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = obj(await widget.session.api.request('/bookings'));
      if (mounted) setState(() => bookings = listOf(result['data']));
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> accept(Map<String, dynamic> booking) async {
    try {
      await widget.session.api.request(
        '/bookings/${booking['id']}/accept-quote',
        method: 'POST',
      );
      if (mounted)
        showMessage(
          context,
          'Quote accepted. A verified deposit payment is needed to confirm your booking.',
        );
      await load();
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.session.loggedIn)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_note_outlined, size: 52, color: green),
              const SizedBox(height: 12),
              const Text('Sign in to view bookings.'),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthPage(session: widget.session),
                  ),
                ),
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      );
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PageTitle(
            'My bookings',
            subtitle: 'Track your service requests',
          ),
          const SizedBox(height: 18),
          if (busy) const Center(child: CircularProgressIndicator()),
          if (error != null) ErrorNotice(error!),
          if (!busy && bookings.isEmpty)
            const Text('You have no bookings yet.'),
          ...bookings.map(
            (b) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${obj(b['service'])['title'] ?? 'Service'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 9),
                    StatusTag('${b['status']}'),
                    const SizedBox(height: 9),
                    Text(
                      'Schedule: ${('${b['scheduled_at']}').replaceAll('T', ' ').substring(0, 16)}',
                    ),
                    if (b['quoted_price'] != null) ...[
                      const SizedBox(height: 8),
                      Text('Agreed price: ${pesos(b['quoted_price'])}'),
                      Text(
                        'Deposit: ${pesos(b['deposit_amount'])} (${b['deposit_percent']}%)',
                      ),
                    ],
                    if (b['status'] == 'awaiting_customer_acceptance' &&
                        !widget.session.provider) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => accept(b),
                        child: const Text('Accept quotation'),
                      ),
                    ],
                    if (b['status'] == 'awaiting_deposit')
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: InfoPanel(
                          icon: Icons.info_outline,
                          text:
                              'Deposit processing is not yet connected. This booking is NOT confirmed.',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
