package com.neurosdk2;

import static com.neurosdk2.Constants.DATA_ID;
import static com.neurosdk2.Constants.GUID_ID;
import static com.neurosdk2.Utils.sensorInfoToFlutter;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.neurosdk2.neuro.Scanner;
import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorInfo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public class ScannerHolder {

    protected Handler mainThread = new Handler(Looper.getMainLooper());
    private final HashMap<String, Scanner> _scanners = new HashMap<>();

    public ScannerHolder() {
    }

    public void createScanner(SensorFamily[] filters, @NonNull PigeonMessages.Result<String> result) {
        if (filters == null || filters.length == 0) {
            result.error(new Throwable("Filters is null"));
            return;
        }

        String uuid = UUID.randomUUID().toString();
        try {
            _scanners.put(uuid, new Scanner(filters));
            result.success(uuid);
        } catch (Exception ex) {
            result.error(ex);
        }
    }

    public void closeScanner(String guid, @NonNull PigeonMessages.VoidResult result) {
        try {
            Scanner scanner = Objects.requireNonNull(_scanners.get(guid));
            scanner.sensorsChanged = null;
            scanner.close();
            _scanners.remove(guid);
            result.success();
        } catch (Exception e) {
            result.error(e);
        }
    }

    public void startScan(String guid, EventHolder events, @NonNull PigeonMessages.VoidResult result) {
        try {
            Scanner scanner = Objects.requireNonNull(_scanners.get(guid));

            scanner.sensorsChanged = (sender, list) -> {
                HashMap<String, Object> map = new HashMap<>();
                map.put(GUID_ID, guid);
                ArrayList<HashMap<String, Object>> sensorList = new ArrayList<>();
                for (SensorInfo sensorInfo : list) {
                    sensorList.add(sensorInfoToHashMap(sensorInfo));
                }
                map.put(DATA_ID, sensorList);
                if (events.scannerSensorsSink != null) {
                    mainThread.post(() -> events.scannerSensorsSink.success(map));
                }
            };

            scanner.start();
            result.success();
        } catch (Exception e) {
            result.error(e);
        }

    }

    public void stopScan(String guid, @NonNull PigeonMessages.VoidResult result) {
        try {
            Scanner scanner = Objects.requireNonNull(_scanners.get(guid));
            scanner.stop();
            scanner.sensorsChanged = null;
            result.success();
        } catch (Exception e) {
            result.error(e);
        }
    }

    public List<PigeonMessages.FSensorInfo> getSensors(String guid) {
        ArrayList<PigeonMessages.FSensorInfo> sensorList = new ArrayList<>();
        Scanner scanner = Objects.requireNonNull(_scanners.get(guid));
        for (SensorInfo sensorInfo : scanner.getSensors()) {
            sensorList.add(sensorInfoToFlutter(sensorInfo));
        }
        return sensorList;
    }

    public Scanner getScanner(String guid) {
        if (_scanners.containsKey(guid)) {
            return _scanners.get(guid);
        }
        return null;
    }

    private HashMap<String, Object> sensorInfoToHashMap(SensorInfo sensorInfo) {
        HashMap<String, Object> sensor = new HashMap<>();
        sensor.put("Name", sensorInfo.getName());
        sensor.put("Address", sensorInfo.getAddress());
        sensor.put("SerialNumber", sensorInfo.getSerialNumber());
        sensor.put("SensModel", sensorInfo.getSensModel());
        sensor.put("SensFamily", Utils.nativeFamilyToPigeon(sensorInfo.getSensFamily()).ordinal());
        sensor.put("PairingRequired", sensorInfo.getPairingRequired());
        sensor.put("RSSI", sensorInfo.getRSSI());
        return sensor;
    }
}
