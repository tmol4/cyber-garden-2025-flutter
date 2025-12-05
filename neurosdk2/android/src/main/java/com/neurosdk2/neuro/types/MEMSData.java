package com.neurosdk2.neuro.types;

public class MEMSData {
    private final int mPackNum;
    private final Accelerometer mAccelerometer;
    private final Gyroscope mGyroscope;

    public MEMSData(int packNum, Accelerometer accelerometer, Gyroscope gyroscope) {
        mPackNum = packNum;
        mAccelerometer = accelerometer;
        mGyroscope = gyroscope;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public Accelerometer getAccelerometer() {
        return mAccelerometer;
    }

    public Gyroscope getGyroscope() {
        return mGyroscope;
    }
}
