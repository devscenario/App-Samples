import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class _Product {
  _Product(this.name, this.price, this.lowStock);
  final String name;
  final String price;
  // Inventory kept as a flag so the label localizes at display time.
  final bool lowStock;

  String inventory(SampleStrings s) =>
      lowStock ? s.gridLowStock : s.gridInStock;
}

final _products = List.generate(18, (i) {
  return _Product(
    'Product ${i + 1}',
    '\$${(19.99 + i * 3).toStringAsFixed(2)}',
    i % 4 == 0,
  );
});

class GridScreen extends StatefulWidget {
  const GridScreen({super.key});
  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  _Product? _selected;

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return Column(
      children: [
        if (_selected != null)
          Card(
            key: const ValueKey(TestTags.gridDetail),
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.gridProductDetails,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(strings.gridSelected(_selected!.name)),
                  Text(strings.gridPrice(_selected!.price)),
                  Text(strings.gridInventory(_selected!.inventory(strings))),
                ],
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            key: const ValueKey(TestTags.gridContainer),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _products.length,
            itemBuilder: (context, i) {
              final p = _products[i];
              return Card(
                child: InkWell(
                  onTap: () => setState(() => _selected = p),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(p.price),
                        Text(p.inventory(strings)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
