import 'package:flutter/material.dart';

/// Decorative grid of dots the design uses on navy surfaces (membership
/// header, update banner).
class DotGridPattern extends StatelessWidget {
  final int rows;
  final int columns;
  final double dotSize;
  final double spacing;
  final Color color;

  const DotGridPattern({
    super.key,
    this.rows = 5,
    this.columns = 6,
    this.dotSize = 3,
    this.spacing = 10,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rows,
        (row) => Padding(
          padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : spacing),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              columns,
              (column) => Padding(
                padding: EdgeInsets.only(right: column == columns - 1 ? 0 : spacing),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
