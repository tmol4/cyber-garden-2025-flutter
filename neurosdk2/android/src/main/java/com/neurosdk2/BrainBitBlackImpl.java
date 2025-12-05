package com.neurosdk2;

import static com.neurosdk2.Constants.DATA_ID;
import static com.neurosdk2.Utils.ConvertFPGData;
import static com.neurosdk2.Utils.ConvertMEMSData;

import com.neurosdk2.neuro.BrainBit2;
import com.neurosdk2.neuro.BrainBitBlack;
import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.BrainBit2AmplifierParam;
import com.neurosdk2.neuro.types.FPGData;
import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.RedAmplitude;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;

import java.util.ArrayList;
import java.util.HashMap;

public class BrainBitBlackImpl extends BrainBitImpl {

  public BrainBitBlackImpl(Sensor sensor, String guid, EventHolder events) {
    super(sensor, guid, events);
    addCallbacks(events);
  }

  @Override
  protected void addCallbacks(EventHolder events) {
    super.addCallbacks(events);
    ((BrainBitBlack) sensor).fpgDataReceived = (data) -> {
      HashMap<String, Object> result = createResultWithGuid();
      ArrayList<HashMap<String, Object>> array = new ArrayList<>();
      for (FPGData fpgData : data) {
        array.add(ConvertFPGData(fpgData));
      }
      result.put(DATA_ID, array);
      mainThread.post(() -> {
        if (events.mFPGEventSink != null) {
          events.mFPGEventSink.success(result);
        }
      });
    };
    ((BrainBitBlack) sensor).memsDataReceived = data -> {
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
    ((BrainBitBlack) sensor).sensorAmpModeChanged = (data) -> {
      HashMap<String, Object> result = createResultWithGuid();
      result.put(DATA_ID, data.index());
      mainThread.post(() -> {
        if (events.mAmpModeEventSink != null) {
          events.mAmpModeEventSink.success(result);
        }
      });
    };
  }

  @Override
  protected void removeCallbacks() {
    super.removeCallbacks();
    ((BrainBitBlack) sensor).fpgDataReceived = null;
    ((BrainBitBlack) sensor).memsDataReceived = null;
    ((BrainBitBlack) sensor).sensorAmpModeChanged = null;
  }

  @Override
  protected String getSensorName() {
    return "BrainBitBlack";
  }

  @Override
  public SensorSamplingFrequency getSamplingFrequencyMEMS() {
    return ((BrainBitBlack) sensor).getSamplingFrequencyMEMS();
  }

  @Override
  public SensorSamplingFrequency getSamplingFrequencyFPG() {
    return ((BrainBitBlack) sensor).getSamplingFrequencyFPG();
  }

  @Override
  public SensorSamplingFrequency getSamplingFrequencyResist() {
    return ((BrainBitBlack) sensor).getSamplingFrequencyResist();
  }

  @Override
  public IrAmplitude getIrAmplitude() {
    return ((BrainBitBlack) sensor).getIrAmplitude();
  }

  @Override
  public void setIrAmplitude(IrAmplitude amp) {
    ((BrainBitBlack) sensor).setIrAmplitude(amp);
  }

  @Override
  public RedAmplitude getRedAmplitude() {
    return ((BrainBitBlack) sensor).getRedAmplitude();
  }

  @Override
  public void setRedAmplitude(RedAmplitude amp) {
    ((BrainBitBlack) sensor).setRedAmplitude(amp);
  }

  @Override
  public int getAmpMode() {
    return ((BrainBitBlack) sensor).getAmpMode().index();
  }

  @Override
  public void pingNeuroSmart(byte marker) {
    ((BrainBitBlack) sensor).pingNeuroSmart(marker);
  }

  @Override
  public BrainBit2AmplifierParam getAmplifierParamBB2() {
    return ((BrainBit2) sensor).getAmplifierParam();
  }

  @Override
  public void setAmplifierParamBB2(BrainBit2AmplifierParam param) {
    ((BrainBit2) sensor).setAmplifierParam(param);
  }

}
