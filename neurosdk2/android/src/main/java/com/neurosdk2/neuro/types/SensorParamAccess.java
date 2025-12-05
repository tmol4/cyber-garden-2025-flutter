package com.neurosdk2.neuro.types;

public enum SensorParamAccess {
    Read(0),
    ReadWrite(1),
    ReadNotify(2);

    private final int ID;

    SensorParamAccess(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorParamAccess indexOf(int ID) {
        for (SensorParamAccess env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
