// ignore_for_file: empty_catches

library;

export 'src/custom_app_bar.dart';
export 'src/custom_list.dart';
export 'src/legacy.dart';
export 'src/utils.dart';
export 'src/virtual_input.dart';

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:app_ui/src/flutter.dart';
import 'package:bixat_key_mouse/bixat_key_mouse.dart';
import 'package:collection/collection.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

const _scannerSensorFilters = <FSensorFamily>[.leCallibri, .leKolibri];

enum CallibriDataState { signal, envelope, mems }

enum CallibriConnectionState {
  connection,
  connected,
  disconnection,
  disconnected,
  error,
}

abstract class CallibriStreamEvent {
  const CallibriStreamEvent({required this.sensor});

  final Callibri sensor;
}

class CallibriValueStreamEvent<T extends Object?> extends CallibriStreamEvent {
  const CallibriValueStreamEvent({required super.sensor, required this.value});

  final T value;
}

abstract interface class CallibriDevice {
  String get address;

  String get name;

  CallibriConnectionState get connectionState;

  Stream<CallibriConnectionState> get connectionStateStream;

  Future<int?> get batteryPowerFuture;

  int? get batteryPower;

  Stream<int?> get batteryPowerStream;

  Stream<List<MEMSData>> get memsDataStream;

  Stream<List<CallibriSignalData>> get signalDataStream;

  Stream<bool> get isActiveStream;

  bool get isActive;
}

class MutableCallibriDevice implements CallibriDevice {
  MutableCallibriDevice._({
    required Scanner scanner,
    required FSensorInfo sensorInfo,
  }) : _scanner = scanner,
       _sensorInfo = sensorInfo;

  final Scanner _scanner;

  final FSensorInfo _sensorInfo;

  Callibri? _sensor;

  @override
  String get address => _sensorInfo.address;

  @override
  String get name => _sensorInfo.name;

  @override
  CallibriConnectionState get connectionState =>
      _connectionStateController.value;

  final _connectionStateController =
      BehaviorSubject<CallibriConnectionState>.seeded(.disconnected);

  @override
  Stream<CallibriConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Future<int?> get batteryPowerFuture async =>
      await _sensor?.batteryPower.value;

  StreamSubscription<int>? _batteryPowerSubscription;

  final _batteryPowerController = BehaviorSubject<int?>.seeded(null);

  @override
  Stream<int?> get batteryPowerStream => _batteryPowerController.stream;

  @override
  int? get batteryPower => _batteryPowerController.value;

  StreamSubscription<List<MEMSData>>? _memsDataSubscription;

  final _memsDataController = StreamController<List<MEMSData>>.broadcast();

  @override
  Stream<List<MEMSData>> get memsDataStream => _memsDataController.stream;

  StreamSubscription<List<CallibriSignalData>>? _signalDataSubscription;

  final _signalDataController =
      StreamController<List<CallibriSignalData>>.broadcast();

  @override
  Stream<List<CallibriSignalData>> get signalDataStream =>
      _signalDataController.stream;

  final _isActiveController = BehaviorSubject<bool>.seeded(false);

  @override
  Stream<bool> get isActiveStream => _isActiveController.stream;

  @override
  bool get isActive => _isActiveController.value;

  @protected
  Future<Sensor?> createSensor() => _scanner.createSensor(_sensorInfo);

  Future<void> connect() async {
    _connectionStateController.add(.connection);
    try {
      final sensor = await _scanner.createSensor(_sensorInfo);
      if (sensor is Callibri) {
        _batteryPowerSubscription = sensor.batteryPowerStream.listen(
          _batteryPowerController.add,
        );
        _memsDataSubscription = sensor.memsDataStream.listen(
          _memsDataController.add,
        );
        _signalDataSubscription = sensor.signalDataStream.listen(
          _signalDataController.add,
        );
        await sensor.signalType.set(.EMG);
        _sensor = sensor;
        _connectionStateController.add(.connected);
      } else {
        _connectionStateController.add(.error);
      }
    } on Object {
      _connectionStateController.add(.error);
      rethrow;
    }
  }

  Future<void> setSamplingFrequency(FSensorSamplingFrequency value) async {
    if (_sensor case final sensor?) {
      await sensor.samplingFrequency.set(value);
    }
  }

  Future<void> start() async {
    if (_sensor case final sensor?) {
      await sensor.execute(.startMEMS);
      await sensor.execute(.startSignal);
      _isActiveController.add(true);
    }
  }

  Future<void> stop() async {
    if (_sensor case final sensor?) {
      await sensor.execute(.stopMEMS);
      await sensor.execute(.stopSignal);
      _isActiveController.add(false);
    }
  }

  Future<void> disconnect() async {
    _connectionStateController.add(.disconnection);
    try {
      await stop();
      await Future.wait<void>([
        ?_signalDataSubscription?.cancel(),
        ?_memsDataSubscription?.cancel(),
        ?_batteryPowerSubscription?.cancel(),
      ]);
      _batteryPowerController.add(null);
      await _sensor?.disconnect();
      await _sensor?.dispose();
      _sensor = null;
    } on Object {
      _connectionStateController.add(.error);
      rethrow;
    }
    _connectionStateController.add(.disconnected);
  }

  Future<void> dispose() async {
    _isActiveController.close();
    _signalDataController.close();
    _memsDataController.close();
    _batteryPowerController.close();
    _connectionStateController.close();
  }
}

extension Point3DExtension on Point3D {
  Vector3 toVector3() => Vector3(x, y, z);
}

class CallibriScannerController {
  CallibriScannerController();

  Scanner? _scanner;

  final _devicesController =
      BehaviorSubject<List<MutableCallibriDevice>?>.seeded(null);
  Stream<List<MutableCallibriDevice>?> get devicesStream =>
      _devicesController.stream;
  List<MutableCallibriDevice>? get devices => _devicesController.value;

  final _isScanningController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isScanningStream => _isScanningController.stream;
  bool get isScanning => _isScanningController.value;

  // Future<List<FSensorInfo>> get sensorsFuture async {
  //   final scanner = await _ensureScanner();
  //   final sensors = await scanner.getSensors();
  //   return sensors.nonNulls.toList(growable: false);
  // }

  // StreamSubscription<List<FSensorInfo>>? _sensorsSubscription;
  // final _sensorsController = BehaviorSubject<List<FSensorInfo>>();
  // Stream<List<FSensorInfo>?> get sensorsStream => _sensorsController.stream;
  // List<FSensorInfo>? get sensors => _sensorsController.valueOrNull;

  Future<Scanner> _ensureScanner() async {
    if (_scanner case final scanner?) return scanner;

    final scanner = await createScanner(_scannerSensorFilters);
    scanner.sensorsStream.listen((event) {
      // _sensorsController.add(event);
      final oldDevices = Map<String, MutableCallibriDevice>.fromEntries(
        devices?.map((device) => MapEntry(device.address, device)) ?? const [],
      );
      final newSensorInfos = Map.fromEntries(
        event.map((sensorInfo) => MapEntry(sensorInfo.address, sensorInfo)),
      );
      final addressesUnion = <String>{
        ...oldDevices.keys,
        ...newSensorInfos.keys,
      };
      final newDevices = addressesUnion
          .map<MutableCallibriDevice?>((address) {
            final oldDevice = oldDevices[address];
            final newSensorInfo = newSensorInfos[address];
            if (oldDevice != null && newSensorInfo != null) {
              return oldDevice;
            }
            if (oldDevice != null) {
              oldDevice.disconnect().then((_) => oldDevice.dispose());
              return null;
            }
            if (newSensorInfo != null) {
              final newDevice = MutableCallibriDevice._(
                scanner: scanner,
                sensorInfo: newSensorInfo,
              );
              return newDevice;
            }
            return null;
          })
          .nonNulls
          .toList(growable: false);
      _devicesController.add(newDevices);
    });
    return _scanner = scanner;
  }

