package com.neurosdk2.neuro;

import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.interfaces.MEMSDataReceived;
import com.neurosdk2.neuro.interfaces.QuaternionDataReceived;
import com.neurosdk2.neuro.interfaces.CallibriElectrodeStateChanged;
import com.neurosdk2.neuro.interfaces.CallibriEnvelopeDataReceived;
import com.neurosdk2.neuro.interfaces.CallibriRespirationDataReceived;
import com.neurosdk2.neuro.interfaces.CallibriSignalDataReceived;
import com.neurosdk2.neuro.types.SensorDataOffset;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorFilter;
import com.neurosdk2.neuro.types.SensorExternalSwitchInput;
import com.neurosdk2.neuro.types.SensorADCInput;
import com.neurosdk2.neuro.types.CallibriStimulatorMAState;
import com.neurosdk2.neuro.types.CallibriStimulationParams;
import com.neurosdk2.neuro.types.CallibriMotionAssistantParams;
import com.neurosdk2.neuro.types.CallibriMotionCounterParam;
import com.neurosdk2.neuro.types.CallibriSignalData;
import com.neurosdk2.neuro.types.CallibriRespirationData;
import com.neurosdk2.neuro.types.CallibriElectrodeState;
import com.neurosdk2.neuro.types.CallibriColorType;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.QuaternionData;
import com.neurosdk2.neuro.types.CallibriEnvelopeData;
import com.neurosdk2.neuro.types.CallibriSignalType;
import com.neurosdk2.neuro.types.SensorAccelerometerSensitivity;
import com.neurosdk2.neuro.types.SensorFirmwareMode;
import com.neurosdk2.neuro.types.SensorGain;
import com.neurosdk2.neuro.types.SensorGyroscopeSensitivity;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;

import java.util.List;
import java.util.Arrays;

public final class Callibri extends Sensor {
    static {
        System.loadLibrary("neurosdk2");
    }

    private long mMEMSDataCallbackPtr = 0;
    public MEMSDataReceived memsDataReceived;

    private long mQuaternionDataCallbackPtr = 0;
    public QuaternionDataReceived quaternionDataRecieved;

    private long mSignalCallbackCallibriPtr = 0;
    public CallibriSignalDataReceived callibriSignalDataReceived;

    private long mRespirationCallbackCallibriPtr = 0;
    public CallibriRespirationDataReceived callibriRespirationDataReceived;

    private long mElectrodeStateCallbackCallibriPtr = 0;
    public CallibriElectrodeStateChanged callibriElectrodeStateChanged;

    private long mEnvelopeDataCallbackCallibriPtr = 0;
    public CallibriEnvelopeDataReceived callibriEnvelopeDataReceived;

    Callibri(long sensor_ptr)
    {
        super(sensor_ptr);

        mSignalCallbackCallibriPtr = addSignalCallbackCallibri(mSensorPtr, this);
        mElectrodeStateCallbackCallibriPtr = addElectrodeStateCallbackCallibri(mSensorPtr, this);

        if (isSupportedFeature(SensorFeature.MEMS)) {
            mMEMSDataCallbackPtr = MEMSModule.addMEMSDataCallback(mSensorPtr, this);
            mQuaternionDataCallbackPtr = addQuaternionDataCallback(mSensorPtr, this);
        }

        if (isSupportedFeature(SensorFeature.Respiration)) {
            mRespirationCallbackCallibriPtr = addRespirationCallbackCallibri(mSensorPtr, this);
        }

        if (isSupportedFeature(SensorFeature.Envelope)) {
            mEnvelopeDataCallbackCallibriPtr = addEnvelopeDataCallbackCallibri(mSensorPtr, this);
        }

    }

    @Override
    public void close() {
		
        throwIfClosed();
        try
        {
            if(mMEMSDataCallbackPtr != 0) MEMSModule.removeMEMSDataCallback(mMEMSDataCallbackPtr);
            if(mQuaternionDataCallbackPtr != 0) removeQuaternionDataCallback(mQuaternionDataCallbackPtr);
            if(mSignalCallbackCallibriPtr != 0)removeSignalCallbackCallibri(mSignalCallbackCallibriPtr);
            if(mRespirationCallbackCallibriPtr != 0)removeRespirationCallbackCallibri(mRespirationCallbackCallibriPtr);
            if(mElectrodeStateCallbackCallibriPtr != 0)removeElectrodeStateCallbackCallibri(mElectrodeStateCallbackCallibriPtr);
            if(mEnvelopeDataCallbackCallibriPtr != 0)removeEnvelopeDataCallbackCallibri(mEnvelopeDataCallbackCallibriPtr);
        }
        finally
        {
            super.close();
        }
    }

    public boolean isSupportedFilter(SensorFilter filter) {
        throwIfClosed();
        boolean result = isSupportedFilterSensor(mSensorPtr, filter.index());

        return result;
    }

