import 'package:neurosdk2/brain_bit_sensor.dart';
import 'package:neurosdk2/sensor.dart';
import 'package:neurosdk2/sensors_field.dart';
import 'package:neurosdk2/fpg_mixin.dart';
import 'package:neurosdk2/mems_mixin.dart';
import 'package:neurosdk2/ping_neuro_smart_mixin.dart';
import 'package:neurosdk2/amp_mode_mixin.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class BrainBitBlack extends BrainBit
    with FPGSensor, MEMSSensor, AmpModeSensor, PingNeuroSmart {
  late final SensorGetProperty<FSensorSamplingFrequency>
      samplingFrequencyResist =
      SensorGetProperty(guid, Sensor.api.getSamplingFrequencyResist);

  // For models with numbers 3+
  late final SensorGetProperty<List<FEEGChannelInfo?>> supportedChannels =
      SensorGetProperty(guid, Sensor.api.getSupportedChannels);
  late final SensorGetSetProperty<BrainBit2AmplifierParamNative>
      amplifierParam = SensorGetSetProperty(guid,
          Sensor.api.getAmplifierParamBB2, Sensor.api.setAmplifierParamBB2);

  BrainBitBlack(String guid) : super(guid) {
    initNeuroSmart(guid, Sensor.api);
    initFPG(guid, Sensor.api);
    initMEMS(guid, Sensor.api);
    initAmpMode(guid, Sensor.api);
  }

  @override
  Future dispose() {
    disposeFPG();
    disposeMEMS();
    disposeAmpMode();
    return super.dispose();
  }
}
