/// 随笔数据模型。
///
/// 对应 shared_preferences 中的每条记录：
/// { "date": "2026-11-02", "text": "...", "images": ["<绝对路径>"] }
class Essay {
  /// 内部存储日期，格式 yyyy-MM-dd（作为排序 / 去重 key）。
  final String dateKey;

  /// 正文文本。
  final String text;

  /// 已复制到应用文档目录的图片绝对路径列表。
  final List<String> images;

  const Essay({
    required this.dateKey,
    this.text = '',
    this.images = const [],
  });

  /// 显示用日期，格式 yyyy.MM.dd。
  String get displayDate => dateKey.replaceAll('-', '.');

  /// 是否为空白页（空文本、无图片），空白页不写入存储。
  bool get isEmpty => text.trim().isEmpty && images.isEmpty;

  factory Essay.fromJson(Map<String, dynamic> json) {
    return Essay(
      dateKey: json['date'] as String? ?? '',
      text: json['text'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'text': text,
        'images': images,
      };

  Essay copyWith({
    String? text,
    List<String>? images,
  }) {
    return Essay(
      dateKey: dateKey,
      text: text ?? this.text,
      images: images ?? this.images,
    );
  }
}
