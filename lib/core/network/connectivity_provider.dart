import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider);
  return conn.whenData((results) {
    return results.isNotEmpty && 
           !results.contains(ConnectivityResult.none);
  }).value ?? false;
});