import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:neurosdk2/brain_bit_2_sensor.dart';


import 'package:neurosdk2/brain_bit_black.dart';


import 'package:neurosdk2/brain_bit_sensor.dart';


import 'package:neurosdk2/callibri_sensor.dart';

import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/sensor.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class Scanner {
  static final NeuroApi _api = NeuroApi();

  static const EventChannel _sensorsChangedEventChannel =
      EventChannel(Constants.sensorListChangedEventName);
  static final Stream<dynamic> _sensorListEventStream =
      _sensorsChangedEventChannel.receiveBroadcastStream();

  Stream<List<FSensorInfo>> get sensorsStream =>
      _sensorsChanelStreamWrapper.stream;

  final String _guid;
  late final EventChannelStreamWrapper<List<FSensorInfo>>
      _sensorsChanelStreamWrapper;

  Scanner._(this._guid) {
    _sensorsChanelStreamWrapper = EventChannelStreamWrapper(
        _guid, _sensorListEventStream, _convertEventData);
  }

  Future<List<FSensorInfo?>> getSensors() async {
    return _api.getSensors(_guid);
  }

  Future<void> start() {
    return _api.startScan(_guid);
  }

  Future<void> stop() async {
    return _api.stopScan(_guid);
  }

  Future<Sensor?> createSensor(FSensorInfo sensorInfo) async {
    final sensorGuid = await _api.createSensor(_guid, sensorInfo);
    switch (sensorInfo.sensFamily) {

      case FSensorFamily.leBrainBit:
        return BrainBit(sensorGuid);


      case FSensorFamily.leBrainBitBlack:
        return BrainBitBlack(sensorGuid);


      case FSensorFamily.leCallibri:
      case FSensorFamily.leKolibri:
        return Callibri(sensorGuid);


      case FSensorFamily.leBrainBit2:
      case FSensorFamily.leBrainBitPro:
      case FSensorFamily.leBrainBitFlex:
        return BrainBit2(sensorGuid);

      case FSensorFamily.unknown:
        break;
    }

    return null;
  }

  @mustCallSuper
  void dispose() async {
    _sensorsChanelStreamWrapper.dispose();
    await _api.closeScanner(_guid);
  }

  List<FSensorInfo> _convertEventData(dynamic data) {
    return List.unmodifiable(
      data.map(
        (element) => FSensorInfo(
          name: element['Name'],
          address: element['Address'],
          serialNumber: element['SerialNumber'],
          pairingRequired: element['PairingRequired'],
          sensModel: element['SensModel'],
          sensFamily: FSensorFamily.values[element['SensFamily']],
          rssi: element['RSSI'],
        ),
      ),
    );
  }

  static Future<Scanner> create(List<FSensorFamily> filters) async {
    String? guid =
        await _api.createScanner(filters.map((it) => it.index).toList());

    return Scanner._(guid);
  }
}
