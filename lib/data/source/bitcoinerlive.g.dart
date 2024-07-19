// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitcoinerlive.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FullFeeEstimate _$FullFeeEstimateFromJson(Map<String, dynamic> json) =>
    _FullFeeEstimate(
      (json['timestamp'] as num).toInt(),
      (json['estimates'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, _InnerFeeEstimate.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$FullFeeEstimateToJson(_FullFeeEstimate instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'estimates': instance.estimates,
    };

_InnerFeeEstimate _$InnerFeeEstimateFromJson(Map<String, dynamic> json) =>
    _InnerFeeEstimate(
      (json['sat_per_vbyte'] as num).toInt(),
    );

Map<String, dynamic> _$InnerFeeEstimateToJson(_InnerFeeEstimate instance) =>
    <String, dynamic>{
      'sat_per_vbyte': instance.satsPerVbyte,
    };
