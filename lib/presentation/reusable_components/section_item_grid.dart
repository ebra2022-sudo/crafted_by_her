import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'product_card.dart';

Widget sectionItemGrid({
  required String title,
  required List<dynamic> items,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      ResponsiveGrid(
        items: items,
        itemBuilder: itemBuilder,
      ),
    ],
  );
}
