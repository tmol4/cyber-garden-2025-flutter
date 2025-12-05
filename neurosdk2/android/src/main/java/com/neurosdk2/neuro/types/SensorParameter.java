package com.neurosdk2.neuro.types;

public enum SensorParameter {
    ParameterName(0),
    ParameterState(1),
    ParameterAddress(2),
    ParameterSerialNumber(3),
    ParameterHardwareFilterState(4),
    ParameterFirmwareMode(5),
    ParameterSamplingFrequency(6),
    ParameterGain(7),
    ParameterOffset(8),
    ParameterExternalSwitchState(9),
    ParameterADCInputState(10),
    ParameterAccelerometerSens(11),
    ParameterGyroscopeSens(12),
    ParameterStimulatorAndMAState(13),
    ParameterStimulatorParamPack(14),
    ParameterMotionAssistantParamPack(15),
    ParameterFirmwareVersion(16),
    ParameterMEMSCalibrationStatus(17),
    ParameterMotionCounterParamPack(18),
    ParameterMotionCounter(19),
    ParameterBattPower(20),
    ParameterSensorFamily(21),
    ParameterSensorMode(22),
    ParameterIrAmplitude(23),
    ParameterRedAmplitude(24),
    ParameterEnvelopeAvgWndSz(25),
    ParameterEnvelopeDecimation(26),
    ParameterSamplingFrequencyResist(27),
    ParameterSamplingFrequencyMEMS(28),
    ParameterSamplingFrequencyFPG(29),
    ParameterAmplifier(30),
    ParameterSensorChannels(31),
    ParameterSamplingFrequencyResp(32),
    ParameterSurveyId(33),
    ParameterFileSystemStatus(34),
    ParameterFileSystemDiskInfo(35),
    ParameterReferentsShort(36),
    ParameterReferentsGround(37),
    ParameterSamplingFrequencyEnvelope(38),
    ParameterChannelConfiguration(39),
    ParameterElectrodeState(40),
    ParameterChannelResistConfiguration(41),
    ParameterBattVoltage(42),
    ParameterPhotoStimTimeDefer(43),
    ParameterPhotoStimSyncState(44),
    ParameterSensorPhotoStim(45),
    ParameterStimMode(46),
    ParameterLedChannels(47),
    ParameterLedState(48),
    ParameterPulseOximeterParamPack(49),
    ParameterPulseOximeterState(50),
    ParameterSamplingFrequencyPulseOximeter(51);

    private final int ID;

    SensorParameter(int ID) {
        this.ID = ID;
    }

    public int index() {
        return ID;
    }

    public static SensorParameter indexOf(int ID) {
        for (SensorParameter env : values()) {
            if (env.index() == ID) {
                return env;
            }
        }
        throw new IllegalArgumentException("No enum found with ID: [" + ID + "]");
    }
}
