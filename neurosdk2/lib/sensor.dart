import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/sensors_field.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class Sensor {
  @protected
  static final NeuroApi api = NeuroApi();

  static const EventChannel _stateChangedEventChannel =
      EventChannel(Constants.connectionChangedEventName);
  static const EventChannel _batteryChangedEventChannel =
      EventChannel(Constants.batteryChangedEventName);
  static final _stateEventChanelStream =
      _stateChangedEventChannel.receiveBroadcastStream();
  static final _batteryEventChanelStream =
      _batteryChangedEventChannel.receiveBroadcastStream();

  @protected
  final MethodChannel sensorMethodChannel =
      const MethodChannel(Constants.sensorMethodChannel);

  Stream<FSensorState> get sensorStateStream =>
      _sensorStateChanelStreamWrapper.stream;
  Stream<int> get batteryPowerStream => _batteryChanelStreamWrapper.stream;

  late final SensorGetConvertedProperty<List<int?>, Set<FSensorFeature>>
      features = SensorGetConvertedProperty(
          guid, api.supportedFeatures, SensorFeaturesSetConverter());
  late final SensorGetConvertedProperty<List<int?>, Set<FSensorCommand>>
      commands = SensorGetConvertedProperty(
          guid, api.supportedCommands, SensorCommandsSetConverter());
  late final SensorGetProperty<List<FParameterInfo?>> parameters =
      SensorGetProperty(guid, api.supportedParameters);

  late final SensorGetSetProperty<String> serialNumber =
      SensorGetSetProperty(guid, api.getSerialNumber, api.setSerialNumber);
  late final SensorGetProperty<FSensorSamplingFrequency> samplingFrequency =
      SensorGetProperty(guid, api.getSamplingFrequency);
  late final SensorGetProperty<FSensorFirmwareMode> firmwareMode =
      SensorGetProperty(guid, api.getFirmwareMode);
  late final SensorGetProperty<FSensorDataOffset> dataOffset =
      SensorGetProperty(guid, api.getDataOffset);
  late final SensorGetSetProperty<String> name =
      SensorGetSetProperty(guid, api.getName, api.setName);
  late final SensorGetProperty<FSensorFamily> sensFamily =
      SensorGetProperty(guid, api.getSensFamily);
  late final SensorGetProperty<int> channelsCount =
      SensorGetProperty(guid, api.getChannelsCount);
  late final SensorGetProperty<FSensorVersion> version =
      SensorGetProperty(guid, api.getVersion);
  late final SensorGetProperty<int> batteryPower =
      SensorGetProperty(guid, api.getBattPower);
  late final SensorGetProperty<FSensorState> state =
      SensorGetProperty(guid, api.getState);
  late final SensorGetProperty<String> address =
      SensorGetProperty(guid, api.getAddress);
  late final SensorGetProperty<FSensorGain> gain =
      SensorGetProperty(guid, api.getGain);

  late final EventChannelStreamWrapper<FSensorState>
      _sensorStateChanelStreamWrapper;
  late final EventChannelStreamWrapper<int> _batteryChanelStreamWrapper;

  @protected
  final String guid;

  Sensor(this.guid) {
    _sensorStateChanelStreamWrapper = EventChannelStreamWrapper(
        guid, _stateEventChanelStream, (v) => FSensorState.values[v['state']]);
    _batteryChanelStreamWrapper = EventChannelStreamWrapper(
        guid, _batteryEventChanelStream, (v) => v['power']);

    if (kDebugMode) {
      print("create sensor $guid");
    }
  }

  Future<void> connect() {
    return api.connectSensor(guid);
  }

  Future<void> disconnect() {
    return api.disconnectSensor(guid);
  }

  Future<void> close() {
    return api.closeSensor(guid);
  }

  Future<bool> isSupportedFeature(FSensorFeature feature) async {
    return api.isSupportedFeature(guid, feature);
  }

  Future<bool> isSupportedCommand(FSensorCommand command) async {
    return api.isSupportedCommand(guid, command);
  }

  Future<bool> isSupportedParameter(FSensorParameter parameter) async {
    return api.isSupportedParameter(guid, parameter);
  }

  Future<void> execute(FSensorCommand command) {
    return api.execCommand(guid, command);
  }

  @mustCallSuper
  Future dispose() async {
    _batteryChanelStreamWrapper.dispose();
    _sensorStateChanelStreamWrapper.dispose();

    await close();
  }
}
