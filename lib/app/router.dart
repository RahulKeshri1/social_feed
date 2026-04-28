import 'package:go_router/go_router.dart';

import '../features/detail/presentation/screens/detail_screen.dart';
import '../features/feed/data/models/post_model.dart';
import '../features/feed/presentation/screens/feed_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/detail',
      name: 'detail',
      builder: (context, state) {
        final post = state.extra as PostModel;
        return DetailScreen(post: post);
      },
    ),
  ],
);
