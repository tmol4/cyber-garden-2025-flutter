import 'package:app/flutter.dart';
import 'package:app/main.dart';
import 'package:app_ui/app_ui.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:app_ui/app_ui_debug.dart' as app_ui_debug;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener, TrayListener {
  final _settings = Settings.instance;
  late SingleDeviceController _controller;

  ColorThemeData _createColorTheme({
    required Brightness brightness,
    bool highContrast = false,
  }) {
    return ColorThemeData.fromSeed(
      // sourceColor: Color(0xFF148DC6), // From website
      sourceColor: Color(0xFF1D59BC), // From case presentation
      brightness: brightness,
      contrastLevel: highContrast ? 1.0 : 0.0,
      variant: .vibrant,
      specVersion: .spec2025,
      platform: .phone,
    );
  }

  Widget _buildColorTheme(BuildContext context, Widget child) {
    final Brightness brightness = switch (_settings.themeMode) {
      .system => MediaQuery.platformBrightnessOf(context),
      .light => .light,
      .dark => .dark,
    };
    final highContrast = MediaQuery.highContrastOf(context);
    return ColorTheme(
      data: _createColorTheme(
        brightness: brightness,
        highContrast: highContrast,
      ),
      child: child,
    );
  }

  Widget _buildSpringTheme(BuildContext context, Widget child) =>
      SpringTheme(data: const SpringThemeData.expressive(), child: child);

  Widget _buildAppWrapper({
    Widget? child,
    required Widget Function(BuildContext context, Widget? child) builder,
  }) => CombiningBuilder(
    builders: [_buildColorTheme, _buildSpringTheme],
    child: Builder(builder: (context) => builder(context, child)),
  );

  Widget _buildHomeWrapper(BuildContext context, Widget? child) =>
      child ?? const SizedBox.shrink();

  Widget _buildMaterialApp(BuildContext context) {
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cyber Garden School 2025",
      themeMode: _settings.themeMode,
      theme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(brightness: .light, highContrast: false),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      darkTheme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(brightness: .dark, highContrast: false),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      highContrastTheme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(brightness: .light, highContrast: true),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      highContrastDarkTheme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(brightness: .dark, highContrast: true),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      builder: _buildHomeWrapper,
      home: kDebugUi
          ? const app_ui_debug.mainPage()
          : HomeView(controller: _controller),
    );
  }

  void _themeModeListener() {
    setState(() {});
  }

  void _alwaysOnTopListener() async {
    windowManager.setAlwaysOnTop(_settings.alwaysOnTop);
  }

  @override
  void onWindowClose() async {
    if (!kDebugMode) {
      await windowManager.hide();
    }
  }

  @override
  void onTrayIconMouseDown() async {
    debugPrint("onTrayIconMouseDown()");
    final isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
    }
  }

  @override
  void onTrayIconMouseUp() {
    debugPrint("onTrayIconMouseUp()");
  }

  @override
  void onTrayIconRightMouseDown() {
    debugPrint("onTrayIconRightMouseDown()");
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() async {
    debugPrint("onTrayIconRightMouseUp()");
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    debugPrint("onTrayMenuItemClick($menuItem)");
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _settings.onThemeModeChanged.addListener(_themeModeListener);
    _settings.onAlwaysOnTopChanged.addListener(_alwaysOnTopListener);
    _controller = SingleDeviceController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _settings.onAlwaysOnTopChanged.removeListener(_alwaysOnTopListener);
    _settings.onThemeModeChanged.removeListener(_themeModeListener);
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAppWrapper(
      builder: (context, child) => _buildMaterialApp(context),
    );
  }
}
