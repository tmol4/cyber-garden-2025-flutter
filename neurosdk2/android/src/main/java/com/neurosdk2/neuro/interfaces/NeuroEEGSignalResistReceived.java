package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.ResistChannelsData;
import com.neurosdk2.neuro.types.SignalChannelsData;

public interface NeuroEEGSignalResistReceived {
    void onSignalResistDataReceived(SignalChannelsData[] signalData, ResistChannelsData[] resistData);
}
