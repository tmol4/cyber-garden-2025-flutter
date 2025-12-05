package com.neurosdk2;

import static com.neurosdk2.Constants.DATA_ID;
import static com.neurosdk2.Utils.ConvertMEMSData;

import com.neurosdk2.neuro.Callibri;
import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.CallibriColorType;
import com.neurosdk2.neuro.types.CallibriElectrodeState;
import com.neurosdk2.neuro.types.CallibriEnvelopeData;
import com.neurosdk2.neuro.types.CallibriMotionAssistantParams;
import com.neurosdk2.neuro.types.CallibriMotionCounterParam;
import com.neurosdk2.neuro.types.CallibriRespirationData;
import com.neurosdk2.neuro.types.CallibriSignalData;
import com.neurosdk2.neuro.types.CallibriSignalType;
import com.neurosdk2.neuro.types.CallibriStimulationParams;
import com.neurosdk2.neuro.types.CallibriStimulatorMAState;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.QuaternionData;
import com.neurosdk2.neuro.types.SensorADCInput;
import com.neurosdk2.neuro.types.SensorAccelerometerSensitivity;
import com.neurosdk2.neuro.types.SensorDataOffset;
import com.neurosdk2.neuro.types.SensorExternalSwitchInput;
import com.neurosdk2.neuro.types.SensorFilter;
import com.neurosdk2.neuro.types.SensorFirmwareMode;
import com.neurosdk2.neuro.types.SensorGain;
import com.neurosdk2.neuro.types.SensorGyroscopeSensitivity;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class CallibriImpl extends AFullSensor {

  public CallibriImpl(Sensor sensor, String guid, EventHolder events) {
    this.sensor = sensor;
    this.guid = guid;
    addCallbacks(events);
  }

  @Override
  protected void addCallbacks(EventHolder events) {
    super.addCallbacks(events);

    ((Callibri) sensor).callibriSignalDataReceived = (data) -> {
      HashMap<String, Object> result = createResultWithGuid();
      ArrayList<HashMap<String, Object>> array = new ArrayList<>();
      for (CallibriSignalData signalData : data) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("PackNum", signalData.getPackNum());
        map.put("Samples", signalData.getSamples());
        array.add(map);
      }
      result.put(DATA_ID, array);

      mainThread.post(() -> {
        if (events.mSignalEventSink != null) {
          events.mSignalEventSink.success(result);
        }
      });
    };
    ((Callibri) sensor).callibriElectrodeStateChanged = data -> {
      HashMap<String, Object> result = createResultWithGuid();
      result.put(DATA_ID, data.index());
      mainThread.post(() -> {
        if (events.mElectrodeStateEventSink != null) {
          events.mElectrodeStateEventSink.success(result);
        }
      });
    };
    ((Callibri) sensor).callibriEnvelopeDataReceived = data -> {
      HashMap<String, Object> result = createResultWithGuid();
      ArrayList<HashMap<String, Object>> array = new ArrayList<>();
      for (CallibriEnvelopeData envelopeData : data) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("PackNum", envelopeData.getPackNum());
        map.put("Sample", envelopeData.getSample());
        array.add(map);
      }
      result.put(DATA_ID, array);
      mainThread.post(() -> {
        if (events.mEnvelopeEventSink != null) {
          events.mEnvelopeEventSink.success(result);
        }
      });
    };
    ((Callibri) sensor).callibriRespirationDataReceived = data -> {
      HashMap<String, Object> result = createResultWithGuid();
      ArrayList<HashMap<String, Object>> array = new ArrayList<>();
      for (CallibriRespirationData respirationData : data) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("PackNum", respirationData.getPackNum());
        map.put("Samples", respirationData.getSamples());
        array.add(map);
      }
      result.put(DATA_ID, array);
      mainThread.post(() -> {
        if (events.mRespirationEventSink != null) {
          events.mRespirationEventSink.success(result);
        }
      });
    };
    ((Callibri) sensor).memsDataReceived = data -> {
      HashMap<String, Object> result = createResultWithGuid();
      ArrayList<HashMap<String, Object>> array = new ArrayList<>();
      for (MEMSData memsData : data) {
        array.add(ConvertMEMSData(memsData));
      }
      result.put(DATA_ID, array);
      mainThread.post(() -> {
        if (events.mMEMSEventSink != null) {
          events.mMEMSEventSink.success(result);
        }
      });

    };
    ((Callibri) sensor).quaternionDataRecieved = data -> {
      HashMap<String, Object> result = createResultWithGuid();
      ArrayList<HashMap<String, Object>> array = new ArrayList<>();
      for (QuaternionData quaternionData : data) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("PackNum", quaternionData.getPackNum());
        map.put("W", quaternionData.getW());
        map.put("X", quaternionData.getX());
        map.put("Y", quaternionData.getY());
        map.put("Z", quaternionData.getZ());
        array.add(map);
      }
      result.put(DATA_ID, array);
      mainThread.post(() -> {
        if (events.mQuaternionEventSink != null) {
          events.mQuaternionEventSink.success(result);
        }
      });
    };
  }

  @Override
  protected void removeCallbacks() {
    super.removeCallbacks();

    ((Callibri) sensor).callibriSignalDataReceived = null;
    ((Callibri) sensor).callibriElectrodeStateChanged = null;
    ((Callibri) sensor).callibriEnvelopeDataReceived = null;
    ((Callibri) sensor).callibriRespirationDataReceived = null;
    ((Callibri) sensor).memsDataReceived = null;
    ((Callibri) sensor).quaternionDataRecieved = null;
  }

  @Override
  protected String getSensorName() {
    return "Callibri";
  }

  @Override
  public SensorSamplingFrequency getSamplingFrequencyMEMS() {
    return ((Callibri) sensor).getSamplingFrequencyMEMS();
  }

  @Override
  public boolean isSupportedFilter(SensorFilter filter) {
    return ((Callibri) sensor).isSupportedFilter(filter);
  }

  @Override
  public void getSupportedFilters(List<Long> res) {
    List<SensorFilter> filterList = ((Callibri) sensor).getSupportedFilters();
    for (SensorFilter filter : filterList) {
      res.add((long) filter.ordinal());
    }
  }

  @Override
  public void getHardwareFilters(List<Long> res) {
    List<SensorFilter> filterList = ((Callibri) sensor).getHardwareFilters();
    for (SensorFilter filter : filterList) {
      res.add((long) filter.ordinal());
    }
  }

  @Override
  public void setHardwareFilters(List<Long> filters) {
    List<SensorFilter> hardwareFiltersList = new ArrayList<>();
    for (Object filter : filters) {
      hardwareFiltersList.add(SensorFilter.values()[((Long) filter).intValue()]);
    }
    ((Callibri) sensor).setHardwareFilters(hardwareFiltersList);
  }

  @Override
  public void setFirmwareMode(SensorFirmwareMode mode) {
    ((Callibri) sensor).setFirmwareMode(mode);
  }

  @Override
  public void setSamplingFrequency(SensorSamplingFrequency sf) {
    ((Callibri) sensor).setSamplingFrequency(sf);
  }

  @Override
  public void setGain(SensorGain gain) {
    ((Callibri) sensor).setGain(gain);
  }

  @Override
  public void setDataOffset(SensorDataOffset offset) {
    ((Callibri) sensor).setDataOffset(offset);
  }

  @Override
  public SensorExternalSwitchInput getExtSwInput() {
    return ((Callibri) sensor).getExtSwInput();
  }

  @Override
  public void setExtSwInput(SensorExternalSwitchInput extSwInp) {
    ((Callibri) sensor).setExtSwInput(extSwInp);
  }

  @Override
  public SensorADCInput getADCInput() {
    return ((Callibri) sensor).getADCInput();
  }

  @Override
  public void setADCInput(SensorADCInput adcInp) {
    ((Callibri) sensor).setADCInput(adcInp);
  }

  @Override
  public CallibriStimulatorMAState getStimulatorMAState() {
    return ((Callibri) sensor).getStimulatorMAState();
  }

  @Override
  public CallibriStimulationParams getStimulatorParam() {
    return ((Callibri) sensor).getStimulatorParam();
  }

  @Override
  public void setStimulatorParam(CallibriStimulationParams param) {
    ((Callibri) sensor).setStimulatorParam(param);
  }

  @Override
  public CallibriMotionAssistantParams getMotionAssistantParam() {
    return ((Callibri) sensor).getMotionAssistantParam();
  }

  @Override
  public void setMotionAssistantParam(CallibriMotionAssistantParams param) {
    ((Callibri) sensor).setMotionAssistantParam(param);
  }

  @Override
  public CallibriMotionCounterParam getMotionCounterParam() {
    return ((Callibri) sensor).getMotionCounterParam();
  }

  @Override
  public void setMotionCounterParam(CallibriMotionCounterParam param) {
    ((Callibri) sensor).setMotionCounterParam(param);
  }

  @Override
  public int getMotionCounter() {
    return ((Callibri) sensor).getMotionCounter();
  }

  @Override
  public CallibriColorType getColor() {
    return ((Callibri) sensor).getColor();
  }

  @Override
  public boolean getMEMSCalibrateState() {
    return ((Callibri) sensor).getMEMSCalibrateState();
  }

  @Override
  public SensorSamplingFrequency getSamplingFrequencyResp() {
    return ((Callibri) sensor).getSamplingFrequencyResp();
  }

  @Override
  public SensorSamplingFrequency getSamplingFrequencyEnvelope() {
    return ((Callibri) sensor).getSamplingFrequencyEnvelope();
  }

  @Override
  public CallibriSignalType getSignalType() {
    return ((Callibri) sensor).getSignalType();
  }

  @Override
  public void setSignalType(CallibriSignalType type) {
    ((Callibri) sensor).setSignalType(type);
  }

  @Override
  public CallibriElectrodeState getElectrodeState() {
    return ((Callibri) sensor).getElectrodeState();
  }

  @Override
  public SensorAccelerometerSensitivity getAccSens() {
    return ((Callibri) sensor).getAccSens();
  }

  @Override
  public void setAccSens(SensorAccelerometerSensitivity accSens) {
    ((Callibri) sensor).setAccSens(accSens);
  }

  @Override
  public SensorGyroscopeSensitivity getGyroSens() {
    return ((Callibri) sensor).getGyroSens();
  }

  @Override
  public void setGyroSens(SensorGyroscopeSensitivity gyroSens) {
    ((Callibri) sensor).setGyroSens(gyroSens);
  }
}
