package com.neurosdk2;

import static com.neurosdk2.Constants.DATA_ID;
import static com.neurosdk2.Utils.ConvertFPGData;
import static com.neurosdk2.Utils.ConvertMEMSData;
import static com.neurosdk2.Utils.ConvertSignalChannelsData;

import com.neurosdk2.neuro.BrainBit2;
import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.BrainBit2AmplifierParam;
import com.neurosdk2.neuro.types.EEGChannelInfo;
import com.neurosdk2.neuro.types.FPGData;
import com.neurosdk2.neuro.types.IrAmplitude;
import com.neurosdk2.neuro.types.MEMSData;
import com.neurosdk2.neuro.types.RedAmplitude;
import com.neurosdk2.neuro.types.ResistRefChannelsData;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;
import com.neurosdk2.neuro.types.SignalChannelsData;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class BrainBit2Impl extends AFullSensor {

    public BrainBit2Impl(Sensor sensor, String guid, EventHolder events) {
        this.sensor = sensor;
        this.guid = guid;
        addCallbacks(events);
    }

    @Override
    protected void addCallbacks(EventHolder events) {
        ((BrainBit2) sensor).signalDataReceived = (data) -> {
            HashMap<String, Object> result = createResultWithGuid();
            ArrayList<HashMap<String, Object>> signalArray = new ArrayList<>();
            for (SignalChannelsData signal : data) {
                signalArray.add(ConvertSignalChannelsData(signal));
            }
            result.put(DATA_ID, signalArray);
            mainThread.post(() -> {
                if (events.mSignalEventSink != null) {
                    events.mSignalEventSink.success(result);
                }
            });
        };

        ((BrainBit2) sensor).resistDataReceived = (data) -> {
            HashMap<String, Object> result = createResultWithGuid();
            ArrayList<HashMap<String, Object>> array = new ArrayList<>();
            for (ResistRefChannelsData resists : data) {
                HashMap<String, Object> map = new HashMap<>();
                map.put("PackNum", resists.getPackNum());
                map.put("Samples", resists.getSamples());
                map.put("Referents", resists.getReferents());
                array.add(map);
            }
            result.put(DATA_ID, array);
            mainThread.post(() -> {
                if (events.mResistEventSink != null) {
                    events.mResistEventSink.success(result);
                }
            });
        };
        ((BrainBit2) sensor).fpgDataReceived = (data) -> {
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
        ((BrainBit2) sensor).memsDataReceived = data -> {
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
        ((BrainBit2) sensor).sensorAmpModeChanged = (data) -> {
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
        ((BrainBit2) sensor).signalDataReceived = null;
        ((BrainBit2) sensor).resistDataReceived = null;
        ((BrainBit2) sensor).fpgDataReceived = null;
        ((BrainBit2) sensor).memsDataReceived = null;
        ((BrainBit2) sensor).sensorAmpModeChanged = null;
    }

    @Override
    protected String getSensorName() {
        return "BrainBit2";
    }

    @Override
    public SensorSamplingFrequency getSamplingFrequencyMEMS() {
        return ((BrainBit2) sensor).getSamplingFrequencyMEMS();
    }

    @Override
    public SensorSamplingFrequency getSamplingFrequencyFPG() {
        return ((BrainBit2) sensor).getSamplingFrequencyFPG();
    }

    @Override
    public SensorSamplingFrequency getSamplingFrequencyResist() {
        return ((BrainBit2) sensor).getSamplingFrequencyResist();
    }

    @Override
    public IrAmplitude getIrAmplitude() {
        return ((BrainBit2) sensor).getIrAmplitude();
    }

    @Override
    public void setIrAmplitude(IrAmplitude amp) {
        ((BrainBit2) sensor).setIrAmplitude(amp);
    }

    @Override
    public RedAmplitude getRedAmplitude() {
        return ((BrainBit2) sensor).getRedAmplitude();
    }

    @Override
    public void setRedAmplitude(RedAmplitude amp) {
        ((BrainBit2) sensor).setRedAmplitude(amp);
    }

    @Override
    public int getAmpMode() {
        return ((BrainBit2) sensor).getAmpMode().index();
    }

    @Override
    public void pingNeuroSmart(byte marker) {
        ((BrainBit2) sensor).pingNeuroSmart(marker);
    }

    @Override
    public List<EEGChannelInfo> getSupportedChannels() {
        return ((BrainBit2) sensor).getSupportedChannels();
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
