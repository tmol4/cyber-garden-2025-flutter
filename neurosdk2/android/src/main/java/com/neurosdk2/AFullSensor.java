package com.neurosdk2;

import static com.neurosdk2.Constants.DATA_ID;
import static com.neurosdk2.Constants.GUID_ID;

import android.os.Handler;
import android.os.Looper;

import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.ParameterInfo;

import com.neurosdk2.neuro.types.BrainBit2AmplifierParam;
import com.neurosdk2.neuro.types.EEGChannelInfo;


import com.neurosdk2.neuro.types.CallibriColorType;
import com.neurosdk2.neuro.types.CallibriElectrodeState;
import com.neurosdk2.neuro.types.CallibriMotionAssistantParams;
import com.neurosdk2.neuro.types.CallibriMotionCounterParam;
import com.neurosdk2.neuro.types.CallibriSignalType;
import com.neurosdk2.neuro.types.CallibriStimulationParams;
import com.neurosdk2.neuro.types.CallibriStimulatorMAState;
import com.neurosdk2.neuro.types.SensorFilter;


import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.RedAmplitude;

import com.neurosdk2.neuro.types.SensorADCInput;
import com.neurosdk2.neuro.types.SensorAccelerometerSensitivity;
import com.neurosdk2.neuro.types.SensorCommand;
import com.neurosdk2.neuro.types.SensorDataOffset;
import com.neurosdk2.neuro.types.SensorExternalSwitchInput;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorFeature;
import com.neurosdk2.neuro.types.SensorFirmwareMode;
import com.neurosdk2.neuro.types.SensorGain;
import com.neurosdk2.neuro.types.SensorGyroscopeSensitivity;
import com.neurosdk2.neuro.types.SensorParameter;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;
import com.neurosdk2.neuro.types.SensorVersion;

import java.util.HashMap;
import java.util.List;

public abstract class AFullSensor {

  protected Sensor sensor;
  protected String guid;
  protected Handler mainThread = new Handler(Looper.getMainLooper());

  // <editor-fold> Utils
  protected void addCallbacks(EventHolder events) {

    sensor.sensorStateChanged = (state) -> {
      HashMap<String, Object> result = createResultWithGuid();
      HashMap<String, Object> map = new HashMap<>();
      map.put("state", state.index());
      result.put(DATA_ID, map);
      mainThread.post(() -> {
        if (events.mSensorStateEventSink != null) {
          events.mSensorStateEventSink.success(result);
        }
      });
    };
    sensor.batteryChanged = (battery) -> {
      HashMap<String, Object> result = createResultWithGuid();
      HashMap<String, Object> map = new HashMap<>();
      map.put("power", battery);
      result.put(DATA_ID, map);
      mainThread.post(() -> {
        if (events.mBatteryEventSink != null) {
          events.mBatteryEventSink.success(result);
        }
      });
    };
  }

  protected void removeCallbacks() {
    sensor.sensorStateChanged = null;
    sensor.batteryChanged = null;
  }

  protected HashMap<String, Object> createResultWithGuid() {
    HashMap<String, Object> result = new HashMap<>();
    result.put(GUID_ID, guid);
    return result;
  }

  // </editor-fold>

  // <editor-fold> Sensor
  public void closeSensor() {
    removeCallbacks();
    sensor.close();
  }

  public void connectSensor() {
    sensor.connect();
  }

  public void disconnectSensor() {
    sensor.disconnect();
  }

  public void supportedFeatures(List<Long> features) {
    List<SensorFeature> nF = sensor.getSupportedFeature();
    for (int i = 0; i < nF.size(); i++) {
      features.add((long) nF.get(i).ordinal());
    }
  }

  public boolean isSupportedFeature(int feature) {
    return sensor.isSupportedFeature(SensorFeature.indexOf(feature));
  }

  public void supportedCommands(List<Long> commands) {
    List<SensorCommand> nC = sensor.getSupportedCommand();
    for (int i = 0; i < nC.size(); i++) {
      commands.add((long) nC.get(i).ordinal());
    }
  }

  public boolean isSupportedCommand(int command) {
    return sensor.isSupportedCommand(SensorCommand.indexOf(command));
  }

  public void supportedParameters(List<PigeonMessages.FParameterInfo> params) {
    for (ParameterInfo parameterInfo : sensor.getSupportedParameter()) {
      PigeonMessages.FParameterInfo param = new PigeonMessages.FParameterInfo();
      param.setParam(PigeonMessages.FSensorParameter.values()[parameterInfo.getParam().index()]);
      param.setParamAccess(PigeonMessages.FSensorParamAccess.values()[parameterInfo.getParamAccess().index()]);
      params.add(param);
    }
  }

