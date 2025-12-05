package com.neurosdk2.neuro.types;

public enum CallibriStimulatorState {
    NoParams(0),
    Disabled(1),
    Enabled(2),
    Unsupported(0xFF);

    private final int ID;

    CallibriStimulatorState(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static CallibriStimulatorState indexOf(int ID) {
        for (CallibriStimulatorState env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
