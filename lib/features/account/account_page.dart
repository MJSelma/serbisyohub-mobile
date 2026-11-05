import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/page_title.dart';
import '../../widgets/status_tag.dart';
import '../../widgets/info_panel.dart';
import '../auth/auth_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.session});
  final AppSession session;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      const PageTitle('Account', subtitle: 'Manage your SerbisyoHub profile'),
      const SizedBox(height: 25),
      if (session.loggedIn) ...[
        CircleAvatar(
          radius: 33,
          backgroundColor: const Color(0xFFE1F4E9),
          child: Text(
            '${session.user?['name'] ?? 'U'}'.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${session.user?['name']}',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
        ),
        Center(child: Text('${session.user?['email']}')),
        const SizedBox(height: 15),
        Center(child: StatusTag('${session.user?['role']}')),
        const SizedBox(height: 25),
        OutlinedButton.icon(
          onPressed: session.logout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ] else ...[
        const InfoPanel(
          icon: Icons.person_outline,
          text:
              'Create a free customer account to request services or register as a provider to publish listings.',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AuthPage(session: session)),
          ),
          child: const Text('Sign in or register'),
        ),
      ],
      const SizedBox(height: 26),
      const Text(
        'Booking deposits are paid toward the provider’s service. Provider subscriptions are the only marketplace revenue in this model.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
}
