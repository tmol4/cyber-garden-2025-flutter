package com.neurosdk2.neuro.types;

public class CallibriStimulatorMAState {
    private final int mStimulatorState;
    private final int mMAState;

    public CallibriStimulatorMAState(int stimulatorState, int maState){
        mStimulatorState = stimulatorState;
        mMAState = maState;
    }

    public CallibriStimulatorMAState(CallibriStimulatorState stimulatorState, CallibriStimulatorState maState){
        mStimulatorState = stimulatorState.index();
        mMAState = maState.index();
    }

    public CallibriStimulatorState getStimulatorState() {
        return CallibriStimulatorState.indexOf(mStimulatorState);
    }

    public CallibriStimulatorState getMAState() {
        return CallibriStimulatorState.indexOf(mMAState);
    }

    public int getRawStimulatorState() {
        return mStimulatorState;
    }

    public int getRawMAState() {
        return mMAState;
    }
}
