import 'package:neurosdk2/neurosdk2.dart';



class CallibriReadings {
  Point3D acceleration = Point3D(x: 0.0, y: 0.0, z: 0.0);
  double muscle_signal = 0.0;

  CallibriReadings last_reading = CallibriReadings();

  void set_mouse_sensetivity() {
    
  }

  void set_acceleration(Iterable<Point3D> acceleration_list) {
    Point3D acceleration = acceleration_list.last;

    Point3D delta = Point3D(
      x: acceleration.x - last_reading.acceleration.x, 
      y: acceleration.y - last_reading.acceleration.y, 
      z: acceleration.z - last_reading.acceleration.z
    );

    String result = "";

    if (delta.x > delta.y && delta.x > delta.z) {
      print()
    }

    print(acceleration_list);

    last_reading.acceleration = acceleration;
  }

  void set_muscle_signal() {
    
  }


}


CallibriReadings callibri_readings = CallibriReadings();
