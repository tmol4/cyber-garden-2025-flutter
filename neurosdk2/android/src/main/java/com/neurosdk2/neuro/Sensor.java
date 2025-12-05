package com.neurosdk2.neuro;

import com.neurosdk2.neuro.ISensor;
import com.neurosdk2.neuro.types.ParameterInfo;
import com.neurosdk2.neuro.types.SensorCommand;
import com.neurosdk2.neuro.types.SensorDataOffset;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorFirmwareMode;
import com.neurosdk2.neuro.types.SensorGain;
import com.neurosdk2.neuro.types.SensorParameter;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;
import com.neurosdk2.neuro.types.SensorState;
import com.neurosdk2.neuro.types.SensorVersion;

import java.util.Arrays;
import java.util.List;

public class Sensor implements ISensor {

    public interface SensorStateChanged {
        void onStateChanged(SensorState state);
    }

    public interface BatteryChanged {
        void onBatteryChanged(int battery);
    }

    private boolean mIsClosed = false;

    protected final long mSensorPtr;

    private long mBatteryCallbackPtr = 0;
    public BatteryChanged batteryChanged = null;

    private final long mConnectionStateCallbackPtr;
    public SensorStateChanged sensorStateChanged = null;

    protected Sensor(long sensor_ptr) {
        mSensorPtr = sensor_ptr;

        mConnectionStateCallbackPtr = addConnectionStateCallback(mSensorPtr, this);
        if(isSupportedParameter(SensorParameter.ParameterBattPower))
        {
            mBatteryCallbackPtr = addBatteryCallback(mSensorPtr, this);
        }
    }

    public void close()
    {
        if(!mIsClosed)
        {
            try
            {
                if(mBatteryCallbackPtr != 0) removeBatteryCallback(mBatteryCallbackPtr);
                if(mConnectionStateCallbackPtr != 0)removeConnectionStateCallback(mConnectionStateCallbackPtr);
                freeSensor(mSensorPtr);
            }
            finally
            {
                mIsClosed = true;
            }
        }
    }

    public void connect() {
        throwIfClosed();
        connect(mSensorPtr);
    }

    public void disconnect() {
        throwIfClosed();
        disconnect(mSensorPtr);
    }

    public List<SensorFeature> getSupportedFeature()
    {
        throwIfClosed();
        int[] result = getFeaturesSensor(mSensorPtr);
        SensorFeature[] features = new SensorFeature[result.length];
        for (int i = 0; i < result.length; i++) {
            features[i] = SensorFeature.indexOf(result[i]);
        }
        return Arrays.asList(features);
    }

    public boolean isSupportedFeature(SensorFeature module) {
        throwIfClosed();
        return isSupportedFeature(mSensorPtr, module.index());
    }

    public List<SensorCommand> getSupportedCommand()
    {
        throwIfClosed();
        int[] result = getCommandsSensor(mSensorPtr);
        SensorCommand[] commands = new SensorCommand[result.length];
        for (int i = 0; i < result.length; i++) {
            commands[i] = SensorCommand.indexOf(result[i]);
        }
        return Arrays.asList(commands);
    }

    public boolean isSupportedCommand(SensorCommand command) {
        throwIfClosed();
        return isSupportedCommand(mSensorPtr, command.index());
    }

    public List<ParameterInfo> getSupportedParameter()
    {
        throwIfClosed();
        ParameterInfo[] result = getParametersSensor(mSensorPtr);
        return Arrays.asList(result);
    }

    public boolean isSupportedParameter(SensorParameter parameter) {
        throwIfClosed();
        return isSupportedParameter(mSensorPtr, parameter.index());
    }

    public void execCommand(SensorCommand command) {
        throwIfClosed();
        execCommand(mSensorPtr, command.index());
    }

    public String getName() {
        throwIfClosed();
        return readNameSensor(mSensorPtr);
    }

    public void setName(String name) {
        throwIfClosed();
        if(name != null && !name.isEmpty()){
            writeNameSensor(mSensorPtr, name);
        }
    }

    public SensorState getState() {
        throwIfClosed();
        return SensorState.indexOf(readStateSensor(mSensorPtr));
    }

