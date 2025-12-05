package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.BrainBitSignalData;

public interface BrainBitSignalDataReceived {
    void onBrainBitSignalDataReceived(BrainBitSignalData[] data);
}
