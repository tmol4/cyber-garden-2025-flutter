package com.neurosdk2.neuro.types;

public class Headphones2AmplifierParam {

    private boolean ChSignalUse1;
    private boolean ChSignalUse2;
    private boolean ChSignalUse3;
    private boolean ChSignalUse4;

    private boolean ChResistUse1;
    private boolean ChResistUse2;
    private boolean ChResistUse3;
    private boolean ChResistUse4;

    private int ChGain1;
    private int ChGain2;
    private int ChGain3;
    private int ChGain4;

    private int Current;

    public Headphones2AmplifierParam(
            boolean ChSignalUse1,
            boolean ChSignalUse2,
            boolean ChSignalUse3,
            boolean ChSignalUse4,

            boolean ChResistUse1,
            boolean ChResistUse2,
            boolean ChResistUse3,
            boolean ChResistUse4,

            int ChGain1,
            int ChGain2,
            int ChGain3,
            int ChGain4,

            int Current) {
        this.ChSignalUse1 = ChSignalUse1;
        this.ChSignalUse2 = ChSignalUse2;
        this.ChSignalUse3 = ChSignalUse3;
        this.ChSignalUse4 = ChSignalUse4;

        this.ChResistUse1 = ChResistUse1;
        this.ChResistUse2 = ChResistUse2;
        this.ChResistUse3 = ChResistUse3;
        this.ChResistUse4 = ChResistUse4;

        this.ChGain1 = ChGain1;
        this.ChGain2 = ChGain2;
        this.ChGain3 = ChGain3;
        this.ChGain4 = ChGain4;

        this.Current = Current;
    }

    public boolean isChSignalUse1() {
        return ChSignalUse1;
    }
    public void setChSignalUse1(boolean chSignalUse1) {
        ChSignalUse1 = chSignalUse1;
    }

    public boolean isChSignalUse2() {
        return ChSignalUse2;
    }
    public void setChSignalUse2(boolean chSignalUse2) {
        ChSignalUse2 = chSignalUse2;
    }

    public boolean isChSignalUse3() {
        return ChSignalUse3;
    }
    public void setChSignalUse3(boolean chSignalUse3) {
        ChSignalUse3 = chSignalUse3;
    }

    public boolean isChSignalUse4() {
        return ChSignalUse4;
    }
    public void setChSignalUse4(boolean chSignalUse4) {
        ChSignalUse4 = chSignalUse4;
    }

    public boolean isChResistUse1() {
        return ChResistUse1;
    }
    public void setChResistUse1(boolean chResistUse1) {
        ChResistUse1 = chResistUse1;
    }

    public boolean isChResistUse2() {
        return ChResistUse2;
    }
    public void setChResistUse2(boolean chResistUse2) {
        ChResistUse2 = chResistUse2;
    }

    public boolean isChResistUse3() {
        return ChResistUse3;
    }
    public void setChResistUse3(boolean chResistUse3) {
        ChResistUse3 = chResistUse3;
    }

    public boolean isChResistUse4() {
        return ChResistUse4;
    }
    public void setChResistUse4(boolean chResistUse4) {
        ChResistUse4 = chResistUse4;
    }

    public SensorGain getChGain1() {
        return SensorGain.indexOf(ChGain1);
    }
    public int getRawChGain1() { return ChGain1; }
    public void setChGain1(SensorGain chGain1) {
        ChGain1 = chGain1.index();
    }

    public SensorGain getChGain2() {
        return SensorGain.indexOf(ChGain2);
    }
    public int getRawChGain2() { return ChGain2; }
    public void setChGain2(SensorGain chGain2) {
        ChGain2 = chGain2.index();
    }

    public SensorGain getChGain3() { return SensorGain.indexOf(ChGain3); }
    public int getRawChGain3() { return ChGain3; }
    public void setChGain3(SensorGain chGain3) {
        ChGain3 = chGain3.index();
    }

    public SensorGain getChGain4() { return SensorGain.indexOf(ChGain4); }
    public int getRawChGain4() { return ChGain4; }
    public void setChGain4(SensorGain chGain4) {
        ChGain4 = chGain4.index();
    }

    public GenCurrent getCurrent() {
        return GenCurrent.indexOf(Current);
    }
    public int getRawCurrent() { return Current; }
    public void setCurrent(GenCurrent current) {
        Current = current.index();
    }
}
