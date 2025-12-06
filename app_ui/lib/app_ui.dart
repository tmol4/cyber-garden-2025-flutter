library;

export 'src/custom_app_bar.dart';
export 'src/custom_list.dart';
export 'src/legacy.dart';
export 'src/utils.dart';

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

import 'package:bixat_key_mouse/src/key_code_manager.dart';
import 'package:bixat_key_mouse/src/rust/api/bixat_key_mouse.dart'
    show simulateKeyBase, simulateKeyCombinationBase;
import 'package:win32/win32.dart' show MapVirtualKey, MapVirtualKeyEx;

abstract final class InputSimulator {
  static void simulateKey(UniversalKey key, {Direction direction = .click}) {
    final int code;
    if (Platform.isWindows) {
      code = MapVirtualKey(key.code, 0);
      if (code == 0) return;
    } else {
      code = key.code;
    }
    simulateKeyBase(key: code, direction: direction.index);
  }

  static void simulateKeyCombination(
    List<UniversalKey> keys,
    Duration duration,
  ) {
    final List<int> codes;
    if (Platform.isWindows) {
      codes = keys
          .map((key) => MapVirtualKey(key.code, 0))
          .toList(growable: false);
      if (codes.any((value) => value <= 0)) {
        return;
      }
    } else {
      codes = keys.map((key) => key.code).toList(growable: false);
    }
    simulateKeyCombinationBase(
      keys: codes,
      durationMs: BigInt.from(duration.inMilliseconds),
    );
  }
}

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

  Stream<List<MEMSData>> get memsDataStream;
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

  Stream<int?> get batteryPowerStream => _batteryPowerController.stream;

  @override
  int? get batteryPower => _batteryPowerController.value;

  final _memsDataController = StreamController<List<MEMSData>>.broadcast();

  @override
  Stream<List<MEMSData>> get memsDataStream => _memsDataController.stream;

  @protected
  Future<Sensor?> createSensor() => _scanner.createSensor(_sensorInfo);

  Future<void> connect() async {
    _connectionStateController.add(.connection);
    try {
      final sensor = await _scanner.createSensor(_sensorInfo);
      if (sensor is Callibri) {
        _batteryPowerSubscription = sensor.batteryPowerStream.listen((event) {
          _batteryPowerController.add(event);
        });
        _connectionStateController.add(.connected);
        _sensor = sensor;
      } else {
        _connectionStateController.add(.error);
      }
    } on Object {
      _connectionStateController.add(.error);
    }
  }

  Future<void> disconnect() async {
    _connectionStateController.add(.disconnection);
    try {
      _batteryPowerSubscription?.cancel();
      _batteryPowerController.add(null);
      await _sensor?.disconnect();
      await _sensor?.dispose();
      _sensor = null;
    } on Object {
      return;
    }
    _connectionStateController.add(.disconnected);
  }

  Future<void> dispose() async {
    _batteryPowerController.close();
    _connectionStateController.close();
  }
}

class CallibriController {
  CallibriController();

  Scanner? _scanner;

  final _devicesController =
      BehaviorSubject<List<MutableCallibriDevice>?>.seeded(null);
  Stream<List<MutableCallibriDevice>?> get devicesStream =>
      _devicesController.stream;
  List<MutableCallibriDevice>? get devices => _devicesController.value;

  final _isScanningController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isScanningStream => _isScanningController.stream;
  bool get isScanning => _isScanningController.value;

  Future<List<FSensorInfo>> get sensorsFuture async {
    final scanner = await _ensureScanner();
    final sensors = await scanner.getSensors();
    return sensors.nonNulls.toList(growable: false);
  }

  StreamSubscription<List<FSensorInfo>>? _sensorsSubscription;
  final _sensorsController = BehaviorSubject<List<FSensorInfo>>();
  Stream<List<FSensorInfo>?> get sensorsStream => _sensorsController.stream;
  List<FSensorInfo>? get sensors => _sensorsController.valueOrNull;

