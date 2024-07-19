
import 'package:realm/realm.dart';
import 'package:realm_common/realm_common.dart';

part 'database.realm.dart';

class RealmDatabase {
  static RealmDatabase? _instance;
  factory RealmDatabase() {
    _instance ??= RealmDatabase._();
    return _instance!;
  }
  
  static final config = Configuration.local([
    RealmFeeContainer.schema,
    RealmFeeEstimate.schema,
  ]);
  
  Realm realm;

  RealmDatabase._() : realm = Realm(config);
}

@RealmModel()
class _RealmFeeContainer {
  @PrimaryKey()
  int get timestampMillis => timestamp.toUtc().millisecondsSinceEpoch;

  late DateTime timestamp;

  late List<_RealmFeeEstimate> estimates;
}

@RealmModel()
class _RealmFeeEstimate {
  @PrimaryKey()
  String get key => "$timestampMillis-$blocksToConfirmation";

  late DateTime timestamp;
  int get timestampMillis => timestamp.toUtc().millisecondsSinceEpoch;
  late int blocksToConfirmation;
  late int satsPerVbyte;
}