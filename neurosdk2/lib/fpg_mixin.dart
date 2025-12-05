import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:neurosdk2/cmn_types.dart';
import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/sensors_field.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

mixin FPGSensor {
  static const EventChannel _fpgEventChannel =
      EventChannel(Constants.neurosmartFPGDataChangedEventName);
  static final _fpgChanelEventStream =
      _fpgEventChannel.receiveBroadcastStream();

  Stream<List<FPGData>> get fpgStream => _fpgEventStreamWrapper.stream;

  late final SensorGetSetProperty<FIrAmplitude> irAmplitude =
      SensorGetSetProperty<FIrAmplitude>(
          _guid, _api.getIrAmplitude, _api.setIrAmplitude);
  late final SensorGetSetProperty<FRedAmplitude> redAmplitude =
      SensorGetSetProperty(_guid, _api.getRedAmplitude, _api.setRedAmplitude);
  late final SensorGetProperty<FSensorSamplingFrequency> samplingFrequencyFPG =
      SensorGetProperty(_guid, _api.getSamplingFrequencyFPG);

  late final String _guid;
  late final NeuroApi _api;
  late final EventChannelStreamWrapper<List<FPGData>> _fpgEventStreamWrapper;

  @protected
  @mustCallSuper
  void initFPG(String guid, NeuroApi api) {
    _guid = guid;
    _api = api;
    _fpgEventStreamWrapper =
        EventChannelStreamWrapper(_guid, _fpgChanelEventStream, _onFPGReceived);
  }

  @protected
  @mustCallSuper
  void disposeFPG() {
    _fpgEventStreamWrapper.dispose();
  }

  List<FPGData> _onFPGReceived(dynamic data) {
    List<FPGData> samples = List.unmodifiable(
      data.map<FPGData>((e) => FPGData(
            packNum: e['PackNum'],
            irAmplitude: e['IrAmplitude'],
            redAmplitude: e['RedAmplitude'],
          )),
    );

    return samples;
  }
}
