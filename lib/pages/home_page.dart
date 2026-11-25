import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../storage/essay_store.dart';
import '../theme/app_theme.dart';
import '../utils/essay_utils.dart';
import '../widgets/icon_tap.dart';
import 'date_list_page.dart';
import 'edit_page.dart';

/// P1 首页：一本合着的手账封面。
///
/// 点击封面：封面绕左侧书脊翻起（480ms，easeInOutCubic），
/// 翻到空白内页后放大铺满屏幕，再进入今天的编辑页。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const double _coverWidth = 327;
  static const double _coverHeight = 460;
  static const double _coverTopGap = 88; // 距状态栏
  static const double _radius = 12;

  /// 翻页总时长，其中前 300ms 旋转、后 180ms 放大铺满。
  static const Duration _flipDuration = Duration(milliseconds: 480);
  static const double _rotateEnd = 300 / 480;

  final EssayStore _store = EssayStore();

  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: _flipDuration,
  );

  bool _flipping = false;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Future<void> _loadCount() async {
    final all = await _store.loadAll();
    if (!mounted) return;
    setState(() => _pageCount = all.length);
  }

  Future<void> _openToday() async {
    if (_flipping) return;
    setState(() => _flipping = true);
    await _flip.forward(from: 0);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditPage(dateKey: todayKey())),
    );
    if (!mounted) return;
    _flip.value = 0;
    setState(() => _flipping = false);
    await _loadCount();
  }

  Future<void> _openCatalog() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DateListPage()),
    );
    if (mounted) await _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final now = DateTime.now();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final coverLeft = (width - _coverWidth) / 2;
          final coverTop = topInset + _coverTopGap;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (!_flipping) ...[
                // 右上角日历入口：只留 24×24 线性图标
                Positioned(
                  top: topInset + 16,
                  right: 16,
                  child: IconTap(
                    icon: Icons.calendar_today_outlined,
                    semanticLabel: '目录',
                    iconSize: 24,
                    boxSize: 40,
                    onTap: _openCatalog,
                  ),
                ),
                Positioned(
                  left: coverLeft,
                  top: coverTop,
                  width: _coverWidth,
                  height: _coverHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _openToday,
                    child: _buildCover(now),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: coverTop + _coverHeight + 24,
                  child: const Center(
                    child: Text('点击封面，翻开今天', style: AppText.small),
                  ),
                ),
              ] else
                _buildFlipOverlay(
                  width: width,
                  height: height,
                  coverLeft: coverLeft,
                  coverTop: coverTop,
                  now: now,
                ),
            ],
          );
        },
      ),
    );
  }

  /// 封面本体：粉封面 + 靛青书脊 + 黄色书签 + 书名 + 日期框 + 共 N 页。
  Widget _buildCover(DateTime now) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 封面底板与阴影
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cover,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
        // 书脊：贴左内缘，只左上左下圆角
        Positioned(
          left: 0,
          top: 0,
          width: 12,
          height: _coverHeight,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.spine,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_radius),
                bottomLeft: Radius.circular(_radius),
              ),
            ),
          ),
        ),
        // 封面右缘外侧两条 1px 竖线：暗示内页叠层
        const Positioned(
          right: -4,
          top: 80,
          width: 1,
          height: 300,
          child: ColoredBox(color: AppColors.line),
        ),
        const Positioned(
          right: -8,
          top: 80,
          width: 1,
          height: 300,
          child: ColoredBox(color: AppColors.line),
        ),
        // 书签丝带
        Positioned(
          top: 0,
          right: 56,
          width: 8,
          height: 88,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ),
        // 书名与年份
        const Positioned(
          left: 44,
          top: 40,
          child: Text('随笔', style: AppText.title),
        ),
        Positioned(
          left: 44,
          top: 82,
          child: Text('${now.year}', style: AppText.small),
        ),
        // 日期标签框
        Positioned(
          left: 36,
          top: 200,
          width: 172,
          height: 64,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.stampBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${now.month}月${now.day}日', style: AppText.date),
                const SizedBox(height: 2),
                Text(weekdayOf(todayKey()), style: AppText.small),
              ],
            ),
          ),
        ),
        // 总页数
        Positioned(
          left: 44,
          bottom: 24,
          child: Text(
            _pageCount == 0 ? '还没有写过' : '共 $_pageCount 页',
            style: AppText.small,
          ),
        ),
      ],
    );
  }

  /// 翻页：绕左侧书脊 rotateY 180°，随后把内页放大铺满全屏。
  Widget _buildFlipOverlay({
    required double width,
    required double height,
    required double coverLeft,
    required double coverTop,
    required DateTime now,
  }) {
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, _) {
        final t = _flip.value;
        final rotateT = Curves.easeInOutCubic.transform(
          (t / _rotateEnd).clamp(0.0, 1.0),
        );
        final expandT = t <= _rotateEnd
            ? 0.0
            : Curves.easeInOutCubic.transform(
                (t - _rotateEnd) / (1 - _rotateEnd),
              );

        final left = lerpDouble(coverLeft, 0, expandT)!;
        final top = lerpDouble(coverTop, 0, expandT)!;
        final w = lerpDouble(_coverWidth, width, expandT)!;
        final h = lerpDouble(_coverHeight, height, expandT)!;
        final radius = lerpDouble(_radius, 0, expandT)!;

        return Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: Transform(
            // 旋转轴落在封面左缘（书脊）上
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(-math.pi * rotateT),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              // 转过 90° 后换成空白内页，避免看到封面背面镜像
              child: rotateT < 0.5
                  ? _buildCover(now)
                  : const ColoredBox(color: AppColors.paper),
            ),
          ),
        );
      },
    );
  }
}