  Future<Scanner> _ensureScanner() async {
    if (_scanner case final scanner?) return scanner;

    final scanner = await createScanner(_scannerSensorFilters);
    scanner.sensorsStream.listen((event) {
      _sensorsController.add(event);

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

  Future<MutableCallibriDevice?> connectTo(FSensorInfo sensorInfo) async {
    final scanner = await _ensureScanner();
    final sensor = await scanner.createSensor(sensorInfo);
    if (sensor is Callibri) {
      // final device = CallibriDevice._(sensorInfo: sensorInfo, sensor: sensor);
      // _devices[device.address] = device;
      // return device;
    }

    return null;
  }

  Future<void> dispose() async {
    _isScanningController.close();

    _sensorsSubscription?.cancel();
    _sensorsController.close();

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

class MockCallibriController extends CallibriController {
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

class SingleDeviceController {
  SingleDeviceController();

  final _controller = CallibriController();
  MutableCallibriDevice? _device;

  List<CallibriDevice>? get devices => _controller.devices;
  Stream<List<CallibriDevice>?> get devicesStream => _controller.devicesStream;

  Future<void> start() async {
    await _controller.start();
  }

  Future<void> stop() async {
    await _controller.stop();
  }

  Future<void> connectTo(CallibriDevice device) async {
    final devices = _controller.devices;
    if (devices == null || devices.isEmpty) return;
    if (!devices.contains(device)) return;
    assert(device is MutableCallibriDevice);
    device as MutableCallibriDevice;
    await device.connect();
  }

  Future<void> disconnectFrom(CallibriDevice device) async {
    final devices = _controller.devices;
    if (devices == null || devices.isEmpty) return;
    if (!devices.contains(device)) return;
    assert(device is MutableCallibriDevice);
    device as MutableCallibriDevice;
    await device.disconnect();
  }

  void dispose() {
    _controller.dispose();
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.controller});

  final SingleDeviceController controller;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _settings = Settings.instance;

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
            title: const Text("Callibri"),
            collapsedPadding: const .fromLTRB(
              16.0,
              0.0,
              12.0 + 40.0 + 12.0,
              0.0,
            ),
            trailing: Padding(
              padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Flex.horizontal(
                children: [
                  ListenableBuilder(
                    listenable: _settings.onAlwaysOnTopChanged,
                    builder: (context, child) => IconButton(
                      style: LegacyThemeFactory.createIconButtonStyle(
                        colorTheme: colorTheme,
                        elevationTheme: elevationTheme,
                        shapeTheme: shapeTheme,
                        stateTheme: stateTheme,
                        typescaleTheme: typescaleTheme,
                        color: .standard,
                        unselectedContainerColor:
                            colorTheme.surfaceContainerHighest,
                        selectedContainerColor:
                            colorTheme.surfaceContainerHighest,
                        isSelected: _settings.alwaysOnTop,
                      ),
                      onPressed: () =>
                          _settings.alwaysOnTop = !_settings.alwaysOnTop,
                      icon: IconLegacy(
                        Symbols.keep_rounded,
                        fill: _settings.alwaysOnTop ? 1.0 : 0.0,
                      ),
                      tooltip: "Настройки",
                    ),
                  ),
                  const SizedBox(width: 8.0 - 4.0),
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
          SliverFillRemaining(
            fillOverscroll: false,
            hasScrollBody: false,
            child: Flex.vertical(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              children: [
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
        ],
      ),
    );
  }
}

class DevicesView extends StatefulWidget {
  const DevicesView({super.key, required this.controller});
  final SingleDeviceController controller;

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  late CallibriController _controller;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      _start();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _start() async {
    setState(() => _stopTimer());
    await _controller.start();
  }

  void _stop() async {
    setState(() => _stopTimer());
    await _controller.stop();
  }

  Widget _buildIsScanningStream({
    required Widget Function(BuildContext context, bool isScanning) builder,
  }) => StreamBuilder(
    stream: _controller.isScanningStream,
    initialData: _controller.isScanning,
    builder: (context, snapshot) {
      final isScanning = snapshot.data ?? _controller.isScanning;
      return builder(context, isScanning);
    },
  );
  Widget _buildDevicesStream({
    required Widget Function(
      BuildContext context,
      List<MutableCallibriDevice>? devices,
    )
    builder,
  }) => StreamBuilder(
    stream: _controller.devicesStream,
    initialData: _controller.devices,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? _controller.devices),
  );

  Widget _buildConnetionStateStream({
    required MutableCallibriDevice device,
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
    required MutableCallibriDevice device,
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
    _controller = CallibriController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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
            builder: (context, isScanning) => _buildDevicesStream(
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
                                    switch (connectionState) {
                                      case .disconnected:
                                        await device.connect();
                                      case .connected:
                                        await device.disconnect();
                                      default:
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
                    onPressed: () {
                      if (isScanning) {
                        _stop();
                      } else {
                        _start();
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
                  listenable: _settings.onSamplingFrequencyChanged,
                  builder: (context, child) => ListItemContainer(
                    isFirst: true,
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
