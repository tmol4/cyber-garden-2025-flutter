package com.neurosdk2.neuro.types;

public enum SensorSamplingFrequency {
    FrequencyHz10(0),
    FrequencyHz20(1),
    FrequencyHz100(2),
    FrequencyHz125(3),
    FrequencyHz250(4),
    FrequencyHz500(5),
    FrequencyHz1000(6),
    FrequencyHz2000(7),
    FrequencyHz4000(8),
    FrequencyHz8000(9),
    FrequencyHz10000(10),
    FrequencyHz12000(11),
    FrequencyHz16000(12),
    FrequencyHz24000(13),
    FrequencyHz32000(14),
    FrequencyHz48000(15),
    FrequencyHz64000(16),
    FrequencyHz50(17),
    FrequencyUnsupported(0xFF);

    private final int ID;

    SensorSamplingFrequency(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorSamplingFrequency indexOf(int ID) {
        for (SensorSamplingFrequency env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
