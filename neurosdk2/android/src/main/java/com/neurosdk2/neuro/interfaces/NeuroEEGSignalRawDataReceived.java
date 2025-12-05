package com.neurosdk2.neuro.interfaces;

public interface NeuroEEGSignalRawDataReceived {
    void onSignalRawDataReceived(byte[] resistData);
}
