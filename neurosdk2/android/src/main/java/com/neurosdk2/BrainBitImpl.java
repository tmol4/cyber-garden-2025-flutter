package com.neurosdk2;

import static com.neurosdk2.Constants.DATA_ID;
import static com.neurosdk2.Constants.GUID_ID;

import com.neurosdk2.neuro.BrainBit;
import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.BrainBitSignalData;
import com.neurosdk2.neuro.types.SensorGain;

import java.util.ArrayList;
import java.util.HashMap;

public class BrainBitImpl extends AFullSensor {

  public BrainBitImpl(Sensor sensor, String guid, EventHolder events) {
    this.sensor = sensor;
    this.guid = guid;
    addCallbacks(events);
  }

  @Override
  protected void addCallbacks(EventHolder events) {
    super.addCallbacks(events);
    ((BrainBit) sensor).brainBitResistDataReceived = (data) -> {
      HashMap<String, Object> result = new HashMap<>();
      result.put(GUID_ID, guid);
      HashMap<String, Object> map = new HashMap<>();
      map.put("O1", data.getO1());
      map.put("O2", data.getO2());
      map.put("T3", data.getT3());
      map.put("T4", data.getT4());
      result.put(DATA_ID, map);
      mainThread.post(() -> {
        if (events.mResistEventSink != null) {
          events.mResistEventSink.success(result);
        }
      });
    };
    ((BrainBit) sensor).brainBitSignalDataReceived = (data) -> {
      HashMap<String, Object> result = new HashMap<>();
      result.put(GUID_ID, guid);
      ArrayList<HashMap<String, Object>> samples = new ArrayList<>();
      for (BrainBitSignalData signalData : data) {
        HashMap<String, Object> map = new HashMap<>();
        map.put("Marker", signalData.getMarker());
        map.put("PackNum", signalData.getPackNum());
        map.put("O1", signalData.getO1());
        map.put("O2", signalData.getO2());
        map.put("T3", signalData.getT3());
        map.put("T4", signalData.getT4());
        samples.add(map);
      }
      result.put(DATA_ID, samples);
      mainThread.post(() -> {
        if (events.mSignalEventSink != null) {
          events.mSignalEventSink.success(result);
        }
      });
    };
  }

  @Override
  public void setGain(SensorGain gain) {
    ((BrainBit) sensor).setGain(gain);
  }

  @Override
  protected void removeCallbacks() {
    super.removeCallbacks();
    ((BrainBit) sensor).brainBitResistDataReceived = null;
    ((BrainBit) sensor).brainBitSignalDataReceived = null;
  }

  @Override
  protected String getSensorName() {
    return "BrainBit";
  }
}
