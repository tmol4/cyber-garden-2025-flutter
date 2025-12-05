package com.neurosdk2.flutter_impl;

import android.util.Log;
import static com.neurosdk2.Utils.*;

import androidx.annotation.NonNull;

import com.neurosdk2.PigeonMessages;
import com.neurosdk2.ScannerHolder;
import com.neurosdk2.SensorHolder;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.neurosdk2.EventHolder;
import com.neurosdk2.Utils;
import com.neurosdk2.neuro.Scanner;
import com.neurosdk2.neuro.Sensor;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorInfo;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Neurosdk2Plugin
 */
public class Neurosdk2Plugin implements FlutterPlugin, PigeonMessages.NeuroApi {

    private ExecutorService _threadService;
    ScannerHolder scannerHolder;
    SensorHolder sensorHolder;

    EventHolder eventHolder;

    private Object mLocker = new Object();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        PigeonMessages.NeuroApi.setUp(flutterPluginBinding.getBinaryMessenger(), this);
        eventHolder = new EventHolder();
        eventHolder.activate(flutterPluginBinding);
        _threadService = Executors.newCachedThreadPool();
        sensorHolder = new SensorHolder();
        scannerHolder = new ScannerHolder();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        eventHolder.deactivate();
    }

    @Override
    public void createScanner(@NonNull List<Long> filters, @NonNull PigeonMessages.Result<String> result) {
        _threadService.submit(() -> {
            SensorFamily[] nativeFilters = new SensorFamily[filters.size()];
            try {
                for (int i = 0; i < filters.size(); i++) {
                    int id = filters.get(i).intValue();
                    nativeFilters[i] = pigeonFamilyToNative(PigeonMessages.FSensorFamily.values()[id]);
                }
            } catch (Exception ex) {
                Log.e("NeuroSDK2", ex.toString());
            }

            synchronized (mLocker) {
                scannerHolder.createScanner(nativeFilters, result);
            }
        });
    }

    @Override
    public void closeScanner(@NonNull String guid, @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                scannerHolder.closeScanner(guid, result);
            }
        });
    }

    @Override
    public void startScan(@NonNull String guid, @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                scannerHolder.startScan(guid, eventHolder, result);
            }
        });
    }

    @Override
    public void stopScan(@NonNull String guid, @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                scannerHolder.stopScan(guid, result);
            }
        });
    }

    @Override
    public void createSensor(@NonNull String guid, @NonNull PigeonMessages.FSensorInfo sensorInfo,
            @NonNull PigeonMessages.Result<String> result) {
        _threadService.submit(() -> {
            SensorInfo info = flutterToSensorInfo(sensorInfo);

            try {
                Scanner scanner = scannerHolder.getScanner(guid);
                if (scanner == null) {
                    result.error(new Throwable("Scanner don't exist"));
                    return;
                }

                String uuid = UUID.randomUUID().toString();
                Sensor sensor = scanner.createSensor(info);
                if (sensor == null) {
                    result.error(new Throwable("Cannot create sensor"));
                    return;
                }

                synchronized (mLocker) {
                    sensorHolder.addSensor(uuid, sensor, eventHolder);
                }

                result.success(uuid);
            } catch (Exception e) {
                result.error(e);
            }
        });
    }

    @NonNull
    @Override
    public List<PigeonMessages.FSensorInfo> getSensors(@NonNull String guid) {
        return scannerHolder.getSensors(guid);
    }

    @Override
    public void closeSensor(@NonNull String guid, @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                sensorHolder.closeSensor(guid, result);
            }
        });
    }

    @Override
    public void connectSensor(@NonNull String guid, @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                sensorHolder.connectSensor(guid, result);
            }
        });
    }

    @Override
    public void disconnectSensor(@NonNull String guid, @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                sensorHolder.disconnectSensor(guid, result);
            }
        });
    }

    @NonNull
    @Override
    public List<Long> supportedFeatures(@NonNull String guid) {
        return sensorHolder.supportedFeatures(guid);
    }

    @NonNull
    @Override
    public Boolean isSupportedFeature(@NonNull String guid, @NonNull PigeonMessages.FSensorFeature feature) {
        return sensorHolder.isSupportedFeature(guid, feature.ordinal());
    }

    @NonNull
    @Override
    public List<Long> supportedCommands(@NonNull String guid) {
        return sensorHolder.supportedCommands(guid);
    }

    @NonNull
    @Override
    public Boolean isSupportedCommand(@NonNull String guid, @NonNull PigeonMessages.FSensorCommand command) {
        return sensorHolder.isSupportedCommand(guid, command.ordinal());
    }

    @NonNull
    @Override
    public List<PigeonMessages.FParameterInfo> supportedParameters(@NonNull String guid) {
        return sensorHolder.supportedParameters(guid);
    }

    @NonNull
    @Override
    public Boolean isSupportedParameter(@NonNull String guid, @NonNull PigeonMessages.FSensorParameter parameter) {
        return sensorHolder.isSupportedParameter(guid, parameter.ordinal());
    }

    @Override
    public void execCommand(@NonNull String guid, @NonNull PigeonMessages.FSensorCommand command,
            @NonNull PigeonMessages.VoidResult result) {
        _threadService.submit(() -> {
            synchronized (mLocker) {
                sensorHolder.execCommand(guid, result, command.ordinal());
            }
        });
    }

    @NonNull
    @Override
    public String getName(@NonNull String guid) {
        return sensorHolder.getName(guid);
    }

    @Override
    public void setName(@NonNull String guid, @NonNull String name) {
        sensorHolder.setName(guid, name);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorState getState(@NonNull String guid) {
        return sensorHolder.getState(guid);
    }

    @NonNull
    @Override
    public String getAddress(@NonNull String guid) {
        return sensorHolder.getAddress(guid);
    }

    @NonNull
    @Override
    public String getSerialNumber(@NonNull String guid) {
        return sensorHolder.getSerialNumber(guid);
    }

    @Override
    public void setSerialNumber(@NonNull String guid, @NonNull String sn) {
        sensorHolder.setSerialNumber(guid, sn);
    }

    @NonNull
    @Override
    public Long getBattPower(@NonNull String guid) {
        return sensorHolder.getBattPower(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorSamplingFrequency getSamplingFrequency(@NonNull String guid) {
        return sensorHolder.getSamplingFrequency(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorGain getGain(@NonNull String guid) {
        return sensorHolder.getGain(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorDataOffset getDataOffset(@NonNull String guid) {
        return sensorHolder.getDataOffset(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorFirmwareMode getFirmwareMode(@NonNull String guid) {
        return sensorHolder.getFirmwareMode(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorVersion getVersion(@NonNull String guid) {
        return sensorHolder.getVersion(guid);
    }

    @NonNull
    @Override
    public Long getChannelsCount(@NonNull String guid) {
        return sensorHolder.getChannelsCount(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorFamily getSensFamily(@NonNull String guid) {
        return sensorHolder.getSensFamily(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorAmpMode getAmpMode(@NonNull String guid) {
        return sensorHolder.getAmpMode(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyResist(@NonNull String guid) {
        return sensorHolder.getSamplingFrequencyResist(guid);
    }


    @NonNull
    @Override
    public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyFPG(@NonNull String guid) {
        return sensorHolder.getSamplingFrequencyFPG(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FIrAmplitude getIrAmplitude(@NonNull String guid) {
        return sensorHolder.getIrAmplitude(guid);
    }

    @Override
    public void setIrAmplitude(@NonNull String guid, @NonNull PigeonMessages.FIrAmplitude amp) {
        sensorHolder.setIrAmplitude(guid, amp);
    }

    @NonNull
    @Override
    public PigeonMessages.FRedAmplitude getRedAmplitude(@NonNull String guid) {
        return sensorHolder.getRedAmplitude(guid);
    }

    @Override
    public void setRedAmplitude(@NonNull String guid, @NonNull PigeonMessages.FRedAmplitude amp) {
        sensorHolder.setRedAmplitude(guid, amp);
    }

    @Override
    public void pingNeuroSmart(@NonNull String guid, @NonNull Long marker, @NonNull PigeonMessages.VoidResult result) {
        sensorHolder.pingNeuroSmart(guid, marker, result);
    }

    @Override
    public void setGain(@NonNull String guid, @NonNull PigeonMessages.FSensorGain gain) {
        sensorHolder.setGain(guid, gain);
    }

    @NonNull
    @Override
    public Boolean isSupportedFilter(@NonNull String guid, @NonNull PigeonMessages.FSensorFilter filter) {
        return sensorHolder.isSupportedFilter(guid, filter);
    }

    @NonNull
    @Override
    public List<Long> getSupportedFilters(@NonNull String guid) {
        return sensorHolder.getSupportedFilters(guid);
    }

    @NonNull
    @Override
    public List<Long> getHardwareFilters(@NonNull String guid) {
        return sensorHolder.getHardwareFilters(guid);
    }

    @Override
    public void setHardwareFilters(@NonNull String guid, @NonNull List<Long> filters) {
        sensorHolder.setHardwareFilters(guid, filters);
    }

    @Override
    public void setFirmwareMode(@NonNull String guid, @NonNull PigeonMessages.FSensorFirmwareMode mode) {
        sensorHolder.setFirmwareMode(guid, mode);
    }

    @Override
    public void setSamplingFrequency(@NonNull String guid, @NonNull PigeonMessages.FSensorSamplingFrequency sf) {
        sensorHolder.setSamplingFrequency(guid, sf);
    }

    @Override
    public void setDataOffset(@NonNull String guid, @NonNull PigeonMessages.FSensorDataOffset offset) {
        sensorHolder.setDataOffset(guid, offset);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorExternalSwitchInput getExtSwInput(@NonNull String guid) {
        return sensorHolder.getExtSwInput(guid);
    }

    @Override
    public void setExtSwInput(@NonNull String guid, @NonNull PigeonMessages.FSensorExternalSwitchInput extSwInp) {
        sensorHolder.setExtSwInput(guid, extSwInp);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorADCInput getADCInput(@NonNull String guid) {
        return sensorHolder.getADCInput(guid);
    }

    @Override
    public void setADCInput(@NonNull String guid, @NonNull PigeonMessages.FSensorADCInput adcInp) {
        sensorHolder.setADCInput(guid, adcInp);
    }

    @NonNull
    @Override
    public PigeonMessages.FCallibriStimulatorMAState getStimulatorMAState(@NonNull String guid) {
        return sensorHolder.getStimulatorMAState(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FCallibriStimulationParams getStimulatorParam(@NonNull String guid) {
        return sensorHolder.getStimulatorParam(guid);
    }

    @Override
    public void setStimulatorParam(@NonNull String guid, @NonNull PigeonMessages.FCallibriStimulationParams param) {
        sensorHolder.setStimulatorParam(guid, param);
    }

    @NonNull
    @Override
    public PigeonMessages.FCallibriMotionAssistantParams getMotionAssistantParam(@NonNull String guid) {
        return sensorHolder.getMotionAssistantParam(guid);
    }

    @Override
    public void setMotionAssistantParam(@NonNull String guid, @NonNull PigeonMessages.FCallibriMotionAssistantParams param) {
        sensorHolder.setMotionAssistantParam(guid, param);
    }

    @NonNull
    @Override
    public PigeonMessages.FCallibriMotionCounterParam getMotionCounterParam(@NonNull String guid) {
        return sensorHolder.getMotionCounterParam(guid);
    }

    @Override
    public void setMotionCounterParam(@NonNull String guid, @NonNull PigeonMessages.FCallibriMotionCounterParam param) {
        sensorHolder.setMotionCounterParam(guid, param);
    }

    @NonNull
    @Override
    public Long getMotionCounter(@NonNull String guid) {
        return sensorHolder.getMotionCounter(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FCallibriColorType getColor(@NonNull String guid) {
        return sensorHolder.getColor(guid);
    }

    @NonNull
    @Override
    public Boolean getMEMSCalibrateState(@NonNull String guid) {
        return sensorHolder.getMEMSCalibrateState(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyResp(@NonNull String guid) {
        return sensorHolder.getSamplingFrequencyResp(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyEnvelope(@NonNull String guid) {
        return sensorHolder.getSamplingFrequencyEnvelope(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.CallibriSignalType getSignalType(@NonNull String guid) {
        return sensorHolder.getSignalType(guid);
    }

    @Override
    public void setSignalType(@NonNull String guid, @NonNull PigeonMessages.CallibriSignalType type) {
        sensorHolder.setSignalType(guid, type);
    }

    @NonNull
    @Override
    public PigeonMessages.FCallibriElectrodeState getElectrodeState(@NonNull String guid) {
        return sensorHolder.getElectrodeState(guid);
    }


    @NonNull
    @Override
    public PigeonMessages.FSensorAccelerometerSensitivity getAccSens(@NonNull String guid) {
        return sensorHolder.getAccSens(guid);
    }

    @Override
    public void setAccSens(@NonNull String guid, @NonNull PigeonMessages.FSensorAccelerometerSensitivity accSens) {
        sensorHolder.setAccSens(guid, accSens);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorGyroscopeSensitivity getGyroSens(@NonNull String guid) {
        return sensorHolder.getGyroSens(guid);
    }

    @Override
    public void setGyroSens(@NonNull String guid, @NonNull PigeonMessages.FSensorGyroscopeSensitivity gyroSens) {
        sensorHolder.setGyroSens(guid, gyroSens);
    }

    @NonNull
    @Override
    public PigeonMessages.FSensorSamplingFrequency getSamplingFrequencyMEMS(@NonNull String guid) {
        return sensorHolder.getSamplingFrequencyMEMS(guid);
    }


    @NonNull
    @Override
    public List<PigeonMessages.FEEGChannelInfo> getSupportedChannels(@NonNull String guid) {
        return sensorHolder.getSupportedChannels(guid);
    }

    @NonNull
    @Override
    public PigeonMessages.BrainBit2AmplifierParamNative getAmplifierParamBB2(@NonNull String guid) {
        return sensorHolder.getAmplifierParamBB2(guid);
    }

    @Override
    public void setAmplifierParamBB2(@NonNull String guid, @NonNull PigeonMessages.BrainBit2AmplifierParamNative param) {
        sensorHolder.setAmplifierParamBB2(guid, param);
    }

}
