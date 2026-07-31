import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import 'app_icon.dart';

/// The three input shapes every form in this app needs. Each variant
/// configures its own keyboard type / obscuring / digit filtering, so
/// call sites only pick a variant instead of re-wiring those details.
enum AppInputType { text, password, number }

/// Shared form field: a bold label (with an optional trailing action,
/// e.g. "Lupa Password anda?" next to the "Password" label) above a
/// filled, rounded input. Any feature needing a labeled input should use
/// this instead of a bespoke TextFormField, so form styling and behavior
/// stay consistent app-wide.
class AppInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final AppInputType type;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hintText;
  final bool enabled;

  /// Extra text shown at the end of the label row (e.g. a "Forgot
  /// password?" link). Purely a label if [onTrailingTap] is null.
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  const AppInputField({
    super.key,
    required this.label,
    required this.controller,
    this.type = AppInputType.text,
    this.keyboardType,
    this.validator,
    this.hintText,
    this.enabled = true,
    this.trailingText,
    this.onTrailingTap,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late bool _obscureText = widget.type == AppInputType.password;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.type == AppInputType.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  fontSize: 15,
                ),
              ),
            ),
            if (widget.trailingText != null)
              Flexible(
                child: GestureDetector(
                  onTap: widget.onTrailingTap,
                  child: Text(
                    widget.trailingText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.slateBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // White-on-white inputs read as fields thanks to the drop shadow
        // rather than a border, matching the rest of the design.
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.inputShadow,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: isPassword && _obscureText,
            keyboardType: widget.keyboardType ?? _keyboardTypeFor(widget.type),
            inputFormatters: widget.type == AppInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            validator: widget.validator,
            enabled: widget.enabled,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Masukkan ${widget.label} anda',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                      // The shipped eye marks "tap to reveal"; once the
                      // password is visible we switch to the struck-through
                      // Material glyph to signal the opposite action.
                      icon: _obscureText
                          ? const AppIcon(
                              asset: AppIcons.eyePassword,
                              fallback: Icons.visibility_outlined,
                              size: 22,
                            )
                          : const Icon(
                              Icons.visibility_off_outlined,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  TextInputType _keyboardTypeFor(AppInputType type) {
    switch (type) {
      case AppInputType.number:
        return TextInputType.number;
      case AppInputType.password:
        return TextInputType.visiblePassword;
      case AppInputType.text:
        return TextInputType.text;
    }
  }
}
