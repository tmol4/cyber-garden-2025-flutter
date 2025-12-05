package com.neurosdk2.neuro.types;

public class EEGChannelInfo {
    private /*EEGChannelId*/int mId;
    private /*EEGChannelType*/int mChType;
    private String mName;
    private short mNum;

    public EEGChannelInfo(){}

    public EEGChannelInfo(EEGChannelId id, EEGChannelType chType, String name, short num){
        mId = id.index();
        mChType = chType.index();
        mName = name;
        mNum = num;
    }

    public EEGChannelInfo(int id, int chType, String name, short num){
        mId = id;
        mChType = chType;
        mName = name;
        mNum = num;
    }


    public EEGChannelId getId() {
        return EEGChannelId.indexOf(mId);
    }

    public EEGChannelType getChType() {
        return EEGChannelType.indexOf(mChType);
    }

    public String getName() {
        return mName;
    }

    public short getNum() {
        return mNum;
    }
}
