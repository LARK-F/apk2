# 随笔

一本可以翻的纸质手账：首页是合着的封面，点击翻开今天的内页，日期页是这本手账的目录，每一页都有页码。全程用 Flutter + TRAE 完成。

## 扫码安装（Android）

<img src="install-qr.png" width="240" alt="扫码下载 APK" />

或直接下载：[app-release.apk](https://github.com/LARK-F/apk2/releases/latest/download/app-release.apk)

安装步骤：扫码 → 浏览器下载 → 允许「安装未知来源应用」→ 安装。

> APK 使用 Flutter 模板默认的 debug 签名，安装时可能提示「未经 Play 保护机制验证」，选择「仍要安装」即可。

## 页面结构

| 页面 | 内容 |
| --- | --- |
| P1 封面 | 雾桃粉封面、柔靛青书脊、柔柠黄书签、书名与年份、日期框、共 N 页；点击绕书脊翻页 |
| P2 内页 | 左侧三个装订孔、日期 + 星期、正文书写区、图片块（2px 雾霭蓝外框）、底部提示 / 页码 / 字数 |
| P3 目录 | 页码（两位补零）+ 日期 + 首行摘要，今天整行柔柠黄；空状态可「去写第一篇」 |

## 配色（全 App 仅九色）

米纸 `#FDF4DE`、雾桃粉 `#F2B6B6`、柔靛青 `#6A90A6`、纸孔 `#EFE3C6`、柔柠黄 `#F9D77C`、青墨 `#2F4147`、深靛 `#4F7285`、雾灰 `#5F6E75`、雾霭蓝 `#8DA6D2`

## 构建

```bash
flutter pub get
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`

## 数据

本地存储使用 `shared_preferences`，key 为 `essays`，结构 `{ date, text, images[] }`；图片复制到应用文档目录。退出即保存，空白页不落库。
