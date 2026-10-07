import 'package:flutter/material.dart';
import '../../data/models/dua_model.dart';

class DuaDetailScreen extends StatelessWidget {
  const DuaDetailScreen({super.key, required this.dua});

  final DuaModel dua;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dua.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            dua.arabicText,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          Text(
            'O\'qilishi:',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dua.transliteration,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Text(
            'Ma\'nosi:',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(dua.translation, style: Theme.of(context).textTheme.bodyMedium),
          if (dua.source != null) ...[
            const SizedBox(height: 24),
            Text(
              'Manba: ${dua.source}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
