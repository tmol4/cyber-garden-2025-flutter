package com.neurosdk2.neuro.types;

public class HeadbandSignalData {
    private final int PackNum;
    private final byte Marker;
    private final double O1;
    private final double O2;
    private final double T3;
    private final double T4;


    public HeadbandSignalData(int packNum, byte marker, double o1, double o2, double t3, double t4) {
        PackNum = packNum;
        Marker = marker;
        O1 = o1;
        O2 = o2;
        T3 = t3;
        T4 = t4;
    }

    public int getPackNum() {
        return PackNum;
    }

    public byte getMarker() {
        return Marker;
    }

    public double getO1() {
        return O1;
    }

    public double getO2() {
        return O2;
    }

    public double getT3() {
        return T3;
    }

    public double getT4() {
        return T4;
    }
}
