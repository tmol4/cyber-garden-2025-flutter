package com.neurosdk2.neuro.types;

public enum SensorFSStatus {
    OK(0),
    NoInit(1),
    NoDisk(2),
    Protect(3);

    private final int ID;

    SensorFSStatus(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFSStatus indexOf(int ID) {
        for (SensorFSStatus env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
