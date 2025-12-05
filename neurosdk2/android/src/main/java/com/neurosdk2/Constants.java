package com.neurosdk2;

public enum Constants {


  SCANNER_METHOD_CHANNEL("method_neurosdk2/scanner"),
  SENSOR_METHOD_CHANNEL("method_neurosdk2/sensor"),

  SIGNAL_CHANGED_EVENT_NAME("event_neurosdk2/signalChanged"),
  RESISTANCE_CHANGED_EVENT_NAME("event_neurosdk2/resistanceChanged"),


  AMPMODE_CHANGED_EVENT_NAME("event_neurosdk2/AMPModeChanged"),


  MEMSDATA_CHANGED_EVENT_NAME("event_neurosdk2/memsDataChanged"),


  NEUROSMART_FPGDATA_CHANGED_EVENT_NAME("event_neurosdk2/neuroSmartFPGDataChanged"),


  CALLIBRI_ELECTRODE_STATE_EVENT_NAME("event_neurosdk2/callibriElectrodeChanged"),
  CALLIBRI_ENVELOPE_DATA_EVENT_NAME("event_neurosdk2/callibriEnvelopeDataChanged"),
  CALLIBRI_RESPIRATION_DATA_EVENT_NAME("event_neurosdk2/callibriRespirationDataChanged"),
  QUATERNIONDATA_CHANGED_EVENT_NAME("event_neurosdk2/quaternionDataChanged"),

  SENSOR_LIST_CHANGED_EVENT_NAME("event_neurosdk2/sensorListChanged"),
  CONNECTION_CHANGED_EVENT_NAME("event_neurosdk2/connectionChanged"),
  BATTERY_CHANGED_EVENT_NAME("event_neurosdk2/batteryChanged");

  private final String ID;

  Constants(String id) {
    this.ID = id;
  }

  public String raw() {
    return ID;
  }

  public static final String GUID_ID = "guid";
  public static final String DATA_ID = "data";
}
