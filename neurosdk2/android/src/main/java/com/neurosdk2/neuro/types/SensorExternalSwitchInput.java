package com.neurosdk2.neuro.types;

public enum SensorExternalSwitchInput {
    ExtSwInElectrodesRespUSB(0),
    ExtSwInElectrodes(1),
    ExtSwInUSB(2),
    ExtSwInRespUSB(3),
    ExtSwInShort(4),
    ExtSwInUnknown(0xFF);

    private final int ID;

    SensorExternalSwitchInput(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorExternalSwitchInput indexOf(int ID) {
        for (SensorExternalSwitchInput env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
