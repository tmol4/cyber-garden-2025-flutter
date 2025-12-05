package com.neurosdk2.neuro;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorInfo;
import java.util.Arrays;
import java.util.List;

import com.neurosdk2.neuro.Callibri;
import com.neurosdk2.neuro.BrainBit;
import com.neurosdk2.neuro.BrainBitBlack;
import com.neurosdk2.neuro.Headband;
import com.neurosdk2.neuro.Headphones2;
import com.neurosdk2.neuro.NeuroEEG;
import com.neurosdk2.neuro.BrainBit2;

public class Scanner {
    static {
        System.loadLibrary("neurosdk2");
    }

    public interface ScannerCallback{
        void onSensorListChanged(Scanner scanner, List<SensorInfo> sensors);
    }

    private final long mScannerPtr;

    private final long mSensorCallback;
    public ScannerCallback sensorsChanged;

    private boolean mIsClosed = false;

    public Scanner(SensorFamily... filters){
        mScannerPtr = createNativeScanner(filters);
        mSensorCallback = addSensorsCallbackScanner(mScannerPtr, this);
    }

    public void close()
    {
        if(!mIsClosed)
        {
            try
            {
                removeSensorsCallbackScanner(mSensorCallback);
                freeScanner(mScannerPtr);
            }
            finally
            {
                mIsClosed = true;
            }
        }
    }

    public void start()
    {
        throwIfClosed();
        startScanner(mScannerPtr);
    }

    public void stop()
    {
        throwIfClosed();
        stopScanner(mScannerPtr);
    }

    public Sensor createSensor(SensorInfo info)
    {
        throwIfClosed();
        if(info.getName() == null || info.getName().isEmpty())
            throw new UnsupportedOperationException("Sensor info is empty!");
        long sensorPtr = createSensor(mScannerPtr, info);

        if(info.getSensFamily() == SensorFamily.SensorLECallibri || info.getSensFamily() == SensorFamily.SensorLEKolibri)
            return new Callibri(sensorPtr);
        if(info.getSensFamily() == SensorFamily.SensorLEBrainBit)
            return new BrainBit(sensorPtr);
        if(info.getSensFamily() == SensorFamily.SensorLEBrainBitBlack)
            return new BrainBitBlack(sensorPtr);
        if(info.getSensFamily() == SensorFamily.SensorLEHeadband)
            return new Headband(sensorPtr);
        if(info.getSensFamily() == SensorFamily.SensorLEHeadPhones2)
            return new Headphones2(sensorPtr);
        if(info.getSensFamily() == SensorFamily.SensorLENeuroEEG)
            return new NeuroEEG(sensorPtr);
        if(info.getSensFamily() == SensorFamily.SensorLEBrainBit2 ||
        info.getSensFamily() == SensorFamily.SensorLEBrainBitPro || 
        info.getSensFamily() == SensorFamily.SensorLEBrainBitFlex)
            return new BrainBit2(sensorPtr);

        return null;
    }

    public List<SensorInfo> getSensors()
    {
        throwIfClosed();
        SensorInfo[] sensors = sensorsScanner(mScannerPtr);
        return Arrays.asList(sensors);
    }

    @Override
    protected void finalize() throws Throwable {
        if(!mIsClosed) close();
        super.finalize();
    }

    private void throwIfClosed(){
        if (mIsClosed)
            throw new UnsupportedOperationException("Scanner is closed");
    }

    private long createNativeScanner (SensorFamily[] filters)
    {
        int[] result = new int[filters.length];
        for(int i = 0; i < filters.length; i++)
        {
            result[i] = filters[i].index();
        }
        return createScanner(result);
    }

    private void onSensorListChanged(long scannerPtr, SensorInfo[] sensors)
    {
        if(scannerPtr != mScannerPtr || mIsClosed) return;
        if(sensorsChanged != null){
            sensorsChanged.onSensorListChanged(this, Arrays.asList(sensors));
        }
    }

    private static native long createScanner(int[] filters);
    private static native long addSensorsCallbackScanner(long scannerPtr, Scanner scannerObj);
    private static native void removeSensorsCallbackScanner(long callbackPtr);
    private static native void startScanner(long scannerPtr);
    private static native void stopScanner(long scannerPtr);
    private static native SensorInfo[] sensorsScanner(long scannerPtr);
    private static native long createSensor(long scannerPtr, SensorInfo info);
    private static native void freeScanner(long scannerPtr);

}
