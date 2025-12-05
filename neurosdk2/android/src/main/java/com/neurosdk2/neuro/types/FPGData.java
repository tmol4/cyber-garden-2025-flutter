package com.neurosdk2.neuro.types;

public class FPGData {
    private final int mPackNum;
    private final double mIrAmplitude;
    private final double mRedAmplitude;

    public FPGData(int packNum, double irAmplitude, double redAmplitude) {
        mPackNum = packNum;
        mIrAmplitude = irAmplitude;
        mRedAmplitude = redAmplitude;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public double getIrAmplitude() {
        return mIrAmplitude;
    }

    public double getRedAmplitude() {
        return mRedAmplitude;
    }
}
