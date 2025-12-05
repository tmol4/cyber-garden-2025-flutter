package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.CallibriSignalData;

public interface CallibriSignalDataReceived {
    void onCallibriSignalDataReceived(CallibriSignalData[] data);
}
