import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/uzbekistan_regions.dart';
import '../providers/region_selection_provider.dart';
import 'region_picker_sheet.dart';

/// Two side-by-side buttons that open pickers for viloyat/tuman. Each shows
/// the currently selected name; selecting a tuman updates
/// [regionSelectionProvider], which the prayer-times providers read to
/// compute today's table.
class LocationSelectorButtons extends ConsumerWidget {
  const LocationSelectorButtons({super.key});

  Future<void> _pickRegion(BuildContext context, WidgetRef ref) async {
    final selection = ref.read(regionSelectionProvider);
    final picked = await showRegionPickerSheet(
      context,
      title: 'Viloyatni tanlang',
      items: [for (final r in uzbekistanRegions) r.name],
      selected: selection.regionName,
    );
    if (picked != null) {
      await ref.read(regionSelectionProvider.notifier).setRegion(picked);
    }
  }

  Future<void> _pickDistrict(BuildContext context, WidgetRef ref) async {
    final selection = ref.read(regionSelectionProvider);
    final districts = findRegion(selection.regionName)?.districts ?? const [];
    final picked = await showRegionPickerSheet(
      context,
      title: 'Tumanni tanlang',
      items: [for (final d in districts) d.name],
      selected: selection.districtName,
    );
    if (picked != null) {
      await ref.read(regionSelectionProvider.notifier).setDistrict(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(regionSelectionProvider);
    return Row(
      children: [
        Expanded(
          child: _SelectorButton(
            placeholder: 'Viloyat tanlang',
            value: selection.regionName,
            valueColor: const Color(0xFF4CAF17),
            onTap: () => _pickRegion(context, ref),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SelectorButton(
            placeholder: 'Tuman tanlang',
            value: districtLabel(selection.districtName),
            onTap: () => _pickDistrict(context, ref),
          ),
        ),
      ],
    );
  }
}

class _SelectorButton extends StatelessWidget {
  const _SelectorButton({
    required this.placeholder,
    required this.value,
    required this.onTap,
    this.valueColor,
  });

  final String placeholder;
  final String? value;
  final Color? valueColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasValue = value != null && value!.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                hasValue ? value! : placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                  color: hasValue
                      ? (valueColor ?? scheme.onSurface)
                      : scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}
