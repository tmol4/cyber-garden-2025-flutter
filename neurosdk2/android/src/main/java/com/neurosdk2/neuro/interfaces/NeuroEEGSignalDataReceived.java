package com.neurosdk2.neuro.interfaces;


import com.neurosdk2.neuro.types.SignalChannelsData;

public interface NeuroEEGSignalDataReceived {
    void onSignalDataReceived(SignalChannelsData[] data);
}
