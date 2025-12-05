package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.ResistChannelsData;

public interface NeuroEEGResistDataReceived {
    void onResistDataReceived(ResistChannelsData[] data);
}
