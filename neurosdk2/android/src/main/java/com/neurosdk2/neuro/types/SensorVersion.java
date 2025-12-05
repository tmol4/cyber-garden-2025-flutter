package com.neurosdk2.neuro.types;

public class SensorVersion {
    private final int mFwMajor;
    private final int mFwMinor;
    private final int mFwPatch;

    private final int mHwMajor;
    private final int mHwMinor;
    private final int mHwPatch;

    private final int mExtMajor;

    public SensorVersion(int fwMajor, int fwMinor, int fwPatch, int hwMajor, int hwMinor,
                         int hwPatch, int extMajor){
        mFwMajor = fwMajor;
        mFwMinor = fwMinor;
        mFwPatch = fwPatch;
        mHwMajor = hwMajor;
        mHwMinor = hwMinor;
        mHwPatch = hwPatch;
        mExtMajor = extMajor;
    }

    public int getFwMajor() {
        return mFwMajor;
    }

    public int getFwMinor() {
        return mFwMinor;
    }

    public int getFwPatch() {
        return mFwPatch;
    }

    public int getHwMajor() {
        return mHwMajor;
    }

    public int getHwMinor() {
        return mHwMinor;
    }

    public int getHwPatch() {
        return mHwPatch;
    }

    public int getExtMajor() {
        return mExtMajor;
    }
}
