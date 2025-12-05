package com.neurosdk2.neuro;

import com.neurosdk2.neuro.interfaces.BrainBitResistDataReceived;
import com.neurosdk2.neuro.interfaces.NeuroEEGFileStreamDataReceived;
import com.neurosdk2.neuro.interfaces.NeuroEEGResistDataReceived;
import com.neurosdk2.neuro.interfaces.NeuroEEGSignalDataReceived;
import com.neurosdk2.neuro.interfaces.NeuroEEGSignalRawDataReceived;
import com.neurosdk2.neuro.interfaces.NeuroEEGSignalResistReceived;
import com.neurosdk2.neuro.interfaces.SensorAmpModeChanged;
import com.neurosdk2.neuro.types.EEGChannelInfo;
import com.neurosdk2.neuro.types.NeuroEEGAmplifierParam;
import com.neurosdk2.neuro.types.NeuroEEGFSStatus;
import com.neurosdk2.neuro.types.ResistChannelsData;
import com.neurosdk2.neuro.types.SensorAmpMode;
import com.neurosdk2.neuro.types.SensorDiskInfo;
import com.neurosdk2.neuro.types.SensorFileData;
import com.neurosdk2.neuro.types.SensorFileInfo;
import com.neurosdk2.neuro.types.SensorFilter;
import com.neurosdk2.neuro.types.SensorSamplingFrequency;
import com.neurosdk2.neuro.types.SignalChannelsData;

import java.util.Arrays;
import java.util.List;

public class NeuroEEG extends Sensor {

    public static final int NEURO_EEG_MAX_CH_COUNT = 24;

    static {
        System.loadLibrary("neurosdk2");
    }

    private long mAmpModeCallbackPtr = 0;
    public SensorAmpModeChanged ampModeChanged;

    private long mSignalDataCallbackPtr = 0;
    public NeuroEEGSignalDataReceived signalDataReceived;

    private long mResistDataCallbackPtr = 0;
    public NeuroEEGResistDataReceived resistDataReceived;

    private long mSignalResistDataCallbackPtr = 0;
    public NeuroEEGSignalResistReceived signalResistReceived;

    private long mSignalRawCallbackPtr = 0;
    public NeuroEEGSignalRawDataReceived signalRawDataReceived;

    private long mFileStreamDataCallbackPtr = 0;
    public NeuroEEGFileStreamDataReceived fileStreamDataReceived;

    NeuroEEG(long sensor_ptr) {
        super(sensor_ptr);

        mAmpModeCallbackPtr = AmpModeModule.addAmpModeCallback(mSensorPtr, this);
        mSignalDataCallbackPtr = addSignalCallbackNeuroEEG(mSensorPtr, this);
        mResistDataCallbackPtr = addResistCallbackNeuroEEG(mSensorPtr, this);
        mSignalResistDataCallbackPtr = addSignalResistCallbackNeuroEEG(mSensorPtr, this);
        mSignalRawCallbackPtr = addSignalRawCallbackNeuroEEG(mSensorPtr, this);
        mFileStreamDataCallbackPtr = addFileStreamReadCallbackNeuroEEG(mSensorPtr, this);
    }

    public int getSurveyId() {
        throwIfClosed();
        return readSurveyIdNeuroEEG(mSensorPtr);
    }
    public void setSurveyId(int id) {
        throwIfClosed();
        writeSurveyIdNeuroEEG(mSensorPtr, id);
    }

    public SensorAmpMode getAmpMode() {
        throwIfClosed();
        return SensorAmpMode.indexOf(AmpModeModule.readAmpMode(mSensorPtr));
    }

    public List<EEGChannelInfo> getSupportedChannels(){
        throwIfClosed();
        EEGChannelInfo[] supportedChannels = readSupportedChannelsNeuroEEG(mSensorPtr);
        return Arrays.asList(supportedChannels);
    }

