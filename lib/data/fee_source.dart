
import 'package:result_type/result_type.dart';

abstract interface class FeeSource {
  Future<FeeSourceResult<List<FeeEstimate>>> getFeeEstimates();
}

class FeeEstimate {
  DateTime timestamp;
  Duration timeToConfirmation;
  int satsPerVbyte;

  FeeEstimate({
    required this.timestamp,
    required this.timeToConfirmation,
    required this.satsPerVbyte
  });
}

typedef FeeSourceResult<T> = Result<T, FeeSourceError>;
typedef FeeSourceSuccess<T> = Success<T, FeeSourceError>;
typedef FeeSourceFailure<T> = Failure<T, FeeSourceError>;

sealed class FeeSourceError {}

class HttpError extends FeeSourceError {
  int statusCode;
  String body;
  
  HttpError(this.statusCode, this.body);
}

class DartException extends FeeSourceError {
  Exception underlying;

  DartException(this.underlying);
}