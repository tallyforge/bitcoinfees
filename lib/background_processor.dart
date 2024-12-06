
import 'dart:ui';

import 'package:bitcoinfees/data/fee_source.dart';
import 'package:bitcoinfees/data/history/database.dart';
import 'package:bitcoinfees/data/preferences/app_prefs.dart';
import 'package:bitcoinfees/data/source/bitcoinerlive.dart';
import 'package:bitcoinfees/notifications.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
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
  if(estimates.isEmpty) {
    debugPrint("Empty estimates");
    return false;
  }

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
  debugPrint("Stored estimates in DB");
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
  await appPrefs.ready;

  var now = DateTime.now();

  int latestFee = estimates.first.satsPerVbyte;
  var sender = NotificationSender();

  debugPrint("Fee checks: ${appPrefs.feeThresholdEnabled} ${appPrefs.shortTermAverageFeeEnabled} ${appPrefs.longTermAverageFeeEnabled}");

  if(appPrefs.checkAverageFees) {
    debugPrint("Checking average fees: short ${appPrefs.shortTermAverageFeeEnabled} long ${appPrefs.longTermAverageFeeEnabled}");
    var weekTimestamp = now.subtract(const Duration(days: 7));
    var monthTimestamp = now.subtract(const Duration(days: 30));
    String comparison = appPrefs.averageFeeThresholdRatio > 1 ? "above" : "below";

    if(appPrefs.shortTermAverageFeeEnabled) {
      var feesThisWeek = _getFeesSince(db, weekTimestamp);

      if (feesThisWeek.isNotEmpty &&
          now.difference(feesThisWeek.first.timestamp) > const Duration(days: 3)) {
        var weekAverage = feesThisWeek
            .map((e) => e.estimates.first.satsPerVbyte)
            .average;

        bool test;
        if(appPrefs.averageFeeThresholdRatio >= 1) {
          test = latestFee >= appPrefs.averageFeeThresholdRatio * weekAverage;
        }
        else {
          test = latestFee <= appPrefs.averageFeeThresholdRatio * weekAverage;
        }

        debugPrint("Latest fee vs short average: $latestFee $weekAverage");
        if(test) {
          sender.sendNotification(
            NotificationType.feesBelowShortAverage,
            title: "Fees $comparison weekly average",
            body: "Fees of $latestFee sats/vbyte are $comparison the weekly average of ${weekAverage.toStringAsFixed(1)} sats/vbyte",
          );
        }
      }
    }

    if(appPrefs.longTermAverageFeeEnabled) {
      var feesThisMonth = _getFeesSince(db, monthTimestamp);

      if (feesThisMonth.isNotEmpty
          && now.difference(feesThisMonth.first.timestamp) > const Duration(days: 15)) {
        var monthAverage = feesThisMonth
            .map((e) => e.estimates.first.satsPerVbyte)
            .average;

        bool test;
        if(appPrefs.averageFeeThresholdRatio >= 1) {
          test = latestFee >= appPrefs.averageFeeThresholdRatio * monthAverage;
        }
        else {
          test = latestFee <= appPrefs.averageFeeThresholdRatio * monthAverage;
        }

        debugPrint("Latest fee vs short average: $latestFee $monthAverage");
        if(latestFee <= appPrefs.averageFeeThresholdRatio * monthAverage) {
          sender.sendNotification(
            NotificationType.feesBelowLongAverage,
            title: "Fees $comparison monthly average",
            body: "Fees of $latestFee sats/vbyte are $comparison the monthly average of ${monthAverage.toStringAsFixed(1)} sats/vbyte",
          );
        }
      }
    }
  }

  if(appPrefs.feeThresholdEnabled) {
    debugPrint("Checking threshold fees");
    bool test;
    String comparison;
    if(appPrefs.notifyHighFees) {
      test = latestFee >= appPrefs.feeNotificationThreshold;
      comparison = "above";
    }
    else {
      test = latestFee <= appPrefs.feeNotificationThreshold;
      comparison = "below";
    }
    if(test) {
      sender.sendNotification(
        NotificationType.feesBelowThreshold,
        title: "Fees $comparison threshold",
        body: "Fees of $latestFee sats/vbyte are $comparison your threshold of ${appPrefs.feeNotificationThreshold} sats/vbyte",
      );
    }
  }
}

List<RealmFeeContainer> _getFeesSince(RealmDatabase db, DateTime startTime) {
  var query = r"timestamp >= $0 SORT(timestamp DESC)";
  var allResults = db.realm.query<RealmFeeContainer>(query, [startTime]).toList();
  return allResults;
}