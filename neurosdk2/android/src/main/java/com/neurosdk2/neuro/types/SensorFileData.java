package com.neurosdk2.neuro.types;

public class SensorFileData {
    private int mOffsetStart;
    private int mDataAmount;
    private byte[] mData;

    public SensorFileData(int offsetStart, int dataAmount, byte[] data){
        mOffsetStart = offsetStart;
        mDataAmount = dataAmount;
        mData = data;
    }

    public int getOffsetStart() {
        return mOffsetStart;
    }

    public int getDataAmount() {
        return mDataAmount;
    }

    public byte[] getData() {
        return mData;
    }
}
