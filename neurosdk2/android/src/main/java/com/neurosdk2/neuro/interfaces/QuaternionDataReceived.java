package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.QuaternionData;

public interface QuaternionDataReceived {
    void onQuaternionDataReceived(QuaternionData[] data);
}
