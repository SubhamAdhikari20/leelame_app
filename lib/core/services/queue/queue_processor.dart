// lib/core/services/queue/queue_processor.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/datasources/remote/buyer_auth_remote_datasource.dart';

final queueProcessorProvider = Provider<QueueProcessor>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final buyerAuthRemoteDatasource = ref.read(buyerAuthRemoteDatasourceProvider);
  final connectivity = Connectivity();
  final networkInfo = ref.read(networkInfoProvider);

  return QueueProcessor(
    hiveService: hiveService,
    connectivity: connectivity,
    buyerAuthRemoteDatasource: buyerAuthRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class QueueProcessor {
  final HiveService _hiveService;
  final IBuyerAuthRemoteDatasource _buyerAuthRemoteDatasource;
  final Connectivity _connectivity;
  final INetworkInfo _networkInfo;
  StreamSubscription<ConnectivityResult>? _sub;

  QueueProcessor({
    required HiveService hiveService,
    required IBuyerAuthRemoteDatasource buyerAuthRemoteDatasource,
    required Connectivity connectivity,
    required INetworkInfo networkInfo,
  }) : _hiveService = hiveService,
       _buyerAuthRemoteDatasource = buyerAuthRemoteDatasource,
       _connectivity = connectivity,
       _networkInfo = networkInfo {
    // Listen for connectivity changes
    _sub =
        _connectivity.onConnectivityChanged.listen((
              List<ConnectivityResult> results,
            ) async {
              if (results.contains(ConnectivityResult.mobile) ||
                  results.contains(ConnectivityResult.wifi)) {
                // double-check actual internet
                if (await _networkInfo.isConnected) {
                  await _processQueue();
                }
              }
            })
            as StreamSubscription<ConnectivityResult>?;

    _initProcess();
  }

  Future<void> _initProcess() async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.wifi) ||
        status.contains(ConnectivityResult.mobile)) {
      if (await _networkInfo.isConnected) {
        await _processQueue();
      }
    }
  }

  Future<void> _processQueue() async {
    try {
      final pending = await _hiveService.getPendingEmails();
      for (final item in pending) {
        final key = item['key'] as String? ?? '';
        final toEmail = item['toEmail'] as String? ?? '';
        // final fullName = item['fullName'] as String? ?? '';
        final otp = item['otp'] as String? ?? '';
        final attempts = item['attempts'] as int? ?? 0;

        // if attempts too many, delete to avoid infinite retries
        const maxAttempts = 3;
        if (attempts >= maxAttempts) {
          await _hiveService.deleteFromQueue(key);
          continue;
        }

        try {
          final success = await _buyerAuthRemoteDatasource
              .sendQueuedVerificationEmail(
                email: toEmail,
                otp: otp,
              );

          if (success) {
            await _hiveService.deleteFromQueue(key);
          } else {
            // increment attempts
            await _hiveService.incrementQueueAttempts(key);
          }
        } catch (e) {
          // network or other error: increment attempts and continue
          await _hiveService.incrementQueueAttempts(key);
        }
      }
    } catch (e) {
      // log or ignore
      // print('QueueProcessor _processQueue error: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  // Future<void> _processQueue() async {
  //   final pendingEmails = await _hiveService.getPendingEmails();
  //   for (final data in pendingEmails) {
  //     final keys = _hiveService.getPendingEmailsKeysList(data);
  //     if (keys.isNotEmpty) {
  //       final queueKey = keys.first as String;
  //       try {
  //         final success = await _emailUtil.call(
  //           toEmail: data['toEmail'] as String,
  //           fullName: data['fullName'] as String,
  //           verifyCode: data['otp'] as String,
  //         );
  //         if (success) {
  //           await _hiveService.deleteFromQueue(queueKey);
  //         }
  //       } catch (e) {
  //         // Handle error, perhaps retry limit
  //       }
  //     }
  //   }
  // }
}
