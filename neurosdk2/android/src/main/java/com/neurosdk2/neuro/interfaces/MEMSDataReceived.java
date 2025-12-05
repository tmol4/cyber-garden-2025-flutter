package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.MEMSData;

public interface MEMSDataReceived {
    void onMEMSDataReceived(MEMSData[] data);
}