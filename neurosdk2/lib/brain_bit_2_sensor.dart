import 'package:flutter/services.dart';
import 'package:neurosdk2/amp_mode_mixin.dart';
import 'package:neurosdk2/cmn_types.dart';
import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/fpg_mixin.dart';
import 'package:neurosdk2/mems_mixin.dart';
import 'package:neurosdk2/ping_neuro_smart_mixin.dart';
import 'package:neurosdk2/sensors_field.dart';

import 'package:neurosdk2/sensor.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class BrainBit2 extends Sensor
    with FPGSensor, MEMSSensor, AmpModeSensor, PingNeuroSmart {
  static const EventChannel _signalEventChannel =
      EventChannel(Constants.signalEventName);
  static const EventChannel _resistEventChannel =
      EventChannel(Constants.resistanceEventName);
  static final Stream<dynamic> _signalChannelStream =
      _signalEventChannel.receiveBroadcastStream();
  static final Stream<dynamic> _resistChannelStream =
      _resistEventChannel.receiveBroadcastStream();

  Stream<List<SignalChannelsData>> get signalDataStream =>
      _signalEventStreamWrapper.stream;
  Stream<List<ResistRefChannelsData>> get resistDataStream =>
      _resistEventStreamWrapper.stream;

  late final SensorGetSetConvertedProperty<BrainBit2AmplifierParamNative,
          BrainBit2AmplifierParam> amplifierParam =
      SensorGetSetConvertedProperty(guid, Sensor.api.getAmplifierParamBB2,
          Sensor.api.setAmplifierParamBB2, BrainBit2AmplifierParamConverter());
  late final SensorGetProperty<FSensorSamplingFrequency>
      samplingFrequencyResist =
      SensorGetProperty(guid, Sensor.api.getSamplingFrequencyResist);
  late final SensorGetProperty<List<FEEGChannelInfo?>> supportedChannels =
      SensorGetProperty(guid, Sensor.api.getSupportedChannels);

  late final EventChannelStreamWrapper<List<SignalChannelsData>>
      _signalEventStreamWrapper;
  late final EventChannelStreamWrapper<List<ResistRefChannelsData>>
      _resistEventStreamWrapper;

  BrainBit2(super.guid) {
    _signalEventStreamWrapper = EventChannelStreamWrapper(
        guid, _signalChannelStream, _onSignalDataReceived);
    _resistEventStreamWrapper = EventChannelStreamWrapper(
        guid, _resistChannelStream, _onResistDataReceived);

    initNeuroSmart(guid, Sensor.api);
    initFPG(guid, Sensor.api);
    initMEMS(guid, Sensor.api);
    initAmpMode(guid, Sensor.api);
  }

  @override
  Future dispose() {
    _resistEventStreamWrapper.dispose();
    _signalEventStreamWrapper.dispose();

    disposeAmpMode();
    disposeMEMS();
    disposeFPG();

    return super.dispose();
  }

  List<SignalChannelsData> _onSignalDataReceived(dynamic data) =>
      List.unmodifiable(
        data.map<SignalChannelsData>(
          (element) => SignalChannelsData(
            marker: element['Marker'],
            packNum: element['PackNum'],
            samples: element['Samples'].cast<double>(),
          ),
        ),
      );

  List<ResistRefChannelsData> _onResistDataReceived(dynamic data) =>
      List.unmodifiable(
        data.map<ResistRefChannelsData>(
          (element) => ResistRefChannelsData(
            packNum: element['PackNum'],
            samples: element['Samples'].cast<double>(),
            referents: element['Referents'].cast<double>(),
          ),
        ),
      );
}
