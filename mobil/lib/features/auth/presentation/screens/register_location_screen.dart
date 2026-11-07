import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/uzbekistan_regions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../prayer_times/presentation/providers/region_selection_provider.dart';
import '../../../prayer_times/presentation/widgets/region_picker_sheet.dart';

/// Shown once, right after an account is created: the person picks the
/// viloyat and tuman, which are then saved on the account.
class RegisterLocationScreen extends ConsumerStatefulWidget {
  const RegisterLocationScreen({super.key});

  @override
  ConsumerState<RegisterLocationScreen> createState() =>
      _RegisterLocationScreenState();
}

class _RegisterLocationScreenState
    extends ConsumerState<RegisterLocationScreen> {
  String? _region;
  String? _district;
  bool _saving = false;

  Future<void> _pickRegion() async {
    final picked = await showRegionPickerSheet(
      context,
      title: 'Viloyatni tanlang',
      items: sortedAlphabetically([for (final r in uzbekistanRegions) r.name]),
      selected: _region,
    );
    if (picked == null || picked == _region) return;
    setState(() {
      _region = picked;
      _district = null;
    });
  }

  Future<void> _pickDistrict() async {
    final region = _region;
    if (region == null) return;
    final districts = findRegion(region)?.districts ?? const [];
    final picked = await showRegionPickerSheet(
      context,
      title: 'Tumanni tanlang',
      items: sortedAlphabetically([for (final d in districts) d.name]),
      selected: _district,
    );
    if (picked != null) setState(() => _district = picked);
  }

  Future<void> _save() async {
    final region = _region;
    final district = _district;
    if (region == null || district == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(regionSelectionProvider.notifier)
          .setSelection(region, district);
      if (mounted) context.go(RouteNames.home);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text("Saqlab bo'lmadi. Qayta urinib ko'ring."),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      // The choice is part of registering: there is no way back from here.
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Hududingiz'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Viloyat va tumaningizni tanlang',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Namoz vaqtlari shu hudud bo'yicha ko'rsatiladi.",
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _ChoiceButton(
                  label: _region ?? 'Viloyatni tanlang',
                  chosen: _region != null,
                  onPressed: _saving ? null : _pickRegion,
                ),
                const SizedBox(height: 12),
                _ChoiceButton(
                  label: _district ?? 'Tumanni tanlang',
                  chosen: _district != null,
                  onPressed: (_saving || _region == null)
                      ? null
                      : _pickDistrict,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Davom etish',
                  isLoading: _saving,
                  backgroundColor: const Color(0xFF396E0D),
                  foregroundColor: Colors.black,
                  onPressed: (_region != null && _district != null)
                      ? _save
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A wide outlined button that shows the current choice (or a prompt) and a
/// down arrow.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.chosen,
    required this.onPressed,
  });

  final String label;
  final bool chosen;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: chosen ? const Color(0xFF4CAF17) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
