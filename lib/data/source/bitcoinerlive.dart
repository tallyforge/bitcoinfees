import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:tallyforge_bitcoin_fees/data/fee_source.dart';
import 'package:http/http.dart' as http;

part 'bitcoinerlive.g.dart';

class BitcoinerLiveFeeSource implements FeeSource {
  @override
  Future<FeeSourceResult<List<FeeEstimate>>> getFeeEstimates() async {
    try {
      var response = await http.get(Uri.parse("https://bitcoiner.live/api/fees/estimates/latest"));

      if(response.statusCode == 200) {
        var body = _FullFeeEstimate.fromJson(jsonDecode(response.body));
        return FeeSourceSuccess(body.convert());
      }
      else {
        return FeeSourceFailure(HttpError(response.statusCode, response.body));
      }
    } on Exception catch(e) {
      return FeeSourceFailure(DartException(e));
    }
  }
}

@JsonSerializable()
class _FullFeeEstimate {
  int timestamp;
  Map<String, _InnerFeeEstimate> estimates;

  _FullFeeEstimate(this.timestamp, this.estimates);

  factory _FullFeeEstimate.fromJson(Map<String, dynamic> json) => _$FullFeeEstimateFromJson(json);
  Map<String, dynamic> toJson() => _$FullFeeEstimateToJson(this);

  List<FeeEstimate> convert() {
    List<FeeEstimate> out = [];
    for(var minutes in estimates.keys) {
      var e = estimates[minutes]!;

      out.add(FeeEstimate(timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true), timeToConfirmation: Duration(minutes: int.parse(minutes)), satsPerVbyte: e.satsPerVbyte));
    }

    return out;
  }
}

@JsonSerializable()
class _InnerFeeEstimate  {
  @JsonKey(name: "sat_per_vbyte")
  int satsPerVbyte;

  _InnerFeeEstimate(this.satsPerVbyte);

  factory _InnerFeeEstimate.fromJson(Map<String, dynamic> json) => _$InnerFeeEstimateFromJson(json);
  Map<String, dynamic> toJson() => _$InnerFeeEstimateToJson(this);
}
