enum TxnType {
  p2pkh,
  p2wpkh,
  p2tr;

  TxnElementWeights get weights => switch(this) {
    p2pkh => const TxnElementWeights(10, 148, 34),
    p2wpkh => const TxnElementWeights(10.5, 68, 31),
    p2tr => const TxnElementWeights(10.5, 57.5, 43)
  };

  int feeForTxn(int satsPerVbyte, {int inputs = 1, int outputs = 1}) {
    return weights.feeForTxn(satsPerVbyte, inputs: inputs, outputs: outputs);
  }

  int paymentFee(int satsPerVbyte) {
    return feeForTxn(satsPerVbyte, outputs: 2);
  }

  int consolidationFee(int satsPerVbyte) {
    return feeForTxn(satsPerVbyte, inputs: 3);
  }
}

class TxnElementWeights {
  final double overheadVbytes;
  final double vbytesPerInput;
  final double vbytesPerOutput;

  const TxnElementWeights(
    this.overheadVbytes,
    this.vbytesPerInput,
    this.vbytesPerOutput
  );

  int feeForTxn(int satsPerVbyte, {int inputs = 1, int outputs = 1}) {
    return ((overheadVbytes + inputs * vbytesPerInput + outputs + vbytesPerOutput) * satsPerVbyte).round();
  }
}