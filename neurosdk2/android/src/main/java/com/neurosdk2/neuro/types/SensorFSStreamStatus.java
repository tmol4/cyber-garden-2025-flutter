package com.neurosdk2.neuro.types;

public enum SensorFSStreamStatus {
    Closed(0),
    Write(1),
    Read(2);

    private final int ID;

    SensorFSStreamStatus(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFSStreamStatus indexOf(int ID) {
        for (SensorFSStreamStatus env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
