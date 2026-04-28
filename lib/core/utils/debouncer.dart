import 'dart:async';

class Debouncer {
  final Duration delay;
  final Map<String, Timer> _pending = {};

  Debouncer({required this.delay});

  void run(String key, void Function() action) {
    _pending[key]?.cancel();
    _pending[key] = Timer(delay, () {
      action();
      _pending.remove(key);
    });
  }

  void cancel(String key) {
    _pending[key]?.cancel();
    _pending.remove(key);
  }

  void dispose() {
    for (final t in _pending.values) {
      t.cancel();
    }
    _pending.clear();
  }

  bool isPending(String key) => _pending.containsKey(key);
}
