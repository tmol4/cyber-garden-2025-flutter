import 'package:app/flutter.dart';
import 'package:bixat_key_mouse/bixat_key_mouse.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:app/app.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

const kDebugUi = bool.fromEnvironment("BORIS");
void main(List<String> arguments) async {
  // Initialize binding singletons
  WidgetsFlutterBinding.ensureInitialized();

  final settings = Settings.instance
    ..loadAll()
    ..saveAll();

  //
  await BixatKeyMouse.initialize();

  // Window
  await windowManager.ensureInitialized();

  final windowOptions = WindowOptions(
    title: "Cyber Garden 2025",
    minimumSize: const Size(360.0, 640.0),
    size: const Size(412.0, 664.0),
    alwaysOnTop: settings.alwaysOnTop,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await Future.value([
      if (!kDebugMode) windowManager.setPreventClose(true),
      windowManager.setMaximizable(false),
      windowManager.setResizable(true),
    ]);
    await windowManager.show();
    if (!kDebugMode) await windowManager.focus();
  });

  // Tray
  final menu = Menu(
    items: [
      // MenuItem.checkbox(
      //   key: "show_window",
      //   checked: true,
      //   label: "Показывать окно",
      // ),
      // MenuItem.separator(),
      MenuItem(key: "exit", label: "Выйти"),
    ],
  );
  await trayManager.setIcon("assets/images/tray_icon.ico");
  await trayManager.setToolTip("Cyber Garden 2025");
  await trayManager.setContextMenu(menu);

  runApp(const App());
}
