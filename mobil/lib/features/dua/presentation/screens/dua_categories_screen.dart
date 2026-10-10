import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/dua_provider.dart';

class DuaCategoriesScreen extends ConsumerWidget {
  const DuaCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Duolar')),
      body: categoriesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(duaCategoriesProvider),
        ),
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(category.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '${RouteNames.duaListByCategory}/${category.id}',
                  extra: category.name,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
