import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/dua_provider.dart';

class DuaListScreen extends ConsumerWidget {
  const DuaListScreen({super.key, required this.categoryId, required this.categoryName});

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
        data: (duas) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: duas.length,
          itemBuilder: (context, index) {
            final dua = duas[index];
            return Card(
              child: ListTile(
                title: Text(dua.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RouteNames.duaDetail, extra: dua),
              ),
            );
          },
        ),
      ),
    );
  }
}
