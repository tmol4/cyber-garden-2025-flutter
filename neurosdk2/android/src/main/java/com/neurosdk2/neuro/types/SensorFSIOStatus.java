package com.neurosdk2.neuro.types;

public enum SensorFSIOStatus {
    NoError(0),
    IOError(1),
    Timeout(2);

    private final int ID;

    SensorFSIOStatus(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFSIOStatus indexOf(int ID) {
        for (SensorFSIOStatus env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
