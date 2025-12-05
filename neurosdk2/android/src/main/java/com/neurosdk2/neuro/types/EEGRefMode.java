package com.neurosdk2.neuro.types;

public enum EEGRefMode {
    HeadTop(1),
    A1A2(2);

    private final int ID;

    EEGRefMode(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static EEGRefMode indexOf(int ID) {
        for (EEGRefMode env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
