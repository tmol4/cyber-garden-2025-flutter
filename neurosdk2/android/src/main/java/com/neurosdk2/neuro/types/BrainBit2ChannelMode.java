package com.neurosdk2.neuro.types;

public enum BrainBit2ChannelMode {
    ChModeShort(0),
    ChModeNormal(1);

    private final int ID;

    BrainBit2ChannelMode(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static BrainBit2ChannelMode indexOf(int ID) {
        for (BrainBit2ChannelMode env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
