
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import 'package:tallyforge_bitcoin_fees/data/fee_source.dart';
import 'package:tallyforge_bitcoin_fees/data/history/database.dart';
import 'package:tallyforge_bitcoin_fees/data/preferences/app_prefs.dart';
import 'package:tallyforge_bitcoin_fees/data/source/bitcoinerlive.dart';
import 'package:tallyforge_bitcoin_fees/notifications.dart';
import 'package:workmanager/workmanager.dart';

@pragma("vm:entry-point")
void backgroundProcessor() async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await AppPrefs().ready;

  Workmanager().executeTask((task, inputData) async {
    try {
      var feeResult = await BitcoinerLiveFeeSource().getFeeEstimates();
      switch (feeResult) {
        case FeeSourceSuccess(value: final data):
          return _processFeeEstimates(data);
        case FeeSourceFailure(value: final error):
          debugPrint("error: $error");
          return false;
      }

      return true;
    } on Exception catch(e) {
      debugPrint("Exception: $e");
      return false;
    }
  });
}

Future<bool> runBackgroundTasks(List<FeeEstimate> estimates) async {
  try {
    return _processFeeEstimates(estimates);
  } catch(e) {
    debugPrint("Exception: $e");
    return false;
  }
}

Future<bool> _processFeeEstimates(List<FeeEstimate> estimates) async {
  if(estimates.isEmpty) return false;

  var db = RealmDatabase();

  try {
    await _storeFeeEstimates(db, estimates);
  } on RealmException catch(e) {
    // ignore existing primary key error
    if(!e.message.contains("1013")) {
      debugPrint("Exception: $e");
      return false;
    }
  }
  await _checkFeeChanges(db, estimates);

  return true;
}

Future<void> _storeFeeEstimates(RealmDatabase db, List<FeeEstimate> estimates) async {
  var container = RealmFeeContainer(estimates.first.timestamp);
  for(var e in estimates) {
    container.estimates.add(RealmFeeEstimate(e.timestamp, e.timeToConfirmation.inMinutes, e.satsPerVbyte));
  }
  return db.realm.writeAsync(() {
    db.realm.add(container);
  });
}

Future<void> _checkFeeChanges(RealmDatabase db, List<FeeEstimate> estimates) async {
  var appPrefs = AppPrefs();
  var now = DateTime.now();

  int latestFee = estimates.first.satsPerVbyte;
  var sender = NotificationSender();

  if(appPrefs.checkAverageFees) {
    var weekTimestamp = now.subtract(const Duration(days: 7));
    var monthTimestamp = now.subtract(const Duration(days: 30));
    var feesThisWeek = _getFeesSince(db, weekTimestamp);
    var feesThisMonth = _getFeesSince(db, monthTimestamp);

    if(appPrefs.shortTermAverageFeeEnabled) {
      if (feesThisWeek.isNotEmpty &&
          now.difference(feesThisWeek.first.timestamp) > const Duration(days: 3)) {
        var weekAverage = feesThisWeek
            .map((e) => e.estimates.first.satsPerVbyte)
            .average;

        sender.sendNotification(
          NotificationType.feesBelowShortAverage,
          title: "Fees below weekly average",
          body: "Fees of $latestFee are below the weekly average of ${weekAverage.toStringAsFixed(1)}",
        );
      }
    }

    if(appPrefs.longTermAverageFeeEnabled) {
      if (feesThisMonth.isNotEmpty
          && now.difference(feesThisMonth.first.timestamp) > const Duration(days: 15)) {
        var monthAverage = feesThisMonth
            .map((e) => e.estimates.first.satsPerVbyte)
            .average;

        sender.sendNotification(
          NotificationType.feesBelowLongAverage,
          title: "Fees below monthly average",
          body: "Fees of $latestFee are below the monthly average of ${monthAverage.toStringAsFixed(1)}",
        );
      }
    }
  }

  if(appPrefs.feeThresholdEnabled) {
    if(latestFee <= appPrefs.feeNotificationThreshold) {
      sender.sendNotification(
        NotificationType.feesBelowThreshold,
        title: "Fees below threshold",
        body: "Fees of $latestFee are below your threshold of ${appPrefs.feeNotificationThreshold}",
      );
    }
  }
}

List<RealmFeeContainer> _getFeesSince(RealmDatabase db, DateTime startTime) {
  var query = r"timestamp >= $0 SORT(timestamp DESC)";
  var allResults = db.realm.query<RealmFeeContainer>(query, [startTime]).toList();
  return allResults;
}