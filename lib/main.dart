import 'package:app/flutter.dart';
import 'package:bixat_key_mouse/bixat_key_mouse.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:app/app.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // Initialize binding singletons
  WidgetsFlutterBinding.ensureInitialized();

  //
  await BixatKeyMouse.initialize();

  // Window
  await windowManager.ensureInitialized();

  final windowOptions = const WindowOptions(
    title: "Cyber Garden 2025",
    size: const Size(360.0, 664.0),
    // titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await Future.value([
      windowManager.setPreventClose(true),
      windowManager.setMaximizable(false),
      windowManager.setResizable(false),
    ]);
    await windowManager.show();
  });

  // Tray
  final menu = Menu(
    items: [
      MenuItem.checkbox(
        key: "show_window",
        checked: true,
        label: "Показывать окно",
      ),
      MenuItem.separator(),
      MenuItem(key: "exit", label: "Выйти"),
    ],
  );
  await trayManager.setIcon("assets/images/tray_icon.ico");
  await trayManager.setToolTip("Cyber Garden 2025");
  await trayManager.setContextMenu(menu);

  runApp(const App());
}
