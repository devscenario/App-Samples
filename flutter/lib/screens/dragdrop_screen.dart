import 'package:flutter/material.dart';

import '../sample_locale.dart';
import '../sample_strings.dart';
import '../test_tags.dart';

class DragDropScreen extends StatefulWidget {
  const DragDropScreen({super.key});
  @override
  State<DragDropScreen> createState() => _DragDropScreenState();
}

class _DragDropScreenState extends State<DragDropScreen> {
  // Status resolver so the message re-localizes when the language toggles.
  String Function(SampleStrings) _status = (s) => s.dragStatusNone;
  bool _hovering = false;
  // Reorderable rows kept as stable keys; labels localize at display time.
  final List<String> _rows = ['one', 'two', 'three'];

  void _set(String Function(SampleStrings) resolver) =>
      setState(() => _status = resolver);

  String _rowLabel(SampleStrings s, String key) {
    switch (key) {
      case 'two':
        return s.dragRowTwo;
      case 'three':
        return s.dragRowThree;
      default:
        return s.dragRowOne;
    }
  }

  // Source chips carry data names (untranslated identifiers, like the CMP
  // sample). The drag status interpolates the same value verbatim.
  Widget _chip(String name, String tag) {
    return Draggable<String>(
      data: name,
      onDragStarted: () => _set((s) => s.dragDragging(name)),
      onDraggableCanceled: (_, _) => _set((s) => s.dragCancelled(name)),
      feedback: Material(
        color: Colors.transparent,
        child: Chip(label: Text(name), backgroundColor: Colors.indigo.shade100),
      ),
      childWhenDragging: Chip(label: Text(name), backgroundColor: Colors.grey.shade300),
      child: Chip(key: ValueKey(tag), label: Text(name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = SampleLocale.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(strings.dragTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(strings.dragIntro),
        const SizedBox(height: 12),
        Text(strings.dragStatus(_status(strings)),
            key: const ValueKey(TestTags.dragStatus)),
        const SizedBox(height: 16),
        Text(strings.dragSources,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            _chip('Alpha', TestTags.dragItemAlpha),
            _chip('Beta', TestTags.dragItemBeta),
            _chip('Gamma', TestTags.dragItemGamma),
          ],
        ),
        const SizedBox(height: 16),
        DragTarget<String>(
          onWillAcceptWithDetails: (_) {
            setState(() => _hovering = true);
            return true;
          },
          onLeave: (_) => setState(() => _hovering = false),
          onAcceptWithDetails: (d) {
            setState(() => _hovering = false);
            _set((s) => s.dragDroppedInZone(d.data));
          },
          builder: (context, candidate, rejected) => Container(
            key: const ValueKey(TestTags.dragDropTarget),
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: _hovering ? Colors.indigo : Colors.grey,
                width: _hovering ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  candidate.isNotEmpty
                      ? strings.dragDropHere(candidate.first!)
                      : strings.dragDropZone,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (candidate.isEmpty)
                  Text(strings.dragDropHint,
                      style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(strings.dragReorderable,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(strings.dragReorderHint),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderStart: (i) {
            final key = _rows[i];
            _set((s) => s.dragPickedUp(_rowLabel(s, key)));
          },
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              final moved = _rows.removeAt(oldIndex);
              _rows.insert(newIndex, moved);
              _status = newIndex < oldIndex
                  ? (s) => s.dragMovedUp(_rowLabel(s, moved))
                  : (s) => s.dragMovedDown(_rowLabel(s, moved));
            });
          },
          children: [
            for (var i = 0; i < _rows.length; i++)
              ListTile(
                key: ValueKey('${TestTags.dragReorderItemPrefix}$i'),
                leading: const Icon(Icons.drag_handle),
                title: Text(_rowLabel(strings, _rows[i])),
              ),
          ],
        ),
      ],
    );
  }
}
