package com.neurosdk2.neuro.types;

public class CallibriMotionAssistantParams {
    private final byte mGyroStart;
    private final byte mGyroStop;
    private final int mLimb;
    /*
    * multiple of 10. This means that the device is using the (MinPauseMs / 10) value.
    * Correct values: 10, 20, 30, 40 ...
    * */
    private final byte mMinPauseMs;

    public CallibriMotionAssistantParams(byte gyroStart, byte gyroStop, int limb, byte minPauseMs){
        mGyroStart = gyroStart;
        mGyroStop = gyroStop;
        mLimb = limb;
        mMinPauseMs = minPauseMs;
    }

    public CallibriMotionAssistantParams(byte gyroStart, byte gyroStop, CallibriMotionAssistantLimb limb, byte minPauseMs){
        mGyroStart = gyroStart;
        mGyroStop = gyroStop;
        mLimb = limb.index();
        mMinPauseMs = minPauseMs;
    }

    public byte getGyroStart() {
        return mGyroStart;
    }

    public byte getGyroStop() {
        return mGyroStop;
    }

    public CallibriMotionAssistantLimb getLimb() {
        return CallibriMotionAssistantLimb.indexOf(mLimb);
    }

    public int getRawLimb() {
        return mLimb;
    }

    public byte getMinPauseMs() {
        return mMinPauseMs;
    }
}