    public String getAddress() {
        throwIfClosed();
        return readAddressSensor(mSensorPtr);
    }

    public String getSerialNumber() {
        throwIfClosed();
        return readSerialNumberSensor(mSensorPtr);
    }
	
    public void setSerialNumber(String serialNumber) {
        throwIfClosed();
        writeSerialNumberSensor(mSensorPtr, serialNumber);
    }

    public int getBattPower() {
        throwIfClosed();
        return readBattPowerSensor(mSensorPtr);
    }

    public SensorSamplingFrequency getSamplingFrequency() {
        throwIfClosed();
        return SensorSamplingFrequency.indexOf( readSamplingFrequencySensor(mSensorPtr));
    }

    public SensorGain getGain() {
        return SensorGain.indexOf(readGainSensor(mSensorPtr));
    }

    public SensorDataOffset getDataOffset() {
        throwIfClosed();
        return SensorDataOffset.indexOf(readDataOffsetSensor(mSensorPtr));
    }

    public SensorFirmwareMode getFirmwareMode() {
        throwIfClosed();
        return SensorFirmwareMode.indexOf(readFirmwareModeSensor(mSensorPtr));
    }

    public SensorVersion getVersion() {
        throwIfClosed();
        return readVersionSensor(mSensorPtr);
    }

    public int getChannelsCount() {
        throwIfClosed();
        return getChannelsCountSensor(mSensorPtr);
    }

    public SensorFamily getSensFamily() {
        throwIfClosed();
        return SensorFamily.indexOf(getFamilySensor(mSensorPtr));
    }
	
	@Override
    protected void finalize() throws Throwable {
        if(!mIsClosed) close();
        super.finalize();
    }

    protected void throwIfClosed() {
        if (mIsClosed)
            throw new UnsupportedOperationException("Sensor is closed");
    }
	
	protected boolean isClosed() 
	{ 
		return mIsClosed; 
	}

    protected void onConnectionChanged(long sensorPtr, int state)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if (sensorStateChanged != null) {
            sensorStateChanged.onStateChanged(SensorState.indexOf(state));
        }
    }

    protected void onBatteryChanged(long sensorPtr, int battery) {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if (batteryChanged != null) {
            batteryChanged.onBatteryChanged(battery);
        }
    }

    private static native void connect(long sensor_ptr);
    private static native void disconnect(long sensor_ptr);
    private static native void freeSensor(long sensor_ptr);

    private static native int[] getFeaturesSensor(long sensor_ptr);
    private static native boolean isSupportedFeature(long sensor_ptr, int feature);

    private static native int[] getCommandsSensor(long sensor_ptr);
    private static native boolean isSupportedCommand(long sensor_ptr, int command);

    private static native ParameterInfo[] getParametersSensor(long sensor_ptr);
    private static native boolean isSupportedParameter(long sensor_ptr, int parameter);

    private static native void execCommand(long sensor_ptr, int command);

    private static native int getChannelsCountSensor(long sensor_ptr);
    private static native int getFamilySensor(long sensor_ptr);

    private static native String readNameSensor(long sensor_ptr);
    private static native void writeNameSensor(long sensor_ptr, String name);
    private static native int readStateSensor(long sensor_ptr);
    private static native String readAddressSensor(long sensor_ptr);
    private static native String readSerialNumberSensor(long sensor_ptr);
    private static native void writeSerialNumberSensor(long sensor_ptr, String sn);
    private static native int readBattPowerSensor(long sensor_ptr);
    private static native int readSamplingFrequencySensor(long sensor_ptr);
    private static native int readGainSensor(long sensor_ptr);
    private static native int readDataOffsetSensor(long sensor_ptr);
    private static native int readFirmwareModeSensor(long sensor_ptr);
    private static native SensorVersion readVersionSensor(long sensor_ptr);

    private static native long addConnectionStateCallback(long sensor_ptr, Sensor sensor_obj);
    private static native long addBatteryCallback(long sensor_ptr, Sensor sensor_obj);
    private static native void removeConnectionStateCallback(long mHandle_ptr);
    private static native void removeBatteryCallback(long mHandle_ptr);

}