import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Filter button + search field pair used above the product catalogue.
class SearchBarRow extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;

  const SearchBarRow({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.onFilterPressed,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onFilterPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.softShadow,
            ),
            child: const Icon(Icons.tune, color: AppColors.navy, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.softShadow,
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                // The shared input theme draws a filled, outlined box; here
                // the wrapping Container owns the fill/rounding instead.
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                suffixIcon: const Icon(Icons.search, color: AppColors.navy, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
