import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class SocialFeedApp extends StatelessWidget {
  const SocialFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Social Feed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
