#import <Foundation/Foundation.h>
#import "CallibriImpl.h"
#import "AFullSensorProtected.h"
#import "Constants.h"

@implementation CallibriImpl

- (instancetype _Nonnull )init:(NSString*_Nonnull)guid
                        sensor:(NTSensor*_Nonnull)sensor
                   eventHolder:(EventHolder* _Nonnull)eventHolder{
    self = [super init];
    if (self) {
        self.sensor = sensor;
        self.guid = guid;
        self.eventHolder = eventHolder;
        [self addCallbacks];
    }
    return self;
}

- (void) addCallbacks{
    [super addCallbacks];
    
    __weak CallibriImpl* weakSelf = self;
    [((NTCallibri*)self.sensor) setSignalCallback:^(NSArray<NTCallibriSignalData *> * _Nonnull signals) {
        @try {
            NSMutableArray* signalsArray = [[NSMutableArray alloc] initWithCapacity: [signals count]];
                    for (NTCallibriSignalData* signal in signals) {
                        NSDictionary *signalDic = @{
                            @"PackNum" : [NSNumber numberWithInt:signal.PackNum],
                            @"Samples" : signal.Samples
                        };
                        [signalsArray addObject:signalDic];
                    }
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:signalsArray forKey:DATA_ID];
            
            FlutterEventSink sink = weakSelf.eventHolder.signalEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }];
    [((NTCallibri*)self.sensor) setElectrodeStateCallback:^(NTCallibriElectrodeState callibriElectrodeState) {
        @try {
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:[NSNumber numberWithInt:callibriElectrodeState] forKey:DATA_ID];
            
            FlutterEventSink sink = weakSelf.eventHolder.electrodeStateEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
        
    }];
    [((NTCallibri*)self.sensor) setEnvelopeDataCallback:^(NSArray<NTCallibriEnvelopeData *> * _Nonnull envelopes) {
        @try {
            NSMutableArray* envelopesArray = [[NSMutableArray alloc] initWithCapacity: [envelopes count]];
                    for (NTCallibriEnvelopeData* envelope in envelopes) {
                        NSDictionary *envelopeDic = @{
                            @"PackNum" : [NSNumber numberWithInt:envelope.PackNum],
                            @"Sample" : envelope.Sample
                        };
                        [envelopesArray addObject:envelopeDic];
                    }
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:envelopesArray forKey:DATA_ID];
            
            FlutterEventSink sink = weakSelf.eventHolder.envelopeEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
        
    }];
    [((NTCallibri*)self.sensor) setRespirationCallback:^(NSArray<NTCallibriRespirationData *> * _Nonnull callibriRespirationData) {
        @try {
            NSMutableArray* callibriRespirationDataArray = [[NSMutableArray alloc] initWithCapacity: [callibriRespirationData count]];
                    for (NTCallibriRespirationData* respData in callibriRespirationData) {
                        NSDictionary *callibriRespirationDataDic = @{
                            @"PackNum" : [NSNumber numberWithInt:respData.PackNum],
                            @"Samples" : respData.Samples
                        };
                        [callibriRespirationDataArray addObject:callibriRespirationDataDic];
                    }
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:callibriRespirationDataArray forKey:DATA_ID];
            
            FlutterEventSink sink = weakSelf.eventHolder.respirationEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
        
    }];
    [((NTCallibri*)self.sensor) setQuaternionDataCallback:^(NSArray<NTQuaternionData *> * _Nonnull quaternionData) {
        @try {
            NSMutableArray* quaternionDataArray = [[NSMutableArray alloc] initWithCapacity: [quaternionData count]];
                    for (NTQuaternionData* data in quaternionData) {
                        NSDictionary *dataDic = @{
                            @"PackNum" : [NSNumber numberWithUnsignedInt:data.PackNum],
                            @"W" : [NSNumber numberWithFloat: data.W],
                            @"X" : [NSNumber numberWithFloat: data.X],
                            @"Y" : [NSNumber numberWithFloat: data.Y],
                            @"Z" : [NSNumber numberWithFloat: data.Z]
                        };
                        [quaternionDataArray addObject:dataDic];
                    }
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:quaternionDataArray forKey:DATA_ID];
            
            FlutterEventSink sink = weakSelf.eventHolder.quaternionEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
        
    }];
    [((NTCallibri*)self.sensor) setMEMSDataCallback:^(NSArray<NTMEMSData *> * _Nonnull MEMSData) {
        @try {
            NSMutableArray* MEMSDataArray = [[NSMutableArray alloc] initWithCapacity: [MEMSData count]];
                    for (NTMEMSData* data in MEMSData) {
                        NSDictionary* AccelerometerDic = @{
                            @"X" : [NSNumber numberWithDouble: data.Accelerometer.X],
                            @"Y" : [NSNumber numberWithDouble: data.Accelerometer.Y],
                            @"Z" : [NSNumber numberWithDouble: data.Accelerometer.Z]
                        };
                        NSDictionary* GyroscopeDic = @{
                            @"X" : [NSNumber numberWithDouble: data.Gyroscope.X],
                            @"Y" : [NSNumber numberWithDouble: data.Gyroscope.Y],
                            @"Z" : [NSNumber numberWithDouble: data.Gyroscope.Z]
                        };
                        NSDictionary *dataDic = @{
                            @"PackNum" : [NSNumber numberWithInt:data.PackNum],
                            @"Accelerometer" : AccelerometerDic,
                            @"Gyroscope" : GyroscopeDic
                        };
                        [MEMSDataArray addObject:dataDic];
                    }
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:MEMSDataArray forKey:DATA_ID];

            FlutterEventSink sink = weakSelf.eventHolder.memsEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }];
}

