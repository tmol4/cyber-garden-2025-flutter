package com.neurosdk2.neuro.types;

public enum EEGChannelId {
    Unknown(0),
    O1(1),
    P3(2),
    C3(3),
    F3(4),
    Fp1(5),
    T5(6),
    T3(7),
    F7(8),

    F8(9),
    T4(10),
    T6(11),
    Fp2(12),
    F4(13),
    C4(14),
    P4(15),
    O2(16),

    D1(17),
    D2(18),
    OZ(19),
    PZ(20),
    CZ(21),
    FZ(22),
    FpZ(23),
    D3(24);

    private final int ID;

    EEGChannelId(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static EEGChannelId indexOf(int ID) {
        for (EEGChannelId env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
