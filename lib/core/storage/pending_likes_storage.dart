import 'package:shared_preferences/shared_preferences.dart';

abstract final class PendingLikesStorage {
  static const String _key = 'pending_likes';

  static Future<void> addPendingLike(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      
      if (!list.contains(postId)) {
        list.add(postId);
        await prefs.setStringList(_key, list);
        print('[Store] Added $postId - queue size: ${list.length}');
      }
    } catch (e) {
      print('[Store] Failed to save like - $e');
      rethrow;
    }
  }

  static Future<Set<String>> loadPendingLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = prefs.getStringList(_key) ?? [];
      print('[Store] Loaded ${items.length} pending items');
      return items.toSet();
    } catch (e) {
      print('[Store] Load failed - returning empty set');
      return {};
    }
  }

  static Future<void> removePendingLike(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      list.remove(postId);
      await prefs.setStringList(_key, list);
    } catch (e) {
      print('[Store] Error removing like: $e');
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<int> getPendingLikeCount() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    return items.length;
  }
}
