package com.neurosdk2.neuro.types;

public class Headphones2SignalData {
    private final int mPackNum;
    private final byte mMarker;
    private final double mCh1;
    private final double mCh2;
    private final double mCh3;
    private final double mCh4;

    public Headphones2SignalData(int packNum, byte marker, double ch1, double ch2, double ch3, double ch4) {
        mPackNum = packNum;
        mMarker = marker;
        mCh1 = ch1;
        mCh2 = ch2;
        mCh3 = ch3;
        mCh4 = ch4;
    }

    public int getPackNum() { return mPackNum; }
    public byte getMarker() { return mMarker; }
    public double getCh1() { return mCh1; }
    public double getCh2() { return mCh2; }
    public double getCh3() { return mCh3; }
    public double getCh4() { return mCh4; }
}
