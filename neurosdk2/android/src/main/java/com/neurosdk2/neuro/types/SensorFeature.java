package com.neurosdk2.neuro.types;

public enum SensorFeature {
    Signal(0),
    MEMS(1),
    CurrentStimulator(2),
    Respiration(3),
    Resist(4),
    FPG(5),
    Envelope(6),
    PhotoStimulator(7),
    AcousticStimulator(8),
    FeatureFlashCard(9),
    LedChannels(10),
    SignalWithResist(11),
    FeaturePulseOximeter(12);

    private final int ID;

    SensorFeature(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorFeature indexOf(int ID) {
        for (SensorFeature env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
