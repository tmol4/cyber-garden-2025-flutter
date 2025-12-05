package com.neurosdk2.neuro;

import com.neurosdk2.neuro.interfaces.FPGDataReceived;
import com.neurosdk2.neuro.interfaces.MEMSDataReceived;
import com.neurosdk2.neuro.interfaces.SensorAmpModeChanged;
import com.neurosdk2.neuro.interfaces.Headphones2ResistDataReceived;
import com.neurosdk2.neuro.interfaces.Headphones2SignalDataReceived;
import com.neurosdk2.neuro.types.FPGData;
import com.neurosdk2.neuro.types.Headphones2AmplifierParam;
import com.neurosdk2.neuro.types.Headphones2ResistData;
import com.neurosdk2.neuro.types.Headphones2SignalData;
import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.RedAmplitude;
import com.neurosdk2.neuro.types.SensorAccelerometerSensitivity;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorAmpMode;
import com.neurosdk2.neuro.types.SensorGyroscopeSensitivity;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;

public final class Headphones2 extends Sensor {
    static {
        System.loadLibrary("neurosdk2");
    }

    private long mAmpModeCallbackNeuroSmartPtr = 0;
    public SensorAmpModeChanged ampModeChanged;

    private long mResistCallbackHeadphones2Ptr = 0;
    public Headphones2ResistDataReceived resistDataReceived;

    private long mSignalDataCallbackHeadphones2Ptr = 0;
    public Headphones2SignalDataReceived signalDataReceived;

    private long mFPGDataCallbackNeuroSmartPtr = 0;
    public FPGDataReceived fpgDataReceived;

    private long mMEMSDataCallbackPtr = 0;
    public MEMSDataReceived memsDataReceived;

    Headphones2(long sensor_ptr)
    {
        super(sensor_ptr);

        mAmpModeCallbackNeuroSmartPtr = AmpModeModule.addAmpModeCallback(mSensorPtr, this);
		if (isSupportedFeature(SensorFeature.Resist)) {
            mResistCallbackHeadphones2Ptr = addResistCallbackHeadphones2(mSensorPtr, this);
        }
		if (isSupportedFeature(SensorFeature.Signal)) {
            mSignalDataCallbackHeadphones2Ptr = addSignalDataCallbackHeadphones2(mSensorPtr, this);
        }
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
            if(mAmpModeCallbackNeuroSmartPtr != 0) AmpModeModule.removeAmpModeCallback(mAmpModeCallbackNeuroSmartPtr);
            if(mSignalDataCallbackHeadphones2Ptr != 0)removeSignalDataCallbackHeadphones2(mSignalDataCallbackHeadphones2Ptr);
            if(mResistCallbackHeadphones2Ptr != 0)removeResistCallbackHeadphones2(mResistCallbackHeadphones2Ptr);
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

    public Headphones2AmplifierParam getAmplifierParam() {
        throwIfClosed();
        return readAmplifierParamHeadphones2(mSensorPtr);
    }

    public void setAmplifierParam(Headphones2AmplifierParam amplifierParamHeadphones) {
        throwIfClosed();
        writeAmplifierParamHeadphones2(mSensorPtr, amplifierParamHeadphones);
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
	
	public void pingNeuroSmart(byte marker) {
        throwIfClosed();
        pingNeuroSmart(mSensorPtr, marker);
    }

    public SensorAmpMode getAmpMode() {
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
        if(ampModeChanged != null) {
            ampModeChanged.onSensorAmpModeChanged(SensorAmpMode.indexOf(data));
        }
    }

    private void onHeadphones2ResistDataReceived(long sensorPtr, Headphones2ResistData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(resistDataReceived != null) {
            resistDataReceived.onHeadphones2ResistDataReceived(data);
        }
    }

    private void onHeadphones2SignalDataReceived(long sensorPtr, Headphones2SignalData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(signalDataReceived != null) {
            signalDataReceived.onHeadphones2SignalDataReceived(data);
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

    private static native int readSamplingFrequencyResistSensor(long sensor_ptr);
    private static native Headphones2AmplifierParam readAmplifierParamHeadphones2(long sensor_ptr);
    private static native void writeAmplifierParamHeadphones2(long sensor_ptr, Headphones2AmplifierParam amp);
	private static native void pingNeuroSmart(long sensor_ptr, byte marker);
	
    private static native long addResistCallbackHeadphones2(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalDataCallbackHeadphones2(long sensor_ptr, Sensor sensor_obj);
    private static native void removeSignalDataCallbackHeadphones2(long mHandle_ptr);
    private static native void removeResistCallbackHeadphones2(long mHandle_ptr);
}
