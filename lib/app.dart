import 'package:app/flutter.dart';
import 'package:app/theme/theme.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener, TrayListener {
  ColorThemeData _createColorTheme({
    required Brightness brightness,
    bool highContrast = false,
  }) {
    return ColorThemeData.fromSeed(
      sourceColor: Color(0xFF148DC6),
      brightness: brightness,
      contrastLevel: highContrast ? 1.0 : 0.0,
      variant: .vibrant,
      specVersion: .spec2025,
      platform: .phone,
    );
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
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
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cyber Garden 2025",
      themeMode: .system,
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

      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return Scaffold(
      body: Align.center(
        child: FilledButton(
          style: LegacyThemeFactory.createButtonStyle(
            colorTheme: colorTheme,
            elevationTheme: elevationTheme,
            shapeTheme: shapeTheme,
            stateTheme: stateTheme,
            typescaleTheme: typescaleTheme,
            size: .extraLarge,
            shape: .square,
            color: .outlined,
          ),
          onPressed: () {},
          child: Text("CLICK"),
        ),
      ),
    );
  }
}
