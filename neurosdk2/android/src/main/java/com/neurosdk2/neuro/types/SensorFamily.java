package com.neurosdk2.neuro.types;

public enum SensorFamily {
    SensorLECallibri(1),
    SensorLEKolibri(2),
	SensorLEBrainBit(3),
	SensorLEBrainBitBlack(4),
	SensorLEHeadPhones2(6),
	SensorLEHeadband(11),
    SensorLENeuroEEG(14),
	SensorLEBrainBit2(18),
        SensorLEBrainBitPro(19),
	SensorLEBrainBitFlex(20),

    SensorUnknown(0);

    private final int ID;

    SensorFamily(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFamily indexOf(int ID) {
        for (SensorFamily env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
