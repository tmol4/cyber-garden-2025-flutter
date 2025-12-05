package com.neurosdk2.neuro.types;

public enum SensorAccelerometerSensitivity {
    AccSens2g(0),
    AccSens4g(1),
    AccSens8g(2),
    AccSens16g(3),
    AccSensUnsupported(4);

    private final int ID;

    SensorAccelerometerSensitivity(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorAccelerometerSensitivity indexOf(int ID) {
        for (SensorAccelerometerSensitivity env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
