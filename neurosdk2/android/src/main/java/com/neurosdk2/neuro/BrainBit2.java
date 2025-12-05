package com.neurosdk2.neuro;

import com.neurosdk2.neuro.interfaces.BrainBit2ResistDataReceived;
import com.neurosdk2.neuro.interfaces.BrainBit2SignalDataReceived;
import com.neurosdk2.neuro.interfaces.FPGDataReceived;
import com.neurosdk2.neuro.interfaces.MEMSDataReceived;
import com.neurosdk2.neuro.interfaces.SensorAmpModeChanged;
import com.neurosdk2.neuro.types.BrainBit2AmplifierParam;
import com.neurosdk2.neuro.types.EEGChannelInfo;
import com.neurosdk2.neuro.types.FPGData;
import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.RedAmplitude;
import com.neurosdk2.neuro.types.ResistRefChannelsData;
import com.neurosdk2.neuro.types.SensorAccelerometerSensitivity;
import com.neurosdk2.neuro.types.SensorAmpMode;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorGyroscopeSensitivity;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;
import com.neurosdk2.neuro.types.SignalChannelsData;

import java.util.Arrays;
import java.util.List;

public class BrainBit2 extends Sensor {

    static {
        System.loadLibrary("neurosdk2");
    }

    public static final int BRAINBIT2_MAX_CH_COUNT = 8;    

    private long mResistCallbackBrainBit2Ptr = 0;
    public BrainBit2ResistDataReceived resistDataReceived;

    private long mSignalCallbackBrainBit2Ptr = 0;
    public BrainBit2SignalDataReceived signalDataReceived;

    private long mAmpModeCallbackNeuroSmartPtr = 0;
    public SensorAmpModeChanged sensorAmpModeChanged;

    private long mFPGDataCallbackNeuroSmartPtr = 0;
    public FPGDataReceived fpgDataReceived;

    private long mMEMSDataCallbackPtr = 0;
    public MEMSDataReceived memsDataReceived;

    protected BrainBit2(long sensor_ptr) {
        super(sensor_ptr);

        if (isSupportedFeature(SensorFeature.Resist)) {
            mResistCallbackBrainBit2Ptr = addResistCallbackBrainBit2(mSensorPtr, this);
        }
        if (isSupportedFeature(SensorFeature.Signal)) {
            mSignalCallbackBrainBit2Ptr = addSignalCallbackBrainBit2(mSensorPtr, this);
        }
        mAmpModeCallbackNeuroSmartPtr = AmpModeModule.addAmpModeCallback(mSensorPtr, this);
        if (isSupportedFeature(SensorFeature.FPG)) {
            mFPGDataCallbackNeuroSmartPtr = FPGModule.addFPGDataCallbackNeuroSmart(mSensorPtr, this);
        }
        if (isSupportedFeature(SensorFeature.MEMS)) {
            mMEMSDataCallbackPtr = MEMSModule.addMEMSDataCallback(mSensorPtr, this);
        }
    }

    @Override
    public void close() {
        throwIfClosed();
        try
        {
            if(mResistCallbackBrainBit2Ptr != 0) removeResistCallbackBrain2Bit(mResistCallbackBrainBit2Ptr);
            if(mSignalCallbackBrainBit2Ptr != 0) removeSignalCallbackBrain2Bit(mSignalCallbackBrainBit2Ptr);
            if(mAmpModeCallbackNeuroSmartPtr != 0) AmpModeModule.removeAmpModeCallback(mAmpModeCallbackNeuroSmartPtr);
            if(mFPGDataCallbackNeuroSmartPtr != 0) FPGModule.removeFPGDataCallbackNeuroSmart(mFPGDataCallbackNeuroSmartPtr);
            if(mMEMSDataCallbackPtr != 0) MEMSModule.removeMEMSDataCallback(mMEMSDataCallbackPtr);
        }
        finally
        {
            super.close();
        }
    }

