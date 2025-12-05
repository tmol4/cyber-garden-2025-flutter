package com.neurosdk2;

import com.neurosdk2.neuro.types.FPGData;


import com.neurosdk2.neuro.types.MEMSData;

import com.neurosdk2.neuro.types.SensorFamily;
import com.neurosdk2.neuro.types.SensorInfo;
import com.neurosdk2.neuro.types.SignalChannelsData;

import java.util.HashMap;
import java.util.List;

public class Utils {

  static HashMap<String, Object> ConvertSignalChannelsData(SignalChannelsData value) {
    HashMap<String, Object> result = new HashMap<>();
    result.put("PackNum", value.getPackNum());
    result.put("Marker", value.getMarker());
    result.put("Samples", value.getSamples());
    return result;
  }

  static HashMap<String, Object> ConvertFPGData(FPGData value){
    HashMap<String, Object> result = new HashMap<>();
    result.put("PackNum", value.getPackNum());
    result.put("IrAmplitude", value.getIrAmplitude());
    result.put("RedAmplitude", value.getRedAmplitude());
    return  result;
  }


  static HashMap<String, Object> ConvertMEMSData(MEMSData value){
    HashMap<String, Object> result = new HashMap<>();
    HashMap<String, Double> accelerometerMap = new HashMap<>();
    accelerometerMap.put("X", value.getAccelerometer().getX());
    accelerometerMap.put("Y", value.getAccelerometer().getY());
    accelerometerMap.put("Z", value.getAccelerometer().getZ());
    HashMap<String, Double> gyroscopeMap = new HashMap<>();
    gyroscopeMap.put("X", value.getGyroscope().getX());
    gyroscopeMap.put("Y", value.getGyroscope().getY());
    gyroscopeMap.put("Z", value.getGyroscope().getZ());
    result.put("PackNum", value.getPackNum());
    result.put("Accelerometer", accelerometerMap);
    result.put("Gyroscope",gyroscopeMap);
    return result;
  }

  static int[] ConvertListToIntArray(List<Object> array)
  {
    int[] result = new int[array.size()];
    for (int i = 0; i < result.length; i++) {
      result[i] = (int)array.get(i);
    }
    return result;
  }
  static boolean[] ConvertListToBoolArray(List<Object> array)
  {
    boolean[] result = new boolean[array.size()];
    for (int i = 0; i < result.length; i++) {
      result[i] = (boolean)array.get(i);
    }
    return result;
  }

  static public SensorInfo flutterToSensorInfo(PigeonMessages.FSensorInfo rawSI){
    return new SensorInfo(Utils.pigeonFamilyToNative(rawSI.getSensFamily()),
            rawSI.getSensModel().byteValue(),
            rawSI.getName(),
            rawSI.getAddress(),
            rawSI.getSerialNumber(),
            rawSI.getPairingRequired(),
            rawSI.getRssi().shortValue());
  }

  static PigeonMessages.FSensorInfo sensorInfoToFlutter(SensorInfo sensorInfo) {
    PigeonMessages.FSensorInfo sensor = new PigeonMessages.FSensorInfo();
    sensor.setName(sensorInfo.getName());
    sensor.setAddress(sensorInfo.getAddress());
    sensor.setSerialNumber(sensorInfo.getSerialNumber());
    sensor.setSensModel((long)sensorInfo.getSensModel());
    sensor.setSensFamily(Utils.nativeFamilyToPigeon(sensorInfo.getSensFamily()));
    sensor.setPairingRequired(sensorInfo.getPairingRequired());
    sensor.setRssi((long) sensorInfo.getRSSI());
    return sensor;
  }

  public static  PigeonMessages.FSensorFamily nativeFamilyToPigeon(SensorFamily family) {
    switch(family) {
        case SensorLECallibri:
          return PigeonMessages.FSensorFamily.LE_CALLIBRI;
        case SensorLEKolibri:
          return PigeonMessages.FSensorFamily.LE_KOLIBRI;
        case SensorLEBrainBit:
          return PigeonMessages.FSensorFamily.LE_BRAIN_BIT;
        case SensorLEBrainBitBlack:
          return PigeonMessages.FSensorFamily.LE_BRAIN_BIT_BLACK;
        case SensorLEBrainBit2:
          return PigeonMessages.FSensorFamily.LE_BRAIN_BIT2;
        case SensorLEBrainBitPro:
          return PigeonMessages.FSensorFamily.LE_BRAIN_BIT_PRO;
        case SensorLEBrainBitFlex:
          return PigeonMessages.FSensorFamily.LE_BRAIN_BIT_FLEX;
      case SensorLENeuroEEG:
      case SensorUnknown:
          return PigeonMessages.FSensorFamily.UNKNOWN;
    }

    return PigeonMessages.FSensorFamily.UNKNOWN;
  }

  public static SensorFamily pigeonFamilyToNative(PigeonMessages.FSensorFamily family) {
    switch (family) {
        case LE_CALLIBRI:
          return SensorFamily.SensorLECallibri;
        case LE_KOLIBRI:
          return SensorFamily.SensorLEKolibri;
        case LE_BRAIN_BIT:
          return SensorFamily.SensorLEBrainBit;
        case LE_BRAIN_BIT_BLACK:
          return SensorFamily.SensorLEBrainBitBlack;
        case LE_BRAIN_BIT2:
          return SensorFamily.SensorLEBrainBit2;
        case LE_BRAIN_BIT_PRO:
          return SensorFamily.SensorLEBrainBitPro;
        case LE_BRAIN_BIT_FLEX:
          return SensorFamily.SensorLEBrainBitFlex;
        case UNKNOWN:
          return SensorFamily.SensorUnknown;
    }

    return SensorFamily.SensorUnknown;
  }
}
