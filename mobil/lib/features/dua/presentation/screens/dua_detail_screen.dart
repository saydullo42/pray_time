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
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          if (dua.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  dua.imageUrl!,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                dua.arabicText,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 28,
                  height: 2.0,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dua.translation.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      children: [
                        const TextSpan(
                          text: 'Ma\'nosi: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: dua.translation),
                      ],
                    ),
                  ),
                ],
                if (dua.source != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Manba: ${dua.source}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
