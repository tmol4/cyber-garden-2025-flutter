import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:neurosdk2/constants.dart';
import 'package:neurosdk2/event_channel_stream_wrapper.dart';
import 'package:neurosdk2/sensors_field.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

mixin AmpModeSensor {
  static const EventChannel _ampModeEventChannel =
      EventChannel(Constants.ampModeChangedEventName);
  static final Stream<dynamic> _ampModeChannelStream =
      _ampModeEventChannel.receiveBroadcastStream();

  Stream<FSensorAmpMode> get ampModeStream => _ampEventStreamWrapper.stream;
  late final SensorGetProperty<FSensorAmpMode> ampMode =
      SensorGetProperty(_guid, _api.getAmpMode);

  late final String _guid;
  late final NeuroApi _api;
  late final EventChannelStreamWrapper<FSensorAmpMode> _ampEventStreamWrapper;

  @protected
  @mustCallSuper
  void initAmpMode(String guid, NeuroApi api) {
    _guid = guid;
    _api = api;
    _ampEventStreamWrapper = EventChannelStreamWrapper(
        _guid, _ampModeChannelStream, (v) => FSensorAmpMode.values[v]);
  }

  @protected
  @mustCallSuper
  void disposeAmpMode() {
    _ampEventStreamWrapper.dispose();
  }
}
