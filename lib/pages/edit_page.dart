import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/essay.dart';
import '../storage/essay_store.dart';
import '../theme/app_theme.dart';
import '../utils/essay_utils.dart';
import '../widgets/icon_tap.dart';

/// P2 编辑页（手账内页）：左侧三个装订孔，底部提示 / 页码 / 字数，退出即保存。
class EditPage extends StatefulWidget {
  /// 目标日期，格式 yyyy-MM-dd。
  final String dateKey;

  const EditPage({super.key, required this.dateKey});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final EssayStore _store = EssayStore();

  List<String> _images = const [];
  bool _loaded = false;
  int _pageNo = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // 系统返回键 / 侧滑退出时的兜底保存（“退出即保存”）。
    if (_loaded) {
      final essay = Essay(
        dateKey: widget.dateKey,
        text: _textCtrl.text,
        images: _images,
      );
      unawaited(_store.upsert(essay));
    }
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await _store.loadAll();
    final asc = sortByDateAsc(all);
    final index = asc.indexWhere((e) => e.dateKey == widget.dateKey);
    final essay = index >= 0 ? asc[index] : null;
    if (!mounted) return;
    setState(() {
      _textCtrl.text = essay?.text ?? '';
      _images = List<String>.from(essay?.images ?? const <String>[]);
      _pageNo = pageNumberOf(asc, widget.dateKey);
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await _store.upsert(
      Essay(dateKey: widget.dateKey, text: _textCtrl.text, images: _images),
    );
  }

  /// 返回箭头：保存后退出。
  Future<void> _back() async {
    if (_loaded) await _save();
    if (mounted) Navigator.of(context).pop();
  }

  /// 右上角图片按钮：相册选一张 → 复制到文档目录 → 追加到图片块列表。
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final path = await _store.copyPickedImage(picked);
    if (!mounted) return;
    setState(() => _images = [..._images, path]);
  }

  /// 字数口径：除换行符外全部计入。
  int _wordCount() {
    var n = 0;
    for (final c in _textCtrl.text.runes) {
      if (c != 10) n++; // 10 = '\n'
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // 左侧三个装订孔：屏幕 30% / 50% / 70%
              Positioned(left: 14, top: h * 0.3 - 5, child: const _Hole()),
              Positioned(left: 14, top: h * 0.5 - 5, child: const _Hole()),
              Positioned(left: 14, top: h * 0.7 - 5, child: const _Hole()),
              SafeArea(
                child: _loaded
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 24, 24, 0),
                            child: Row(
                              children: [
                                IconTap(
                                  icon: Icons.chevron_left,
                                  semanticLabel: '返回',
                                  iconSize: 20,
                                  onTap: _back,
                                ),
                                const Spacer(),
                                IconTap(
                                  icon: Icons.image_outlined,
                                  semanticLabel: '图片',
                                  iconSize: 24,
                                  onTap: _pickImage,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 16, 24, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  dotDate(widget.dateKey),
                                  style: AppText.date,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  weekdayOf(widget.dateKey),
                                  style: AppText.small,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(40, 24, 40, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _textCtrl,
                                    minLines: 3,
                                    maxLines: null,
                                    textAlignVertical: TextAlignVertical.top,
                                    keyboardType: TextInputType.multiline,
                                    style: AppText.body.copyWith(height: 1.8),
                                    cursorColor: AppColors.ink,
                                    decoration: const InputDecoration(
                                      hintText: '记录今天的点滴…',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.muted,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  ..._images.map(
                                    (path) => Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _ImageBlock(path: path),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 0, 24, 24),
                            child: SizedBox(
                              height: 48,
                              child: Stack(
                                children: [
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('退出即保存', style: AppText.small),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '第 $_pageNo 页',
                                      style: AppText.small,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '字数：${_wordCount()}字',
                                      style: AppText.small,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 左侧装订孔：d=10 的圆，纸孔填充 + 1px 青墨 20% 边。
class _Hole extends StatelessWidget {
  const _Hole();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.hole,
        border: Border.all(color: AppColors.holeEdge),
      ),
    );
  }
}

/// 图片块：200 高，2px 雾霭蓝外框 + 圆角 12，块下“放大 / 缩小”。
class _ImageBlock extends StatefulWidget {
  final String path;

  const _ImageBlock({required this.path});

  @override
  State<_ImageBlock> createState() => _ImageBlockState();
}

class _ImageBlockState extends State<_ImageBlock> {
  final TransformationController _tc = TransformationController();
  static const double _min = 1.0;
  static const double _max = 3.0;
  static const double _step = 0.25;

  void _zoom(double delta) {
    final cur = _tc.value.storage[0];
    final next = (cur + delta).clamp(_min, _max).toDouble();
    _tc.value = Matrix4.diagonal3Values(next, next, 1);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.sky, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InteractiveViewer(
                transformationController: _tc,
                minScale: _min,
                maxScale: _max,
                clipBehavior: Clip.hardEdge,
                child: Center(
                  child: Image.file(File(widget.path), fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ZoomText(label: '放大', onTap: () => _zoom(_step)),
            const SizedBox(width: 16),
            _ZoomText(label: '缩小', onTap: () => _zoom(-_step)),
          ],
        ),
      ],
    );
  }
}

class _ZoomText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ZoomText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.accent),
      ),
    );
  }
}
