import 'package:flutter/material.dart';

import '../models/essay.dart';
import '../storage/essay_store.dart';
import '../theme/app_theme.dart';
import '../utils/essay_utils.dart';
import '../widgets/icon_tap.dart';
import 'edit_page.dart';

/// P3 目录页：页码 + 日期 + 首行摘要，今天那一行整行铺柔柠黄。
class DateListPage extends StatefulWidget {
  const DateListPage({super.key});

  @override
  State<DateListPage> createState() => _DateListPageState();
}

class _DateListPageState extends State<DateListPage> {
  final EssayStore _store = EssayStore();

  List<_CatalogRow> _rows = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final all = await _store.loadAll();
    final asc = sortByDateAsc(all);
    final rows = all
        .map(
          (e) => _CatalogRow(
            pageNo: pageNumberOf(asc, e.dateKey),
            essay: e,
          ),
        )
        .toList()
      ..sort((a, b) => b.essay.dateKey.compareTo(a.essay.dateKey));
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loaded = true;
    });
  }

  Future<void> _openDate(String dateKey) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditPage(dateKey: dateKey)),
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconTap(
                        icon: Icons.chevron_left,
                        semanticLabel: '返回',
                        iconSize: 20,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('目录', style: AppText.title),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('共 ${_rows.length} 页', style: AppText.small),
                    ),
                  ),
                  Expanded(
                    child: _rows.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 24),
                            itemCount: _rows.length,
                            itemBuilder: (_, i) => _buildRow(_rows[i]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRow(_CatalogRow row) {
    final isToday = row.essay.dateKey == todayKey();
    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isToday ? AppColors.cream : null,
        borderRadius: isToday ? BorderRadius.circular(16) : null,
        border: isToday
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openDate(row.essay.dateKey),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                row.pageNo.toString().padLeft(2, '0'),
                style: AppText.small,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dotDate(row.essay.dateKey), style: AppText.body),
                  const SizedBox(height: 2),
                  Text(
                    summaryOf(row.essay),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: AppColors.emptyIcon,
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有记录哦，写下第一片点滴吧',
              style: TextStyle(fontSize: 16, color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () => _openDate(todayKey()),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.accent,
                  minimumSize: const Size(0, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '去写第一篇',
                  style: TextStyle(fontSize: 16, color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogRow {
  final int pageNo;
  final Essay essay;

  const _CatalogRow({required this.pageNo, required this.essay});
}
