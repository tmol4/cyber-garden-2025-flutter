package com.neurosdk2.neuro.types;

import java.util.Arrays;

public class NeuroEEGAmplifierParam {

    private boolean mReferentResistMesureAllow;
    private /*SensorSamplingFrequency*/int mFrequency;
    private /*EEGRefMode*/int mReferentMode;
    public EEGChannelMode[] ChannelMode;
    public SensorGain[] ChannelGain;
    private boolean mUseDiffAsRespiration;

    public NeuroEEGAmplifierParam(boolean referentResistMesureAllow,
                                  SensorSamplingFrequency frequency,
                                  EEGRefMode referentMode,
                                  EEGChannelMode[] channelMode,
                                  SensorGain[] channelGain,
                                  boolean useDiffAsRespiration){
        mReferentResistMesureAllow = referentResistMesureAllow;
        mFrequency = frequency.index();
        mReferentMode = referentMode.index();
        ChannelMode = channelMode;
        ChannelGain = channelGain;
        mUseDiffAsRespiration = useDiffAsRespiration;
    }

    public NeuroEEGAmplifierParam(boolean referentResistMesureAllow,
                                  int frequency,
                                  int referentMode,
                                  int[] channelMode,
                                  int[] channelGain,
                                  boolean useDiffAsRespiration){
        mReferentResistMesureAllow = referentResistMesureAllow;
        mFrequency = frequency;
        mReferentMode = referentMode;
        mUseDiffAsRespiration = useDiffAsRespiration;

        ChannelMode = new EEGChannelMode[channelMode.length];
        for (int i = 0; i < channelMode.length; i++) {
            ChannelMode[i] = EEGChannelMode.indexOf(channelMode[i]);
        }
        ChannelGain = new SensorGain[channelGain.length];
        for (int i = 0; i < channelGain.length; i++) {
            ChannelGain[i] = SensorGain.indexOf(channelGain[i]);
        }

    }

    public boolean getReferentResistMesureAllow() {
        return mReferentResistMesureAllow;
    }

    public void setReferentResistMesureAllow(boolean mReferentResistMesureAllow) {
        this.mReferentResistMesureAllow = mReferentResistMesureAllow;
    }

    public SensorSamplingFrequency getFrequency() {
        return SensorSamplingFrequency.indexOf(mFrequency);
    }

    public void setFrequency(SensorSamplingFrequency mFrequency) {
        this.mFrequency = mFrequency.index();
    }

    public EEGRefMode getReferentMode() {
        return EEGRefMode.indexOf(mReferentMode);
    }

    public void setReferentMode(EEGRefMode mReferentMode) {
        this.mReferentMode = mReferentMode.index();
    }

    public boolean getUseDiffAsRespiration(){
        return mUseDiffAsRespiration;
    }

    public void setUseDiffAsRespiration(boolean useDiffAsRespiration){
        mUseDiffAsRespiration = useDiffAsRespiration;
    }

    public int getRawFrequency() {
        return mFrequency;
    }

    public int getRawReferentMode() {
        return mReferentMode;
    }

    public int[] getRawChannelMode() {
        int[] channelMode = new int[ChannelMode.length];
        for (int i = 0; i < ChannelMode.length; i++) {
            channelMode[i] = ChannelMode[i].index();
        }
        return channelMode;
    }

    public int[] getRawChannelGain(){
        int[] channelGain = new int[ChannelGain.length];
        for (int i = 0; i < ChannelGain.length; i++) {
            channelGain[i] = ChannelGain[i].index();
        }
        return channelGain;
    }
}
