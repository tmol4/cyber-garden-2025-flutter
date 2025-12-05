package com.neurosdk2.neuro.types;

public enum CallibriColorType {
    ColorRed(0),
    ColorYellow(1),
    ColorBlue(2),
    ColorWhite(3),

    ColorUnknown(4);

    private final int ID;

    CallibriColorType(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static CallibriColorType indexOf(int ID) {
        for (CallibriColorType env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
