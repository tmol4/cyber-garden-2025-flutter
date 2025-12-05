package com.neurosdk2.neuro.types;

public enum SensorADCInput {
    ADCInputElectrodes(0),
    ADCInputShort(1),
    ADCInputTest(2),
    ADCInputResistance(3);

    private final int ID;

    SensorADCInput(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorADCInput indexOf(int ID) {
        for (SensorADCInput env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
