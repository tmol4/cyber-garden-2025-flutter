package com.neurosdk2.neuro;

import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.ParameterInfo;
import com.neurosdk2.neuro.types.SensorCommand;
import com.neurosdk2.neuro.types.SensorDataOffset;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorFirmwareMode;
import com.neurosdk2.neuro.types.SensorGain;
import com.neurosdk2.neuro.types.SensorParameter;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;
import com.neurosdk2.neuro.types.SensorState;
import com.neurosdk2.neuro.types.SensorVersion;

import java.util.Arrays;
import java.util.List;

public interface ISensor {



    void close();
    void connect();
    void disconnect();
    List<SensorFeature> getSupportedFeature();
    boolean isSupportedFeature(SensorFeature module);
    List<SensorCommand> getSupportedCommand();
    boolean isSupportedCommand(SensorCommand command);
    List<ParameterInfo> getSupportedParameter();
    boolean isSupportedParameter(SensorParameter parameter);
    void execCommand(SensorCommand command);
    String getName();
    void setName(String name);
    SensorState getState();
    String getAddress();
    String getSerialNumber();
    void setSerialNumber(String serialNumber);
    int getBattPower();
    SensorSamplingFrequency getSamplingFrequency();
    SensorGain getGain();
    SensorDataOffset getDataOffset();
    SensorFirmwareMode getFirmwareMode();
    SensorVersion getVersion();
    int getChannelsCount();
    SensorFamily getSensFamily();
}
