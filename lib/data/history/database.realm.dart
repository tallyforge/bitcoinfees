// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class RealmFeeContainer extends _RealmFeeContainer
    with RealmEntity, RealmObjectBase, RealmObject {
  RealmFeeContainer(
    DateTime timestamp, {
    Iterable<RealmFeeEstimate> estimates = const [],
  }) {
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set<RealmList<RealmFeeEstimate>>(
        this, 'estimates', RealmList<RealmFeeEstimate>(estimates));
  }

  RealmFeeContainer._();

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  RealmList<RealmFeeEstimate> get estimates =>
      RealmObjectBase.get<RealmFeeEstimate>(this, 'estimates')
          as RealmList<RealmFeeEstimate>;
  @override
  set estimates(covariant RealmList<RealmFeeEstimate> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<RealmFeeContainer>> get changes =>
      RealmObjectBase.getChanges<RealmFeeContainer>(this);

  @override
  Stream<RealmObjectChanges<RealmFeeContainer>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RealmFeeContainer>(this, keyPaths);

  @override
  RealmFeeContainer freeze() =>
      RealmObjectBase.freezeObject<RealmFeeContainer>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toEJson(),
      'estimates': estimates.toEJson(),
    };
  }

  static EJsonValue _toEJson(RealmFeeContainer value) => value.toEJson();
  static RealmFeeContainer _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'timestamp': EJsonValue timestamp,
        'estimates': EJsonValue estimates,
      } =>
        RealmFeeContainer(
          fromEJson(timestamp),
          estimates: fromEJson(estimates),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RealmFeeContainer._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.realmObject, RealmFeeContainer, 'RealmFeeContainer', [
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('estimates', RealmPropertyType.object,
          linkTarget: 'RealmFeeEstimate',
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class RealmFeeEstimate extends _RealmFeeEstimate
    with RealmEntity, RealmObjectBase, RealmObject {
  RealmFeeEstimate(
    DateTime timestamp,
    int blocksToConfirmation,
    int satsPerVbyte,
  ) {
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'blocksToConfirmation', blocksToConfirmation);
    RealmObjectBase.set(this, 'satsPerVbyte', satsPerVbyte);
  }

  RealmFeeEstimate._();

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  int get blocksToConfirmation =>
      RealmObjectBase.get<int>(this, 'blocksToConfirmation') as int;
  @override
  set blocksToConfirmation(int value) =>
      RealmObjectBase.set(this, 'blocksToConfirmation', value);

  @override
  int get satsPerVbyte => RealmObjectBase.get<int>(this, 'satsPerVbyte') as int;
  @override
  set satsPerVbyte(int value) =>
      RealmObjectBase.set(this, 'satsPerVbyte', value);

  @override
  Stream<RealmObjectChanges<RealmFeeEstimate>> get changes =>
      RealmObjectBase.getChanges<RealmFeeEstimate>(this);

  @override
  Stream<RealmObjectChanges<RealmFeeEstimate>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RealmFeeEstimate>(this, keyPaths);

  @override
  RealmFeeEstimate freeze() =>
      RealmObjectBase.freezeObject<RealmFeeEstimate>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toEJson(),
      'blocksToConfirmation': blocksToConfirmation.toEJson(),
      'satsPerVbyte': satsPerVbyte.toEJson(),
    };
  }

  static EJsonValue _toEJson(RealmFeeEstimate value) => value.toEJson();
  static RealmFeeEstimate _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'timestamp': EJsonValue timestamp,
        'blocksToConfirmation': EJsonValue blocksToConfirmation,
        'satsPerVbyte': EJsonValue satsPerVbyte,
      } =>
        RealmFeeEstimate(
          fromEJson(timestamp),
          fromEJson(blocksToConfirmation),
          fromEJson(satsPerVbyte),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RealmFeeEstimate._);
    register(_toEJson, _fromEJson);
    return SchemaObject(
        ObjectType.realmObject, RealmFeeEstimate, 'RealmFeeEstimate', [
      SchemaProperty('timestamp', RealmPropertyType.timestamp),
      SchemaProperty('blocksToConfirmation', RealmPropertyType.int),
      SchemaProperty('satsPerVbyte', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