    public NeuroEEGFSStatus getFSStatus(){
        throwIfClosed();
        return readFilesystemStatusNeuroEEG(mSensorPtr);
    }

    public SensorDiskInfo getFSDiskInfo(){
        throwIfClosed();
        return readFileSystemDiskInfoNeuroEEG(mSensorPtr);
    }

    public NeuroEEGAmplifierParam getAmplifierParam(){
        throwIfClosed();
        return readAmplifierParamNeuroEEG(mSensorPtr);
    }
    public void setAmplifierParam(NeuroEEGAmplifierParam param){
        throwIfClosed();
        writeAmplifierParamNeuroEEG(mSensorPtr, param);
    }

    public SensorSamplingFrequency getSamplingFrequencyResist(){
        throwIfClosed();
        int sf = readSamplingFrequencyResistSensor(mSensorPtr);
        return SensorSamplingFrequency.indexOf(sf);
    }

    public SensorFileInfo readFileInfo(String fileName){
        return readFileInfoNeuroEEG(mSensorPtr, fileName);
    }

    public List<SensorFileInfo> readFileInfoAll(int maxFiles){
        SensorFileInfo[] infos = readFileInfoAllNeuroEEG(mSensorPtr);
        return Arrays.asList(infos);
    }

    public void writeFile(String fileName, byte[] data){
        writeFile(fileName, data, 0);
    }

    public void writeFile(String fileName, byte[] data, int offset){
        writeFileNeuroEEG(mSensorPtr, fileName, data, offset);
    }

    public byte[] readFile(String fileName){
        return readFile(fileName, 0xFFFFFFFF, 0);
    }

    public byte[] readFile(String fileName, int sizeData){
        return readFile(fileName, sizeData, 0);
    }

    public byte[] readFile(String fileName, int sizeData, int offset){
        return readFileNeuroEEG(mSensorPtr, fileName, sizeData, offset);
    }

    public void deleteFile(String fileName){
        deleteFileNeuroEEG(mSensorPtr, fileName);
    }

    public void deleteAllFiles(String fileExt){
        deleteAllFilesNeuroEEG(mSensorPtr, fileExt);
    }

    public int readFileCRC32(String fileName, int totalSize, int offset){
        return readFileCRC32NeuroEEG(mSensorPtr, fileName, totalSize, offset);
    }

    public void fileStreamAutosave(String fileName){
        fileStreamAutosaveNeuroEEG(mSensorPtr, fileName);
    }

    public void fileStreamRead(String fileName){
        fileStreamRead(fileName, 0);
    }

    public void fileStreamRead(String fileName, int totalSize){
        fileStreamRead(fileName, totalSize, 0);
    }

    public void fileStreamRead(String fileName, int totalSize, int offset){
        fileStreamReadNeuroEEG(mSensorPtr, fileName, totalSize, offset);
    }

    @Override
    public void close() {
        throwIfClosed();
        try
        {
            if(mAmpModeCallbackPtr != 0) AmpModeModule.removeAmpModeCallback(mAmpModeCallbackPtr);
            if(mSignalDataCallbackPtr != 0) removeSignalCallbackNeuroEEG(mSignalDataCallbackPtr);
            if(mResistDataCallbackPtr != 0) removeResistCallbackNeuroEEG(mResistDataCallbackPtr);
            if(mSignalResistDataCallbackPtr != 0) removeSignalResistCallbackNeuroEEG(mSignalResistDataCallbackPtr);
            if(mSignalRawCallbackPtr != 0) removeSignalRawCallbackNeuroEEG(mSignalRawCallbackPtr);
            if(mFileStreamDataCallbackPtr != 0) removeFileStreamReadCallbackNeuroEEG(mFileStreamDataCallbackPtr);
        }
        finally
        {
            super.close();
        }
    }

    private void onAmpModeChanged(long sensorPtr, int data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(ampModeChanged != null) {
            ampModeChanged.onSensorAmpModeChanged(SensorAmpMode.indexOf(data));
        }
    }

