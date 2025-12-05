import 'package:flutter/services.dart';
import 'package:neurosdk2/cmn_types.dart';
import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/mems_mixin.dart';
import 'package:neurosdk2/sensor.dart';
import 'package:neurosdk2/sensors_field.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class Callibri extends Sensor with MEMSSensor {
  static const EventChannel _callibriElectrodeStateEventChannel = EventChannel(Constants.callibriElectrodeStateEventName);
  static const EventChannel _callibriRespirationEventChannel = EventChannel(Constants.callibriRespirationDataEventName);
  static const EventChannel _callibriQuaternionEventChannel = EventChannel(Constants.quaternionDataChangedEventName);
  static const EventChannel _callibriEnvelopeEventChannel = EventChannel(Constants.callibriEnvelopeDataEventName);
  static const EventChannel _callibriSignalEventChannel = EventChannel(Constants.signalEventName);

  static final _electrodeStateChanelStream = _callibriElectrodeStateEventChannel.receiveBroadcastStream();
  static final _respirationChannelStream = _callibriRespirationEventChannel.receiveBroadcastStream();
  static final _quaternionChannelStream = _callibriQuaternionEventChannel.receiveBroadcastStream();
  static final _envelopeChannelStream = _callibriEnvelopeEventChannel.receiveBroadcastStream();
  static final _signalChannelStream = _callibriSignalEventChannel.receiveBroadcastStream();

  Stream<List<CallibriRespirationData>> get respirationDataStream => _respirationStreamWrapper.stream;
  Stream<FCallibriElectrodeState> get electrodeStateStream => _electrodeStateStreamWrapper.stream;
  Stream<List<CallibriEnvelopeData>> get envelopeDataStream => _envelopeStreamWrapper.stream;
  Stream<List<QuaternionData>> get quaternionDataStream => _quaternionStreamWrapper.stream;
  Stream<List<CallibriSignalData>> get signalDataStream => _signalStreamWrapper.stream;

  @override
  // ignore: overridden_fields
  late final SensorGetSetProperty<FSensorGain> gain = SensorGetSetProperty(guid, Sensor.api.getGain, Sensor.api.setGain);
  @override
  // ignore: overridden_fields
  late final SensorGetSetProperty<FSensorDataOffset> dataOffset = SensorGetSetProperty(guid, Sensor.api.getDataOffset, Sensor.api.setDataOffset);
  @override
  // ignore: overridden_fields
  late final SensorGetSetProperty<FSensorFirmwareMode> firmwareMode = SensorGetSetProperty(guid, Sensor.api.getFirmwareMode, Sensor.api.setFirmwareMode);
  @override
  // ignore: overridden_fields
  late final SensorGetSetProperty<FSensorSamplingFrequency> samplingFrequency = SensorGetSetProperty(guid, Sensor.api.getSamplingFrequency, Sensor.api.setSamplingFrequency);

  late final SensorGetProperty<FCallibriColorType> color = SensorGetProperty(guid, Sensor.api.getColor);
  late final SensorGetProperty<int> motionCounter = SensorGetProperty(guid, Sensor.api.getMotionCounter);
  late final SensorGetProperty<bool> memsCalibrateState = SensorGetProperty(guid, Sensor.api.getMEMSCalibrateState);
  late final SensorGetProperty<FCallibriElectrodeState> electrodeState = SensorGetProperty(guid, Sensor.api.getElectrodeState);
  late final SensorGetProperty<FCallibriStimulatorMAState> stimulatorMAState = SensorGetProperty(guid, Sensor.api.getStimulatorMAState);
  late final SensorGetSetProperty<FSensorADCInput> adcInput = SensorGetSetProperty(guid, Sensor.api.getADCInput, Sensor.api.setADCInput);
  late final SensorGetProperty<FSensorSamplingFrequency> samplingFrequencyResp = SensorGetProperty(guid, Sensor.api.getSamplingFrequencyResp);
  late final SensorGetSetProperty<CallibriSignalType> signalType = SensorGetSetProperty(guid, Sensor.api.getSignalType, Sensor.api.setSignalType);
  late final SensorGetProperty<FSensorSamplingFrequency> samplingFrequencyEnvelope = SensorGetProperty(guid, Sensor.api.getSamplingFrequencyEnvelope);
  late final SensorGetSetProperty<FSensorExternalSwitchInput> extSwInput = SensorGetSetProperty(guid, Sensor.api.getExtSwInput, Sensor.api.setExtSwInput);
  late final SensorGetSetProperty<FCallibriStimulationParams> stimulatorParam = SensorGetSetProperty(guid, Sensor.api.getStimulatorParam, Sensor.api.setStimulatorParam);
  late final SensorGetSetProperty<FCallibriMotionCounterParam> motionCounterParam = SensorGetSetProperty(guid, Sensor.api.getMotionCounterParam, Sensor.api.setMotionCounterParam);
  late final SensorGetSetProperty<FCallibriMotionAssistantParams> motionAssistantParam =
      SensorGetSetProperty(guid, Sensor.api.getMotionAssistantParam, Sensor.api.setMotionAssistantParam);
  late final SensorGetConvertedProperty<List<int?>, Set<FSensorFilter>> supportedFilters =
      SensorGetConvertedProperty(guid, Sensor.api.getSupportedFilters, SensorFiltersSetConverter());
  late final SensorGetSetConvertedProperty<List<int>, Set<FSensorFilter>> hardwareFilters =
      SensorGetSetConvertedProperty(guid, Sensor.api.getHardwareFilters, Sensor.api.setHardwareFilters, SensorFiltersSetConverter());

  late final EventChannelStreamWrapper<List<CallibriSignalData>> _signalStreamWrapper;
  late final EventChannelStreamWrapper<List<QuaternionData>> _quaternionStreamWrapper;
  late final EventChannelStreamWrapper<List<CallibriEnvelopeData>> _envelopeStreamWrapper;
  late final EventChannelStreamWrapper<FCallibriElectrodeState> _electrodeStateStreamWrapper;
  late final EventChannelStreamWrapper<List<CallibriRespirationData>> _respirationStreamWrapper;

  Callibri(super.guid) {
    _signalStreamWrapper = EventChannelStreamWrapper(guid, _signalChannelStream, _onSignalDataReceived);
    _envelopeStreamWrapper = EventChannelStreamWrapper(guid, _envelopeChannelStream, _onEnvelopeReceived);
    _quaternionStreamWrapper = EventChannelStreamWrapper(guid, _quaternionChannelStream, _onQuaternionDataReceived);
    _respirationStreamWrapper = EventChannelStreamWrapper(guid, _respirationChannelStream, _onRespirationDataReceived);
    _electrodeStateStreamWrapper = EventChannelStreamWrapper(guid, _electrodeStateChanelStream, (v) => FCallibriElectrodeState.values[v]);
    initMEMS(guid, Sensor.api);
  }

  Future<bool> isSupportedFilter(FSensorFilter filter) async {
    return Sensor.api.isSupportedFilter(guid, filter);
  }

  @override
  Future dispose() {
    disposeMEMS();

    _signalStreamWrapper.dispose();
    _envelopeStreamWrapper.dispose();
    _quaternionStreamWrapper.dispose();
    _respirationStreamWrapper.dispose();
    _electrodeStateStreamWrapper.dispose();

    return super.dispose();
  }

  List<QuaternionData> _onQuaternionDataReceived(dynamic data) => List.unmodifiable(
        data.map<QuaternionData>(
          (element) => QuaternionData(
            packNum: element['PackNum'],
            w: element['W'],
            x: element['X'],
            y: element['Y'],
            z: element['Z'],
          ),
        ),
      );

  List<CallibriSignalData> _onSignalDataReceived(dynamic data) => List.unmodifiable(
        data.map<CallibriSignalData>(
          (element) => CallibriSignalData(
            packNum: element['PackNum'],
            samples: element['Samples'].cast<double>(),
          ),
        ),
      );

  List<CallibriRespirationData> _onRespirationDataReceived(dynamic data) => List.unmodifiable(
        data.map<CallibriRespirationData>(
          (element) => CallibriRespirationData(
            packNum: element['PackNum'],
            samples: element['Samples'].cast<double>(),
          ),
        ),
      );

  List<CallibriEnvelopeData> _onEnvelopeReceived(dynamic data) => List.unmodifiable(
        data.map<CallibriEnvelopeData>(
          (element) => CallibriEnvelopeData(
            packNum: element['PackNum'],
            sample: element['Sample'],
          ),
        ),
      );
}
