/// Application-wide constants.
abstract final class AppConstants {
  /// Number of posts to fetch per page.
  static const int pageSize = 10;

  /// Hardcoded user ID for testing (no auth flow required).
  static const String userId = 'user_123';

  /// Debounce duration for like toggle network calls (ms).
  static const int likeDebounceMs = 500;

  /// Scroll threshold for triggering next page load (0.0 – 1.0).
  static const double paginationThreshold = 0.8;

  /// Duration for hero animation in milliseconds.
  static const int heroAnimationDurationMs = 350;

  /// Duration for image crossfade in milliseconds.
  static const int imageCrossfadeDurationMs = 500;
}
