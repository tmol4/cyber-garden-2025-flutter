package com.neurosdk2.neuro;

class AmpModeModule {
    static native long addAmpModeCallback(long sensor_ptr, Sensor sensor_obj);
    static native void removeAmpModeCallback(long ptr);
    static native int readAmpMode(long sensor_ptr);
}