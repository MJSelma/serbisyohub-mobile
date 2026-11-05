import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/show_message.dart';
import '../../widgets/page_title.dart';
import '../../widgets/info_panel.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key, required this.session});
  final AppSession session;
  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final title = TextEditingController(),
      description = TextEditingController(),
      city = TextEditingController(),
      price = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  int? categoryId;
  int deposit = 10;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final c = listOf(await widget.session.api.request('/categories'));
      if (mounted)
        setState(() {
          categories = c;
          if (c.isNotEmpty) categoryId = c.first['id'] as int;
        });
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    city.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      await widget.session.api.request(
        '/provider/services',
        method: 'POST',
        body: {
          'title': title.text.trim(),
          'description': description.text.trim(),
          'city': city.text.trim(),
          'category_id': categoryId,
          'starting_price': price.text.trim(),
          'deposit_percent': deposit,
        },
      );
      if (mounted) {
        showMessage(context, 'Service published!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Post a service')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageTitle(
          'New service',
          subtitle: 'Tell customers what you offer',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Service title'),
        ),
        const SizedBox(height: 13),
        DropdownButtonFormField<int>(
          value: categoryId,
          decoration: const InputDecoration(labelText: 'Category'),
          items: categories
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c['id'] as int,
                  child: Text('${c['name']}'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => categoryId = v),
        ),
        const SizedBox(height: 13),
        TextField(
          controller: city,
          decoration: const InputDecoration(labelText: 'City / service area'),
        ),
        const SizedBox(height: 13),
        TextField(
          controller: price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Starting price (PHP)'),
        ),
        const SizedBox(height: 13),
        TextField(
          controller: description,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Description (20+ characters)',
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text('Deposit required'),
            const Spacer(),
            Text(
              '$deposit%',
              style: const TextStyle(fontWeight: FontWeight.bold, color: green),
            ),
          ],
        ),
        Slider(
          value: deposit.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '$deposit%',
          onChanged: (v) => setState(() => deposit = v.round()),
        ),
        const InfoPanel(
          icon: Icons.receipt_long_outlined,
          text:
              'The deposit is calculated on the final quote, not the starting price.',
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: saving ? null : save,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(saving ? 'Publishing...' : 'Publish service'),
          ),
        ),
      ],
    ),
  );
}
