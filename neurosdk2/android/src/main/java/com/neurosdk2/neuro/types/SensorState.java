package com.neurosdk2.neuro.types;

public enum SensorState {
    StateInRange(0),
    StateOutOfRange(1);

    private final int ID;

    SensorState(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorState indexOf(int ID) {
        for (SensorState env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
