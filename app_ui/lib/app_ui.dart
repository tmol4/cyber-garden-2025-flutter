library;

export 'src/custom_app_bar.dart';
export 'src/custom_list.dart';
export 'src/legacy.dart';
export 'src/utils.dart';

import 'dart:async';

import 'package:app_ui/src/flutter.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class CallibriController {
  CallibriController();

  Scanner? _scanner;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  final StreamController<bool> _isScanningController = BehaviorSubject.seeded(
    false,
  );

  Stream<bool> get isScanningStream => _isScanningController.stream;

  final StreamController<List<FSensorInfo>> _sensorsController =
      StreamController.broadcast();

  StreamSubscription<List<FSensorInfo>>? _sensorsSubscription;

  Stream<List<FSensorInfo>> get sensorsStream => _sensorsController.stream;

  Future<Scanner> _ensureScanner() async {
    if (_scanner case final scanner?) return scanner;

    final scanner = await Scanner.create(_filters);
    scanner.sensorsStream.listen(_onSensorsChanged);

    return _scanner = scanner;
  }

  void _onSensorsChanged(List<FSensorInfo> event) {
    _sensorsController.add(event);
  }

  Future<void> start() async {
    final scanner = await _ensureScanner();
    await scanner.start();
    _isScanning = true;
    _isScanningController.add(true);
  }

  Future<void> stop() async {
    final scanner = await _ensureScanner();
    await scanner.stop();
    _isScanning = false;
    _isScanningController.add(false);
  }

  Future<void> dispose() async {
    _isScanningController.close();

    _sensorsSubscription?.cancel();
    _sensorsController.close();

    await _scanner?.stop();
    _scanner?.dispose();
  }

  static const _filters = <FSensorFamily>[.leCallibri, .leKolibri];
}

Future<void> _isolateStart(Scanner message) async {
  await message.start();
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const AboutView(),
                  ),
                ),
                icon: const IconLegacy(Symbols.info_rounded, fill: 1.0),
                tooltip: "О приложении",
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
    // return Scaffold(
    //   backgroundColor: colorTheme.surfaceContainer,
    //   body: CustomScrollView(
    //     slivers: [
    //       // SliverHeader(minExtent: minExtent, maxExtent: maxExtent, builder: builder),
    //       CustomAppBar(
    //         type: .small,
    //         collapsedContainerColor: colorTheme.surfaceContainer,
    //         expandedContainerColor: colorTheme.surfaceContainer,
    //         // title: Text("Нейротех"),
    //         trailing: Padding(
    //           padding: .fromLTRB(8.0, 0.0, 8.0, 0.0),
    //           child: Flex.horizontal(
    //             children: [
    //               FilledButton.icon(
    //                 style: LegacyThemeFactory.createButtonStyle(
    //                   colorTheme: colorTheme,
    //                   elevationTheme: elevationTheme,
    //                   shapeTheme: shapeTheme,
    //                   stateTheme: stateTheme,
    //                   typescaleTheme: typescaleTheme,
    //                   size: .small,
    //                   color: .filled,
    //                   unselectedContainerColor:
    //                       colorTheme.surfaceContainerHighest,
    //                   isSelected: false,
    //                 ),
    //                 onPressed: () {},
    //                 icon: const IconLegacy(Symbols.battery_80_rounded),
    //                 label: Text("80%"),
    //               ),
    //               IconButton(
    //                 style: LegacyThemeFactory.createIconButtonStyle(
    //                   colorTheme: colorTheme,
    //                   elevationTheme: elevationTheme,
    //                   shapeTheme: shapeTheme,
    //                   stateTheme: stateTheme,
    //                   typescaleTheme: typescaleTheme,
    //                   size: .small,
    //                   shape: .round,
    //                   width: .normal,
    //                   color: .standard,
    //                   unselectedContainerColor:
    //                       colorTheme.surfaceContainerHighest,
    //                   isSelected: false,
    //                 ),
    //                 onPressed: () {},
    //                 icon: const IconLegacy(Symbols.refresh_rounded, fill: 0.0),
    //               ),
    //               IconButton(
    //                 style: LegacyThemeFactory.createIconButtonStyle(
    //                   colorTheme: colorTheme,
    //                   elevationTheme: elevationTheme,
    //                   shapeTheme: shapeTheme,
    //                   stateTheme: stateTheme,
    //                   typescaleTheme: typescaleTheme,
    //                   size: .small,
    //                   shape: .round,
    //                   width: .normal,
    //                   color: .standard,
    //                   unselectedContainerColor:
    //                       colorTheme.surfaceContainerHighest,
    //                   isSelected: false,
    //                 ),
    //                 onPressed: () {},
    //                 icon: const IconLegacy(Symbols.keep_rounded, fill: 0.0),
    //               ),
    //               IconButton(
    //                 style: LegacyThemeFactory.createIconButtonStyle(
    //                   colorTheme: colorTheme,
    //                   elevationTheme: elevationTheme,
    //                   shapeTheme: shapeTheme,
    //                   stateTheme: stateTheme,
    //                   typescaleTheme: typescaleTheme,
    //                   size: .small,
    //                   shape: .round,
    //                   width: .normal,
    //                   color: .standard,
    //                   unselectedContainerColor:
    //                       colorTheme.surfaceContainerHighest,
    //                   isSelected: false,
    //                 ),
    //                 onPressed: () {},
    //                 icon: const IconLegacy(Symbols.settings_rounded),
    //               ),
    //             ],
    //           ),
    //         ),
    //         // bottom: PreferredSize(
    //         //   preferredSize: Size(.infinity, 4.0),
    //         //   child: LinearProgressIndicator(value: null),
    //         // ),
    //       ),
    //       SliverPadding(
    //         padding: const .fromLTRB(8.0, 0.0, 8.0, 0.0),
    //         sliver: SliverList.separated(
    //           itemCount: 5,
    //           separatorBuilder: (context, index) => const SizedBox(height: 2.0),
    //           itemBuilder: (context, index) => ListItemContainer(
    //             isFirst: index == 0,
    //             isLast: index == 5 - 1,
    //             child: ListItemInteraction(
    //               onTap: () {},
    //               child: ListItemLayout(
    //                 isMultiline: false,
    //                 leading: const Icon(Symbols.sensors),
    //                 headline: Text("Callibri_Yellow"),
    //                 trailing: const Text("80%"),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       SliverList.list(
    //         children: [
    //           FilledButton(
    //             style: LegacyThemeFactory.createButtonStyle(
    //               colorTheme: colorTheme,
    //               elevationTheme: elevationTheme,
    //               shapeTheme: shapeTheme,
    //               stateTheme: stateTheme,
    //               typescaleTheme: typescaleTheme,
    //               size: .medium,
    //             ),
    //             onPressed: () {},
    //             child: Flex.horizontal(
    //               mainAxisSize: .min,
    //               spacing: 8.0,
    //               children: [
    //                 const IconLegacy(Symbols.add_rounded),
    //                 const Text("Подключиться"),
    //               ],
    //             ),
    //           ),
    //           const SizedBox(height: 8.0),
    //           Padding(
    //             padding: const .fromLTRB(16.0, 8.0, 16.0, 12.0),
    //             child: Flex.vertical(
    //               crossAxisAlignment: CrossAxisAlignment.stretch,
    //               children: [
    //                 Align.center(
    //                   child: SizedBox.square(
    //                     dimension: 48.0,
    //                     child: IndeterminateLoadingIndicator(contained: false),
    //                   ),
    //                 ),
    //                 const SizedBox(height: 4.0),
    //                 Text(
    //                   "Ищем устройства",
    //                   textAlign: TextAlign.center,
    //                   overflow: TextOverflow.ellipsis,
    //                   style: typescaleTheme.labelLarge.toTextStyle(
    //                     color: colorTheme.primary,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}

