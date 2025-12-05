package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.HeadbandSignalData;

public interface HeadbandSignalDataReceived {
    void onHeadbandSignalDataReceived(HeadbandSignalData[] data);
}
