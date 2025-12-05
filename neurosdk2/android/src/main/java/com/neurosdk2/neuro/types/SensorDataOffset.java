package com.neurosdk2.neuro.types;

public enum SensorDataOffset {
    DataOffset0(0x00),
    DataOffset1(0x01),
    DataOffset2(0x02),
    DataOffset3(0x03),
    DataOffset4(0x04),
    DataOffset5(0x05),
    DataOffset6(0x06),
    DataOffset7(0x07),
    DataOffset8(0x08),
    DataOffsetUnsupported(0xFF);

    private final int ID;

    SensorDataOffset(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorDataOffset indexOf(int ID) {
        for (SensorDataOffset env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
