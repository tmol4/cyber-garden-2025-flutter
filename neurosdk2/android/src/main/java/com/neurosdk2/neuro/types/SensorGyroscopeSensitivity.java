package com.neurosdk2.neuro.types;

public enum SensorGyroscopeSensitivity {
    GyroSens250Grad(0),
    GyroSens500Grad(1),
    GyroSens1000Grad(2),
    GyroSens2000Grad(3),
    GyroSensUnsupported(4);

    private final int ID;

    SensorGyroscopeSensitivity(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorGyroscopeSensitivity indexOf(int ID) {
        for (SensorGyroscopeSensitivity env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
