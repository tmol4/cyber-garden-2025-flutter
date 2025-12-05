#import "EventHolder.h"
#import "Constants.h"

FlutterEventSink scannerSensorsSink;
FlutterEventSink sensorStateEventSink;
FlutterEventSink batteryEventSink;
FlutterEventSink signalEventSink;
FlutterEventSink resistEventSink;
FlutterEventSink fpgEventSink;
FlutterEventSink memsEventSink;
FlutterEventSink ampModeEventSink;
FlutterEventSink electrodeStateEventSink;
FlutterEventSink quaternionEventSink;
FlutterEventSink respirationEventSink;
FlutterEventSink envelopeEventSink;

@implementation EventHolder

- (FlutterEventSink)scannerSensorsSink{
    return scannerSensorsSink;
}

- (FlutterEventSink)sensorStateEventSink{
    return sensorStateEventSink;
}

- (FlutterEventSink)batteryEventSink{
    return batteryEventSink;
}

- (FlutterEventSink)signalEventSink{
    return signalEventSink;
}

- (FlutterEventSink)resistEventSink{
    return resistEventSink;
}

- (FlutterEventSink)fpgEventSink{
    return fpgEventSink;
}

- (FlutterEventSink)memsEventSink{
    return memsEventSink;
}

- (FlutterEventSink)ampModeEventSink{
    return ampModeEventSink;
}

- (FlutterEventSink)electrodeStateEventSink{
    return electrodeStateEventSink;
}

- (FlutterEventSink)quaternionEventSink{
    return quaternionEventSink;
}

- (FlutterEventSink)respirationEventSink{
    return respirationEventSink;
}

- (FlutterEventSink)envelopeEventSink{
    return envelopeEventSink;
}

- (void)activateWithBinaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    ScannerSensorsStreamHandler* scannerSensorsStreamHandler = [[ScannerSensorsStreamHandler alloc] init];
    self.scannerSensorsChannel = [FlutterEventChannel eventChannelWithName:SENSOR_LIST_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.scannerSensorsChannel setStreamHandler:scannerSensorsStreamHandler];

    SensorStateStreamHandler* sensorStateStreamHandler = [[SensorStateStreamHandler alloc] init];
    self.sensorStateEventChannel = [FlutterEventChannel eventChannelWithName:CONNECTION_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.sensorStateEventChannel setStreamHandler:sensorStateStreamHandler];

    BatteryStreamHandler* batteryStreamHandler = [[BatteryStreamHandler alloc] init];
    self.batteryEventChannel = [FlutterEventChannel eventChannelWithName:BATTERY_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.batteryEventChannel setStreamHandler:batteryStreamHandler];

    SignalStreamHandler* signalStreamHandler = [[SignalStreamHandler alloc] init];
    self.signalEventChannel = [FlutterEventChannel eventChannelWithName:SIGNAL_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.signalEventChannel setStreamHandler:signalStreamHandler];

    ResistStreamHandler* resistStreamHandler = [[ResistStreamHandler alloc] init];
    self.resistEventChannel = [FlutterEventChannel eventChannelWithName:RESISTANCE_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.resistEventChannel setStreamHandler:resistStreamHandler];

    FPGStreamHandler* fpgStreamHandler = [[FPGStreamHandler alloc] init];
    self.fpgEventChannel = [FlutterEventChannel eventChannelWithName:NEUROSMART_FPGDATA_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.fpgEventChannel setStreamHandler:fpgStreamHandler];

    MEMSStreamHandler* memsStreamHandler = [[MEMSStreamHandler alloc] init];
    self.memsEventChannel = [FlutterEventChannel eventChannelWithName:MEMSDATA_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.memsEventChannel setStreamHandler:memsStreamHandler];

    AmpModeStreamHandler* ampModeStreamHandler = [[AmpModeStreamHandler alloc] init];
    self.ampModeEventChannel = [FlutterEventChannel eventChannelWithName:AMPMODE_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.ampModeEventChannel setStreamHandler:ampModeStreamHandler];

    ElectrodeStateStreamHandler* electrodeStreamHandler = [[ElectrodeStateStreamHandler alloc] init];
    self.electrodeStateEventChannel = [FlutterEventChannel eventChannelWithName:CALLIBRI_ELECTRODE_STATE_EVENT_NAME binaryMessenger:messenger];
    [self.electrodeStateEventChannel setStreamHandler:electrodeStreamHandler];

    QuaternionStreamHandler* quaternionStreamHandler = [[QuaternionStreamHandler alloc] init];
    self.quaternionEventChannel = [FlutterEventChannel eventChannelWithName:QUATERNIONDATA_CHANGED_EVENT_NAME binaryMessenger:messenger];
    [self.quaternionEventChannel setStreamHandler:quaternionStreamHandler];

    RespirationStreamHandler* respirationStreamHandler = [[RespirationStreamHandler alloc] init];
    self.respirationEventChannel = [FlutterEventChannel eventChannelWithName:CALLIBRI_RESPIRATION_DATA_EVENT_NAME binaryMessenger:messenger];
    [self.respirationEventChannel setStreamHandler:respirationStreamHandler];

    EnvelopeStreamHandler* envelopeStreamHandler = [[EnvelopeStreamHandler alloc] init];
    self.envelopeEventChannel = [FlutterEventChannel eventChannelWithName:CALLIBRI_ENVELOPE_DATA_EVENT_NAME binaryMessenger:messenger];
    [self.envelopeEventChannel setStreamHandler:envelopeStreamHandler];
}

