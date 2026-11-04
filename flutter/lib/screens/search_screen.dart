import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class _Item {
  const _Item(this.name, this.category, this.price);
  final String name;
  final String category;
  final String price;
}

const _catalog = [
  _Item('Wireless Headphones', 'Audio', '\$89.99'),
  _Item('Noise Canceling Headphones', 'Audio', '\$129.99'),
  _Item('USB-C Travel Charger', 'Accessories', '\$24.99'),
  _Item('Fitness Watch', 'Wearables', '\$149.99'),
  _Item('Laptop Backpack', 'Travel', '\$59.99'),
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  bool _searched = false;

  List<_Item> get _results {
    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return _catalog;
    return _catalog
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q))
        .toList();
  }

  String _statusOf(SampleStrings s) {
    final n = _results.length;
    if (_searched && _query.text.trim().isNotEmpty) {
      return s.searchResults(_query.text.trim(), n);
    }
    return s.searchFeatured(n);
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    final results = _results;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.searchTitle,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey(TestTags.searchQuery),
                controller: _query,
                decoration: InputDecoration(labelText: strings.searchField),
                onChanged: (_) => setState(() => _searched = false),
              ),
              if (_query.text.isNotEmpty)
                Text(strings.searchQueryTyped(_query.text),
                    key: const ValueKey(TestTags.searchQueryPreview)),
              const SizedBox(height: 8),
              FilledButton(
                key: const ValueKey(TestTags.searchSubmit),
                onPressed: () => setState(() => _searched = true),
                child: Text(strings.searchRun),
              ),
              const SizedBox(height: 8),
              Text(_statusOf(strings),
                  key: const ValueKey(TestTags.searchStatus)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const ValueKey(TestTags.searchResults),
            itemCount: results.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(results[i].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.searchCategory(results[i].category)),
                  Text(strings.searchPrice(results[i].price)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
