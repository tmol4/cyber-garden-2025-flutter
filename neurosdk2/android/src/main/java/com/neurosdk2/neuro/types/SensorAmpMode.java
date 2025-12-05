package com.neurosdk2.neuro.types;

public enum SensorAmpMode {
    Invalid(0),
    PowerDown(1),
    Idle(2),
    Signal(3),
    Resist(4),
    SignalResist(5),
    Envelope(6);

    private final int ID;

    SensorAmpMode(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorAmpMode indexOf(int ID) {
        for (SensorAmpMode env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
