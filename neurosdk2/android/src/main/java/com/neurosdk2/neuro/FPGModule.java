package com.neurosdk2.neuro;

class FPGModule {
    static native long addFPGDataCallbackNeuroSmart(long sensor_ptr, Sensor sensor_obj);
    static native void removeFPGDataCallbackNeuroSmart(long mHandle_ptr);
    static native int readSamplingFrequencyFPGSensor(long sensor_ptr);
    static native int readIrAmplitudeHeadband(long sensor_ptr);
    static native void writeIrAmplitudeHeadband(long sensor_ptr, int amp);
    static native int readRedAmplitudeHeadband(long sensor_ptr);
    static native void writeRedAmplitudeHeadband(long sensor_ptr, int amp);
}