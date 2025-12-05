package com.neurosdk2.neuro.types;

public class CallibriSignalData {
    private final int mPackNum;
    private final double[] mSamples;

    public CallibriSignalData(int packNum, double[] samples) {
        mPackNum = packNum;
        mSamples = samples;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public double[] getSamples() {
        return mSamples;
    }
}
