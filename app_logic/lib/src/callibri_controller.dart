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

  Future<void> _createScanner() async {
    if (_scanner != null) return;
    final scanner = await Scanner.create(_filters);
    _scanner = scanner;
  }

  void search({required Duration duration}) async {
    final scanner = await Scanner.create(_filters);
  }

  void dispose() {}

  static const _filters = <FSensorFamily>[.leCallibri, .leKolibri];
}
