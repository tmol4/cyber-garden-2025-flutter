library;

export 'src/custom_app_bar.dart';
export 'src/custom_list.dart';
export 'src/legacy.dart';
export 'src/utils.dart';

import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:app_ui/src/flutter.dart';
import 'package:collection/collection.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

const _scannerSensorFilters = <FSensorFamily>[.leCallibri, .leKolibri];

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

abstract class CallibriStreamEvent {
  const CallibriStreamEvent({required this.sensor});

  final Callibri sensor;
}

class CallibriValueStreamEvent<T extends Object?> extends CallibriStreamEvent {
  const CallibriValueStreamEvent({required super.sensor, required this.value});

  final T value;
}

class CallibriDevice {
  CallibriDevice._({required Scanner scanner, required FSensorInfo sensorInfo})
    : _scanner = scanner,
      _sensorInfo = sensorInfo;

  final Scanner _scanner;
  final FSensorInfo _sensorInfo;
  Callibri? _sensor;

  String get address => _sensorInfo.address;
  String get name => _sensorInfo.name;

  CallibriConnectionState get connectionState =>
      _connectionStateController.value;

  final _connectionStateController =
      BehaviorSubject<CallibriConnectionState>.seeded(.disconnected);
  Stream<CallibriConnectionState> get connetionStateStream =>
      _connectionStateController.stream;

  Future<int?> get batteryPower async => await _sensor?.batteryPower.value;
  StreamSubscription<int>? _batteryPowerSubscription;
  final _batteryPowerController = StreamController<int>.broadcast();
  Stream<int> get batteryPowerStream => _batteryPowerController.stream;

  @protected
  Future<Sensor?> createSensor() => _scanner.createSensor(_sensorInfo);

  Future<void> connect() async {
    _connectionStateController.add(.connection);
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
  }

  Future<void> disconnect() async {
    _connectionStateController.add(.disconnection);

    _batteryPowerSubscription?.cancel();
    await _sensor?.disconnect();
    await _sensor?.dispose();
    _sensor = null;

    _connectionStateController.add(.disconnected);
  }

  void dispose() async {
    _batteryPowerController.close();
    _connectionStateController.close();
  }
}

class CallibriController {
  CallibriController();

  Scanner? _scanner;

  final _devicesController = BehaviorSubject<Map<String, CallibriDevice>>();
  Stream<Map<String, CallibriDevice>> get devicesStream =>
      _devicesController.stream;
  Map<String, CallibriDevice>? get devices => _devicesController.valueOrNull;

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

      final oldDevices = devices ?? const {};
      final newSensorInfos = Map.fromEntries(
        event.map((sensorInfo) => MapEntry(sensorInfo.address, sensorInfo)),
      );

      final addressesUnion = <String>{
        ...oldDevices.keys,
        ...newSensorInfos.keys,
      };

      final newDevices = Map.fromEntries(
        addressesUnion.map<MapEntry<String, CallibriDevice>?>((address) {
          final oldDevice = oldDevices[address];
          final newSensorInfo = newSensorInfos[address];
          if (oldDevice != null && newSensorInfo != null) {
            return MapEntry(address, oldDevice);
          }
          if (oldDevice != null) {
            oldDevice.disconnect().then((_) => oldDevice.dispose());
            return null;
          }
          if (newSensorInfo != null) {
            final newDevice = CallibriDevice._(
              scanner: scanner,
              sensorInfo: newSensorInfo,
            );
            return MapEntry(address, newDevice);
          }
          return null;
        }).nonNulls,
      );
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

  Future<CallibriDevice?> connectTo(FSensorInfo sensorInfo) async {
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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
            title: Text("Нейротех"),
            trailing: Padding(
              padding: .fromLTRB(0.0, 0.0, 12.0 - 4.0, 0.0),
              child: Flex.horizontal(
                children: [
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
                  IconButton(
                    style: LegacyThemeFactory.createIconButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      width: .narrow,
                      color: .standard,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const AboutView(),
                      ),
                    ),
                    icon: const IconLegacy(Symbols.info_rounded, fill: 1.0),
                    tooltip: "О приложении",
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
                        builder: (context) => DevicesView(),
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
  const DevicesView({super.key});

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
      Map<String, CallibriDevice>? devices,
    )
    builder,
  }) => StreamBuilder(
    stream: _controller.devicesStream,
    initialData: _controller.devices,
    builder: (context, snapshot) =>
        builder(context, snapshot.data ?? _controller.devices),
  );

  @override
  void initState() {
    super.initState();
    _controller = MockCallibriController();
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
                title: Text("Подключение"),
                trailing: Padding(
                  padding: const .fromLTRB(12.0 - 4.0, 0.0, 12.0 - 4.0, 0.0),
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
                  final devicesList = devices.values.toList(growable: false);
                  return SliverPadding(
                    padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
                    sliver: SliverList.separated(
                      itemCount: devicesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2.0),
                      itemBuilder: (context, index) {
                        final sensorInfo = devicesList[index];
                        return ListItemContainer(
                          isFirst: index == 0,
                          isLast: index == devices.length - 1,
                          child: ListItemInteraction(
                            onTap: () {},
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
                                        Symbols.add_rounded,
                                        fill: 1.0,
                                        color: colorTheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              headline: Text(
                                sensorInfo.name,
                                style: TextStyle(color: colorTheme.primary),
                              ),
                              supportingText: Text(
                                "Нажмите, чтобы подключить",
                                style: typescaleTheme.bodySmall.toTextStyle(
                                  color: colorTheme.onSurface,
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

class _SettingsViewState extends State<SettingsView> {
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
                          applicationName: "Нейротех",
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
