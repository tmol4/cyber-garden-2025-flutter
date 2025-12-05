import 'package:flutter/foundation.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

mixin PingNeuroSmart {
  late final String _guid;
  late final NeuroApi _api;

  @protected
  void initNeuroSmart(String guid, NeuroApi api) {
    _guid = guid;
    _api = api;
  }

  Future<void> pingNeuroSmart(int marker) {
    return _api.pingNeuroSmart(_guid, marker);
  }
}
