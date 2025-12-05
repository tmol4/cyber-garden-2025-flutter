package com.neurosdk2.neuro.types;

public class SignalChannelsData {
    private int mPackNum;
    private short mMarker;
    private double[] mSamples;

    public SignalChannelsData(int packNum, short marker, double[] samples){
        mPackNum = packNum;
        mMarker = marker;
        mSamples = samples;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public short getMarker() {
        return mMarker;
    }

    public double[] getSamples() {
        return mSamples;
    }

    public void setSamples(double[] samples){
        mSamples = samples;
    }
}
