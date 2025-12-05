package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.SensorFileData;

public interface NeuroEEGFileStreamDataReceived {
    void onFileStreamDataReceived(SensorFileData[] data);
}