- (void)removeCallbacks{
    [super removeCallbacks];
    [((NTCallibri*)self.sensor) setSignalCallback:nil];
    [((NTCallibri*)self.sensor) setElectrodeStateCallback:nil];
    [((NTCallibri*)self.sensor) setEnvelopeDataCallback:nil];
    [((NTCallibri*)self.sensor) setRespirationCallback:nil];
    [((NTCallibri*)self.sensor) setQuaternionDataCallback:nil];
    [((NTCallibri*)self.sensor) setMEMSDataCallback:nil];
}

- (NTSensorADCInput)getADCInput{
    return [((NTCallibri*)self.sensor) ADCInput];
}

- (NTSensorAccelerometerSensitivity)getAccSens{
    return [((NTCallibri*)self.sensor) AccSens];
}

- (NTCallibriColorType)getColor{
    return [((NTCallibri*)self.sensor) Color];
}

- (NTSensorExternalSwitchInput)getExtSwInput{
    return [((NTCallibri*)self.sensor) ExtSwInput];
}

- (NTSensorGyroscopeSensitivity)getGyroSens{
    return [((NTCallibri*)self.sensor) GyroSens];
}

- (NSNumber *_Nonnull)isSupportedFilter:(NTSensorFilter)filter{
    BOOL supported = [((NTCallibri*)self.sensor) isSupportedFilter:filter];
    return [[NSNumber alloc] initWithBool:supported];
}

- (void)getSupportedFilters:(NSMutableArray<NSNumber *> *_Nonnull)result{
    [result addObjectsFromArray:[((NTCallibri*)self.sensor) SupportedFilters]];
}

- (void)getHardwareFilters:(NSMutableArray<NSNumber *> *_Nonnull)result{
    [result addObjectsFromArray:[((NTCallibri*)self.sensor) HardwareFilters]];
}

- (NSNumber *_Nonnull)getMEMSCalibrateState{
    return @([((NTCallibri*)self.sensor) MEMSCalibrateState]);
}

- (NTCallibriMotionAssistantParams* _Nullable)getMotionAssistantParam{
    return [(NTCallibri*)self.sensor MotionAssistantParam];
}

- (NSNumber *_Nonnull)getMotionCounter{
    return @([((NTCallibri*)self.sensor) MotionCounter]);
}

- (NTCallibriMotionCounterParam* _Nullable)getMotionCounterParam{
    return [(NTCallibri*)self.sensor MotionCounterParam];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyMEMS{
    return [((NTCallibri*)self.sensor) SamplingFrequencyMEMS];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyResp{
    return [((NTCallibri*)self.sensor) SamplingFrequencyResp];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyEnvelope{
    return [((NTCallibri*)self.sensor) SamplingFrequencyEnvelope];
}

- (NTCallibriSignalType)getSignalType{
    return [((NTCallibri*)self.sensor) SignalType];
}

- (NTCallibriElectrodeState)getElectrodeState{
    return [((NTCallibri*)self.sensor) ElectrodeState];
}

- (NTCallibriStimulatorMAState* _Nullable)getStimulatorMAState{
    return [(NTCallibri*)self.sensor StimulatorMAState];
}

- (NTCallibriStimulationParams* _Nullable)getStimulatorParam{
    return [(NTCallibri*)self.sensor StimulatorParam];
}

- (void)setADCInput:(NTSensorADCInput)adcInp{
    ((NTCallibri*)self.sensor).ADCInput = adcInp;
}

- (void)setAccSens:(NTSensorAccelerometerSensitivity)accSens{
    ((NTCallibri*)self.sensor).AccSens = accSens;
}

- (void)setDataOffset:(NTSensorDataOffset)offset{
    ((NTCallibri*)self.sensor).DataOffset = offset;
}

- (void)setExtSwInput:(NTSensorExternalSwitchInput)extSwInp{
    ((NTCallibri*)self.sensor).ExtSwInput = extSwInp;
}

- (void)setFirmwareMode:(NTSensorFirmwareMode)mode{
    ((NTCallibri*)self.sensor).FirmwareMode = mode;
}

- (void)setGain:(NTSensorGain)gain{
    ((NTCallibri*)self.sensor).Gain = gain;
}

- (void)setGyroSens:(NTSensorGyroscopeSensitivity)gyroSens{
    ((NTCallibri*)self.sensor).GyroSens = gyroSens;
}

- (void)setHardwareFilters:(NSArray *_Nonnull)filters{
    ((NTCallibri*)self.sensor).HardwareFilters = filters;
}

- (void)setMotionAssistantParam:(NTCallibriMotionAssistantParams*_Nonnull)param{
    ((NTCallibri*)self.sensor).MotionAssistantParam = param;
}

- (void)setMotionCounterParam:(NTCallibriMotionCounterParam*_Nonnull)param{
    ((NTCallibri*)self.sensor).MotionCounterParam = param;
}

- (void)setSamplingFrequency:(NTSensorSamplingFrequency)sf{
    ((NTCallibri*)self.sensor).SamplingFrequency = sf;
}

- (void)setSignalType:(NTCallibriSignalType)type{
    ((NTCallibri*)self.sensor).SignalType = type;
}

- (void)setStimulatorParam:(NTCallibriStimulationParams*_Nonnull)param{
    ((NTCallibri*)self.sensor).StimulatorParam = param;
}

@end
