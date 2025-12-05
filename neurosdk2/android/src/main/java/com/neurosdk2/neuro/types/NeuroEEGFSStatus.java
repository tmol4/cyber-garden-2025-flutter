package com.neurosdk2.neuro.types;

public class NeuroEEGFSStatus {
    private /*SensorFSStatus*/int mStatus;
    private /*SensorFSIOStatus*/int mIOStatus;
    private /*SensorFSStreamStatus*/int mStreamStatus;
    private short mAutosaveSignal;

    public NeuroEEGFSStatus(int status, int ioStatus, int streamStatus, short autosaveSignal){
        mStatus = status;
        mIOStatus = ioStatus;
        mStreamStatus = streamStatus;
        mAutosaveSignal = autosaveSignal;
    }

    public SensorFSStatus getStatus() {
        return SensorFSStatus.indexOf(mStatus);
    }

    public SensorFSIOStatus getIOStatus() {
        return SensorFSIOStatus.indexOf(mIOStatus);
    }

    public SensorFSStreamStatus getStreamStatus() {
        return SensorFSStreamStatus.indexOf(mStreamStatus);
    }

    public boolean getAutosaveSignal() {
        return mAutosaveSignal == 1;
    }
}
