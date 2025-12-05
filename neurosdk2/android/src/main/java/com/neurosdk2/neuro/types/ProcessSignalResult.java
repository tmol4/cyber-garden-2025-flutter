package com.neurosdk2.neuro.types;

public class ProcessSignalResult {
    private int mSzReady;
    private SignalChannelsData[] mSignal;
    private ResistChannelsData[] mResist;

    public ProcessSignalResult(int szReady, SignalChannelsData[] signal, ResistChannelsData[] resist){
        mSzReady = szReady;
        mSignal = signal;
        mResist = resist;
    }

    public int getSzReady() {
        return mSzReady;
    }

    public SignalChannelsData[] getSignal() {
        return mSignal;
    }

    public ResistChannelsData[] getResist() {
        return mResist;
    }
}
