import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const SectionCard({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}
