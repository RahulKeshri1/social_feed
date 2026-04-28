import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class SocialFeedApp extends ConsumerStatefulWidget {
  const SocialFeedApp({super.key});

  @override
  ConsumerState<SocialFeedApp> createState() => _SocialFeedAppState();
}

class _SocialFeedAppState extends ConsumerState<SocialFeedApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Social Feed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
