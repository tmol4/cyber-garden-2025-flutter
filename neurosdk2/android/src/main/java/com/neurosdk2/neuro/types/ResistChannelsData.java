package com.neurosdk2.neuro.types;

public class ResistChannelsData {
    private int mPackNum;
    private double mA1;
    private double mA2;
    private double mBias;
    private double[] mValues;

    public ResistChannelsData(int packNum, double a1, double a2, double bias, double[] values){
        mPackNum = packNum;
        mA1 = a1;
        mA2 = a2;
        mBias = bias;
        mValues = values;
    }


    public int getPackNum() {
        return mPackNum;
    }

    public double getA1() {
        return mA1;
    }

    public double getA2() {
        return mA2;
    }

    public double getBias() {
        return mBias;
    }

    public double[] getValues() {
        return mValues;
    }

    public void setValues(double[] values){
        mValues = values;
    }
}
