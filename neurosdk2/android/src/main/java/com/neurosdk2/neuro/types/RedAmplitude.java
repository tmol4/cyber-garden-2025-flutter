package com.neurosdk2.neuro.types;

public enum RedAmplitude {
    RedAmp0(0),
    RedAmp14(1),
    RedAmp28(2),
    RedAmp42(3),
    RedAmp56(4),
    RedAmp70(5),
    RedAmp84(6),
    RedAmp100(7),
    RedAmpUnsupported(0xFF);

    private final int ID;

    RedAmplitude(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static RedAmplitude indexOf(int ID) {
        for (RedAmplitude env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
