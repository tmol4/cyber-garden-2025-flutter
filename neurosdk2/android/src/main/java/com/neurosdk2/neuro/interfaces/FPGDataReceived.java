package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.FPGData;

public interface FPGDataReceived {
    void onFPGDataReceived(FPGData[] data);
}
