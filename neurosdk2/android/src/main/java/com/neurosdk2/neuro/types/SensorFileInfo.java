package com.neurosdk2.neuro.types;

public class SensorFileInfo {
    private final String mFileName;
    private final int mFileSize;
    private final short mModifiedYear;
    private final byte mModifiedMonth;
    private final byte mModifiedDayOfMonth;
    private final byte mModifiedHour;
    private final byte mModifiedMin;
    private final byte mModifiedSec;
    private final byte mAttribute;

    public SensorFileInfo(String fileName, int fileSize,
                          short modifiedYear, byte modifiedMonth, byte modifiedDayOfMonth,
                          byte modifiedHour, byte modifiedMin, byte modifiedSec,
    byte attribute){
        mFileName = fileName;
        mFileSize = fileSize;
        mModifiedYear = modifiedYear;
        mModifiedMonth = modifiedMonth;
        mModifiedDayOfMonth = modifiedDayOfMonth;
        mModifiedHour = modifiedHour;
        mModifiedMin = modifiedMin;
        mModifiedSec = modifiedSec;
        mAttribute = attribute;
    }

    public String getFileName() {
        return mFileName;
    }

    public int getFileSize() {
        return mFileSize;
    }

    public short getModifiedYear() {
        return mModifiedYear;
    }

    public byte getModifiedMonth() {
        return mModifiedMonth;
    }

    public byte getModifiedDayOfMonth() {
        return mModifiedDayOfMonth;
    }

    public byte getModifiedHour() {
        return mModifiedHour;
    }

    public byte getModifiedMin() {
        return mModifiedMin;
    }

    public byte getModifiedSec() {
        return mModifiedSec;
    }

    public byte getAttribute() {
        return mAttribute;
    }
}
