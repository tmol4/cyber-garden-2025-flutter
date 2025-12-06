import 'package:neurosdk2/neurosdk2.dart';

import 'package:vector_math/vector_math_64.dart';

import 'package:bixat_key_mouse/bixat_key_mouse.dart';

import 'package:app_logic/src/key_mouse_functions.dart';

class CallibriReadings {
  Vector3 acceleration = Vector3.zero();
  double muscleSignal = 0.0;

  double mouseSens = 200.0;
  double gyroSens = 0.2;
  double scrollSens = 0.01;
  final double mouseMoveThreshold = 2.0;
  final double scrollThreshold = 0.4;

  final int calibration_n = 100;
  int calibration_cnt = 0;
  Vector3 calibration_vector = Vector3.zero();

  List<Vector3> gyro_deltas = List<Vector3>.filled(15, Vector3.zero());
  List<Vector3> accel_deltas = List<Vector3>.filled(15, Vector3.zero());
  int curr_n = 0;

  // Vector3 dir = Vector3.zero();
  // int dir_change_num = 10;
  // Vector3 cnt = Vector3.zero();

  Vector3 lastAcceleration = Vector3.zero();
  Vector3 lastVel = Vector3.zero();

  void set_mouse_sensetivity(double newSens) {
    mouseSens = newSens;
  }

  void set_scroll_sensetivity(double newSens) {
    scrollSens = newSens;
  }

  void set_acceleration(Iterable<Point3D> accelerationList) {
    // print(accelerationList.map((e) => e,));

    // calculations
    Vector3 acceleration = Vector3(
      accelerationList.last.x,
      accelerationList.last.y,
      accelerationList.last.z,
    );
    Vector3 delta = acceleration - lastAcceleration;
    lastAcceleration = acceleration;

    accel_deltas[curr_n] = delta;
    curr_n = (curr_n + 1) % accel_deltas.length;

    Vector3 avg_delta = Vector3.zero();
    for (Vector3 d in accel_deltas) {
      avg_delta += d;
    }
    avg_delta /= accel_deltas.length.toDouble();

    delta = avg_delta;

    // move mouse
    Vector3 movement = Vector3.zero();

    if (delta.x > mouseMoveThreshold || delta.x < -mouseMoveThreshold)
      movement.x = delta.x;
    if (delta.y > mouseMoveThreshold || delta.y < -mouseMoveThreshold)
      movement.y = delta.y;
    move_mouse(
      -(movement.x * mouseSens).ceil(),
      -(movement.y * mouseSens).ceil(),
    );
  }

  void set_gyro(Iterable<Point3D> gyro) {
    // calculations
    Vector3 vel = Vector3(gyro.last.x, gyro.last.y, gyro.last.z);
    Vector3 delta = vel; // - lastVel;
    lastVel = vel;

    // calc average
    gyro_deltas[curr_n] = delta;
    curr_n = (curr_n + 1) % gyro_deltas.length;

    Vector3 avgDelta = Vector3.zero();
    for (Vector3 d in gyro_deltas) {
      avgDelta += d;
    }
    avgDelta /= gyro_deltas.length.toDouble();
    delta = avgDelta;

    // calibration
    if (calibration_cnt <= calibration_n) {
      if (calibration_cnt == calibration_n) {
        calibration_vector = avgDelta;
      }
      calibration_cnt++;
      return;
    }

    // move mouse
    Vector3 movement = Vector3.zero();

    delta -= calibration_vector;

    if (delta.x > mouseMoveThreshold || delta.x < -mouseMoveThreshold)
      movement.y = -delta.x;
    if (delta.z > mouseMoveThreshold || delta.z < -mouseMoveThreshold)
      movement.x = -delta.z;

    print(movement.toString() + " | " + calibration_vector.toString());

    move_mouse((movement.x * gyroSens).ceil(), (movement.y * gyroSens).ceil());
  }

  void set_muscle_signal(Iterable<List<double>> signal) {
    double avg_signal = 0.0;
    for (double s in signal.last) {
      avg_signal += s;
    }
    avg_signal /= signal.length;

    print(avg_signal);
  }
}

CallibriReadings callibri_readings = CallibriReadings();
