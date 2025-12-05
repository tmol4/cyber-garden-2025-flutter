package com.neurosdk2.neuro.types;

public class SensorDiskInfo {
    private long mTotalSize;
    private long mFreeSize;

    public SensorDiskInfo(long totalSize, long freeSize){
        mTotalSize = totalSize;
        mFreeSize = freeSize;
    }

    public long getTotalSize() {
        return mTotalSize;
    }

    public long getFreeSize() {
        return mFreeSize;
    }
}
