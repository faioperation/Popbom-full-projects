import 'package:flutter/material.dart';

class GiftItem extends StatelessWidget {
  final String label;
  final String emoji;
  final int count;

  const GiftItem({
    required this.label,
    required this.emoji,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 3),
            Text(emoji, style: TextStyle(fontSize: 14)),
          ],
        ),
        SizedBox(height: 4),
        Text(
          "$count",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cs.onBackground,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}