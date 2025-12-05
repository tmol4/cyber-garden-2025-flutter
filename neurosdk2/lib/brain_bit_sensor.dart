import 'package:flutter/services.dart';
import 'package:neurosdk2/cmn_types.dart';
import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/sensor.dart';
import 'package:neurosdk2/sensors_field.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class BrainBit extends Sensor {
  static const EventChannel _brainbitSignalEventChannel =
      EventChannel(Constants.signalEventName);
  static const EventChannel _brainbitResistEventChannel =
      EventChannel(Constants.resistanceEventName);
  static final Stream<dynamic> _signalChannelStream =
      _brainbitSignalEventChannel.receiveBroadcastStream();
  static final Stream<dynamic> _resistChannelStream =
      _brainbitResistEventChannel.receiveBroadcastStream();

  Stream<BrainBitResistData> get resistDataStream =>
      _resistEventStreamWrapper.stream;
  Stream<List<BrainBitSignalData>> get signalDataStream =>
      _signalEventStreamWrapper.stream;

  late final EventChannelStreamWrapper<BrainBitResistData>
      _resistEventStreamWrapper;
  late final EventChannelStreamWrapper<List<BrainBitSignalData>>
      _signalEventStreamWrapper;

  @override
  // ignore: overridden_fields
  late final SensorGetSetProperty<FSensorGain> gain =
      SensorGetSetProperty(guid, Sensor.api.getGain, Sensor.api.setGain);

  BrainBit(super.guid) {
    _resistEventStreamWrapper = EventChannelStreamWrapper(
        guid, _resistChannelStream, _onResistDataReceived);
    _signalEventStreamWrapper = EventChannelStreamWrapper(
        guid, _signalChannelStream, _onSignalDataReceived);
  }

  @override
  Future dispose() {
    _resistEventStreamWrapper.dispose();
    _signalEventStreamWrapper.dispose();
    return super.dispose();
  }

  List<BrainBitSignalData> _onSignalDataReceived(dynamic data) =>
      List.unmodifiable(
        data.map<BrainBitSignalData>(
          (element) => BrainBitSignalData(
            packNum: element['PackNum'],
            marker: element['Marker'],
            o1: element['O1'],
            o2: element['O2'],
            t3: element['T3'],
            t4: element['T4'],
          ),
        ),
      );

  BrainBitResistData _onResistDataReceived(dynamic data) => BrainBitResistData(
        o1: data["O1"],
        o2: data["O2"],
        t3: data["T3"],
        t4: data["T4"],
      );
}