    public List<SensorFilter> getSupportedFilters() {
        throwIfClosed();
        int[] result = getSupportedFiltersSensor(mSensorPtr);
        SensorFilter[] filters = new SensorFilter[result.length];
        for (int i = 0; i < result.length; i++) {
            filters[i] = SensorFilter.indexOf(result[i]);
        }
        return Arrays.asList(filters);
    }

    public List<SensorFilter> getHardwareFilters() {
        throwIfClosed();
        int[] result = readHardwareFiltersSensor(mSensorPtr);
        SensorFilter[] filters = new SensorFilter[result.length];
        for (int i = 0; i < result.length; i++) {
            filters[i] = SensorFilter.indexOf(result[i]);
        }
        return Arrays.asList(filters);
    }

    public void setHardwareFilters(List<SensorFilter> hardwareFilters) {
        throwIfClosed();
        int[] result = new int[hardwareFilters.size()];
        for (int i = 0; i < hardwareFilters.size(); i++) {
            result[i] = hardwareFilters.get(i).index();
        }
        writeHardwareFiltersSensor(mSensorPtr, result);
    }

    public void setFirmwareMode(SensorFirmwareMode firmwareMode) {
        throwIfClosed();
        writeFirmwareModeSensor(mSensorPtr, firmwareMode.index());
    }

    public void setSamplingFrequency(SensorSamplingFrequency samplingFrequency) {
        throwIfClosed();
        writeSamplingFrequencySensor(mSensorPtr, samplingFrequency.index());
    }

    public void setGain(SensorGain gain) {
        throwIfClosed();
        writeGainSensor(mSensorPtr, gain.index());
    }

    public void setDataOffset(SensorDataOffset dataOffset) {
        throwIfClosed();
        writeDataOffsetSensor(mSensorPtr, dataOffset.index());
    }

    public SensorExternalSwitchInput getExtSwInput() {
        throwIfClosed();
        return SensorExternalSwitchInput.indexOf(readExternalSwitchSensor(mSensorPtr));
    }

    public void setExtSwInput(SensorExternalSwitchInput extSwInput) {
        throwIfClosed();
        writeExternalSwitchSensor(mSensorPtr, extSwInput.index());
    }

    public SensorADCInput getADCInput() {
        throwIfClosed();
        return SensorADCInput.indexOf(readADCInputSensor(mSensorPtr));
    }

    public void setADCInput(SensorADCInput ADCInput) {
        throwIfClosed();
        writeADCInputSensor(mSensorPtr, ADCInput.index());
    }

    public CallibriStimulatorMAState getStimulatorMAState() {
        throwIfClosed();
        return readStimulatorAndMAStateCallibri(mSensorPtr);
    }

    public CallibriStimulationParams getStimulatorParam() {
        throwIfClosed();
        return readStimulatorParamCallibri(mSensorPtr);
    }

    public void setStimulatorParam(CallibriStimulationParams stimulatorParamCallibri) {
        throwIfClosed();
        writeStimulatorParamCallibri(mSensorPtr, stimulatorParamCallibri);
    }

    public CallibriMotionAssistantParams getMotionAssistantParam() {
        throwIfClosed();
        return readMotionAssistantParamCallibri(mSensorPtr);
    }

    public void setMotionAssistantParam(CallibriMotionAssistantParams motionAssistantParamCallibri) {
        throwIfClosed();
        writeMotionAssistantParamCallibri(mSensorPtr, motionAssistantParamCallibri);
    }

    public CallibriMotionCounterParam getMotionCounterParam() {
        throwIfClosed();
        return readMotionCounterParamCallibri(mSensorPtr);
    }

    public void setMotionCounterParam(CallibriMotionCounterParam motionCounterParamCallibri) {
        throwIfClosed();
        writeMotionCounterParamCallibri(mSensorPtr, motionCounterParamCallibri);
    }

    public int getMotionCounter() {
        throwIfClosed();
        return readMotionCounterCallibri(mSensorPtr);
    }

    public CallibriColorType getColor() {
        throwIfClosed();
        return CallibriColorType.indexOf(readColorCallibri(mSensorPtr));
    }

    public boolean getMEMSCalibrateState(){
        throwIfClosed();
        return readMEMSCalibrateStateCallibri(mSensorPtr);
    }

