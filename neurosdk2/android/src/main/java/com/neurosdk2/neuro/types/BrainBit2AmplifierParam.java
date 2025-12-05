package com.neurosdk2.neuro.types;

public class BrainBit2AmplifierParam {
    private BrainBit2ChannelMode[] mChSignalMode;

    private boolean[] mChResistUse;
    private SensorGain[] mChGain;
    private GenCurrent mCurrent;

    public BrainBit2AmplifierParam(BrainBit2ChannelMode[] chSignalMode, boolean[] chResistUse, SensorGain[] chGain, GenCurrent current){
        mChSignalMode = chSignalMode;
        mChResistUse = chResistUse;
        mChGain = chGain;
        mCurrent = current;
    }

    public BrainBit2AmplifierParam(int[] chSignalMode, boolean[] chResistUse, int[] chGain, int current){
        mChSignalMode = new BrainBit2ChannelMode[chSignalMode.length];
        for (int i = 0; i < chSignalMode.length; i++) {
            mChSignalMode[i] = BrainBit2ChannelMode.indexOf(chSignalMode[i]);
        }
        mChResistUse = chResistUse;
        mChGain = new SensorGain[chGain.length];
        for (int i = 0; i < chGain.length; i++) {
            mChGain[i] = SensorGain.indexOf(chGain[i]);
        }
        mCurrent = GenCurrent.indexOf(current);
    }

    public BrainBit2ChannelMode[] getChSignalMode() {
        return mChSignalMode;
    }

    public boolean[] getChResistUse() {
        return mChResistUse;
    }

    public SensorGain[] getChGain() {
        return mChGain;
    }

    public GenCurrent getCurrent() {
        return mCurrent;
    }

    public void setCurrent(GenCurrent current){ mCurrent = current; }

    public int[] getRawChGain() {
        int[] chGain = new int[mChGain.length];
        for (int i = 0; i < mChGain.length; i++) {
            chGain[i] = mChGain[i].index();
        }
        return chGain;
    }

    public int[] getRawChSignalMode() {
        int[] chSMode = new int[mChSignalMode.length];
        for (int i = 0; i < mChSignalMode.length; i++) {
            chSMode[i] = mChSignalMode[i].index();
        }
        return chSMode;
    }

    public int getRawCurrent(){ return mCurrent.index(); }

}
