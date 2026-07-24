import 'package:flutter/material.dart';
import 'package:livecanvas/core/theme/app_spacing.dart';
import 'package:livecanvas/core/widgets/controls/filter_chip.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// Horizontal, single-select row of tag chips (FR-005). The first tag is the
/// backend's virtual "All" (`id: 0`) and is selected by default.
class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    required this.tags,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<Tag> tags;
  final int selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.chipH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: tags.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp2),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final id = tag.id ?? 0;
          return AppFilterChip(
            label: tag.name ?? '',
            selected: id == selectedId,
            onTap: () => onSelected(id),
          );
        },
      ),
    );
  }
}
