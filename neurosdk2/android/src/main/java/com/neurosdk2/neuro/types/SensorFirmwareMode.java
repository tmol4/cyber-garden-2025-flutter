package com.neurosdk2.neuro.types;

public enum SensorFirmwareMode {
    ModeBootloader(0),
    ModeApplication(1);

    private final int ID;

    SensorFirmwareMode(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFirmwareMode indexOf(int ID) {
        for (SensorFirmwareMode env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
