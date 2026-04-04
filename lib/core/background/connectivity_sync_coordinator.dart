import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';

class ConnectivitySyncCoordinator {
  ConnectivitySyncCoordinator({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _wasOffline = false;

  Future<void> start() async {
    final current = await _connectivity.checkConnectivity();
    _wasOffline = !_isOnline(current);

    _sub ??= _connectivity.onConnectivityChanged.listen((results) async {
      final onlineNow = _isOnline(results);
      if (_wasOffline && onlineNow) {
        await WorkManagerService.scheduleFlushPendingAi();
      }
      _wasOffline = !onlineNow;
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((result) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn;
    });
  }
}
