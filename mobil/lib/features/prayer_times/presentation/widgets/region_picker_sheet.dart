import 'package:flutter/material.dart';

/// Opens a modal sheet listing [items], highlighting [selected]; resolves
/// with the tapped item, or null if dismissed without a selection.
Future<String?> showRegionPickerSheet(
  BuildContext context, {
  required String title,
  required List<String> items,
  required String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _RegionPickerSheet(title: title, items: items, selected: selected),
  );
}

class _RegionPickerSheet extends StatelessWidget {
  const _RegionPickerSheet({required this.title, required this.items, required this.selected});

  final String title;
  final List<String> items;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final name = items[index];
                  final isSelected = name == selected;
                  return ListTile(
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF396E0D) : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF396E0D))
                        : null,
                    onTap: () => Navigator.of(context).pop(name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