    public SensorSamplingFrequency getSamplingFrequencyResp() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf(readSamplingFrequencyRespSensor(mSensorPtr));
    }
	
	public SensorSamplingFrequency getSamplingFrequencyMEMS() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf(MEMSModule.readSamplingFrequencyMEMSSensor(mSensorPtr));
    }

	public SensorSamplingFrequency getSamplingFrequencyEnvelope() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf(readSamplingFrequencyEnvelopeSensor(mSensorPtr));
    }

    public CallibriSignalType getSignalType() {
        throwIfClosed();
        return CallibriSignalType.indexOf(getSignalTypeCallibriCallibri(mSensorPtr));
    }

    public void setSignalType(CallibriSignalType signalType) {
        throwIfClosed();
        setSignalTypeCallibriCallibri(mSensorPtr, signalType.index());
    }

    public CallibriElectrodeState getElectrodeState() {
        throwIfClosed();
        return CallibriElectrodeState.indexOf(readElectrodeStateCallibri(mSensorPtr));
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

    public void setGyroSens(SensorGyroscopeSensitivity gyroSens) {
        throwIfClosed();
        MEMSModule.writeGyroscopeSensSensor(mSensorPtr, gyroSens.index());
    }
	
	@Override
    protected void finalize() throws Throwable {
        if(!isClosed()) close();
        super.finalize();
    }

    private void onMEMSDataReceived(long sensorPtr, MEMSData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(memsDataReceived != null) {
            memsDataReceived.onMEMSDataReceived(data);
        }
    }

    private void onQuaternionDataReceived(long sensorPtr, QuaternionData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(quaternionDataRecieved != null) {
            quaternionDataRecieved.onQuaternionDataReceived(data);
        }
    }

    private void onCallibriSignalDataReceived(long sensorPtr, CallibriSignalData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(callibriSignalDataReceived != null) {
            callibriSignalDataReceived.onCallibriSignalDataReceived(data);
        }
    }

    private void onCallibriRespirationDataReceived(long sensorPtr, CallibriRespirationData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(callibriRespirationDataReceived != null) {
            callibriRespirationDataReceived.onCallibriRespirationDataReceived(data);
        }
    }

    private void onCallibriElectrodeStateChanged(long sensorPtr, int state)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(callibriElectrodeStateChanged != null) {
            callibriElectrodeStateChanged.onCallibriElectrodeStateChanged(CallibriElectrodeState.indexOf(state));
        }
    }

    private void onCallibriEnvelopeDataReceived(long sensorPtr, CallibriEnvelopeData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(callibriEnvelopeDataReceived != null) {
            callibriEnvelopeDataReceived.onCallibriEnvelopeDataReceived(data);
        }
    }

    private static native boolean isSupportedFilterSensor(long sensor_ptr, int filter);
    private static native int[] getSupportedFiltersSensor(long sensor_ptr);
    private static native int[] readHardwareFiltersSensor(long sensor_ptr);
    private static native void writeHardwareFiltersSensor(long sensor_ptr, int[] filters);
    private static native void writeFirmwareModeSensor(long sensor_ptr, int mode);
    private static native void writeSamplingFrequencySensor(long sensor_ptr, int samplingFrequency);
    private static native void writeGainSensor(long sensor_ptr, int gain);
    private static native void writeDataOffsetSensor(long sensor_ptr, int offset);
    private static native int readExternalSwitchSensor(long sensor_ptr);
    private static native void writeExternalSwitchSensor(long sensor_ptr, int extSwInput);
    private static native int readADCInputSensor(long sensor_ptr);
    private static native void writeADCInputSensor(long sensor_ptr, int adcInput);

    private static native CallibriStimulatorMAState readStimulatorAndMAStateCallibri(long sensor_ptr);
    private static native CallibriStimulationParams readStimulatorParamCallibri(long sensor_ptr);
    private static native void writeStimulatorParamCallibri(long sensor_ptr, CallibriStimulationParams params);
    private static native CallibriMotionAssistantParams readMotionAssistantParamCallibri(long sensor_ptr);
    private static native void writeMotionAssistantParamCallibri(long sensor_ptr, CallibriMotionAssistantParams params);
    private static native CallibriMotionCounterParam readMotionCounterParamCallibri(long sensor_ptr);
    private static native void writeMotionCounterParamCallibri(long sensor_ptr, CallibriMotionCounterParam params);
    private static native int readMotionCounterCallibri(long sensor_ptr);
    private static native int readColorCallibri(long sensor_ptr);
    private static native boolean readMEMSCalibrateStateCallibri(long sensor_ptr);
    private static native int readSamplingFrequencyRespSensor(long sensor_ptr);
	private static native int readSamplingFrequencyEnvelopeSensor(long sensor_ptr);

    private static native int getSignalTypeCallibriCallibri(long sensor_ptr);
    private static native void setSignalTypeCallibriCallibri(long sensor_ptr, int signal_type);

    private static native int readElectrodeStateCallibri(long sensor_ptr);

    private static native long addQuaternionDataCallback(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalCallbackCallibri(long sensor_ptr, Sensor sensor_obj);
    private static native long addRespirationCallbackCallibri(long sensor_ptr, Sensor sensor_obj);
    private static native long addElectrodeStateCallbackCallibri(long sensor_ptr, Sensor sensor_obj);
    private static native long addEnvelopeDataCallbackCallibri(long sensor_ptr, Sensor sensor_obj);
    private static native void removeQuaternionDataCallback(long mHandle_ptr);
    private static native void removeSignalCallbackCallibri(long mHandle_ptr);
    private static native void removeRespirationCallbackCallibri(long mHandle_ptr);
    private static native void removeElectrodeStateCallbackCallibri(long mHandle_ptr);
    private static native void removeEnvelopeDataCallbackCallibri(long mHandle_ptr);


}
