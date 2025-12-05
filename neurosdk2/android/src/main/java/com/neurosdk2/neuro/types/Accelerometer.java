package com.neurosdk2.neuro.types;

public class Accelerometer {
    private final double mX;
    private final double mY;
    private final double mZ;


    public Accelerometer(double x, double y, double z) {
        mX = x;
        mY = y;
        mZ = z;
    }

    public double getX() {
        return mX;
    }

    public double getY() {
        return mY;
    }

    public double getZ() {
        return mZ;
    }
}
