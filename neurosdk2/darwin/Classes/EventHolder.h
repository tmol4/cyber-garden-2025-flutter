#ifndef EventHolder_h
#define EventHolder_h

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

@interface EventHolder : NSObject
@property (nonatomic, strong) FlutterEventChannel *scannerSensorsChannel;
@property (nonatomic, strong) FlutterEventSink scannerSensorsSink;

@property (nonatomic, strong) FlutterEventChannel *sensorStateEventChannel;
@property (nonatomic, strong) FlutterEventSink sensorStateEventSink;

@property (nonatomic, strong) FlutterEventChannel *batteryEventChannel;
@property (nonatomic, strong) FlutterEventSink batteryEventSink;

@property (nonatomic, strong) FlutterEventChannel *signalEventChannel;
@property (nonatomic, strong) FlutterEventSink signalEventSink;

@property (nonatomic, strong) FlutterEventChannel *resistEventChannel;
@property (nonatomic, strong) FlutterEventSink resistEventSink;

@property (nonatomic, strong) FlutterEventChannel *fpgEventChannel;
@property (nonatomic, strong) FlutterEventSink fpgEventSink;

@property (nonatomic, strong) FlutterEventChannel *memsEventChannel;
@property (nonatomic, strong) FlutterEventSink memsEventSink;

@property (nonatomic, strong) FlutterEventChannel *ampModeEventChannel;
@property (nonatomic, strong) FlutterEventSink ampModeEventSink;

@property (nonatomic, strong) FlutterEventChannel *electrodeStateEventChannel;
@property (nonatomic, strong) FlutterEventSink electrodeStateEventSink;

@property (nonatomic, strong) FlutterEventChannel *quaternionEventChannel;
@property (nonatomic, strong) FlutterEventSink quaternionEventSink;

@property (nonatomic, strong) FlutterEventChannel *respirationEventChannel;
@property (nonatomic, strong) FlutterEventSink respirationEventSink;

@property (nonatomic, strong) FlutterEventChannel *envelopeEventChannel;
@property (nonatomic, strong) FlutterEventSink envelopeEventSink;

- (void)activateWithBinaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)deactivate;

@end

@interface ScannerSensorsStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface SensorStateStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface BatteryStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface SignalStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface ResistStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface FPGStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface MEMSStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface AmpModeStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface ElectrodeStateStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface QuaternionStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface RespirationStreamHandler : NSObject <FlutterStreamHandler>
@end

@interface EnvelopeStreamHandler : NSObject <FlutterStreamHandler>
@end

#endif
