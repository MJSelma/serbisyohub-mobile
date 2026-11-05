import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_icons.dart';
import '../../core/utils/show_message.dart';
import '../../widgets/page_title.dart';
import '../../widgets/info_panel.dart';
import '../auth/auth_page.dart';
import '../bookings/booking_request_page.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({
    super.key,
    required this.session,
    required this.service,
  });
  final AppSession session;
  final Map<String, dynamic> service;
  @override
  Widget build(BuildContext context) {
    final provider = obj(obj(service['provider'])['provider_profile']);
    final category = obj(service['category']);
    return Scaffold(
      appBar: AppBar(title: const Text('Service details')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: FilledButton.icon(
            onPressed: () {
              if (!session.loggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AuthPage(session: session)),
                );
              } else if (session.provider) {
                showMessage(
                  context,
                  'Use a customer account to request services.',
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookingRequestPage(session: session, service: service),
                  ),
                );
              }
            },
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Request a booking'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 185,
            decoration: BoxDecoration(
              color: const Color(0xFFDCF2E5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(iconFor('${category['icon']}'), size: 86, color: green),
          ),
          const SizedBox(height: 22),
          Text(
            '${category['name'] ?? 'Service'}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: green),
          ),
          const SizedBox(height: 8),
          PageTitle('${service['title']}', subtitle: '${service['city']}'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${provider['display_name'] ?? 'Verified provider'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Starting at ${pesos(service['starting_price'])}',
            style: const TextStyle(
              color: green,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Typical booking deposit: ${service['deposit_percent']}% after final quotation',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 22),
          const Text(
            'About this service',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            '${service['description']}',
            style: const TextStyle(height: 1.6),
          ),
          const SizedBox(height: 17),
          const InfoPanel(
            icon: Icons.info_outline,
            text:
                'The provider will send a final quote. You pay the deposit only after accepting it. The balance is paid directly after the service.',
          ),
        ],
      ),
    );
  }
}
