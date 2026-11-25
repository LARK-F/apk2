import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EssayApp());
}

class EssayApp extends StatelessWidget {
  const EssayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '随笔',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // 状态栏透明 + 深色图标，让米纸延伸到状态栏下面。
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.paper,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}
