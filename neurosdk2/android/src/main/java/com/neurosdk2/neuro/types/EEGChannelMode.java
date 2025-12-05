package com.neurosdk2.neuro.types;

public enum EEGChannelMode {
    Off(0),
    Shorted(1),
    SignalResist(2),
    Signal(3),
    Test(4);

    private final int ID;

    EEGChannelMode(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static EEGChannelMode indexOf(int ID) {
        for (EEGChannelMode env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