- (void)deactivate {
    [self.scannerSensorsChannel setStreamHandler:nil];
    scannerSensorsSink = nil;

    [self.sensorStateEventChannel setStreamHandler:nil];
    sensorStateEventSink = nil;

    [self.batteryEventChannel setStreamHandler:nil];
    batteryEventSink = nil;

    [self.signalEventChannel setStreamHandler:nil];
    signalEventSink = nil;

    [self.resistEventChannel setStreamHandler:nil];
    resistEventSink = nil;

    [self.fpgEventChannel setStreamHandler:nil];
    fpgEventSink = nil;

    [self.memsEventChannel setStreamHandler:nil];
    memsEventSink = nil;

    [self.ampModeEventChannel setStreamHandler:nil];
    ampModeEventSink = nil;

    [self.electrodeStateEventChannel setStreamHandler:nil];
    electrodeStateEventSink = nil;

    [self.quaternionEventChannel setStreamHandler:nil];
    quaternionEventSink = nil;

    [self.respirationEventChannel setStreamHandler:nil];
    respirationEventSink = nil;

    [self.envelopeEventChannel setStreamHandler:nil];
    envelopeEventSink = nil;
}

@end

#pragma mark - FlutterStreamHandler
@implementation ScannerSensorsStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    scannerSensorsSink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  scannerSensorsSink = nil;
  return nil;
}
@end

@implementation SensorStateStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    sensorStateEventSink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    sensorStateEventSink = nil;
  return nil;
}
@end

@implementation BatteryStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    batteryEventSink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    batteryEventSink = nil;
  return nil;
}
@end

@implementation SignalStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    signalEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    signalEventSink = nil;
    return nil;
}
@end

@implementation ResistStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    resistEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    resistEventSink = nil;
    return nil;
}
@end

@implementation FPGStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    fpgEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    fpgEventSink = nil;
    return nil;
}
@end

@implementation MEMSStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    memsEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    memsEventSink = nil;
    return nil;
}
@end

@implementation AmpModeStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    ampModeEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    ampModeEventSink = nil;
    return nil;
}
@end

@implementation ElectrodeStateStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    electrodeStateEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    electrodeStateEventSink = nil;
    return nil;
}
@end

@implementation QuaternionStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    quaternionEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    quaternionEventSink = nil;
    return nil;
}
@end

@implementation RespirationStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    respirationEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    respirationEventSink = nil;
    return nil;
}
@end

@implementation EnvelopeStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    envelopeEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    envelopeEventSink = nil;
    return nil;
}
@end
