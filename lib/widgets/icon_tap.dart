import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 只画一个线性图标、不加任何彩色底块的点击区域。
///
/// [boxSize] 是实际占位尺寸（默认等于图标尺寸），用于右上角日历那种
/// 24×24 图标 + 40×40 点击区域的情况。
class IconTap extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final double? boxSize;
  final String semanticLabel;

  const IconTap({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.iconSize = 24,
    this.boxSize,
  });

  @override
  Widget build(BuildContext context) {
    final box = boxSize ?? iconSize;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: box,
          height: box,
          child: Center(
            child: Icon(icon, size: iconSize, color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}