    private void onNeuroEEGSignalDataReceived(long sensorPtr, SignalChannelsData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(signalDataReceived != null) {
            signalDataReceived.onSignalDataReceived(data);
        }
    }

    private void onNeuroEEGResistDataReceived(long sensorPtr, ResistChannelsData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(resistDataReceived != null) {
            resistDataReceived.onResistDataReceived(data);
        }
    }

    private void onNeuroEEGSignalResistDataReceived(long sensorPtr, SignalChannelsData[] signalData, ResistChannelsData[] resistData)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(signalResistReceived != null) {
            signalResistReceived.onSignalResistDataReceived(signalData, resistData);
        }
    }

    private void onNeuroEEGSignalRawDataReceived(long sensorPtr, byte[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(signalRawDataReceived != null) {
            signalRawDataReceived.onSignalRawDataReceived(data);
        }
    }

    private void onFileStreamDataReceived(long sensorPtr, SensorFileData[] data)
    {
        throwIfClosed();
        if (sensorPtr != mSensorPtr) return;
        if(fileStreamDataReceived != null) {
            fileStreamDataReceived.onFileStreamDataReceived(data);
        }
    }
    

//    private static native long addAmpModeCallback(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalCallbackNeuroEEG(long sensor_ptr, Sensor sensor_obj);
    private static native long addResistCallbackNeuroEEG(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalResistCallbackNeuroEEG(long sensor_ptr, Sensor sensor_obj);
    private static native long addSignalRawCallbackNeuroEEG(long sensor_ptr, Sensor sensor_obj);
    private static native long addFileStreamReadCallbackNeuroEEG(long sensor_ptr, Sensor sensor_obj);

//    private static native void removeAmpModeCallback(long ptr);
    private static native void removeSignalCallbackNeuroEEG(long ptr);
    private static native void removeResistCallbackNeuroEEG(long ptr);
    private static native void removeSignalResistCallbackNeuroEEG(long ptr);
    private static native void removeSignalRawCallbackNeuroEEG(long ptr);
    private static native void removeFileStreamReadCallbackNeuroEEG(long ptr);

    private static native int readSurveyIdNeuroEEG(long sensor_ptr);
    private static native void writeSurveyIdNeuroEEG(long sensor_ptr, int id);

//    private static native int readAmpMode(long sensor_ptr);
    private static native EEGChannelInfo[] readSupportedChannelsNeuroEEG(long sensor_ptr);
    private static native NeuroEEGFSStatus readFilesystemStatusNeuroEEG(long sensor_ptr);
    private static native SensorDiskInfo readFileSystemDiskInfoNeuroEEG(long sensor_ptr);
    private static native NeuroEEGAmplifierParam readAmplifierParamNeuroEEG(long sensor_ptr);
    private static native void writeAmplifierParamNeuroEEG(long sensor_ptr, NeuroEEGAmplifierParam param);
    private static native int readSamplingFrequencyResistSensor(long sensor_ptr);

    private static native SensorFileInfo readFileInfoNeuroEEG(long sensor_ptr, String fileName);
    private static native SensorFileInfo[] readFileInfoAllNeuroEEG(long sensor_ptr);
    private static native void writeFileNeuroEEG(long sensor_ptr, String fileName, byte[] data, int offset);
    private static native byte[] readFileNeuroEEG(long sensor_ptr, String fileName, int sizeData, int offset);
    private static native void deleteFileNeuroEEG(long sensor_ptr, String fileName);
    private static native void deleteAllFilesNeuroEEG(long sensor_ptr, String fileExt);
    private static native int readFileCRC32NeuroEEG(long sensor_ptr, String fileName, int totalSize, int offset);
    private static native void fileStreamAutosaveNeuroEEG(long sensor_ptr, String fileName);
    private static native void fileStreamReadNeuroEEG(long sensor_ptr, String fileName, int totalSize, int offset);

}
