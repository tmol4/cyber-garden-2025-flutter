package com.neurosdk2.neuro.types;

public enum CallibriMotionAssistantLimb {
    RightLeg(0),
    LeftLeg(1),
    RightArm(2),
    LeftArm(3),
    Unsupported(0xFF);

    private final int ID;

    CallibriMotionAssistantLimb(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static CallibriMotionAssistantLimb indexOf(int ID) {
        for (CallibriMotionAssistantLimb env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
