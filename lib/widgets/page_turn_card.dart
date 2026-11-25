/// 首页点击卡片时播放的便签本翻页动效。
///
/// 技术说明（这是动画章节尚未学习的最小例外）：
///   1. AnimationController：在给定时长（500ms）内从 0 线性驱动到 1。
///   2. AnimatedBuilder：每帧重建 Transform，把 0..1 的值映射到 0..π/2 的绕 Y 轴旋转角度。
///   3. Matrix4.identity()
///        ..setEntry(3, 2, 0.001)   // 透视：让远处看起来更小（z 方向的缩放系数）
///        ..rotateY(angle)          // 绕 Y 轴旋转，产生"沿左侧翻起"的立体感
///   4. 同时叠加一个 Alignment.center 下的 scale 变换（从 1.0 → 1.2），
///      以及颜色从初始色淡化为目标背景色，模拟翻过去再放大全屏的感觉。
///   5. 动画结束后通过 onDone 回调让调用方执行真正的 Navigator.push。
///
/// 总时长 500ms，期间不阻塞 UI。
library;

import 'package:flutter/material.dart';

class PageTurnCard extends StatefulWidget {
  final Widget child;

  /// 动画完成时回调，由调用方在里面执行 Navigator.push。
  final VoidCallback onDone;

  const PageTurnCard({
    super.key,
    required this.child,
    required this.onDone,
  });

  @override
  State<PageTurnCard> createState() => PageTurnCardState();
}

// 需要被外部 GlobalKey 引用，因此保持公开（不再是私有）。
class PageTurnCardState extends State<PageTurnCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 500ms：题目要求 400–600ms。
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 外部点击时调用，启动一次翻页。
  void forward() {
    _ctrl.forward(from: 0).whenComplete(widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder 每帧重建 Transform；animation 的 value 0..1 由 _ctrl 驱动。
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // 0 → 1
        // 绕 Y 轴旋转：0 → π/2，看起来就是卡片沿左侧翻起。
        final angle = t * 1.57079632679; // π/2
        // 缩放：翻页同时轻微放大，模拟"展开成全屏"。
        final scale = 1.0 + t * 0.2; // 1.0 → 1.2
        return Transform(
          // Matrix4 设置透视 + Y 轴旋转。
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Opacity(
              opacity: 1.0 - t * 0.3, // 最后稍微淡化，视觉过渡更柔和
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
