import 'package:flutter/material.dart';

// This widget adds row/column labels to a 5x5 grid
class GridWithLabels extends StatelessWidget {
  final Widget Function(String position) buildCell;

  const GridWithLabels({super.key, required this.buildCell});

  @override
  Widget build(BuildContext context) {
    const columns = ['1', '2', '3', '4', '5'];
    const rows = ['A', 'B', 'C', 'D', 'E'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // figure out the cell size so everything fits
        const labelSize = 24.0;
        const cellSpacing = 0.0;
        final gridWidth = constraints.maxWidth - labelSize;
        final gridHeight = constraints.maxHeight - labelSize - 8.0;
        final cellWidth = (gridWidth - cellSpacing * 4) / 5;
        final cellHeight = (gridHeight - cellSpacing * 4) / 5;
        final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: labelSize),
                ...columns.map((c) => SizedBox(
                      width: cellSize,
                      child: Center(child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold))),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            ...rows.map((row) {
              return Row(
                children: [
                  SizedBox(width: labelSize, child: Text(row, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ...List.generate(5, (col) {
                    final pos = '$row${col + 1}';
                    return SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: buildCell(pos),
                    );
                  }),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
