package com.neurosdk2.neuro.types;

public class SensorInfo {
    private int mSensFamily;
    private byte mSensModel;
    private String mName;
    private String mAddress;
    private String mSerialNumber;
    private byte mPairingRequired;
    private short mRSSI;

    public SensorInfo(){}

    public SensorInfo(SensorFamily sensFamily, byte sensModel, String name, String address,
                      String serialNumber, boolean pairingRequired, short rssi){
        mSensFamily = sensFamily.index();
        mSensModel = sensModel;
        mName = name;
        mAddress = address;
        mSerialNumber = serialNumber;
        mPairingRequired = pairingRequired ? (byte)1 : (byte)0;
        mRSSI = rssi;
    }

    public SensorInfo(int sensFamily, byte sensModel, String name, String address,
                      String serialNumber, byte PairingRequired, short rssi){
        mSensFamily = sensFamily;
        mSensModel = sensModel;
        mName = name;
        mAddress = address;
        mSerialNumber = serialNumber;
        mPairingRequired = PairingRequired;
        mRSSI = rssi;
    }

    public int getRawSensFamily() {
        return mSensFamily;
    }

    public SensorFamily getSensFamily() {
        return SensorFamily.indexOf(mSensFamily);
    }

    public int getSensModel() {
        return mSensModel;
    }

    public String getName() {
        return mName;
    }

    public String getAddress() {
        return mAddress;
    }

    public String getSerialNumber() {
        return mSerialNumber;
    }

    public boolean getPairingRequired() { return mPairingRequired != 0; }

    public short getRSSI() {
        return mRSSI;
    }

}
