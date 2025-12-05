package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.SignalChannelsData;

public interface BrainBit2SignalDataReceived {
    void onSignalDataReceived(SignalChannelsData[] data);
}