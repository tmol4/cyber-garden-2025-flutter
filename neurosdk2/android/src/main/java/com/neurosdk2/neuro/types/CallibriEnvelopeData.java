package com.neurosdk2.neuro.types;

public class CallibriEnvelopeData {

    private final int mPackNum;
    private final double mSample;

    public CallibriEnvelopeData(int packNum, double sample) {
        mPackNum = packNum;
        mSample = sample;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public double getSample() {
        return mSample;
    }
}
