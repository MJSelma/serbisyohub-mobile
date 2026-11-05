import 'package:flutter/material.dart';

class QuoteDialog extends StatefulWidget {
  const QuoteDialog({super.key});

  @override
  State<QuoteDialog> createState() => _QuoteDialogState();
}

class _QuoteDialogState extends State<QuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  String _price = '';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    Navigator.of(context).pop(_price);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send final quotation'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Final price (PHP)',
            prefixText: '₱ ',
          ),
          validator: (input) {
            final value = input?.trim() ?? '';
            final amount = double.tryParse(value);
            if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value) ||
                amount == null ||
                !amount.isFinite ||
                amount < 1) {
              return 'Enter at least ₱1 (up to two decimal places).';
            }
            return null;
          },
          onSaved: (value) {
            _price = value?.trim() ?? '';
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Send quote'),
        ),
      ],
    );
  }
}
