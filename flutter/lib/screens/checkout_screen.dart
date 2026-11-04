import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _address = TextEditingController();
  bool _express = false;
  // Status resolver so the message re-localizes when the language toggles.
  String Function(SampleStrings)? _status;

  String get _shipping => _express ? '\$12.00' : '\$0.00';
  String get _total => _express ? '\$101.99' : '\$89.99';

  void _place() {
    final addr = _address.text.trim();
    setState(() => _status = addr.length >= 8
        ? (s) => s.checkoutOrderPlaced(addr)
        : (s) => s.checkoutFailure);
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.checkoutTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey(TestTags.checkoutAddress),
          controller: _address,
          decoration:
              InputDecoration(labelText: strings.checkoutShippingAddress),
          onChanged: (_) => setState(() {}),
        ),
        if (_address.text.isNotEmpty)
          Text(strings.checkoutAddressTyped(_address.text),
              key: const ValueKey(TestTags.checkoutAddressPreview)),
        SwitchListTile(
          key: const ValueKey(TestTags.checkoutDelivery),
          title: Text(strings.checkoutExpressDelivery),
          value: _express,
          onChanged: (v) => setState(() => _express = v),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.checkoutOrderSummary,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(strings.checkoutProduct),
                Text(strings.checkoutSubtotal('\$89.99')),
                Text(strings.checkoutShipping(_shipping)),
                Text(strings.checkoutTotal(_total)),
                const SizedBox(height: 8),
                Text(strings.checkoutPayment('Visa •••• 4242'),
                    key: const ValueKey(TestTags.checkoutPayment)),
              ],
            ),
          ),
        ),
        FilledButton(
          key: const ValueKey(TestTags.checkoutPlaceOrder),
          onPressed: _place,
          child: Text(strings.checkoutPlaceOrder),
        ),
        const SizedBox(height: 12),
        Text(_status?.call(strings) ?? '',
            key: const ValueKey(TestTags.checkoutStatus)),
      ],
    );
  }
}
