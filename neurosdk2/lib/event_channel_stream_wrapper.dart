import 'dart:async';
import 'package:neurosdk2/constants.dart';

class EventChannelStreamWrapper<T> {
  Stream<T> get stream => _streamController.stream;

  final String _guid;
  final T Function(dynamic value) _converter;

  final _streamController = StreamController<T>.broadcast();
  late final StreamSubscription _chanelStreamSubscription;

  EventChannelStreamWrapper(this._guid, Stream<dynamic> chanelStream, this._converter) {
    _chanelStreamSubscription = chanelStream.listen(_onDataReceived);
  }

  void dispose() {
    _chanelStreamSubscription.cancel();
  }

  void _onDataReceived(dynamic data) {
    if (data[Constants.guidId] != _guid) return;
    _streamController.sink.add(_converter(data[Constants.dataId]));
  }
}
