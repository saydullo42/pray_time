import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/dua_model.dart';
import '../providers/dua_provider.dart';

class DuaListScreen extends ConsumerWidget {
  const DuaListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasAsync = ref.watch(duasByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: duasAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(duasByCategoryProvider(categoryId)),
        ),
        data: (duas) {
          final inline =
              ref
                  .watch(duaCategoriesProvider)
                  .valueOrNull
                  ?.any((c) => c.id == categoryId && c.inlineImages) ??
              false;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: duas.length,
            itemBuilder: (context, index) {
              final dua = duas[index];
              if (inline) {
                return _InlineDua(
                  dua: dua,
                  showDivider: dua.title.isNotEmpty || dua.imageUrl == null,
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: ListTile(
                    title: Text(dua.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(RouteNames.duaDetail, extra: dua),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// A dua shown directly in the category list: heading, picture, meaning, and
/// a divider underneath, instead of a tile that opens a detail page.
class _InlineDua extends StatelessWidget {
  const _InlineDua({required this.dua, required this.showDivider});

  final DuaModel dua;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dua.title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dua.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (dua.imageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  dua.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          if (dua.translation.trim().isNotEmpty) ...[
            if (dua.imageUrl != null) const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  children: [
                    if (dua.imageUrl != null)
                      const TextSpan(
                        text: 'Ma\'nosi: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ..._styledLines(dua.translation),
                  ],
                ),
              ),
            ),
          ],
          if (showDivider) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

/// Splits [text] into lines, rendering any line wrapped in `**...**` as a
/// semi-bold sub-heading and everything else as plain text.
List<InlineSpan> _styledLines(String text) {
  final lines = text.split('\n');
  return [
    for (var i = 0; i < lines.length; i++)
      if (lines[i].startsWith('**') &&
          lines[i].endsWith('**') &&
          lines[i].length > 4)
        TextSpan(
          text:
              lines[i].substring(2, lines[i].length - 2) +
              (i < lines.length - 1 ? '\n' : ''),
          style: const TextStyle(fontWeight: FontWeight.w600),
        )
      else
        TextSpan(text: lines[i] + (i < lines.length - 1 ? '\n' : '')),
  ];
}
