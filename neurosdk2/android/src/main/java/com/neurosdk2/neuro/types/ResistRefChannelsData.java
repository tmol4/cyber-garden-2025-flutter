package com.neurosdk2.neuro.types;

public class ResistRefChannelsData {
    private int mPackNum;
    private double[] mSamples;
    private double[] mReferents;

    public ResistRefChannelsData(int packNum, double[] samples, double[] referents){
        mPackNum = packNum;
        mSamples = samples;
        mReferents = referents;
    }

    public int getPackNum() {
        return mPackNum;
    }

    public double[] getSamples() {
        return mSamples;
    }

    public double[] getReferents() { return mReferents; }
}
