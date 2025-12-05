package com.neurosdk2.neuro.types;

public class ParameterInfo {
    private final int mParam;
    private final int mParamAccess;

    public ParameterInfo(int param, int paramAccess) {
        mParam = param;
        mParamAccess = paramAccess;
    }

    public SensorParameter getParam() {
        return SensorParameter.indexOf(mParam);
    }

    public SensorParamAccess getParamAccess() {
        return SensorParamAccess.indexOf(mParamAccess);
    }

    public int getRawParam() {
        return mParam;
    }

    public int getRawParamAccess() {
        return mParamAccess;
    }
}
