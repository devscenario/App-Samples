import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class _Order {
  _Order(this.id, this.customer, this.total, this.ready);
  final String id;
  final String customer;
  final String total;
  // Status kept as a flag so the label localizes at display time.
  final bool ready;

  String status(SampleStrings s) =>
      ready ? s.listStatusReady : s.listStatusProcessing;
}

final _customers = ['Guja', 'Giorgi', 'Anzori', 'Luka'];
final _orders = List.generate(24, (i) {
  return _Order(
    'Order #${1001 + i}',
    _customers[i % _customers.length],
    '\$${42 + i * 7}.00',
    i % 3 == 0,
  );
});

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  _Order? _selected;

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return Column(
      children: [
        if (_selected != null)
          Card(
            key: const ValueKey(TestTags.listDetail),
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.listOrderDetails,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(strings.listSelected(_selected!.id)),
                  Text(strings.listCustomer(_selected!.customer)),
                  Text(strings.listTotal(_selected!.total)),
                  Text(strings.listStatus(_selected!.status(strings))),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            key: const ValueKey(TestTags.listContainer),
            itemCount: _orders.length,
            itemBuilder: (context, i) {
              final o = _orders[i];
              return ListTile(
                title: Text(o.id),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.listCustomer(o.customer)),
                    Text(strings.listStatus(o.status(strings))),
                  ],
                ),
                onTap: () => setState(() => _selected = o),
              );
            },
          ),
        ),
      ],
    );
  }
}
