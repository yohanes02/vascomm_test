import 'package:flutter/material.dart';

/// Shared primary action button. Any feature that needs a "main CTA"
/// button should use this instead of a bespoke ElevatedButton, so
/// visual style stays consistent app-wide (DRY).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  /// Pin [icon] to the button's trailing edge with the label centred
  /// (as on "Simpan Profile") instead of sitting beside the label.
  final bool iconAtEnd;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : icon != null && iconAtEnd
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Forces the stack to the button's full width so the
                    // icon can pin to its trailing edge.
                    const SizedBox(width: double.infinity),
                    Text(label),
                    Positioned(right: 0, child: Icon(icon, size: 20)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(icon, size: 18),
                    ],
                  ],
                ),
    );
  }
}