    public SensorSamplingFrequency getSamplingFrequencyMEMS() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf(MEMSModule.readSamplingFrequencyMEMSSensor(mSensorPtr));
    }

    public SensorSamplingFrequency getSamplingFrequencyFPG() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf(FPGModule.readSamplingFrequencyFPGSensor(mSensorPtr));
    }

    public SensorSamplingFrequency getSamplingFrequencyResist() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf(readSamplingFrequencyResistSensor(mSensorPtr));
    }

    public SensorAccelerometerSensitivity getAccSens() {
        throwIfClosed();
        return SensorAccelerometerSensitivity.indexOf(MEMSModule.readAccelerometerSensSensor(mSensorPtr));
    }

    public void setAccSens(SensorAccelerometerSensitivity accSens) {
        throwIfClosed();
        MEMSModule.writeAccelerometerSensSensor(mSensorPtr, accSens.index());
    }

    public SensorGyroscopeSensitivity getGyroSens() {
        throwIfClosed();
        return SensorGyroscopeSensitivity.indexOf(MEMSModule.readGyroscopeSensSensor(mSensorPtr));
    }

    public void setGyroSens(SensorGyroscopeSensitivity accSens) {
        throwIfClosed();
        MEMSModule.writeGyroscopeSensSensor(mSensorPtr, accSens.index());
    }

    public IrAmplitude getIrAmplitude() {
        throwIfClosed();
        return IrAmplitude.indexOf(FPGModule.readIrAmplitudeHeadband(mSensorPtr));
    }

    public void setIrAmplitude(IrAmplitude irAmplitudeHeadband) {
        throwIfClosed();
        FPGModule.writeIrAmplitudeHeadband(mSensorPtr, irAmplitudeHeadband.index());
    }

    public RedAmplitude getRedAmplitude() {
        throwIfClosed();
        return RedAmplitude.indexOf(FPGModule.readRedAmplitudeHeadband(mSensorPtr));
    }

    public void setRedAmplitude(RedAmplitude redAmplitudeHeadband) {
        throwIfClosed();
        FPGModule.writeRedAmplitudeHeadband(mSensorPtr, redAmplitudeHeadband.index());
    }

    public SensorAmpMode getAmpMode() {
        throwIfClosed();
        return SensorAmpMode.indexOf(AmpModeModule.readAmpMode(mSensorPtr));
    }

    public List<EEGChannelInfo> getSupportedChannels() {
        throwIfClosed();
        EEGChannelInfo[] supportedChannels = readSupportedChannelsBrainBit2(mSensorPtr);
        return Arrays.asList(supportedChannels);
    }

    public BrainBit2AmplifierParam getAmplifierParam(){
        throwIfClosed();
        return readAmplifierParamBrainBit2(mSensorPtr);
    }

    public void setAmplifierParam(BrainBit2AmplifierParam params){
        throwIfClosed();
        writeAmplifierParamBrainBit2(mSensorPtr, params);
    }

    public void pingNeuroSmart(byte marker) {
        throwIfClosed();
        pingNeuroSmart(mSensorPtr, marker);
    }

    private void onAmpModeChanged(long sensorPtr, int data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(sensorAmpModeChanged != null) {
            sensorAmpModeChanged.onSensorAmpModeChanged(SensorAmpMode.indexOf(data));
        }
    }

    private void onFPGDataReceived(long sensorPtr, FPGData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(fpgDataReceived != null) {
            fpgDataReceived.onFPGDataReceived(data);
        }
    }

    private void onMEMSDataReceived(long sensorPtr, MEMSData[] data){
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if (memsDataReceived != null) {
            memsDataReceived.onMEMSDataReceived(data);
        }
    }

    private void onResistReceived(long sensorPtr, ResistRefChannelsData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(resistDataReceived != null) {
            resistDataReceived.onResistDataReceived(data);
        }
    }

    private void onSignalReceived(long sensorPtr, SignalChannelsData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(signalDataReceived != null) {
            signalDataReceived.onSignalDataReceived(data);
        }
    }


    private static native long addResistCallbackBrainBit2(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalCallbackBrainBit2(long sensor_ptr, Sensor sensor_obj);
    private static native void removeResistCallbackBrain2Bit(long ptr);
    private static native void removeSignalCallbackBrain2Bit(long ptr);

    private static native int readSamplingFrequencyResistSensor(long sensor_ptr);
    private static native void pingNeuroSmart(long sensor_ptr, byte marker);
    private static native EEGChannelInfo[] readSupportedChannelsBrainBit2(long sensor_ptr);

    private static native BrainBit2AmplifierParam readAmplifierParamBrainBit2(long sensor_ptr);
    private static native void writeAmplifierParamBrainBit2(long sensor_ptr, BrainBit2AmplifierParam params);

}
