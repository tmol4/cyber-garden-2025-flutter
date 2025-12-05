package com.neurosdk2.neuro.types;

public enum CallibriElectrodeState {
    Normal(0),
    HighResistance(1),
    Detached(2);

    private final int ID;

    CallibriElectrodeState(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static CallibriElectrodeState indexOf(int ID) {
        for (CallibriElectrodeState env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
