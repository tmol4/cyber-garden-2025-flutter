package com.neurosdk2.neuro.types;

public enum GenCurrent {
    GenCurr0uA(0),
    GenCurr6nA(1),
    GenCurr12nA(2),
    GenCurr18nA(3),
    GenCurr24nA(4),
    GenCurr6uA(5),
    GenCurr24uA(6),
    GenUnsupported(0xFF);

    private final int ID;

    GenCurrent(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static GenCurrent indexOf(int ID) {
        for (GenCurrent env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
