package com.neurosdk2.neuro.types;

public class QuaternionData {
    private final int mPackNum;
    private final float mW;
    private final float mX;
    private final float mY;
    private final float mZ;


    public QuaternionData(int packNum, float w, float x, float y, float z) {
        mPackNum = packNum;
        mW = w;
        mX = x;
        mY = y;
        mZ = z;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public float getW() {
        return mW;
    }

    public float getX() {
        return mX;
    }

    public float getY() {
        return mY;
    }

    public float getZ() {
        return mZ;
    }
}
