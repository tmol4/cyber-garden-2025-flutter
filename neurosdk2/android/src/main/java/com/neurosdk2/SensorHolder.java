package com.neurosdk2;

import androidx.annotation.NonNull;

import com.neurosdk2.neuro.Sensor;

import com.neurosdk2.neuro.types.BrainBit2AmplifierParam;


import com.neurosdk2.neuro.types.CallibriMotionAssistantLimb;
import com.neurosdk2.neuro.types.CallibriMotionAssistantParams;
import com.neurosdk2.neuro.types.CallibriMotionCounterParam;
import com.neurosdk2.neuro.types.CallibriSignalType;
import com.neurosdk2.neuro.types.CallibriStimulationParams;
import com.neurosdk2.neuro.types.CallibriStimulatorMAState;
import com.neurosdk2.neuro.types.SensorFilter;


import com.neurosdk2.neuro.types.EEGChannelInfo;


import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.RedAmplitude;

import com.neurosdk2.neuro.types.SensorADCInput;

import com.neurosdk2.neuro.types.SensorAccelerometerSensitivity;
import com.neurosdk2.neuro.types.SensorGyroscopeSensitivity;

import com.neurosdk2.neuro.types.SensorDataOffset;
import com.neurosdk2.neuro.types.SensorExternalSwitchInput;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorFirmwareMode;
import com.neurosdk2.neuro.types.SensorGain;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

public class SensorHolder {

  private final ConcurrentHashMap<String, AFullSensor> mSensors = new ConcurrentHashMap<>();


  public SensorHolder()
  {

  }
  public synchronized void addSensor(String guid, Sensor sensor, EventHolder events){
    SensorFamily sensFamily = sensor.getSensFamily();
    switch (sensFamily){
      case SensorUnknown:
        break;

      case SensorLECallibri:
      case SensorLEKolibri:
        mSensors.put(guid, new CallibriImpl(sensor, guid, events));
        break;


      case SensorLEBrainBit:
        mSensors.put(guid, new BrainBitImpl(sensor, guid, events));
        break;


      case SensorLEBrainBitBlack:
        mSensors.put(guid, new BrainBitBlackImpl(sensor, guid, events));
        break;


      case SensorLEBrainBit2:
      case SensorLEBrainBitFlex:
      case SensorLEBrainBitPro:
        mSensors.put(guid, new BrainBit2Impl(sensor, guid, events));
        break;

    }
  }

  // <editor-fold> Sensor

