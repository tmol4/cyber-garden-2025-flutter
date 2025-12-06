import 'dart:io';
import 'dart:ui';

import 'package:bixat_key_mouse/bixat_key_mouse.dart';
import 'package:bixat_key_mouse/src/rust/api/bixat_key_mouse.dart'
    show
        moveMouseBase,
        simulateKeyBase,
        simulateKeyCombinationBase,
        enterTextBase,
        pressMouseButtonBase,
        scrollMouseBase;
import 'package:win32/win32.dart' show MapVirtualKey;

abstract class VirtualInputPlatform {
  VirtualInputPlatform();

  void moveMouse(Offset offset, Coordinate coordinate) {
    throw UnimplementedError("moveMouse() has not been implemented.");
  }

  void pressMouseButton(MouseButton button, Direction direction) {
    throw UnimplementedError("pressMouseButton() has not been implemented.");
  }

  void pressKeyboardKey(UniversalKey key, Direction direction) {
    throw UnimplementedError("pressKeyboardKey() has not been implemented.");
  }

  void pressKeyboardKeyCombo(List<UniversalKey> keys, Duration duration) {
    throw UnimplementedError(
      "pressKeyboardKeyCombo() has not been implemented.",
    );
  }

  void scrollMouse(double distance, ScrollAxis axis) {
    throw UnimplementedError("scrollMouse() has not been implemented.");
  }

  void enterText(String text) {
    throw UnimplementedError("enterText() has not been implemented.");
  }

  static VirtualInputPlatform _instance = VirtualInputDefault();

  // ignore: unnecessary_getters_setters
  static VirtualInputPlatform get instance => _instance;

  static set instance(VirtualInputPlatform instance) {
    _instance = instance;
  }
}

class VirtualInputDefault extends VirtualInputPlatform {
  VirtualInputDefault();

  @override
  void moveMouse(Offset offset, Coordinate coordinate) {
    moveMouseBase(
      x: offset.dx.round(),
      y: offset.dy.round(),
      coordinate: coordinate.index,
    );
  }

  @override
  void pressMouseButton(MouseButton button, Direction direction) {
    pressMouseButtonBase(button: button.index, direction: direction.index);
  }

  @override
  void pressKeyboardKey(UniversalKey key, Direction direction) {
    final int code;
    if (Platform.isWindows) {
      code = MapVirtualKey(key.code, 0);
      if (code == 0) return;
    } else {
      code = key.code;
    }
    simulateKeyBase(key: code, direction: direction.index);
  }

  @override
  void pressKeyboardKeyCombo(List<UniversalKey> keys, Duration duration) {
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

  @override
  void scrollMouse(double distance, ScrollAxis axis) {
    scrollMouseBase(distance: distance.round(), axis: axis.index);
  }

  @override
  void enterText(String text) {
    enterTextBase(text: text);
  }
}

abstract final class VirtualInput {
  static VirtualInputPlatform get _platform => VirtualInputPlatform.instance;

  void moveMouse(Offset offset, Coordinate coordinate) =>
      _platform.moveMouse(offset, coordinate);

  void pressMouseButton(MouseButton button, Direction direction) =>
      _platform.pressMouseButton(button, direction);

  void pressKeyboardKey(UniversalKey key, Direction direction) =>
      _platform.pressKeyboardKey(key, direction);

  void pressKeyboardKeyCombo(List<UniversalKey> keys, Duration duration) =>
      _platform.pressKeyboardKeyCombo(keys, duration);

  void scrollMouse(double distance, ScrollAxis axis) =>
      _platform.scrollMouse(distance, axis);

  void enterText(String text) => _platform.enterText(text);
}
