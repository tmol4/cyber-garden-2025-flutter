package com.neurosdk2.neuro;

import com.neurosdk2.neuro.interfaces.FPGDataReceived;
import com.neurosdk2.neuro.interfaces.HeadbandResistDataReceived;
import com.neurosdk2.neuro.interfaces.HeadbandSignalDataReceived;
import com.neurosdk2.neuro.interfaces.MEMSDataReceived;
import com.neurosdk2.neuro.interfaces.SensorAmpModeChanged;
import com.neurosdk2.neuro.types.FPGData;
import com.neurosdk2.neuro.types.HeadbandResistData;
import com.neurosdk2.neuro.types.HeadbandSignalData;
import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.RedAmplitude;
import com.neurosdk2.neuro.types.SensorAmpMode;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;

public final class Headband extends Sensor {
    static {
        System.loadLibrary("neurosdk2");
    }

    private long mAmpModeCallbackNeuroSmartPtr = 0;
    public SensorAmpModeChanged sensorAmpModeChanged;

    private long mFPGDataCallbackNeuroSmartPtr = 0;
    public FPGDataReceived fpgDataReceived;

    private long mMEMSDataCallbackPtr = 0;
    public MEMSDataReceived memsDataReceived;

    private long mResistCallbackHeadbandPtr = 0;
    public HeadbandResistDataReceived headbandResistDataReceived;

    private long mSignalDataCallbackHeadbandPtr = 0;
    public HeadbandSignalDataReceived headbandSignalDataReceived;

    Headband(long sensor_ptr)
    {
        super(sensor_ptr);

        mAmpModeCallbackNeuroSmartPtr = AmpModeModule.addAmpModeCallback(mSensorPtr, this);
        if(isSupportedFeature(SensorFeature.MEMS))
        {
            mMEMSDataCallbackPtr = MEMSModule.addMEMSDataCallback(mSensorPtr, this);
        }
        if (isSupportedFeature(SensorFeature.Resist)) {
            mResistCallbackHeadbandPtr = addResistCallbackHeadband(mSensorPtr, this);
        }
        if (isSupportedFeature(SensorFeature.Signal)) {
            mSignalDataCallbackHeadbandPtr = addSignalDataCallbackHeadband(mSensorPtr, this);
        }
        if (isSupportedFeature(SensorFeature.FPG)) {
            mFPGDataCallbackNeuroSmartPtr = FPGModule.addFPGDataCallbackNeuroSmart(mSensorPtr, this);
        }
    }

    @Override
    public void close() {
        throwIfClosed();
        try
        {
            if(mAmpModeCallbackNeuroSmartPtr != 0) AmpModeModule.removeAmpModeCallback(mAmpModeCallbackNeuroSmartPtr);
            if(mFPGDataCallbackNeuroSmartPtr != 0) FPGModule.removeFPGDataCallbackNeuroSmart(mFPGDataCallbackNeuroSmartPtr);
            if(mMEMSDataCallbackPtr != 0) MEMSModule.removeMEMSDataCallback(mMEMSDataCallbackPtr);
            if(mResistCallbackHeadbandPtr != 0) removeResistCallbackHeadband(mResistCallbackHeadbandPtr);
            if(mSignalDataCallbackHeadbandPtr != 0) removeSignalDataCallbackHeadband(mSignalDataCallbackHeadbandPtr);
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

    public void pingNeuroSmart(byte marker) {
        throwIfClosed();
        pingNeuroSmart(mSensorPtr, marker);
    }

    public SensorAmpMode getAmpModeSensor() {
        throwIfClosed();
        return SensorAmpMode.indexOf(AmpModeModule.readAmpMode(mSensorPtr));
    }
	
	@Override
    protected void finalize() throws Throwable {
        if(!isClosed()) close();
        super.finalize();
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

    private void onHeadbandResistDataReceived(long sensorPtr, HeadbandResistData data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(headbandResistDataReceived != null) {
            headbandResistDataReceived.onHeadbandResistDataReceived(data);
        }
    }

    private void onHeadbandSignalDataReceived(long sensorPtr, HeadbandSignalData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(headbandSignalDataReceived != null) {
            headbandSignalDataReceived.onHeadbandSignalDataReceived(data);
        }
    }

    private static native int readSamplingFrequencyResistSensor(long sensor_ptr);
    private static native void pingNeuroSmart(long sensor_ptr, byte marker);
    private static native long addResistCallbackHeadband(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalDataCallbackHeadband(long sensor_ptr, Sensor sensor_obj);
    private static native void removeResistCallbackHeadband(long mHandle_ptr);
    private static native void removeSignalDataCallbackHeadband(long mHandle_ptr);

}
