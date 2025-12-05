package com.neurosdk2.neuro.types;

public class CallibriMotionCounterParam {
    /*
    * Insense threshold mg. 0..500
    * */
    private final short mInsenseThresholdMG;
    /*
    * Algorithm insense threshold in time (in samples with the MEMS sampling rate) 0..500
    */
    private final short mInsenseThresholdSample;

    public CallibriMotionCounterParam(short mInsenseThresholdMG, short insenseThresholdSample) {
        this.mInsenseThresholdMG = mInsenseThresholdMG;
        mInsenseThresholdSample = insenseThresholdSample;
    }


    public short getInsenseThresholdMG() {
        return mInsenseThresholdMG;
    }

    public short getInsenseThresholdSample() {
        return mInsenseThresholdSample;
    }
}
