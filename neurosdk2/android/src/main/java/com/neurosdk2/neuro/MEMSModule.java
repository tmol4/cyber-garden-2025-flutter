package com.neurosdk2.neuro;

class MEMSModule {
    static native long addMEMSDataCallback(long sensor_ptr, Sensor sensor_obj);
    static native void removeMEMSDataCallback(long mHandle_ptr);
    static native int readSamplingFrequencyMEMSSensor(long sensor_ptr);
    static native int readAccelerometerSensSensor(long sensor_ptr);
    static native void writeAccelerometerSensSensor(long sensor_ptr, int ams);
    static native int readGyroscopeSensSensor(long sensor_ptr);
    static native void writeGyroscopeSensSensor(long sensor_ptr, int gs);
}