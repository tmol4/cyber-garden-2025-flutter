package com.neurosdk2.neuro;

import com.neurosdk2.neuro.types.NeuroEEGAmplifierParam;
import com.neurosdk2.neuro.types.ProcessSignalResult;

public class NeuroEEGSignalProcessing {

    private boolean mIsClosed = false;
    long mNeuroEEGSignalProcessParam;

    public NeuroEEGSignalProcessing(NeuroEEGAmplifierParam ampParam){
        mNeuroEEGSignalProcessParam = createSignalProcessParamNeuroEEG(ampParam);
    }

    public static int calcCRC32(byte[] data){
        return nativeCalcCRC32(data);
    }

    public ProcessSignalResult parseRawSignal(byte[] data){
        throwIfClosed();
        return parseRawSignalNeuroEEG(data, mNeuroEEGSignalProcessParam);
    }

    public void close() {
        throwIfClosed();
        try
        {
            removeSignalProcessParamNeuroEEG(mNeuroEEGSignalProcessParam);
        }
        finally
        {
            mIsClosed = true;
        }
    }

    @Override
    protected void finalize() throws Throwable {
        if(!mIsClosed) close();
        super.finalize();
    }

    protected void throwIfClosed() {
        if (mIsClosed)
            throw new UnsupportedOperationException("Signal processor is closed");
    }

    private static native long createSignalProcessParamNeuroEEG(NeuroEEGAmplifierParam ampParam);
    private static native int nativeCalcCRC32(byte[] data);
    private static native ProcessSignalResult parseRawSignalNeuroEEG(byte[] data, long param);
    private static native void removeSignalProcessParamNeuroEEG(long param);

}
