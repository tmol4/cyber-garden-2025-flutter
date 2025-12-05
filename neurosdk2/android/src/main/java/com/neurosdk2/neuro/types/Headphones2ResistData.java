package com.neurosdk2.neuro.types;

public class Headphones2ResistData {

    private final int mPackNum;
    private final double mCh1;
    private final double mCh2;
    private final double mCh3;
    private final double mCh4;

    public Headphones2ResistData(int mPackNum, double mCh1, double mCh2, double mCh3, double mCh4) {
        this.mPackNum = mPackNum;
        this.mCh1 = mCh1;
        this.mCh2 = mCh2;
        this.mCh3 = mCh3;
        this.mCh4 = mCh4;
    }

    public int getPackNum() { return mPackNum; }
    public double getCh1() { return mCh1; }
    public double getCh2() { return mCh2; }
    public double getCh3() { return mCh3; }
    public double getCh4() { return mCh4; }
}
