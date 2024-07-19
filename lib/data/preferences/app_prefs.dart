import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static AppPrefs? _instance;
  factory AppPrefs() {
    _instance ??= AppPrefs._();
    return _instance!;
  }

  AppPrefs._() {
    _initialize();
  }

  final Completer<void> _readyCompleter = Completer();
  Future<void> get ready => _readyCompleter.future;

  late SharedPreferences _prefs;

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _load();
  }

  Future<void> _load() async {
    // Defaults are the starting value of the properties
    feeThresholdEnabled = _prefs.getBool(_feeThresholdEnabledKey) ?? feeThresholdEnabled;
    feeNotificationThreshold = _prefs.getInt(_feeNotificationThresholdKey) ?? feeNotificationThreshold;
    shortTermAverageFeeEnabled = _prefs.getBool(_shortTermAverageFeeEnabledKey) ?? shortTermAverageFeeEnabled;
    longTermAverageFeeEnabled = _prefs.getBool(_longTermAverageFeeEnabledKey) ?? longTermAverageFeeEnabled;
    averageFeeThresholdRatio = _prefs.getDouble(_averageFeeThresholdRatioKey) ?? averageFeeThresholdRatio;
  }

  Future<void> _save() async {

  }

  /// Whether absolute fee threshold notifications are enabled.
  bool feeThresholdEnabled = false;
  static const _feeThresholdEnabledKey = "fee_notification_enabled";

  /// The fee in sats per vbyte that should trigger a fee threshold notification.
  int feeNotificationThreshold = 10;
  static const _feeNotificationThresholdKey = "fee_notification_threshold";

  /// Whether 1-day average fee notifications are enabled.
  bool shortTermAverageFeeEnabled = false;
  static const _shortTermAverageFeeEnabledKey = "short_average_fee_notification_enabled";

  /// Whether 1-week average fee notifications are enabled.
  bool longTermAverageFeeEnabled = false;
  static const _longTermAverageFeeEnabledKey = "long_average_fee_notification_enabled";

  bool get checkAverageFees => shortTermAverageFeeEnabled || longTermAverageFeeEnabled;

  /// The percentage of the average fee that should trigger a notification.
  ///
  /// e.g. 0.9 means send a notification when current are <=90% of the average.
  double averageFeeThresholdRatio = 0.9;
  static const _averageFeeThresholdRatioKey = "average_fee_ratio";
}