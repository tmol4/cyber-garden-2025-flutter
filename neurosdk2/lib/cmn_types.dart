
import 'package:neurosdk2/pigeon_messages.g.dart'
    show FBrainBit2ChannelMode, FSensorGain, FGenCurrent;


class CallibriEnvelopeData {
  final int packNum;
  final double sample;

  CallibriEnvelopeData({required this.packNum, required this.sample});

  @override
  String toString() {
    return "[packNum = $packNum, sample = $sample]";
  }
}

class CallibriSignalData {
  final int packNum;
  final List<double> samples;

  CallibriSignalData({required this.packNum, required this.samples});

  @override
  String toString() {
    return "[packNum = $packNum, samples = $samples]";
  }
}

class QuaternionData {
  final int packNum;
  final double w;
  final double x;
  final double y;
  final double z;

  QuaternionData(
      {required this.packNum,
      required this.w,
      required this.x,
      required this.y,
      required this.z});

  @override
  String toString() {
    return "[packNum = $packNum, w = $w, x = $x, y = $y, z = $z]";
  }
}

class CallibriRespirationData {
  final int packNum;
  final List<double> samples;

  CallibriRespirationData({required this.packNum, required this.samples});

  @override
  String toString() {
    return "[packNum = $packNum, samples = $samples]";
  }
}

const int sensorNameLength = 256;
const int sensorAddressLength = 128;
const int sensorSerialNumberLength = 128;


class BrainBitResistData {
  final double o1;
  final double o2;
  final double t3;
  final double t4;

  BrainBitResistData(
      {required this.o1, required this.o2, required this.t3, required this.t4});

  @override
  String toString() {
    return "[o1 = $o1, o2 = $o2, t3 = $t3, t4 = $t4]";
  }
}

class BrainBitSignalData {
  final int packNum;
  final int marker;
  final double o1;
  final double o2;
  final double t3;
  final double t4;

  BrainBitSignalData(
      {required this.packNum,
      required this.marker,
      required this.o1,
      required this.o2,
      required this.t3,
      required this.t4});

  @override
  String toString() {
    return "[packNum = $packNum, marker = $marker, o1 = $o1, o2 = $o2, t3 = $t3, t4 = $t4]";
  }
}


class Point3D {
  final double x;
  final double y;
  final double z;

  Point3D({required this.x, required this.y, required this.z});

  @override
  String toString() {
    return "[x = $x, y = $y, z = $z]";
  }
}

class MEMSData {
  final int packNum;
  final Point3D accelerometer;
  final Point3D gyroscope;

  MEMSData(
      {required this.packNum,
      required this.accelerometer,
      required this.gyroscope});

  @override
  String toString() {
    return "[packNum = $packNum, accelerometer = $accelerometer, gyroscope = $gyroscope]";
  }
}


class SignalChannelsData {
  final int packNum;
  final int marker;
  final List<double> samples;

  SignalChannelsData(
      {required this.packNum, required this.marker, required this.samples});

  @override
  String toString() {
    return "[packNum = $packNum, marker = $marker, samples = $samples]";
  }
}

class ResistRefChannelsData {
  final int packNum;
  final List<double> samples;
  final List<double> referents;

  ResistRefChannelsData(
      {required this.packNum, required this.samples, required this.referents});

  @override
  String toString() {
    return "[packNum = $packNum, samples = $samples, referents = $referents]";
  }
}


class FPGData {
  int packNum;
  double irAmplitude;
  double redAmplitude;

  FPGData(
      {required this.packNum,
      required this.irAmplitude,
      required this.redAmplitude});

  @override
  String toString() {
    return "[packNum = $packNum, irAmplitude = $irAmplitude, redAmplitude = $redAmplitude]";
  }
}


class BrainBit2AmplifierParam {
  List<FBrainBit2ChannelMode> chSignalMode;
  List<bool> chResistUse;
  List<FSensorGain> chGain;
  FGenCurrent current;

  BrainBit2AmplifierParam(
      {required this.chSignalMode,
      required this.chResistUse,
      required this.chGain,
      required this.current});

  @override
  String toString() {
    return "[chSignalMode = $chSignalMode, chResistUse = $chResistUse, chGain = $chGain, current = $current]";
  }
}

