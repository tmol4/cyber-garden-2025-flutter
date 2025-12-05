package com.neurosdk2.neuro.interfaces;

import com.neurosdk2.neuro.types.CallibriRespirationData;

public interface CallibriRespirationDataReceived {
    void onCallibriRespirationDataReceived(CallibriRespirationData[] data);
}