  @protected
  Future<Scanner> createScanner(List<FSensorFamily> filters) async =>
      await Scanner.create(filters);

  Future<void> start() async {
    final scanner = await _ensureScanner();
    await scanner.start();
    _isScanningController.add(true);
  }

  Future<void> stop() async {
    final scanner = await _ensureScanner();
    await scanner.stop();
    _isScanningController.add(false);
  }

  Future<void> dispose() async {
    _isScanningController.close();

    // _sensorsSubscription?.cancel();
    // _sensorsController.close();

    await _scanner?.stop();

    if (devices case final devices?) {
      for (final device in devices) {
        await device.disconnect();
        await device.dispose();
      }
      _devicesController.add(null);
    }
    _devicesController.close();

    _scanner?.dispose();
  }
}

class MockCallibriController extends CallibriScannerController {
  @override
  Future<Scanner> createScanner(List<FSensorFamily> filters) async =>
      MockScanner(filters);
}

class MockScanner implements Scanner {
  MockScanner(this._filters)
    : _dataValues = UnmodifiableListView(
        _createDataList(filters: _filters, amount: 25),
      ) {
    _data = {
      for (final sensorInfo in _dataValues) sensorInfo.address: sensorInfo,
    };
  }

  final List<FSensorInfo> _dataValues;
  late final Map<String, FSensorInfo> _data;
  final List<FSensorFamily> _filters;
  Timer? _timer;

  final _sensorsController = StreamController<List<FSensorInfo>>.broadcast();

  List<FSensorInfo> _shuffledSubList(int length) {
    final shuffled = _dataValues.shuffled(_random);
    if (length >= _data.length) return shuffled;
    return shuffled.sublist(0, length);
  }

  @override
  Future<Sensor?> createSensor(FSensorInfo sensorInfo) async {
    if (!_data.containsKey(sensorInfo.address)) return null;
    return null;
  }

  @override
  Future<List<FSensorInfo?>> getSensors() async {
    return const [];
  }

  @override
  Stream<List<FSensorInfo>> get sensorsStream => _sensorsController.stream;

  @override
  Future<void> start() async {
    final alwaysAvailable = _dataValues[_random.nextInt(_dataValues.length)];
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final sublist = _shuffledSubList(_random.nextInt(_dataValues.length))
        ..remove(alwaysAvailable)
        ..insert(0, alwaysAvailable);
      _sensorsController.add(sublist);
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
  }

  @override
  void dispose() {}

  static const _uuid = Uuid();
  static final _random = math.Random();
  static List<FSensorInfo> _createDataList({
    required List<FSensorFamily> filters,
    required int amount,
  }) {
    return List.generate(amount, (index) {
      final address = _uuid.v4();
      return FSensorInfo(
        name: "Callibri_$index",
        address: address,
        serialNumber: _uuid.v4(),
        pairingRequired: true,
        sensModel: -1,
        sensFamily: .leCallibri,
        rssi: -1,
      );
    });
  }
}

class CallibriSingleController {
  CallibriSingleController() {
    _devicesSubscription = _controller.devicesStream.listen(_onDevicesChanged);
  }

  final _controller = CallibriScannerController();

  StreamSubscription<List<MutableCallibriDevice>?>? _devicesSubscription;

  final _currentDeviceController =
      BehaviorSubject<MutableCallibriDevice?>.seeded(null);

  Stream<MutableCallibriDevice?> get _currentDeviceStream =>
      _currentDeviceController.stream;
  Stream<CallibriDevice?> get currentDeviceStream => _currentDeviceStream;

  MutableCallibriDevice? get _currentDevice => _currentDeviceController.value;
  CallibriDevice? get currentDevice => _currentDevice;

  bool get isScanning => _controller.isScanning;
  Stream<bool> get isScanningStream => _controller.isScanningStream;

  List<CallibriDevice>? get devices => _controller.devices;
  Stream<List<CallibriDevice>?> get devicesStream => _controller.devicesStream;

  FSensorSamplingFrequency? _samplingFrequency;

  FSensorSamplingFrequency? get samplingFrequency => _samplingFrequency;

  set samplingFrequency(FSensorSamplingFrequency? value) {
    if (_samplingFrequency == value) return;
    _samplingFrequency = value;
    final currentDevice = _currentDevice;
    if (currentDevice != null && value != null) {
      currentDevice.setSamplingFrequency(value);
    }
  }

  void _onDevicesChanged(List<MutableCallibriDevice>? devices) async {
    devices ??= const [];
    final currentDevice = _currentDevice;
    if (currentDevice != null) {
      if (!devices.contains(currentDevice)) {
        try {
          await currentDevice.disconnect();
          await currentDevice.dispose();
        } on Object {}
      }
    }
  }

  Future<void> start() async {
    await _controller.start();
  }

  Future<void> stop() async {
    await _controller.stop();
  }

  Future<bool> connectTo(CallibriDevice device) async {
    final devices = _controller.devices;
    if (devices == null ||
        devices.isEmpty ||
        !devices.contains(device) ||
        _currentDevice != null) {
      return false;
    }
    try {
      assert(device is MutableCallibriDevice);
      device as MutableCallibriDevice;

      await device.connect();
      if (_samplingFrequency case final samplingFrequency?) {
        await device.setSamplingFrequency(samplingFrequency);
      }
      _currentDeviceController.add(device);
      return true;
    } on Object {
      _currentDeviceController.add(null);
      return false;
    }
  }

  Future<void> setSamplingFrequency(FSensorSamplingFrequency value) async {
    await _currentDevice?.setSamplingFrequency(value);
  }

  Future<void> startData() async {
    await _currentDevice?.start();
  }

  Future<void> stopData() async {
    await _currentDevice?.stop();
  }

  Future<bool> disconnectFrom(CallibriDevice device) async {
    if (_currentDevice != device) {
      return false;
    }
    try {
      assert(device is MutableCallibriDevice);
      device as MutableCallibriDevice;
      await stopData();
      await device.disconnect();
      _currentDeviceController.add(null);
      return true;
    } on Object {
      _currentDeviceController.add(null);
      return false;
    }
  }

  Future<bool> disconnect() async {
    final currentDevice = _currentDevice;
    if (currentDevice == null) return false;
    try {
      await stopData();
      await currentDevice.disconnect();
      _currentDeviceController.add(null);
      return true;
    } on Object {
      _currentDeviceController.add(null);
      return false;
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _devicesSubscription?.cancel();
    await _controller.dispose();
  }
}

enum GyroscopeControllerMode { calibration, calculation }

class GyroscopeController {
  GyroscopeController({int buffer = 10})
    : _cache = .generate(buffer, (_) => .zero());

  final List<Vector3> _cache;
  var _cacheIndex = 0;

  final _correctionVector = Vector3.zero();
  var _calibrationsAmount = 0;

  final _modeController = BehaviorSubject<GyroscopeControllerMode>.seeded(
    .calibration,
  );

  Stream<GyroscopeControllerMode> get modeStream => _modeController.stream;

  GyroscopeControllerMode get mode => _modeController.value;

  set mode(GyroscopeControllerMode value) {
    if (mode == value) return;
    _modeController.add(value);
    switch (value) {
      case .calibration:
        _correctionVector.setZero();
        _calibrationsAmount = 0;
      default:
    }
  }

