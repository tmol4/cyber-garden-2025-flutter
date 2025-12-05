package com.neurosdk2.neuro.types;

public enum IrAmplitude {
    IrAmp0(0),
    IrAmp14(1),
    IrAmp28(2),
    IrAmp42(3),
    IrAmp56(4),
    IrAmp70(5),
    IrAmp84(6),
    IrAmp100(7),
    IrAmpUnsupported(0xFF);

    private final int ID;

    IrAmplitude(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static IrAmplitude indexOf(int ID) {
        for (IrAmplitude env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
