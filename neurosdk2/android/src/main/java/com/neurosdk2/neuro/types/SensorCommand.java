package com.neurosdk2.neuro.types;

public enum SensorCommand {
    StartSignal(0),
    StopSignal(1),
    StartResist(2),
    StopResist(3),
    StartMEMS(4),
    StopMEMS(5),
    StartRespiration(6),
    StopRespiration(7),
    StartCurrentStimulation(8),
    StopCurrentStimulation(9),
    EnableMotionAssistant(10),
    DisableMotionAssistant(11),
    FindMe(12),
    StartAngle(13),
    StopAngle(14),
    CalibrateMEMS(15),
    ResetQuaternion(16),
    StartEnvelope(17),
    StopEnvelope(18),
    ResetMotionCounter(19),
    CalibrateStimulation(20),
    Idle(21),
    PowerDown(22),
    StartFPG(23),
    StopFPG(24),
    StartSignalAndResist(25),
    StopSignalAndResist(26),
    StartPhotoStimulation(27),
    StopPhotoStimulation(28),
    StartAcousticStimulation(29),
    StopAcousticStimulation(30),
    CommandFileSystemEnable(31),
    CommandFileSystemDisable(32),
    CommandFileSystemStreamClose(33),
    CommandStartCalibrateSignal(34),
    CommandStopCalibrateSignal(35),
    CommandPhotoStimEnable(36),
    CommandPhotoStimDisable(37),
	CommandStartPulseOximeter(38),
	CommandStopPulseOximeter(39);

    private final int ID;

    SensorCommand(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorCommand indexOf(int ID) {
        for (SensorCommand env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
