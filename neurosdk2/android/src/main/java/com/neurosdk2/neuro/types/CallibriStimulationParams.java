package com.neurosdk2.neuro.types;

/*
* Limitations:
* (Current * Frequency * PulseWidth / 100) <= 2300 uA
* */
public class CallibriStimulationParams {
    /*
    * Stimulus amplitude in  mA. 1..100
    * */
    private final byte mCurrent;
    /*
    * Duration of the stimulating pulse by us. 20..460
    * */
    private final short mPulseWidth;
    /*
    * Frequency of stimulation impulses by Hz. 1..200.
    * */
    private final byte mFrequency;
    /*
    * Maximum stimulation time by ms. 0...65535.
    * Zero is infinitely.
    * */
    private short mStimulusDuration;

    public CallibriStimulationParams(byte current, short pulseWidth, byte frequency, short stimulusDuration){
        mCurrent = current;
        mPulseWidth = pulseWidth;
        mFrequency = frequency;
        mStimulusDuration = stimulusDuration;
    }

    public byte getCurrent() {
        return mCurrent;
    }

    public short getPulseWidth() {
        return mPulseWidth;
    }

    public byte getFrequency() {
        return mFrequency;
    }

    public short getStimulusDuration() {
        return mStimulusDuration;
    }
}
