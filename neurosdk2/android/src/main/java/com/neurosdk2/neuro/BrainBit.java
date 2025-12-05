package com.neurosdk2.neuro;

import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.interfaces.BrainBitResistDataReceived;
import com.neurosdk2.neuro.interfaces.BrainBitSignalDataReceived;
import com.neurosdk2.neuro.types.BrainBitResistData;
import com.neurosdk2.neuro.types.BrainBitSignalData;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorGain;

public class BrainBit extends Sensor {
    static {
        System.loadLibrary("neurosdk2");
    }

    private long mResistCallbackBrainBitPtr = 0;
    public BrainBitResistDataReceived brainBitResistDataReceived;

    private long mSignalDataCallbackBrainBitPtr = 0;
    public BrainBitSignalDataReceived brainBitSignalDataReceived;

    BrainBit(long sensor_ptr)
    {
        super(sensor_ptr);

        if (isSupportedFeature(SensorFeature.Resist)) {
            mResistCallbackBrainBitPtr = addResistCallbackBrainBit(mSensorPtr, this);
        }
        if (isSupportedFeature(SensorFeature.Signal)) {
            mSignalDataCallbackBrainBitPtr = addSignalDataCallbackBrainBit(mSensorPtr, this);
        }
    }

    @Override
    public void close() {
        throwIfClosed();
        try
        {
            if(mResistCallbackBrainBitPtr != 0)removeResistCallbackBrainBit(mResistCallbackBrainBitPtr);
            if(mSignalDataCallbackBrainBitPtr != 0)removeSignalDataCallbackBrainBit(mSignalDataCallbackBrainBitPtr);
        }
        finally
        {
            super.close();
        }
    }
	
	@Override
    protected void finalize() throws Throwable {
        if(!isClosed()) close();
        super.finalize();
    }

    protected void onBrainBitResistDataReceived(long sensorPtr, BrainBitResistData data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(brainBitResistDataReceived != null) {
            brainBitResistDataReceived.onBrainBitResistDataReceived(data);
        }
    }

    protected void onBrainBitSignalDataReceived(long sensorPtr, BrainBitSignalData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(brainBitSignalDataReceived != null) {
            brainBitSignalDataReceived.onBrainBitSignalDataReceived(data);
        }
    }

    public void setGain(SensorGain gain) {
        throwIfClosed();
        writeGainSensor(mSensorPtr, gain.index());
    }

    private static native long addResistCallbackBrainBit(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalDataCallbackBrainBit(long sensor_ptr, Sensor sensor_obj);
    private static native void removeResistCallbackBrainBit(long mHandle_ptr);
    private static native void removeSignalDataCallbackBrainBit(long mHandle_ptr);
    private static native void writeGainSensor(long sensor_ptr, int gain);
}
