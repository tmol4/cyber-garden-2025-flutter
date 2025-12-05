package com.neurosdk2.neuro.types;

public class HeadbandResistData {
    private final double mO1;
    private final double mO2;
    private final double mT3;
    private final double mT4;

    public HeadbandResistData(double o1, double o2, double t3, double t4) {
        mO1 = o1;
        mO2 = o2;
        mT3 = t3;
        mT4 = t4;
    }

    public double getO1() {
        return mO1;
    }

    public double getO2() {
        return mO2;
    }

    public double getT3() {
        return mT3;
    }

    public double getT4() {
        return mT4;
    }
}
