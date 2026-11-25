/// 本地存储层：shared_preferences 读整份 JSON 数组，key 固定为 `essays`。
///
/// 图片统一复制到 getApplicationDocumentsDirectory()/images/ 下，
/// 避免只存 image_picker 返回的临时路径（临时路径可能被系统清理）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../models/essay.dart';

class EssayStore {
  static const String _kKey = 'essays';
  static EssayStore? _instance;

  EssayStore._();

  factory EssayStore() => _instance ??= EssayStore._();

  // ------- JSON 数组完整读写 -------

  Future<List<Essay>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return const [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Essay.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveAll(List<Essay> essays) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(essays.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, raw);
  }

  // ------- 单篇读写 -------

  Future<Essay?> getByDate(String dateKey) async {
    final list = await loadAll();
    for (final e in list) {
      if (e.dateKey == dateKey) return e;
    }
    return null;
  }

  /// 保存或更新某一天的随笔。空白页（无文本、无图片）不写入。
  Future<void> upsert(Essay essay) async {
    final list = await loadAll();
    final i = list.indexWhere((e) => e.dateKey == essay.dateKey);
    if (essay.isEmpty) {
      // 空白页：若已有存档则删除，若原本就没有则忽略。
      if (i >= 0) list.removeAt(i);
    } else {
      if (i >= 0) {
        list[i] = essay;
      } else {
        list.add(essay);
      }
    }
    await _saveAll(list);
  }

  /// 按日期倒序返回全部随笔。
  Future<List<Essay>> loadAllSorted() async {
    final list = await loadAll();
    list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return list;
  }

  // ------- 图片拷贝 -------

  /// 把 image_picker 选出的文件复制到应用文档目录下，返回新的绝对路径。
  Future<String> copyPickedImage(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final imgDir = Directory('${dir.path}/images');
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }
    final now = DateTime.now();
    final name =
        'img_${now.millisecondsSinceEpoch}_${now.microsecond}.${file.name.split('.').last}';
    final target = File('${imgDir.path}/$name');
    await target.writeAsBytes(await file.readAsBytes());
    return target.path;
  }
}
