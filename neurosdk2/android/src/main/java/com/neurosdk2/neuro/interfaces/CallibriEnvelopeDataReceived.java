package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.CallibriEnvelopeData;

public interface CallibriEnvelopeDataReceived {
    void onCallibriEnvelopeDataReceived(CallibriEnvelopeData[] data);
}
