package com.neurosdk2.neuro.interfaces;


import com.neurosdk2.neuro.types.ResistRefChannelsData;

public interface BrainBit2ResistDataReceived {
    void onResistDataReceived(ResistRefChannelsData[] data);
}