  public boolean isSupportedParameter(int parameter) {
    return sensor.isSupportedParameter(SensorParameter.indexOf(parameter));
  }

  public void execCommand(int command) {
    sensor.execCommand(SensorCommand.indexOf(command));

  }

  public String getName() {
    return sensor.getName();
  }

  public void setName(String name) {
    sensor.setName(name);
  }

  public int getState() {
    return sensor.getState().index();
  }

  public String getAddress() {
    return sensor.getAddress();
  }

  public String getSerialNumber() {
    return sensor.getSerialNumber();
  }

  public void setSerialNumber(String sn) {
    sensor.setSerialNumber(sn);
  }

  public int getBattPower() {
    return sensor.getBattPower();
  }

  public int getSamplingFrequency() {
    return sensor.getSamplingFrequency().index();
  }

  public int getGain() {
    return sensor.getGain().index();
  }

  public SensorDataOffset getDataOffset() {
    return sensor.getDataOffset();
  }

  public int getFirmwareMode() {
    return sensor.getFirmwareMode().index();
  }

  public void getVersion(PigeonMessages.FSensorVersion res) {
    SensorVersion sensorVersion = sensor.getVersion();
    res.setFwMajor((long) sensorVersion.getFwMajor());
    res.setFwMinor((long) sensorVersion.getFwMinor());
    res.setFwPatch((long) sensorVersion.getFwPatch());
    res.setHwMajor((long) sensorVersion.getHwMajor());
    res.setHwMinor((long) sensorVersion.getHwMinor());
    res.setHwPatch((long) sensorVersion.getHwPatch());
    res.setExtMajor((long) sensorVersion.getExtMajor());
  }

  public int getChannelsCount() {
    return sensor.getChannelsCount();
  }

  public SensorFamily getSensFamily() {
    return sensor.getSensFamily();
  }
  // </editor-fold>

  protected abstract String getSensorName();

  // <editor-fold> Concrete sensors

  public int getAmpMode() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorSamplingFrequency getSamplingFrequencyResist() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }


  public SensorSamplingFrequency getSamplingFrequencyFPG() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public IrAmplitude getIrAmplitude() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setIrAmplitude(IrAmplitude amp) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public RedAmplitude getRedAmplitude() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setRedAmplitude(RedAmplitude amp) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void pingNeuroSmart(byte marker) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }


  public boolean isSupportedFilter(SensorFilter filter) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void getSupportedFilters(List<Long> res) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void getHardwareFilters(List<Long> res) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setHardwareFilters(List<Long> filters) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setFirmwareMode(SensorFirmwareMode mode) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setSamplingFrequency(SensorSamplingFrequency sf) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setGain(SensorGain gain) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setDataOffset(SensorDataOffset offset) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorExternalSwitchInput getExtSwInput() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setExtSwInput(SensorExternalSwitchInput extSwInp) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorADCInput getADCInput() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setADCInput(SensorADCInput adcInp) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriStimulatorMAState getStimulatorMAState() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriStimulationParams getStimulatorParam() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setStimulatorParam(CallibriStimulationParams param) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriMotionAssistantParams getMotionAssistantParam() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setMotionAssistantParam(CallibriMotionAssistantParams param) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriMotionCounterParam getMotionCounterParam() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setMotionCounterParam(CallibriMotionCounterParam param) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public int getMotionCounter() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriColorType getColor() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public boolean getMEMSCalibrateState() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorSamplingFrequency getSamplingFrequencyResp() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorSamplingFrequency getSamplingFrequencyEnvelope() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriSignalType getSignalType() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setSignalType(CallibriSignalType type) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public CallibriElectrodeState getElectrodeState() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }


  public SensorAccelerometerSensitivity getAccSens() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setAccSens(SensorAccelerometerSensitivity accSens) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorGyroscopeSensitivity getGyroSens() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setGyroSens(SensorGyroscopeSensitivity gyroSens) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public SensorSamplingFrequency getSamplingFrequencyMEMS() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }


  public List<EEGChannelInfo> getSupportedChannels() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public BrainBit2AmplifierParam getAmplifierParamBB2() {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  public void setAmplifierParamBB2(BrainBit2AmplifierParam param) {
    throw new UnsupportedOperationException("Unsupported " + getSensorName() + " parameter");
  }

  // </editor-fold>
}
