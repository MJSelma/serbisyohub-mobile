import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/utils/show_message.dart';
import '../../widgets/page_title.dart';
import '../../widgets/info_panel.dart';

class BookingRequestPage extends StatefulWidget {
  const BookingRequestPage({
    super.key,
    required this.session,
    required this.service,
  });
  final AppSession session;
  final Map<String, dynamic> service;
  @override
  State<BookingRequestPage> createState() => _BookingRequestPageState();
}

class _BookingRequestPageState extends State<BookingRequestPage> {
  final address = TextEditingController(), notes = TextEditingController();
  DateTime? scheduled;
  bool saving = false;
  @override
  void dispose() {
    address.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted) return;
    if (time != null)
      setState(
        () => scheduled = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
  }

  Future<void> submit() async {
    if (scheduled == null || address.text.trim().isEmpty) {
      showMessage(context, 'Select a schedule and enter the service address.');
      return;
    }
    setState(() => saving = true);
    try {
      await widget.session.api.request(
        '/bookings',
        method: 'POST',
        body: {
          'service_id': widget.service['id'],
          'scheduled_at': scheduled!.toUtc().toIso8601String(),
          'service_address': address.text.trim(),
          'notes': notes.text.trim(),
        },
      );
      if (!mounted) return;
      showMessage(
        context,
        'Request sent! The provider will review and quote your service.',
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Request service')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PageTitle('Book a service', subtitle: '${widget.service['title']}'),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: pickDate,
          icon: const Icon(Icons.calendar_month),
          label: Text(
            scheduled == null
                ? 'Select preferred date and time'
                : scheduled.toString().substring(0, 16),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: address,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Service address'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: notes,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Describe the job (optional)',
          ),
        ),
        const SizedBox(height: 18),
        const InfoPanel(
          icon: Icons.lock_outline,
          text:
              'No payment is required to request a booking. A quotation and deposit amount will be shown for your approval.',
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: saving ? null : submit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(saving ? 'Sending request...' : 'Send booking request'),
          ),
        ),
      ],
    ),
  );
}