class DevicesView extends StatefulWidget {
  const DevicesView({super.key});

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  late CallibriController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CallibriController();
  }

  @override
  void dispose() {
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
            title: Text("Подключение"),
            collapsedPadding: .fromLTRB(12.0 + 40.0 + 12.0, 0.0, 16.0, 0.0),
          ),
          SliverList.list(
            children: [
              Padding(
                padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
                child: StreamBuilder(
                  stream: _controller.isScanningStream,
                  builder: (context, snapshot) {
                    final isScanning = snapshot.data ?? false;
                    return FilledButton(
                      style: LegacyThemeFactory.createButtonStyle(
                        colorTheme: colorTheme,
                        elevationTheme: elevationTheme,
                        shapeTheme: shapeTheme,
                        stateTheme: stateTheme,
                        typescaleTheme: typescaleTheme,
                        size: .small,
                        shape: .square,
                        color: .tonal,
                        isSelected: !isScanning,
                      ),
                      onPressed: () {
                        if (isScanning) {
                          _controller.stop();
                        } else {
                          _controller.start();
                        }
                      },
                      child: Flex.horizontal(
                        mainAxisSize: .min,
                        spacing: 8.0,
                        children: [
                          IconLegacy(
                            isScanning
                                ? Symbols.pause_rounded
                                : Symbols.play_arrow_rounded,
                            fill: 1.0,
                          ),
                          Text(
                            isScanning ? "Остановить поиск" : "Начать поиск",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0 - 4.0),
            ],
          ),
          SliverPadding(
            padding: const .fromLTRB(12.0, 0.0, 12.0, 0.0),
            sliver: SliverList.separated(
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: 2.0),
              itemBuilder: (context, index) => ListItemContainer(
                isFirst: index == 0,
                isLast: index == 3 - 1,
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
                      "Callibri_Yellow",
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
              ),
            ),
          ),
          SliverList.list(
            children: [
              StreamBuilder(
                stream: _controller.sensorsStream,
                builder: (context, snapshot) => Text("${snapshot.data}"),
              ),

              Flex.vertical(
                crossAxisAlignment: .stretch,
                children: [
                  const SizedBox(height: 8.0),
                  Align.center(
                    child: SizedBox.square(
                      dimension: 64.0,
                      child: IndeterminateLoadingIndicator(contained: false),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "Поиск устройств",
                    textAlign: .center,
                    overflow: .ellipsis,
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
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

class UserData {
  const UserData({this.image, required this.name, this.displayName});

  final ImageProvider<Object?>? image;
  final String name;
  final String? displayName;
}
