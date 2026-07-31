import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Two-way pill toggle (e.g. "Satuan" / "Paket Pemeriksaan", "Profile
/// Saya" / "Pengaturan") shared across Home and Profile.
class SegmentedToggle extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final ValueChanged<bool> onChanged;

  /// Stretch to the available width. Set `false` to shrink-wrap the labels,
  /// which is how the design shows it on Home and Profile.
  final bool expanded;

  /// Tighter paddings and type — for places where the toggle is secondary
  /// chrome rather than the section's main control.
  final bool dense;

  /// Where the shrink-wrapped pill sits in the space it's given. Ignored
  /// when [expanded] is true.
  final Alignment alignment;

  const SegmentedToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onChanged,
    this.expanded = true,
    this.dense = false,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _wrap(_segment(leftLabel, leftSelected, () => onChanged(true))),
        _wrap(_segment(rightLabel, !leftSelected, () => onChanged(false))),
      ],
    );

    final container = Container(
      padding: EdgeInsets.all(dense ? 4 : 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow,
      ),
      child: row,
    );

    // Align keeps the shrink-wrapped pill where the design puts it instead
    // of letting it stretch across its parent.
    return expanded ? container : Align(alignment: alignment, child: container);
  }

  // Expanded splits the width evenly; Flexible lets the shrink-wrapped
  // variant keep its natural size but still give way (rather than
  // overflowing) when the labels are too long for the screen.
  Widget _wrap(Widget child) =>
      expanded ? Expanded(child: child) : Flexible(child: child);

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: dense ? 8 : 10,
          horizontal: dense ? 14 : 18,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        // Only centre when the segments split the width evenly — a
        // non-null alignment makes the container expand to fill, which
        // would stretch the shrink-wrapped variant to full width.
        alignment: expanded ? Alignment.center : null,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: dense ? 13 : 14,
          ),
        ),
      ),
    );
  }
}
