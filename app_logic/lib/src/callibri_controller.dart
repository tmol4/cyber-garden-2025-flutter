import 'package:neurosdk2/neurosdk2.dart';

enum CallibriDataState { signal, envelope, mems }

enum CallibriConnectionState {
  connection,
  connected,
  disconnection,
  disconnected,
  error,
}

class CallibriInfo {
  const CallibriInfo({
    required this.name,
    required this.adress,
    required this.sensorInfo,
  });

  final String name;
  final String adress;
  final FSensorInfo sensorInfo;
}

class CallibriController {
  CallibriController();

  Scanner? _scanner;

  void _onSensorsChanged(List<FSensorInfo> data) {}

  Future<Scanner> _ensureScanner() async {
    if (_scanner case final scanner?) return scanner;
    final scanner = await Scanner.create(_filters)
      ..sensorsStream.listen(_onSensorsChanged);
    _scanner = scanner;
    return scanner;
  }

  void search({required Duration duration}) async {}

  void dispose() {}

  static const _filters = <FSensorFamily>[.leCallibri, .leKolibri];
}
