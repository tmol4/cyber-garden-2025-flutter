import 'package:bixat_key_mouse/bixat_key_mouse.dart';

void move_mouse(int x,int y){
  BixatKeyMouse.moveMouse(
    x: x,
    y: y,
    coordinate: Coordinate.relative, // May be absolute version
    );
}
void scroll_up(int z){
  BixatKeyMouse.moveMouse(
    x: 300,
    y: -300,
    coordinate: Coordinate.relative, // May be absolute version
    );
  BixatKeyMouse.pressMouseButton(
  button: MouseButton.left,
  direction: Direction.click,
  );
  BixatKeyMouse.scrollMouse(
  distance: -z,
  axis: ScrollAxis.vertical,
  );
}
void scroll_dw(int z){
  BixatKeyMouse.moveMouse(
    x: 300,
    y: -300,
    coordinate: Coordinate.relative, // May be absolute version
    );
  BixatKeyMouse.pressMouseButton(
  button: MouseButton.left,
  direction: Direction.click,
  );
  BixatKeyMouse.scrollMouse(
  distance: z,
  axis: ScrollAxis.vertical,
  );
}
// if x < 0 its switching direction
void hscroll(int x ){
    BixatKeyMouse.moveMouse(
    x: 300,
    y: -300,
    coordinate: Coordinate.relative, // May be absolute version
    );
  BixatKeyMouse.pressMouseButton(
  button: MouseButton.left,
  direction: Direction.click,
  );
  BixatKeyMouse.scrollMouse(
  distance: -x,
  axis: ScrollAxis.horizontal,
  );

}
/*void switch_window() {
  // Важно: Не используйте await если метод не async
      BixatKeyMouse.moveMouse(
    x: 300,
    y: -300,
    coordinate: Coordinate.relative, // May be absolute version
    );
  BixatKeyMouse.pressMouseButton(
  button: MouseButton.left,
  direction: Direction.click,
  );
  BixatKeyMouse.simulateKeyCombination(
    keys: [
      UniversalKey.leftAlt,  // Сначала зажимаем Alt
      UniversalKey.tab       // Затем Tab
    ],
    duration: Duration(milliseconds: 300), // Увеличиваем время удержания
  );
}*/
