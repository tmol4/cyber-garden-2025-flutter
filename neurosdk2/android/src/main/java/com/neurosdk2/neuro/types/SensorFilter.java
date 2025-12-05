package com.neurosdk2.neuro.types;

public enum SensorFilter {
    FilterHPFBwhLvl1CutoffFreq1Hz(0),
    FilterHPFBwhLvl1CutoffFreq5Hz(1),
    FilterBSFBwhLvl2CutoffFreq45_55Hz(2),
    FilterBSFBwhLvl2CutoffFreq55_65Hz(3),
    FilterHPFBwhLvl2CutoffFreq10Hz(4),
    FilterLPFBwhLvl2CutoffFreq400Hz(5),
    FilterHPFBwhLvl2CutoffFreq80Hz(6),
    FilterUnknown(0xFF);

    private final int ID;

    SensorFilter(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFilter indexOf(int ID) {
        for (SensorFilter env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
