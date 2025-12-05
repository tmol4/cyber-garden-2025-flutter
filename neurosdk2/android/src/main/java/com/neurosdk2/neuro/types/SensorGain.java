package com.neurosdk2.neuro.types;

public enum SensorGain {
    Gain1(0),
    Gain2(1),
    Gain3(2),
    Gain4(3),
    Gain6(4),
    Gain8(5),
    Gain12(6),
    Gain24(7),
    Gain5(8),
    Gain2x(9),
    Gain4x(10),
    GainUnsupported(11);

    private final int ID;

    SensorGain(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorGain indexOf(int ID) {
        for (SensorGain env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
