package com.neurosdk2.neuro.types;

public enum CallibriSignalType {
    EEG(0),
    EMG(1),
    ECG(2),
    EDA(3),// GSR
    StrainGaugeBreathing(4),
    ImpedanceBreathing(5),

    TenzoBreathing(6),
    Unknown(7);

    private final int ID;

    CallibriSignalType(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static CallibriSignalType indexOf(int ID) {
        for (CallibriSignalType env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
