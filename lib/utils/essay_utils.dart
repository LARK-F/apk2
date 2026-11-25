import '../models/essay.dart';

const List<String> _weekNames = [
  '星期一',
  '星期二',
  '星期三',
  '星期四',
  '星期五',
  '星期六',
  '星期日',
];

/// 今天的日期 key，格式 yyyy-MM-dd。
String todayKey() {
  final d = DateTime.now();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// yyyy-MM-dd → 星期一 … 星期日。
String weekdayOf(String dateKey) {
  final d = DateTime.tryParse(dateKey);
  if (d == null) return '';
  return _weekNames[d.weekday - 1];
}

/// yyyy-MM-dd → yyyy.MM.dd（内页与目录的显示格式）。
String dotDate(String dateKey) => dateKey.replaceAll('-', '.');

/// 页码口径：所有记录按日期正序排列，第 1 页是最早的一条。
List<Essay> sortByDateAsc(List<Essay> essays) {
  final list = List<Essay>.from(essays);
  list.sort((a, b) => a.dateKey.compareTo(b.dateKey));
  return list;
}

/// 某一天的页码；当天还没有记录时 = 现有条数 + 1。
int pageNumberOf(List<Essay> asc, String dateKey) {
  final i = asc.indexWhere((e) => e.dateKey == dateKey);
  return i >= 0 ? i + 1 : asc.length + 1;
}

/// 目录行摘要：正文首行，去掉首尾空白。
String summaryOf(Essay essay) => essay.text.split('\n').first.trim();
