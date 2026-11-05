import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/utils/show_message.dart';
import '../../widgets/page_title.dart';
import '../../widgets/info_panel.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.session});
  final AppSession session;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      providerName = TextEditingController();
  bool register = false, saving = false;
  String role = 'customer', kind = 'individual';
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    providerName.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() => saving = true);
    try {
      await widget.session.authenticate(register ? '/register' : '/login', {
        'email': email.text.trim(),
        'password': password.text,
        if (register) ...{
          'name': name.text.trim(),
          'password_confirmation': password.text,
          'role': role,
          if (role == 'provider') ...{
            'provider_display_name': providerName.text.trim(),
            'provider_kind': kind,
          },
        },
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SerbisyoHub')),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 16),
        PageTitle(
          register ? 'Create an account' : 'Welcome back',
          subtitle: register
              ? 'Discover or promote trusted services'
              : 'Sign in to continue',
        ),
        const SizedBox(height: 25),
        if (register) ...[
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'customer',
                label: Text('Customer'),
                icon: Icon(Icons.person_outline),
              ),
              ButtonSegment(
                value: 'provider',
                label: Text('Provider'),
                icon: Icon(Icons.storefront_outlined),
              ),
            ],
            selected: {role},
            onSelectionChanged: (v) => setState(() => role = v.first),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 13),
          if (role == 'provider') ...[
            TextField(
              controller: providerName,
              decoration: const InputDecoration(
                labelText: 'Service business / professional name',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: kind,
              decoration: const InputDecoration(labelText: 'Provider type'),
              items: const [
                DropdownMenuItem(
                  value: 'individual',
                  child: Text('Individual professional'),
                ),
                DropdownMenuItem(
                  value: 'business',
                  child: Text('Business / company'),
                ),
              ],
              onChanged: (v) => setState(() => kind = v ?? 'individual'),
            ),
            const SizedBox(height: 13),
          ],
        ],
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 13),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 23),
        FilledButton(
          onPressed: saving ? null : submit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              saving
                  ? 'Please wait...'
                  : (register ? 'Create account' : 'Sign in'),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => register = !register),
          child: Text(
            register
                ? 'Already have an account? Sign in'
                : 'No account yet? Register',
          ),
        ),
        if (register && role == 'provider')
          const InfoPanel(
            icon: Icons.verified_user,
            text:
                'Your provider profile must be approved before you can subscribe and post services.',
          ),
      ],
    ),
  );
}
