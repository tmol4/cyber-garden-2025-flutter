package com.neurosdk2.neuro.types;

public enum EEGChannelType {
    A1(0),
    A2(1),
    Differential(2),
    Ref(3);

    private final int ID;

    EEGChannelType(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static EEGChannelType indexOf(int ID) {
        for (EEGChannelType env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