  Vector3 _calculateAverageVector(Iterable<Vector3> values) {
    final result = Vector3.zero();
    var amount = 0;
    for (final value in values) {
      result.add(value);
      amount++;
    }
    final amountDouble = amount.toDouble();
    result.setValues(
      result.x / amountDouble,
      result.y / amountDouble,
      result.z / amountDouble,
    );
    return result;
  }

  void _addToCache(Iterable<Vector3> data) {
    for (final value in data) {
      _cache[_cacheIndex].setFrom(value);
      _cacheIndex = (_cacheIndex + 1) % _cache.length;
    }
  }

  void add(Iterable<Vector3> data) {
    if (data.isEmpty) return;
    const mouseMoveThreshold = 2.0;
    _addToCache(data);
    switch (mode) {
      case .calibration:
        for (final value in data) {
          _correctionVector.add(value);
          _calibrationsAmount++;
        }
      case .calculation:
        final averageVelocity = _calculateAverageVector(_cache);
        final averageCorrection =
            _correctionVector / _calibrationsAmount.toDouble();
        averageVelocity.sub(averageCorrection);
        print(averageVelocity);
    }
  }

  void addMemsData(Iterable<MEMSData> data) {
    add(data.map((value) => value.gyroscope.toVector3()));
  }

  void dispose() {}
}

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.controller,
    required this.gyroscopeController,
  });

  final CallibriSingleController controller;
  final GyroscopeController gyroscopeController;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _settings = Settings.instance;
  StreamSubscription<CallibriDevice?>? _currentDeviceSubscription;
  CallibriDevice? _currentDevice;

  // Widget _buildCurrentDeviceStream({
  //   required CallibriSingleController controller,
  //   required Widget Function(
  //     BuildContext context,
  //     CallibriDevice? currentDevice,
  //   )
  //   builder,
  // }) => StreamBuilder(
  //   stream: controller.currentDeviceStream,
  //   initialData: controller.currentDevice,
  //   builder: (context, snapshot) =>
  //       builder(context, snapshot.data ?? controller.currentDevice),
  // );

  Widget _buildBatterPowerStream({
    required CallibriDevice device,
    required Widget Function(BuildContext context, int? batteryPower) builder,
  }) => StreamBuilder(
    stream: device.batteryPowerStream,
    initialData: device.batteryPower,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? device.batteryPower),
  );

  Widget _buildIsActiveStream({
    required CallibriDevice device,
    required Widget Function(BuildContext context, bool isActive) builder,
  }) => StreamBuilder(
    stream: device.isActiveStream,
    initialData: device.isActive,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? device.isActive),
  );

  Widget _buildMode({
    required GyroscopeController controller,
    required Widget Function(BuildContext context, GyroscopeControllerMode mode)
    builder,
  }) => StreamBuilder(
    stream: controller.modeStream,
    initialData: controller.mode,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? controller.mode),
  );

  void _onCurrentDeviceChanged(CallibriDevice? currentDevice) {
    setState(() => _currentDevice = currentDevice);
    _didChangeDevice(currentDevice);
  }

  void _onSamplingFrequencyChanged() {
    widget.controller.samplingFrequency = _settings.samplingFrequency;
  }

  void _didChangeDevice(CallibriDevice? currentDevice) {
    currentDevice?.memsDataStream.listen((event) {
      widget.gyroscopeController.addMemsData(event);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentDevice = widget.controller.currentDevice;
    _currentDeviceSubscription = widget.controller.currentDeviceStream.listen(
      _onCurrentDeviceChanged,
    );
    _settings.onSamplingFrequencyChanged.addListener(
      _onSamplingFrequencyChanged,
    );
    widget.controller.samplingFrequency = _settings.samplingFrequency;
    _didChangeDevice(_currentDevice);
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _currentDeviceSubscription?.cancel();
      _currentDeviceSubscription = widget.controller.currentDeviceStream.listen(
        _onCurrentDeviceChanged,
      );
      _currentDevice = widget.controller.currentDevice;
      _didChangeDevice(_currentDevice);
    }
  }

  @override
  void dispose() {
    _settings.onSamplingFrequencyChanged.removeListener(
      _onSamplingFrequencyChanged,
    );
    _currentDeviceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final backgroundColor = colorTheme.surfaceContainer;
    final currentDevice = _currentDevice;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            type: .small,
            collapsedContainerColor: backgroundColor,
            expandedContainerColor: backgroundColor,
            collapsedPadding: const .fromLTRB(
              12.0 + 52.0 + 12.0,
              0.0,
              12.0 + 52.0 + 12.0,
              0.0,
            ),
            leading: Padding(
              padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Flex.horizontal(
                children: [
                  // ListenableBuilder(
                  //   listenable: _settings.onAlwaysOnTopChanged,
                  //   builder: (context, child) => IconButton(
                  //     style: LegacyThemeFactory.createIconButtonStyle(
                  //       colorTheme: colorTheme,
                  //       elevationTheme: elevationTheme,
                  //       shapeTheme: shapeTheme,
                  //       stateTheme: stateTheme,
                  //       typescaleTheme: typescaleTheme,
                  //       color: .standard,
                  //       unselectedContainerColor:
                  //           colorTheme.surfaceContainerHighest,
                  //       selectedContainerColor:
                  //           colorTheme.surfaceContainerHighest,
                  //       isSelected: _settings.alwaysOnTop,
                  //     ),
                  //     onPressed: () =>
                  //         _settings.alwaysOnTop = !_settings.alwaysOnTop,
                  //     icon: IconLegacy(
                  //       Symbols.keep_rounded,
                  //       fill: _settings.alwaysOnTop ? 1.0 : 0.0,
                  //     ),
                  //     tooltip: "Поверх других окон",
                  //   ),
                  // ),
                  // const SizedBox(width: 8.0 - 4.0),
                  IconButton(
                    style: LegacyThemeFactory.createIconButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      width: .wide,
                      color: .filled,
                      unselectedContainerColor:
                          colorTheme.surfaceContainerHighest,
                      isSelected: false,
                    ),
                    onPressed: () {},
                    icon: const IconLegacy(Symbols.menu_rounded, fill: 1.0),
                  ),
                ],
              ),
            ),
            title: const Text("CGS2025", textAlign: .center),
            trailing: Padding(
              padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Flex.horizontal(
                children: [
                  // ListenableBuilder(
                  //   listenable: _settings.onAlwaysOnTopChanged,
                  //   builder: (context, child) => IconButton(
                  //     style: LegacyThemeFactory.createIconButtonStyle(
                  //       colorTheme: colorTheme,
                  //       elevationTheme: elevationTheme,
                  //       shapeTheme: shapeTheme,
                  //       stateTheme: stateTheme,
                  //       typescaleTheme: typescaleTheme,
                  //       color: .standard,
                  //       unselectedContainerColor:
                  //           colorTheme.surfaceContainerHighest,
                  //       selectedContainerColor:
                  //           colorTheme.surfaceContainerHighest,
                  //       isSelected: _settings.alwaysOnTop,
                  //     ),
                  //     onPressed: () =>
                  //         _settings.alwaysOnTop = !_settings.alwaysOnTop,
                  //     icon: IconLegacy(
                  //       Symbols.keep_rounded,
                  //       fill: _settings.alwaysOnTop ? 1.0 : 0.0,
                  //     ),
                  //     tooltip: "Поверх других окон",
                  //   ),
                  // ),
                  // const SizedBox(width: 8.0 - 4.0),
                  IconButton(
                    style: LegacyThemeFactory.createIconButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      width: .wide,
                      color: .filled,
                      unselectedContainerColor:
                          colorTheme.surfaceContainerHighest,
                      isSelected: false,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const SettingsView(),
                      ),
                    ),
                    icon: const IconLegacy(Symbols.settings_rounded, fill: 1.0),
                    tooltip: "Настройки",
                  ),
                ],
              ),
            ),
          ),
          if (currentDevice != null)
            SliverList.list(
              children: [
                Padding(
                  padding: const .fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Flex.vertical(
                    crossAxisAlignment: .stretch,
                    spacing: 2.0,
                    children: [
                      ListItemContainer(
                        isFirst: true,
                        child: ListItemLayout(
                          isMultiline: true,
                          leading: Icon(
                            Symbols.label_rounded,
                            fill: 1.0,
                            color: colorTheme.primary,
                          ),
                          overline: Text(
                            "Имя устройства",
                            style: TextStyle(color: colorTheme.onSurface),
                          ),
                          headline: Text(
                            currentDevice.name,
                            style: TextStyle(color: colorTheme.primary),
                          ),
                        ),
                      ),

                      ListItemContainer(
                        child: ListItemLayout(
                          isMultiline: true,
                          leading: Icon(
                            Symbols.id_card_rounded,
                            fill: 1.0,
                            color: colorTheme.primary,
                          ),
                          overline: Text(
                            "Идентификатор устройства",
                            style: TextStyle(color: colorTheme.onSurface),
                          ),
                          headline: Text(
                            currentDevice.address,
                            style: TextStyle(color: colorTheme.primary),
                          ),
                        ),
                      ),

                      ListItemContainer(
                        child: ListItemLayout(
                          isMultiline: true,
                          leading: Icon(
                            Symbols.package_2_rounded,
                            fill: 1.0,
                            color: colorTheme.primary,
                          ),
                          overline: Text(
                            "Семейство устройства",
                            style: TextStyle(color: colorTheme.onSurface),
                          ),
                          headline: Text(
                            "Callibri SDK",
                            style: TextStyle(color: colorTheme.primary),
                          ),
                        ),
                      ),

                      _buildBatterPowerStream(
                        device: currentDevice,
                        builder: (context, batteryPower) {
                          final value = batteryPower != null
                              ? clampDouble(batteryPower / 100.0, 0.0, 100.0)
                              : 1.0;
                          final valuePercent = (value * 100.0).round();
                          return ListItemContainer(
                            isLast: true,
                            child: ListItemLayout(
                              isMultiline: true,
                              leading: Icon(
                                Symbols.battery_android_full_rounded,
                                fill: 1.0,
                                color: colorTheme.primary,
                              ),
                              overline: Text(
                                "Уровень заряда батареи",
                                style: TextStyle(color: colorTheme.onSurface),
                              ),
                              headline: Text(
                                batteryPower != null
                                    ? "$valuePercent%"
                                    : "Неизвестен",
                                style: TextStyle(color: colorTheme.primary),
                              ),
                              trailing: batteryPower != null
                                  ? SizedBox.square(
                                      dimension: 40.0,
                                      child: CircularProgressIndicator(
                                        padding: .zero,
                                        value: kDebugMode ? value / 2 : value,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const .fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Flex.vertical(
                    crossAxisAlignment: .stretch,
                    children: [
                      _buildIsActiveStream(
                        device: currentDevice,
                        builder: (context, isActive) => FilledButton(
                          style: LegacyThemeFactory.createButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            size: .medium,
                            shape: .round,
                            color: .filled,
                            selectedContainerColor: colorTheme.primary,
                            unselectedContainerColor: colorTheme.primary,
                            selectedContentColor: colorTheme.onPrimary,
                            unselectedContentColor: colorTheme.onPrimary,
                            isSelected: isActive,
                          ),
                          onPressed: () async {
                            if (isActive) {
                              widget.controller.stopData();
                            } else {
                              widget.controller.startData();
                            }
                          },
                          child: Flex.horizontal(
                            mainAxisSize: .min,
                            spacing: 8.0,
                            children: [
                              isActive
                                  ? const IconLegacy(
                                      Symbols.stop_rounded,
                                      fill: 1.0,
                                    )
                                  : const IconLegacy(
                                      Symbols.play_arrow_rounded,
                                      fill: 1.0,
                                    ),
                              Text("Старт"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      _buildMode(
                        controller: widget.gyroscopeController,
                        builder: (context, mode) => FilledButton(
                          style: LegacyThemeFactory.createButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            size: .medium,
                            shape: .round,
                            color: .tonal,
                          ),
                          onPressed: () {
                            widget.gyroscopeController.mode = switch (mode) {
                              .calibration => .calculation,
                              .calculation => .calibration,
                            };
                          },
                          child: Flex.horizontal(
                            mainAxisSize: .min,
                            spacing: 8.0,
                            children: [
                              IconLegacy(
                                Symbols.compass_calibration_rounded,
                                fill: 1.0,
                              ),
                              mode == .calibration
                                  ? Text("ФФФФ")
                                  : Text("Калибровать"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0 - 4.0),
                      FilledButton(
                        style: LegacyThemeFactory.createButtonStyle(
                          colorTheme: colorTheme,
                          elevationTheme: elevationTheme,
                          shapeTheme: shapeTheme,
                          stateTheme: stateTheme,
                          typescaleTheme: typescaleTheme,
                          size: .small,
                          shape: .round,
                          containerColor: colorTheme.errorContainer,
                          contentColor: colorTheme.onErrorContainer,
                        ),
                        onPressed: () {},
                        child: const Flex.horizontal(
                          mainAxisSize: .min,
                          spacing: 8.0,
                          children: [
                            IconLegacy(Symbols.close_rounded),
                            Text("Отсоединиться"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            SliverPadding(
              padding: const .fromLTRB(16.0, 0.0, 16.0, 0.0),
              sliver: SliverFillRemaining(
                fillOverscroll: false,
                hasScrollBody: false,
                child: Flex.vertical(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .stretch,
                  children: [
                    Align.center(
                      child: SizedBox(
                        width: 128.0,
                        height: 96.0,
                        child: Material(
                          animationDuration: .zero,
                          clipBehavior: .antiAlias,
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Icon(
                            Symbols.nest_hello_doorbell_rounded,
                            fill: 1.0,
                            opticalSize: 32.0,
                            size: 32.0,
                            color: colorTheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "Добавление устройства",
                      textAlign: .center,
                      style: typescaleTheme.bodyLarge.toTextStyle(
                        color: colorTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "Для начала работы подключитесь к устройству Callibri",
                      textAlign: .center,
                      style: typescaleTheme.bodyMedium.toTextStyle(
                        color: colorTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Align.center(
                      child: FilledButton(
                        style: LegacyThemeFactory.createButtonStyle(
                          colorTheme: colorTheme,
                          elevationTheme: elevationTheme,
                          shapeTheme: shapeTheme,
                          stateTheme: stateTheme,
                          typescaleTheme: typescaleTheme,
                          size: .medium,
                          shape: .square,
                          color: .filled,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<Object?>(
                            builder: (context) =>
                                DevicesView(controller: widget.controller),
                          ),
                        ),
                        child: Flex.horizontal(
                          mainAxisSize: .min,
                          spacing: 8.0,
                          children: [
                            const IconLegacy(Symbols.add_rounded),
                            const Text("Подключиться"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DevicesView extends StatefulWidget {
  const DevicesView({super.key, required this.controller});
  final CallibriSingleController controller;

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  Timer? _timer;

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () async {
      await _start();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _start() async {
    setState(() => _stopTimer());
    await widget.controller.start();
  }

  Future<void> _stop() async {
    setState(() => _stopTimer());
    await widget.controller.stop();
  }

  Widget _buildIsScanningStream({
    required CallibriSingleController controller,
    required Widget Function(BuildContext context, bool isScanning) builder,
  }) => StreamBuilder(
    stream: controller.isScanningStream,
    initialData: controller.isScanning,
    builder: (context, snapshot) {
      final isScanning = snapshot.data ?? controller.isScanning;
      return builder(context, isScanning);
    },
  );
  Widget _buildDevicesStream({
    required CallibriSingleController controller,
    required Widget Function(
      BuildContext context,
      List<CallibriDevice>? devices,
    )
    builder,
  }) => StreamBuilder(
    stream: controller.devicesStream,
    initialData: controller.devices,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? controller.devices),
  );

  Widget _buildConnetionStateStream({
    required CallibriDevice device,
    required Widget Function(
      BuildContext context,
      CallibriConnectionState connectionState,
    )
    builder,
  }) => StreamBuilder(
    stream: device.connectionStateStream,
    initialData: device.connectionState,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? device.connectionState),
  );

  Widget _buildBatteryPowerStream({
    required CallibriDevice device,
    required Widget Function(BuildContext context, int? batteryPower) builder,
  }) => StreamBuilder(
    stream: device.batteryPowerStream,
    initialData: device.batteryPower,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? device.batteryPower),
  );

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final backgroundColor = colorTheme.surfaceContainer;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildDevicesStream(
            controller: widget.controller,
            builder: (context, devices) {
              final canSearch =
                  kDebugMode && devices != null && devices.isNotEmpty;
              return CustomAppBar(
                type: .small,
                collapsedContainerColor: backgroundColor,
                expandedContainerColor: backgroundColor,
                leading: Padding(
                  padding: const .fromLTRB(12.0 - 4.0, 0.0, 12.0 - 4.0, 0.0),
                  child: IconButton(
                    style: LegacyThemeFactory.createIconButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      color: .filled,
                      unselectedContainerColor:
                          colorTheme.surfaceContainerHighest,
                      isSelected: false,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const IconLegacy(Symbols.arrow_back_rounded),
                    tooltip: "Назад",
                  ),
                ),
                title: const Text("Подключение"),
                trailing: Padding(
                  padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
                  child: IconButton(
                    style: LegacyThemeFactory.createIconButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      color: .tonal,
                      width: .wide,
                    ),
                    onPressed: canSearch ? () {} : null,
                    icon: const IconLegacy(Symbols.search_rounded),
                    tooltip: "Поиск",
                  ),
                ),
                collapsedPadding: .fromLTRB(
                  12.0 + 40.0 + 12.0,
                  0.0,
                  12.0 + 40.0 + 12.0,
                  0.0,
                ),
              );
            },
          ),
          _buildIsScanningStream(
            controller: widget.controller,
            builder: (context, isScanning) => _buildDevicesStream(
              controller: widget.controller,
              builder: (context, devices) {
                if (devices != null && devices.isNotEmpty) {
                  return SliverPadding(
                    padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
                    sliver: SliverList.separated(
                      itemCount: devices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2.0),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return KeyedSubtree(
                          key: ValueKey(device.address),
                          child: _buildConnetionStateStream(
                            device: device,
                            builder: (context, connectionState) => _buildBatteryPowerStream(
                              device: device,
                              builder: (context, batteryPower) => ListItemContainer(
                                isFirst: index == 0,
                                isLast: index == devices.length - 1,
                                containerShape:
                                    connectionState == .connected ||
                                        connectionState == .connection
                                    ? CornersBorder.rounded(
                                        corners: .all(
                                          shapeTheme.corner.largeIncreased,
                                        ),
                                      )
                                    : null,
                                containerColor:
                                    connectionState == .connected ||
                                        connectionState == .connection
                                    ? colorTheme.secondaryContainer
                                    : null,
                                child: ListItemInteraction(
                                  onTap: () async {
                                    _stop();
                                    if (connectionState == .disconnected) {
                                      final result = await widget.controller
                                          .connectTo(device);
                                      if (context.mounted && result) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  child: ListItemLayout(
                                    isMultiline: true,
                                    leading: SizedBox.square(
                                      dimension: 40.0,
                                      child: Material(
                                        color: colorTheme.surfaceContainer,
                                        shape: CornersBorder.rounded(
                                          corners: .all(shapeTheme.corner.full),
                                        ),
                                        child: Stack(
                                          alignment: .center,
                                          children: [
                                            // SizedBox.square(
                                            //   dimension: 40.0,
                                            //   child: CircularProgressIndicator(
                                            //     value: null,
                                            //     padding: .zero,
                                            //     strokeWidth: 2.0,
                                            //     backgroundColor: Colors.transparent,
                                            //   ),
                                            // ),
                                            Icon(
                                              Symbols
                                                  .nest_hello_doorbell_rounded,
                                              fill: 1.0,
                                              color: colorTheme.primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    headline: Text(
                                      "${device.name} (${device.address})",
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      style: TextStyle(
                                        color: colorTheme.primary,
                                      ),
                                    ),
                                    supportingText: Text(
                                      connectionState == .connected
                                          ? "$batteryPower%"
                                          : "Нажмите, чтобы подключить",
                                      style: typescaleTheme.bodySmall
                                          .toTextStyle(
                                            color: colorTheme.onSurface,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  final Widget child;
                  if (_timer != null) {
                    child = Padding(
                      padding: .fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Flex.vertical(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .stretch,
                        children: [
                          Icon(
                            Symbols.timer_rounded,
                            fill: 1.0,
                            size: 40.0,
                            color: colorTheme.primary,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Автостарт",
                            textAlign: .center,
                            style: typescaleTheme.bodyLarge.toTextStyle(
                              color: colorTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Через несколько секунд начнётся автоматическое сканирование устройств",
                            textAlign: .center,
                            style: typescaleTheme.bodyMedium.toTextStyle(
                              color: colorTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16.0 - 4.0),
                          Align.center(
                            child: FilledButton(
                              style: LegacyThemeFactory.createButtonStyle(
                                colorTheme: colorTheme,
                                elevationTheme: elevationTheme,
                                shapeTheme: shapeTheme,
                                stateTheme: stateTheme,
                                typescaleTheme: typescaleTheme,
                                size: .small,
                                shape: .round,
                                color: .tonal,
                              ),
                              onPressed: () {
                                setState(() => _stopTimer());
                              },
                              child: Text("Отмена"),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!isScanning) {
                    child = Padding(
                      padding: .fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Flex.vertical(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .stretch,
                        children: [
                          Icon(
                            Symbols.stop_circle_rounded,
                            fill: 1.0,
                            color: colorTheme.primary,
                            size: 40.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Поиск остановлен",
                            textAlign: .center,
                            style: typescaleTheme.bodyLarge.toTextStyle(
                              color: colorTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Нажмите \"Сканировать\", чтобы начать сканирование",
                            textAlign: .center,
                            style: typescaleTheme.bodyMedium.toTextStyle(
                              color: colorTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (devices != null && devices.isEmpty) {
                    child = Padding(
                      padding: .fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Flex.vertical(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .stretch,
                        children: [
                          Icon(
                            Symbols.radar_rounded,
                            fill: 1.0,
                            color: colorTheme.primary,
                            size: 40.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Устройств не обнаружено",
                            textAlign: .center,
                            style: typescaleTheme.bodyLarge.toTextStyle(
                              color: colorTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Попробуйте провести стандартные процедуры устранения неполадок",
                            textAlign: .center,
                            style: typescaleTheme.bodyMedium.toTextStyle(
                              color: colorTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    child = Padding(
                      padding: .fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Flex.vertical(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .stretch,
                        children: [
                          Icon(
                            Symbols.radar_rounded,
                            fill: 1.0,
                            color: colorTheme.primary,
                            size: 40.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Начинаем сканирование",
                            textAlign: .center,
                            style: typescaleTheme.bodyLarge.toTextStyle(
                              color: colorTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Здесь появится список найденных устройств",
                            textAlign: .center,
                            style: typescaleTheme.bodyMedium.toTextStyle(
                              color: colorTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SliverFillRemaining(
                    fillOverscroll: false,
                    hasScrollBody: false,
                    child: child,
                  );
                }
              },
            ),
          ),
          // SliverList.list(
          //   children: [
          //     Flex.vertical(
          //       crossAxisAlignment: .stretch,
          //       children: [
          //         const SizedBox(height: 8.0),
          //         Align.center(
          //           child: SizedBox.square(
          //             dimension: 64.0,
          //             child: IndeterminateLoadingIndicator(contained: false),
          //           ),
          //         ),
          //         const SizedBox(height: 4.0),
          //         Text(
          //           "Поиск устройств",
          //           textAlign: .center,
          //           overflow: .ellipsis,
          //           style: typescaleTheme.labelLarge.toTextStyle(
          //             color: colorTheme.primary,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        width: .infinity,
        child: Material(
          color: backgroundColor,
          child: Padding(
            padding: const .fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Flex.vertical(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                _buildIsScanningStream(
                  controller: widget.controller,
                  builder: (context, isScanning) => FilledButton(
                    style: LegacyThemeFactory.createButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      size: .medium,
                      shape: .square,
                      color: .filled,
                      isSelected: !isScanning,
                      unselectedContainerColor:
                          colorTheme.surfaceContainerHighest,
                    ),
                    onPressed: () async {
                      if (isScanning) {
                        await _stop();
                      } else {
                        await _start();
                      }
                    },
                    child: Flex.horizontal(
                      mainAxisSize: .min,
                      spacing: isScanning ? 8.0 : 8.0,
                      children: [
                        // IconLegacy(
                        //   isScanning
                        //       ? Symbols.pause_rounded
                        //       : Symbols.play_arrow_rounded,
                        //   fill: 1.0,
                        // ),
                        if (isScanning)
                          SizedBox.square(
                            dimension: 24.0,
                            child: IndeterminateLoadingIndicator(
                              contained: false,
                              indicatorColor: colorTheme.onSurfaceVariant,
                            ),
                            // child: CircularProgressIndicator(
                            //   value: null,
                            //   strokeWidth: 2.0,
                            //   color: colorTheme.onSurfaceVariant,
                            //   backgroundColor: Colors.transparent,
                            // ),
                          )
                        else
                          const IconLegacy(
                            Symbols.play_arrow_rounded,
                            fill: 1.0,
                          ),
                        Text(isScanning ? "Приостановить" : "Сканировать"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

extension FSensorSamplingFrequencyExtension on FSensorSamplingFrequency {
  int? get value => switch (this) {
    .hz10 => 10,
    .hz20 => 20,
    .hz100 => 100,
    .hz125 => 125,
    .hz250 => 250,
    .hz500 => 500,
    .hz1000 => 1000,
    .hz2000 => 2000,
    .hz4000 => 4000,
    .hz8000 => 8000,
    .hz10000 => 10000,
    .hz12000 => 12000,
    .hz16000 => 16000,
    .hz24000 => 24000,
    .hz32000 => 32000,
    .hz48000 => 48000,
    .hz64000 => 64000,
    _ => null,
  };

  static FSensorSamplingFrequency? tryParse(int? value) => switch (value) {
    10 => .hz10,
    20 => .hz20,
    100 => .hz100,
    125 => .hz125,
    250 => .hz250,
    500 => .hz500,
    1000 => .hz1000,
    2000 => .hz2000,
    4000 => .hz4000,
    8000 => .hz8000,
    10000 => .hz10000,
    12000 => .hz12000,
    16000 => .hz16000,
    24000 => .hz24000,
    32000 => .hz32000,
    48000 => .hz48000,
    64000 => .hz64000,
    _ => null,
  };
}

class _SettingsViewState extends State<SettingsView> {
  final _settings = Settings.instance;

  static const _samplingFrequencies = <FSensorSamplingFrequency>[
    .hz100,
    .hz250,
    .hz500,
    .hz1000,
    .hz2000,
    .hz4000,
    .hz8000,
    .hz10000,
  ];

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final backgroundColor = colorTheme.surfaceContainer;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            type: .small,
            collapsedContainerColor: backgroundColor,
            expandedContainerColor: backgroundColor,
            leading: Padding(
              padding: const .fromLTRB(12.0 - 4.0, 0.0, 12.0 - 4.0, 0.0),
              child: IconButton(
                style: LegacyThemeFactory.createIconButtonStyle(
                  colorTheme: colorTheme,
                  elevationTheme: elevationTheme,
                  shapeTheme: shapeTheme,
                  stateTheme: stateTheme,
                  typescaleTheme: typescaleTheme,
                  color: .filled,
                  unselectedContainerColor: colorTheme.surfaceContainerHighest,
                  isSelected: false,
                ),
                onPressed: () => Navigator.pop(context),
                icon: const IconLegacy(Symbols.arrow_back_rounded),
                tooltip: "Назад",
              ),
            ),
            title: Text("Настройки"),
            collapsedPadding: .fromLTRB(12.0 + 40.0 + 12.0, 0.0, 16.0, 0.0),
          ),
          SliverPadding(
            padding: const .fromLTRB(16.0, 0.0, 16.0, 16.0),
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: .fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Text(
                    "Поведение",
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: _settings.onAlwaysOnTopChanged,
                  builder: (context, _) => ListItemContainer(
                    isFirst: true,
                    child: ListItemInteraction(
                      onTap: () =>
                          _settings.alwaysOnTop = !_settings.alwaysOnTop,
                      child: ListItemLayout(
                        isMultiline: true,
                        leading: const Icon(
                          Symbols.select_window_rounded,
                          fill: 1.0,
                        ),
                        headline: const Text("Поверх других окон"),
                        supportingText: const Text(
                          "Закрепить окно поверх других",
                        ),
                        trailing: Switch(
                          onCheckedChanged: (value) =>
                              _settings.alwaysOnTop = value,
                          checked: _settings.alwaysOnTop,
                        ),
                      ),
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: _settings.onSamplingFrequencyChanged,
                  builder: (context, child) => ListItemContainer(
                    child: Flex.vertical(
                      crossAxisAlignment: .stretch,
                      children: [
                        ListItemInteraction(
                          onTap: _settings.samplingFrequency != .hz250
                              ? () {
                                  _settings.samplingFrequency = .hz250;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Значение параметра сброшено",
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: ListItemLayout(
                            isMultiline: true,
                            leading: const Icon(Symbols.vital_signs_rounded),
                            headline: Text("Частота ЭМГ"),
                            supportingText: Text(
                              "Частота считывания мышечной активности",
                            ),
                            trailing: _settings.samplingFrequency.value != null
                                ? Text(
                                    "${_settings.samplingFrequency.value} Гц",
                                  )
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const .fromLTRB(
                            16.0,
                            8.0 - 2.0,
                            16.0,
                            16.0 - 2.0,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: (_samplingFrequencies.length - 1).toDouble(),
                            value: _samplingFrequencies
                                .indexOf(_settings.samplingFrequency)
                                .toDouble(),
                            divisions: _samplingFrequencies.length - 1,
                            onChanged: (value) {
                              final index = value.round();
                              final newValue = _samplingFrequencies
                                  .elementAtOrNull(index);
                              if (newValue != null) {
                                _settings.samplingFrequency = newValue;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListenableBuilder(
                  listenable: _settings.onGyroscopeSensitivityChanged,
                  builder: (context, child) => ListItemContainer(
                    isLast: true,
                    child: Flex.vertical(
                      crossAxisAlignment: .stretch,
                      children: [
                        ListItemInteraction(
                          onTap: _settings.gyroscopeSensitivity != 0.5
                              ? () {
                                  _settings.gyroscopeSensitivity = 0.5;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Значение параметра сброшено",
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: ListItemLayout(
                            isMultiline: true,
                            leading: const Icon(
                              Symbols.threed_rotation_rounded,
                            ),
                            headline: Text("Чувствительность гироскопа"),
                            supportingText: Text(
                              "Размах вращательных движений",
                            ),
                            trailing: Text(
                              "${(_settings.gyroscopeSensitivity * 100).round()}%",
                            ),
                          ),
                        ),
                        Padding(
                          padding: const .fromLTRB(
                            16.0,
                            8.0 - 2.0,
                            16.0,
                            16.0 - 2.0,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: 1.0,
                            value: _settings.gyroscopeSensitivity,
                            onChanged: (value) {
                              _settings.gyroscopeSensitivity = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: .fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Text(
                    "Внешний вид",
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: _settings.onThemeModeChanged,
                  builder: (context, child) => DropdownMenuFormField<ThemeMode>(
                    expandedInsets: .zero,
                    initialSelection: _settings.themeMode,
                    enableFilter: false,
                    enableSearch: false,
                    textStyle: typescaleTheme.titleMedium.toTextStyle(
                      color: colorTheme.onSurface,
                    ),
                    leadingIcon: const IconLegacy(
                      Symbols.brightness_6_rounded,
                      fill: 1.0,
                    ),
                    label: const Text("Тема"),
                    onSelected: (value) {
                      if (value != null) _settings.themeMode = value;
                    },
                    inputDecorationTheme: const InputDecorationThemeData(
                      border: UnderlineInputBorder(),
                      filled: true,
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: .system,
                        leadingIcon: IconLegacy(
                          Symbols.auto_mode_rounded,
                          fill: 1.0,
                        ),
                        label: "Как в системе",
                      ),
                      DropdownMenuEntry(
                        value: .light,
                        leadingIcon: IconLegacy(
                          Symbols.light_mode_rounded,
                          fill: 1.0,
                        ),
                        label: "Светлая",
                      ),
                      DropdownMenuEntry(
                        value: .dark,
                        leadingIcon: IconLegacy(
                          Symbols.dark_mode_rounded,
                          fill: 1.0,
                        ),
                        label: "Тёмная",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: .fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Text(
                    "Прочее",
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListItemContainer(
                  isFirst: true,
                  isLast: true,
                  child: ListItemInteraction(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const AboutView(),
                      ),
                    ),
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: const Icon(Symbols.info_rounded, fill: 1.0),
                      headline: Text("О приложении"),
                      supportingText: Text("Различная информация"),
                      trailing: const Icon(
                        Symbols.keyboard_arrow_right_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final backgroundColor = colorTheme.surfaceContainer;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            type: .small,
            collapsedContainerColor: backgroundColor,
            expandedContainerColor: backgroundColor,
            leading: Padding(
              padding: const .fromLTRB(12.0 - 4.0, 0.0, 12.0 - 4.0, 0.0),
              child: IconButton(
                style: LegacyThemeFactory.createIconButtonStyle(
                  colorTheme: colorTheme,
                  elevationTheme: elevationTheme,
                  shapeTheme: shapeTheme,
                  stateTheme: stateTheme,
                  typescaleTheme: typescaleTheme,
                  color: .filled,
                  unselectedContainerColor: colorTheme.surfaceContainerHighest,
                  isSelected: false,
                ),
                onPressed: () => Navigator.pop(context),
                icon: const IconLegacy(Symbols.arrow_back_rounded),
                tooltip: "Назад",
              ),
            ),
            title: Text("О приложении"),
            collapsedPadding: .fromLTRB(12.0 + 40.0 + 12.0, 0.0, 16.0, 0.0),
          ),
          SliverPadding(
            padding: .fromLTRB(12.0, 0.0, 12.0, 0.0),
            sliver: SliverList.list(
              children: [
                ListItemContainer(
                  isFirst: true,
                  child: ListItemInteraction(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse(
                          "https://github.com/tmol4/cyber-garden-2025-flutter",
                        ),
                      );
                    },
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: const Icon(SimpleIcons.github),
                      headline: Text("Исходный код"),
                      supportingText: Text("Открыть проект на GitHub"),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  isLast: true,
                  child: ListItemInteraction(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const LicensePage(
                          applicationName: "Callibri",
                          applicationLegalese:
                              "Copyright (c) 2025 The TMOL4 Team Members",
                        ),
                      ),
                    ),
                    child: ListItemLayout(
                      leading: const Icon(Symbols.license_rounded, fill: 1.0),
                      headline: Text("Лицензии"),
                      supportingText: Text("Просмотреть лицензии открытого ПО"),
                      trailing: const Icon(
                        Symbols.keyboard_arrow_right_rounded,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const .fromLTRB(16.0, 8.0, 0.0, 8.0),
                  child: Text(
                    "Команда",
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListItemContainer(
                  isFirst: true,
                  child: ListItemInteraction(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse("https://github.com/deminearchiver"),
                      );
                    },
                    onLongPress: () {},
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: SizedBox.square(
                        dimension: 40.0,
                        child: Material(
                          animationDuration: .zero,
                          clipBehavior: .antiAlias,
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Image.asset(
                            "assets/images/deminearchiver.png",
                          ),
                        ),
                      ),
                      headline: Text(
                        "@deminearchiver",
                        style: TextStyle(color: colorTheme.primary),
                      ),
                      supportingText: Text("Открыть пользователя в GitHub"),
                      // supportingText: Text(
                      //   "Удерживайте, чтобы скопировать",
                      //   style: TextStyle(color: colorTheme.onSurface),
                      // ),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: ListItemInteraction(
                    onTap: () async {
                      await launchUrl(Uri.parse("https://github.com/Besute"));
                    },
                    onLongPress: () {},
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: SizedBox.square(
                        dimension: 40.0,
                        child: Material(
                          animationDuration: .zero,
                          clipBehavior: .antiAlias,
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Icon(
                            Symbols.account_circle_rounded,
                            fill: 1.0,
                            color: colorTheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      headline: Text(
                        "@Besute",
                        style: TextStyle(color: colorTheme.primary),
                      ),
                      supportingText: Text("Открыть пользователя в GitHub"),
                      // supportingText: Text(
                      //   "Удерживайте, чтобы скопировать",
                      //   style: TextStyle(color: colorTheme.onSurface),
                      // ),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: ListItemInteraction(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse("https://github.com/Olegogonich"),
                      );
                    },
                    onLongPress: () {},
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: SizedBox.square(
                        dimension: 40.0,
                        child: Material(
                          animationDuration: .zero,
                          clipBehavior: .antiAlias,
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Icon(
                            Symbols.account_circle_rounded,
                            fill: 1.0,
                            color: colorTheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      headline: Text(
                        "@Olegogonich",
                        style: TextStyle(color: colorTheme.primary),
                      ),
                      supportingText: Text("Открыть пользователя в GitHub"),
                      // supportingText: Text(
                      //   "Удерживайте, чтобы скопировать",
                      //   style: TextStyle(color: colorTheme.onSurface),
                      // ),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: ListItemInteraction(
                    onTap: () async {
                      await launchUrl(Uri.parse("https://github.com/Dizotec"));
                    },
                    onLongPress: () {},
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: SizedBox.square(
                        dimension: 40.0,
                        child: Material(
                          animationDuration: .zero,
                          clipBehavior: .antiAlias,
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Icon(
                            Symbols.account_circle_rounded,
                            fill: 1.0,
                            color: colorTheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      headline: Text(
                        "@Dizotec",
                        style: TextStyle(color: colorTheme.primary),
                      ),
                      supportingText: Text("Открыть пользователя в GitHub"),
                      // supportingText: Text(
                      //   "Удерживайте, чтобы скопировать",
                      //   style: TextStyle(color: colorTheme.onSurface),
                      // ),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  isLast: true,
                  child: ListItemInteraction(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse("https://github.com/Sofia2008-15"),
                      );
                    },
                    onLongPress: () {},
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: SizedBox.square(
                        dimension: 40.0,
                        child: Material(
                          animationDuration: .zero,
                          clipBehavior: .antiAlias,
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Icon(
                            Symbols.account_circle_rounded,
                            fill: 1.0,
                            color: colorTheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      headline: Text(
                        "@Sofia2008-15",
                        style: TextStyle(color: colorTheme.primary),
                      ),
                      supportingText: Text("Открыть пользователя в GitHub"),
                      // supportingText: Text(
                      //   "Удерживайте, чтобы скопировать",
                      //   style: TextStyle(color: colorTheme.onSurface),
                      // ),
                      trailing: const Icon(Symbols.open_in_new_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notifier extends ChangeNotifier {
  _Notifier() {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  void notify() => notifyListeners();
}

class Settings with ChangeNotifier {
  Settings._({required SharedPreferencesAsync sharedPreferencesAsync})
    : _prefs = sharedPreferencesAsync {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  final SharedPreferencesAsync _prefs;

  final _themeModeNotifier = _Notifier();
  Listenable get onThemeModeChanged => _themeModeNotifier;
  ThemeMode _themeMode = .system;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    _themeModeNotifier.notify();
    notifyListeners();
    saveOnly(themeMode: true);
  }

  final _alwaysOnTopNotifier = _Notifier();
  Listenable get onAlwaysOnTopChanged => _alwaysOnTopNotifier;
  bool _alwaysOnTop = false;
  bool get alwaysOnTop => _alwaysOnTop;
  set alwaysOnTop(bool value) {
    if (_alwaysOnTop == value) return;
    _alwaysOnTop = value;
    _alwaysOnTopNotifier.notify();
    notifyListeners();
    saveOnly(alwaysOnTop: true);
  }

  final _samplingFrequencyNotifier = _Notifier();
  Listenable get onSamplingFrequencyChanged => _samplingFrequencyNotifier;
  FSensorSamplingFrequency _samplingFrequency = .hz250;
  FSensorSamplingFrequency get samplingFrequency => _samplingFrequency;
  set samplingFrequency(FSensorSamplingFrequency value) {
    if (_samplingFrequency == value || value.value == null) return;
    _samplingFrequency = value;
    _samplingFrequencyNotifier.notify();
    notifyListeners();
    saveOnly(samplingFrequency: true);
  }

  final _gyroscopeSensitivityNotifier = _Notifier();
  Listenable get onGyroscopeSensitivityChanged => _gyroscopeSensitivityNotifier;
  double _gyroscopeSensitivity = 0.5;
  double get gyroscopeSensitivity => _gyroscopeSensitivity;
  set gyroscopeSensitivity(double value) {
    if (_gyroscopeSensitivity == value) return;
    _gyroscopeSensitivity = value;
    _gyroscopeSensitivityNotifier.notify();
    notifyListeners();
    saveOnly(gyroscopeSensitivity: true);
  }

  void _notifyAllListeners() {
    _themeModeNotifier.notify();
    _alwaysOnTopNotifier.notify();
    _samplingFrequencyNotifier.notify();
    notifyListeners();
  }

  Future<void> loadOnly({
    bool themeMode = false,
    bool alwaysOnTop = false,
    bool samplingFrequency = false,
    bool gyroscopeSensitivity = false,
  }) async {
    final futures = <Future<bool>>[];
    if (themeMode) {
      final future = _prefs.getString("themeMode").then((data) {
        final ThemeMode value = switch (data?.toLowerCase()) {
          "light" => .light,
          "dark" => .dark,
          _ => .system,
        };
        if (_themeMode != value) {
          _themeMode = value;
          return true;
        } else {
          return false;
        }
      });
      futures.add(future);
    }
    if (alwaysOnTop) {
      final future = _prefs.getBool("alwaysOnTop").then((data) {
        final value = data ?? false;
        if (_alwaysOnTop != value) {
          _alwaysOnTop = value;
          return true;
        } else {
          return false;
        }
      });
      futures.add(future);
    }
    if (samplingFrequency) {
      final future = _prefs.getInt("samplingFrequency").then((data) {
        final value =
            FSensorSamplingFrequencyExtension.tryParse(data) ?? .hz250;
        if (_samplingFrequency != value) {
          _samplingFrequency = value;
          return true;
        } else {
          return false;
        }
      });
      futures.add(future);
    }
    if (gyroscopeSensitivity) {
      final future = _prefs.getDouble("gyroscopeSensitivity").then((data) {
        final value = data ?? 0.5;
        if (_gyroscopeSensitivity != value) {
          _gyroscopeSensitivity = value;
          return true;
        } else {
          return false;
        }
      });
      futures.add(future);
    }
    if (futures.isNotEmpty) {
      final result = await Future.wait(futures);
      if (result.contains(true)) {
        _notifyAllListeners();
      }
    }
  }

  Future<void> loadAll() =>
      loadOnly(themeMode: true, alwaysOnTop: true, samplingFrequency: true);

  Future<void> saveOnly({
    bool themeMode = false,
    bool alwaysOnTop = false,
    bool samplingFrequency = false,
    bool gyroscopeSensitivity = false,
  }) async {
    final futures = <Future<void>>[];
    if (themeMode) {
      final data = _themeMode.name;
      final future = _prefs.setString("themeMode", data);
      futures.add(future);
    }
    if (alwaysOnTop) {
      final data = _alwaysOnTop;
      final future = _prefs.setBool("alwaysOnTop", data);
      futures.add(future);
    }
    if (samplingFrequency) {
      final data = _samplingFrequency.value;
      if (data != null) {
        final future = _prefs.setInt("samplingFrequency", data);
        futures.add(future);
      }
    }
    if (gyroscopeSensitivity) {
      final data = _gyroscopeSensitivity;
      final future = _prefs.setDouble("gyroscopeSensitivity", data);
      futures.add(future);
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> saveAll() =>
      saveOnly(themeMode: true, alwaysOnTop: true, samplingFrequency: true);

  static Settings? _instance;

  static Settings get instance {
    if (_instance case final instance?) return instance;
    final instance = Settings._(
      sharedPreferencesAsync: SharedPreferencesAsync(),
    );
    return _instance = instance;
  }

  static set instance(Settings value) {
    instance = value;
  }
}
