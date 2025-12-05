package com.neurosdk2;

import static com.neurosdk2.Constants.AMPMODE_CHANGED_EVENT_NAME;


import static com.neurosdk2.Constants.CALLIBRI_ELECTRODE_STATE_EVENT_NAME;
import static com.neurosdk2.Constants.CALLIBRI_ENVELOPE_DATA_EVENT_NAME;
import static com.neurosdk2.Constants.CALLIBRI_RESPIRATION_DATA_EVENT_NAME;
import static com.neurosdk2.Constants.QUATERNIONDATA_CHANGED_EVENT_NAME;


import static com.neurosdk2.Constants.MEMSDATA_CHANGED_EVENT_NAME;


import static com.neurosdk2.Constants.NEUROSMART_FPGDATA_CHANGED_EVENT_NAME;

import static com.neurosdk2.Constants.RESISTANCE_CHANGED_EVENT_NAME;
import static com.neurosdk2.Constants.SIGNAL_CHANGED_EVENT_NAME;
import static com.neurosdk2.Constants.CONNECTION_CHANGED_EVENT_NAME;
import static com.neurosdk2.Constants.BATTERY_CHANGED_EVENT_NAME;
import static com.neurosdk2.Constants.SENSOR_LIST_CHANGED_EVENT_NAME;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.StandardMethodCodec;

public class EventHolder {
    private EventChannel scannerSensorsChannel;
    public EventChannel.EventSink scannerSensorsSink;
    private EventChannel mSensorStateEventChannel;
    public EventChannel.EventSink mSensorStateEventSink;
    private EventChannel mBatteryEventChannel;
    public EventChannel.EventSink mBatteryEventSink;
    private EventChannel mSignalEventChannel;
    public EventChannel.EventSink mSignalEventSink;
    private EventChannel mResistEventChannel;
    public EventChannel.EventSink mResistEventSink;

    private EventChannel mFPGEventChannel;
    public EventChannel.EventSink mFPGEventSink;


    private EventChannel mMEMSEventChannel;
    public EventChannel.EventSink mMEMSEventSink;


    private EventChannel mAmpModeEventChannel;
    public EventChannel.EventSink mAmpModeEventSink;


    private EventChannel mElectrodeStateEventChannel;
    public EventChannel.EventSink mElectrodeStateEventSink;
    private EventChannel mQuaternionEventChannel;
    public EventChannel.EventSink mQuaternionEventSink;
    private EventChannel mRespirationEventChannel;
    public EventChannel.EventSink mRespirationEventSink;
    private EventChannel mEnvelopeEventChannel;
    public EventChannel.EventSink mEnvelopeEventSink;


    public void activate(@NonNull FlutterPlugin.FlutterPluginBinding binding){
        BinaryMessenger messenger = binding.getBinaryMessenger();
        BinaryMessenger.TaskQueue taskQueue = messenger.makeBackgroundTaskQueue();

        scannerSensorsChannel = new EventChannel(messenger,
                SENSOR_LIST_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        scannerSensorsChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                scannerSensorsSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                scannerSensorsSink = null;
            }
        });

        mSensorStateEventChannel = new EventChannel(messenger,
                CONNECTION_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mSensorStateEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mSensorStateEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                mSensorStateEventSink = null;
            }
        });

        mBatteryEventChannel = new EventChannel(messenger,
                BATTERY_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mBatteryEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mBatteryEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                mBatteryEventSink = null;
            }
        });

        mSignalEventChannel = new EventChannel(messenger,
                SIGNAL_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mSignalEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mSignalEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mSignalEventSink = null;
            }
        });

        mResistEventChannel = new EventChannel(messenger,
                RESISTANCE_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mResistEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mResistEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mResistEventSink = null;
            }
        });

        mFPGEventChannel = new EventChannel(messenger,
                NEUROSMART_FPGDATA_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mFPGEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mFPGEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mFPGEventSink = null;
            }
        });


        mMEMSEventChannel = new EventChannel(messenger,
                MEMSDATA_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mMEMSEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mMEMSEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mMEMSEventSink = null;
            }
        });


        mAmpModeEventChannel = new EventChannel(messenger,
                AMPMODE_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mAmpModeEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mAmpModeEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mAmpModeEventSink = null;
            }
        });


        mElectrodeStateEventChannel = new EventChannel(messenger,
                CALLIBRI_ELECTRODE_STATE_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mElectrodeStateEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mElectrodeStateEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mElectrodeStateEventSink = null;
            }
        });
        mEnvelopeEventChannel = new EventChannel(messenger,
                CALLIBRI_ENVELOPE_DATA_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mEnvelopeEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mEnvelopeEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mEnvelopeEventSink = null;
            }
        });
        mRespirationEventChannel = new EventChannel(messenger,
                CALLIBRI_RESPIRATION_DATA_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mRespirationEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mRespirationEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mRespirationEventSink = null;
            }
        });
        mQuaternionEventChannel = new EventChannel(messenger,
                QUATERNIONDATA_CHANGED_EVENT_NAME.raw(),
                StandardMethodCodec.INSTANCE,
                taskQueue);
        mQuaternionEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mQuaternionEventSink = events;
            }
            @Override
            public void onCancel(Object arguments) {
                mQuaternionEventSink = null;
            }
        });

    }

    public void deactivate(){
        scannerSensorsChannel.setStreamHandler(null);
        scannerSensorsSink = null;
        mSensorStateEventChannel.setStreamHandler(null);
        mSensorStateEventSink = null;
        mBatteryEventChannel.setStreamHandler(null);
        mBatteryEventSink = null;
        mSignalEventChannel.setStreamHandler(null);
        mSignalEventSink = null;
        mResistEventChannel.setStreamHandler(null);
        mResistEventSink = null;

        mFPGEventChannel.setStreamHandler(null);
        mFPGEventSink = null;


        mMEMSEventChannel.setStreamHandler(null);
        mMEMSEventSink = null;


        mAmpModeEventChannel.setStreamHandler(null);
        mAmpModeEventSink = null;


        mElectrodeStateEventChannel.setStreamHandler(null);
        mElectrodeStateEventSink = null;
        mQuaternionEventChannel.setStreamHandler(null);
        mQuaternionEventSink = null;
        mRespirationEventChannel.setStreamHandler(null);
        mRespirationEventSink = null;
        mEnvelopeEventChannel.setStreamHandler(null);
        mEnvelopeEventSink = null;

    }
}
