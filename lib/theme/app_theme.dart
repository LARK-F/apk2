import 'package:flutter/material.dart';

/// 随笔 · 实体手账九色。
///
/// 全 App 只允许出现这九个色值；下面 line / stampBorder 等都是它们的透明度派生，
/// 不构成新的颜色。
class AppColors {
  const AppColors._();

  static const Color paper = Color(0xFFFDF4DE); // 米纸：页面底色
  static const Color cover = Color(0xFFF2B6B6); // 雾桃粉：封面
  static const Color spine = Color(0xFF6A90A6); // 柔靛青：书脊
  static const Color hole = Color(0xFFEFE3C6); // 纸孔
  static const Color cream = Color(0xFFF9D77C); // 柔柠黄：书签 + 目录今天行
  static const Color ink = Color(0xFF2F4147); // 青墨：主文字
  static const Color accent = Color(0xFF4F7285); // 深靛：图标与文字按钮
  static const Color muted = Color(0xFF5F6E75); // 雾灰：辅助文字
  static const Color sky = Color(0xFF8DA6D2); // 雾霭蓝：图片块外框

  // ------- 上表九色的透明度派生 -------
  static const Color line = Color(0x335F6E75); // 雾灰 20%
  static const Color stampBorder = Color(0x4D2F4147); // 青墨 30%
  static const Color holeEdge = Color(0x332F4147); // 青墨 20%
  static const Color emptyIcon = Color(0x665F6E75); // 雾灰 40%
  static const Color shadow = Color(0x1A2F4147); // 青墨 10% = 0x1A2F4147
}

/// 字号四档：28 / 24 / 16 / 12，标题一律 w600。
class AppText {
  const AppText._();

  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle date = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.ink,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.paper,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
    ),
  );
}