  public synchronized void closeSensor(String guid, @NonNull PigeonMessages.VoidResult result) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.closeSensor();
    mSensors.remove(guid);
    result.success();
  }
  public synchronized void connectSensor(String guid, @NonNull PigeonMessages.VoidResult result) {
    try {
      AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
      sensor.connectSensor();
      result.success();
    }
    catch (Exception ex){
      result.error(ex);
    }
  }
  public void disconnectSensor(String guid, @NonNull PigeonMessages.VoidResult result) {
    try {
      AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
      sensor.disconnectSensor();
      result.success();
    }
    catch (Exception ex){
      result.error(ex);
    }
  }
  public List<Long> supportedFeatures(String guid) {
    List<Long> features = new ArrayList<>();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.supportedFeatures(features);
    return features;
  }
  public Boolean isSupportedFeature(String guid, int feature) {
    boolean isSupported = false;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    isSupported = sensor.isSupportedFeature(feature);
    return isSupported;
  }
  public List<Long> supportedCommands(String guid) {
    List<Long> commands = new ArrayList<>();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.supportedCommands(commands);
    return commands;
  }
  public Boolean isSupportedCommand(String guid, int command) {
    boolean isSupported = false;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    isSupported = sensor.isSupportedCommand(command);
    return isSupported;
  }
  public List<PigeonMessages.FParameterInfo> supportedParameters(String guid) {
    List<PigeonMessages.FParameterInfo> params = new ArrayList<>();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.supportedParameters(params);
    return params;
  }
  public Boolean isSupportedParameter(String guid, int parameter) {
    boolean isSupported = false;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    isSupported = sensor.isSupportedParameter(parameter);
    return isSupported;
  }
  public synchronized void execCommand(String guid, @NonNull PigeonMessages.VoidResult result, int command) {
    try {
      AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
      sensor.execCommand(command);
      result.success();
    }
    catch (Exception ex){
      result.error(ex);
    }
  }
  public String getName(String guid) {
    String result = "";
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = sensor.getName();
    return result;
  }
  public void setName(String guid, String name) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setName(name);
  }
  public PigeonMessages.FSensorState getState(String guid) {
    PigeonMessages.FSensorState state = PigeonMessages.FSensorState.OUT_OF_RANGE;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    state = PigeonMessages.FSensorState.values()[sensor.getState()];
    return state;
  }
  public String getAddress(String guid) {
    String result = "";
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = sensor.getAddress();
    return result;
  }
  public String getSerialNumber(String guid) {
    String result = "";
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = sensor.getSerialNumber();
    return result;
  }
  public void setSerialNumber(String guid, String sn) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setSerialNumber(sn);
  }
  public Long getBattPower(String guid) {
    long result = 0;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = (long)sensor.getBattPower();
    return result;
  }
  public PigeonMessages.FSensorSamplingFrequency getSamplingFrequency(String guid) {
    PigeonMessages.FSensorSamplingFrequency res = PigeonMessages.FSensorSamplingFrequency.UNSUPPORTED;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    res = PigeonMessages.FSensorSamplingFrequency.values()[sensor.getSamplingFrequency()];
    return res;
  }
  public PigeonMessages.FSensorGain getGain(String guid) {
    PigeonMessages.FSensorGain result = PigeonMessages.FSensorGain.GAIN_UNSUPPORTED;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = PigeonMessages.FSensorGain.values()[sensor.getGain()];
    return result;
  }
  public PigeonMessages.FSensorDataOffset getDataOffset(String guid) {
    PigeonMessages.FSensorDataOffset result = PigeonMessages.FSensorDataOffset.DATA_OFFSET_UNSUPPORTED;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = PigeonMessages.FSensorDataOffset.values()[sensor.getDataOffset().ordinal()];
    return result;
  }
  public PigeonMessages.FSensorFirmwareMode getFirmwareMode(String guid) {
    PigeonMessages.FSensorFirmwareMode result = PigeonMessages.FSensorFirmwareMode.MODE_APPLICATION;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    result = PigeonMessages.FSensorFirmwareMode.values()[sensor.getFirmwareMode()];
    return result;
  }
  public PigeonMessages.FSensorVersion getVersion(String guid) {
    PigeonMessages.FSensorVersion res = new PigeonMessages.FSensorVersion();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.getVersion(res);
    return res;
  }
  public long getChannelsCount(String guid) {
    long count = 0;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    count = sensor.getChannelsCount();
    return  count;
  }
  public PigeonMessages.FSensorFamily getSensFamily(String guid) {
    PigeonMessages.FSensorFamily family = PigeonMessages.FSensorFamily.UNKNOWN;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    family = Utils.nativeFamilyToPigeon(sensor.getSensFamily());
    return family;
  }
  // </editor-fold>

  public PigeonMessages.FSensorAmpMode getAmpMode(String guid) {
    PigeonMessages.FSensorAmpMode mode = PigeonMessages.FSensorAmpMode.INVALID;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    mode = PigeonMessages.FSensorAmpMode.values()[sensor.getAmpMode()];
    return mode;
  }
  public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyResist(String guid) {
    PigeonMessages.FSensorSamplingFrequency ssf = PigeonMessages.FSensorSamplingFrequency.UNSUPPORTED;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    ssf = PigeonMessages.FSensorSamplingFrequency.values()[sensor.getSamplingFrequencyResist().ordinal()];
    return ssf;
  }


  // <editor-fold> BrainBitBlack
  public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyFPG(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    PigeonMessages.FSensorSamplingFrequency ssf = PigeonMessages.FSensorSamplingFrequency.values()[sensor.getSamplingFrequencyFPG().ordinal()];
    return ssf;
  }
  public PigeonMessages.FIrAmplitude getIrAmplitude(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    PigeonMessages.FIrAmplitude amp = PigeonMessages.FIrAmplitude.values()[sensor.getIrAmplitude().ordinal()];
    return amp;
  }
  public void setIrAmplitude(String guid, PigeonMessages.FIrAmplitude amp) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setIrAmplitude(IrAmplitude.values()[amp.ordinal()]);
  }
  public PigeonMessages.FRedAmplitude getRedAmplitude(String guid) {
    PigeonMessages.FRedAmplitude rAmp = PigeonMessages.FRedAmplitude.RED_AMP_UNSUPPORTED;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    rAmp = PigeonMessages.FRedAmplitude.values()[sensor.getRedAmplitude().ordinal()];
    return rAmp;
  }
  public void setRedAmplitude(String guid, PigeonMessages.FRedAmplitude amp) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setRedAmplitude(RedAmplitude.values()[amp.ordinal()]);
  }
  public void pingNeuroSmart(String guid, Long marker, @NonNull PigeonMessages.VoidResult result) {
    try {
      AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
      Object m = marker;
      sensor.pingNeuroSmart(((Integer)m).byteValue());
      result.success();
    }
    catch (Exception ex){
      result.error(ex);
    }
  }
  // </editor-fold>


  // <editor-fold> Callibri
  public boolean isSupportedFilter(String guid, PigeonMessages.FSensorFilter filter) {
    boolean res = false;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    res = sensor.isSupportedFilter(SensorFilter.values()[filter.ordinal()]);
    return res;
  }
  public List<Long> getSupportedFilters(String guid) {
    List<Long> res = new ArrayList<>();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.getSupportedFilters(res);
    return res;
  }
  public List<Long> getHardwareFilters(String guid) {
    List<Long> res = new ArrayList<>();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.getHardwareFilters(res);
    return res;
  }
  public void setHardwareFilters(String guid, List<Long> filters) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setHardwareFilters(filters);
  }
  public void setFirmwareMode(String guid, PigeonMessages.FSensorFirmwareMode mode) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setFirmwareMode(SensorFirmwareMode.values()[mode.ordinal()]);
  }
  public void setSamplingFrequency(String guid, PigeonMessages.FSensorSamplingFrequency sf) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setSamplingFrequency(SensorSamplingFrequency.values()[sf.ordinal()]);
  }
  public void setGain(String guid, PigeonMessages.FSensorGain gain) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setGain(SensorGain.indexOf(gain.ordinal()));
  }
  public void setDataOffset(String guid, PigeonMessages.FSensorDataOffset offset) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setDataOffset(SensorDataOffset.values()[offset.ordinal()]);
  }
  public PigeonMessages.FSensorExternalSwitchInput getExtSwInput(String guid) {
    PigeonMessages.FSensorExternalSwitchInput extSwInp = PigeonMessages.FSensorExternalSwitchInput.UNKNOWN_INP;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    extSwInp = PigeonMessages.FSensorExternalSwitchInput.values()[sensor.getExtSwInput().ordinal()];
    return extSwInp;
  }
  public void setExtSwInput(String guid, PigeonMessages.FSensorExternalSwitchInput extSwInp) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setExtSwInput(SensorExternalSwitchInput.values()[extSwInp.ordinal()]);
  }
  public PigeonMessages.FSensorADCInput getADCInput(String guid) {
    PigeonMessages.FSensorADCInput res = PigeonMessages.FSensorADCInput.TEST_INP;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    res = PigeonMessages.FSensorADCInput.values()[sensor.getADCInput().ordinal()];
    return res;
  }
  public void setADCInput(String guid, PigeonMessages.FSensorADCInput adcInp) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setADCInput(SensorADCInput.values()[adcInp.ordinal()]);
  }
  public PigeonMessages.FCallibriStimulatorMAState getStimulatorMAState(String guid) {
    PigeonMessages.FCallibriStimulatorMAState res = new PigeonMessages.FCallibriStimulatorMAState();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriStimulatorMAState state = sensor.getStimulatorMAState();
    res.setMaState(PigeonMessages.FCallibriStimulatorState.values()[state.getMAState().ordinal()]);
    res.setStimulatorState(PigeonMessages.FCallibriStimulatorState.values()[state.getStimulatorState().ordinal()]);
    return res;
  }
  public PigeonMessages.FCallibriStimulationParams getStimulatorParam(String guid) {
    PigeonMessages.FCallibriStimulationParams res = new PigeonMessages.FCallibriStimulationParams();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriStimulationParams params = sensor.getStimulatorParam();
    res.setCurrent((long)params.getCurrent());
    res.setFrequency((long)params.getFrequency());
    res.setPulseWidth((long)params.getPulseWidth());
    res.setStimulusDuration((long)params.getStimulusDuration());
    return  res;
  }
  public void setStimulatorParam(String guid, PigeonMessages.FCallibriStimulationParams param) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriStimulationParams params = new CallibriStimulationParams(param.getCurrent().byteValue(),
            param.getPulseWidth().byteValue(),
            param.getFrequency().byteValue(),
            param.getStimulusDuration().shortValue());
    sensor.setStimulatorParam(params);
  }
  public PigeonMessages.FCallibriMotionAssistantParams getMotionAssistantParam(String guid) {
    PigeonMessages.FCallibriMotionAssistantParams res = new PigeonMessages.FCallibriMotionAssistantParams();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriMotionAssistantParams params = sensor.getMotionAssistantParam();
    res.setGyroStart((long)params.getGyroStart());
    res.setLimb(PigeonMessages.FCallibriMotionAssistantLimb.values()[params.getLimb().ordinal()]);
    res.setGyroStop((long)params.getGyroStop());
    res.setMinPauseMs((long)params.getMinPauseMs());
    return res;
  }
  public void setMotionAssistantParam(String guid, PigeonMessages.FCallibriMotionAssistantParams param) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriMotionAssistantParams nParam = new CallibriMotionAssistantParams(param.getGyroStart().byteValue(),
            param.getGyroStop().byteValue(),
            CallibriMotionAssistantLimb.values()[param.getLimb().ordinal()],
            param.getMinPauseMs().byteValue());
    sensor.setMotionAssistantParam(nParam);
  }
  public PigeonMessages.FCallibriMotionCounterParam getMotionCounterParam(String guid) {
    PigeonMessages.FCallibriMotionCounterParam res = new PigeonMessages.FCallibriMotionCounterParam();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriMotionCounterParam param = sensor.getMotionCounterParam();
    res.setInsenseThresholdMG((long)param.getInsenseThresholdMG());
    res.setInsenseThresholdSample((long)param.getInsenseThresholdSample());
    return res;
  }
  public void setMotionCounterParam(String guid, PigeonMessages.FCallibriMotionCounterParam param) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    CallibriMotionCounterParam p = new CallibriMotionCounterParam(param.getInsenseThresholdMG().shortValue(),
            param.getInsenseThresholdSample().shortValue());
    sensor.setMotionCounterParam(p);
  }
  public long getMotionCounter(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return sensor.getMotionCounter();
  }
  public PigeonMessages.FCallibriColorType getColor(String guid) {
    PigeonMessages.FCallibriColorType res = PigeonMessages.FCallibriColorType.UNKNOWN;
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    res = PigeonMessages.FCallibriColorType.values()[sensor.getColor().ordinal()];
    return res;
  }
  public boolean getMEMSCalibrateState(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return sensor.getMEMSCalibrateState();
  }
  public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyResp(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.FSensorSamplingFrequency.values()[sensor.getSamplingFrequencyResp().ordinal()];
  }
  public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyEnvelope(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.FSensorSamplingFrequency.values()[sensor.getSamplingFrequencyEnvelope().ordinal()];
  }
  public PigeonMessages.CallibriSignalType getSignalType(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.CallibriSignalType.values()[sensor.getSignalType().ordinal()];
  }
  public void setSignalType(String guid, PigeonMessages.CallibriSignalType type) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setSignalType(CallibriSignalType.values()[type.ordinal()]);
  }
  public PigeonMessages.FCallibriElectrodeState getElectrodeState(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.FCallibriElectrodeState.values()[sensor.getElectrodeState().ordinal()];
  }
  // </editor-fold>


  public PigeonMessages.FSensorAccelerometerSensitivity getAccSens(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.FSensorAccelerometerSensitivity.values()[sensor.getAccSens().ordinal()];
  }
  public void setAccSens(String guid, PigeonMessages.FSensorAccelerometerSensitivity accSens) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setAccSens(SensorAccelerometerSensitivity.values()[accSens.ordinal()]);
  }
  public PigeonMessages.FSensorGyroscopeSensitivity getGyroSens(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.FSensorGyroscopeSensitivity.values()[sensor.getGyroSens().ordinal()];
  }
  public void setGyroSens(String guid, PigeonMessages.FSensorGyroscopeSensitivity gyroSens) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    sensor.setGyroSens(SensorGyroscopeSensitivity.values()[gyroSens.ordinal()]);
  }
  public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyMEMS(String guid) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    return PigeonMessages.FSensorSamplingFrequency.values()[sensor.getSamplingFrequencyMEMS().ordinal()];
  }


  public List<PigeonMessages.FEEGChannelInfo> getSupportedChannels(String guid) {
    List<PigeonMessages.FEEGChannelInfo> res = new ArrayList<>();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    List<EEGChannelInfo> channels = sensor.getSupportedChannels();
    for (EEGChannelInfo info :
            channels) {
      PigeonMessages.FEEGChannelInfo it = new PigeonMessages.FEEGChannelInfo();
      it.setNum((long)info.getNum());
      it.setId(PigeonMessages.FEEGChannelId.values()[info.getId().ordinal()]);
      it.setName(info.getName());
      it.setChType(PigeonMessages.FEEGChannelType.values()[info.getChType().ordinal()]);
      res.add(it);
    }
    return res;
  }
  public PigeonMessages.BrainBit2AmplifierParamNative getAmplifierParamBB2(String guid) {
    PigeonMessages.BrainBit2AmplifierParamNative res = new PigeonMessages.BrainBit2AmplifierParamNative();
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    BrainBit2AmplifierParam param = sensor.getAmplifierParamBB2();
    res.setCurrent(PigeonMessages.FGenCurrent.values()[param.getCurrent().ordinal()]);
    ArrayList<Boolean> ru = new ArrayList<>();
    for (boolean cru:
            param.getChResistUse()) {
      ru.add(cru);
    }
    res.setChResistUse(ru);
    ArrayList<Long> gain = new ArrayList<>();
    for (int cru:
            param.getRawChGain()) {
      gain.add((long)cru);
    }
    res.setChGain(gain);
    ArrayList<Long> mode = new ArrayList<>();
    for (int cru:
            param.getRawChSignalMode()) {
      mode.add((long)cru);
    }
    res.setChSignalMode(mode);
    return res;
  }
  public void setAmplifierParamBB2(String guid, PigeonMessages.BrainBit2AmplifierParamNative param) {
    AFullSensor sensor = Objects.requireNonNull(mSensors.get(guid));
    int[] chSignalMode = new int[param.getChSignalMode().size()];
    for (int i = 0 ; i < param.getChSignalMode().size(); i++){
      Object s = param.getChSignalMode().get(i);
      chSignalMode[i] = (Integer)s;
    }
    boolean[] chResistUse = new boolean[param.getChResistUse().size()];
    for (int i = 0 ; i < param.getChResistUse().size(); i++){
      chResistUse[i] = param.getChResistUse().get(i);
    }
    int[] chGain = new int[param.getChGain().size()];
    for (int i = 0 ; i < param.getChGain().size(); i++){
      Object s = param.getChGain().get(i);
      chGain[i] = (Integer)s;
    }
    BrainBit2AmplifierParam nParam = new BrainBit2AmplifierParam(chSignalMode,
            chResistUse,
            chGain,
            param.getCurrent().ordinal());

    sensor.setAmplifierParamBB2(nParam);
  }

}
