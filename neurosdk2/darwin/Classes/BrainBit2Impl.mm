#import <Foundation/Foundation.h>
#import "BrainBit2Impl.h"
#import "AFullSensorProtected.h"
#import "Constants.h"

@implementation BrainBit2Impl

- (instancetype)init:(NSString *)guid
              sensor:(id)bb
         eventHolder:(id)eventHolder{
    self = [super init];
    if (self) {
        self.sensor = bb;
        self.guid = guid;
        self.eventHolder = eventHolder;
        [self addCallbacks];
    }
    return self;
}

- (void) addCallbacks{
    [super addCallbacks];
    __weak BrainBit2Impl* weakSelf = self;
    [((NTBrainBit2*)(self.sensor)) setSignalDataCallback:^(NSArray<NTSignalChannelsData *> * _Nonnull signals) {
        @try {
            NSMutableArray* signalsArray = [[NSMutableArray alloc] initWithCapacity: [signals count]];
            for (NTSignalChannelsData* signal in signals) {
                NSDictionary *signalDic = @{
                    @"PackNum" : [NSNumber numberWithInt:signal.PackNum],
                    @"Marker" : [NSNumber numberWithInt:signal.Marker],
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

    [((NTBrainBit2*)(self.sensor)) setResistDataCallback:^(NSArray<NTResistRefChannelsData*>*_Nonnull resists) {
        @try {
            NSMutableArray* resistArray = [[NSMutableArray alloc] initWithCapacity: [resists count]];
            for (NTResistRefChannelsData* resist in resists) {
                NSDictionary *resistDic = @{
                    @"PackNum" : [NSNumber numberWithInt:resist.PackNum],
                    @"Samples" : resist.Samples,
                    @"Referents" : resist.Referents
                };
                [resistArray addObject:resistDic];
            }
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:resistArray forKey:DATA_ID];
            
            FlutterEventSink sink = weakSelf.eventHolder.resistEventSink;
            if (sink) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sink(res);
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
        }
    }];
    [((NTBrainBit2*)(self.sensor)) setFPGDataCallback:^(NSArray<NTFPGData *> * _Nonnull FPGData) {
        NSMutableArray* FPGDataArray = [[NSMutableArray alloc] initWithCapacity: [FPGData count]];
                for (NTFPGData* data in FPGData) {
                    NSDictionary *dataDic = @{ @"PackNum" : [NSNumber numberWithInt:data.PackNum],
                                               @"IrAmplitude" : data.IrAmplitude,
                                               @"RedAmplitude" : data.RedAmplitude
                    };
                    [FPGDataArray addObject:dataDic];
                }
        NSMutableDictionary* res = [NSMutableDictionary new];
        [res setObject:weakSelf.guid forKey:GUID_ID];
        [res setObject:FPGDataArray forKey:DATA_ID];
        
        FlutterEventSink sink = weakSelf.eventHolder.fpgEventSink;
        if (sink) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sink(res);
            });
        }
    }];
    [((NTBrainBit2*)(self.sensor)) setMEMSDataCallback:^(NSArray<NTMEMSData *> * _Nonnull MEMSData) {
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
    }];
    [((NTBrainBit2*)(self.sensor)) setAmpModeCallback:^(NTSensorAmpMode ampMode) {
        NSMutableDictionary* res = [NSMutableDictionary new];
        [res setObject:weakSelf.guid forKey:GUID_ID];
        [res setObject:[NSNumber numberWithUnsignedInt:ampMode] forKey:DATA_ID];
        
        FlutterEventSink sink = weakSelf.eventHolder.ampModeEventSink;
        if (sink) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sink(res);
            });
        }
    }];
}
- (void) removeCallbacks{
    [super removeCallbacks];
    [((NTBrainBit2*)(self.sensor)) setSignalDataCallback:nil];
    [((NTBrainBit2*)(self.sensor)) setResistDataCallback:nil];
    [((NTBrainBit2*)(self.sensor)) setFPGDataCallback:nil];
    [((NTBrainBit2*)(self.sensor)) setMEMSDataCallback:nil];
    [((NTBrainBit2*)(self.sensor)) setAmpModeCallback:nil];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyMEMS{
    return [(NTBrainBit2*)(self.sensor) SamplingFrequencyMEMS];
}
- (NTSensorSamplingFrequency)getSamplingFrequencyFPG{
    return [(NTBrainBit2*)(self.sensor) SamplingFrequencyFPG];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyResist{
    return [(NTBrainBit2*)(self.sensor) SamplingFrequencyResist];
}
- (NTIrAmplitude)getIrAmplitude{
    return [(NTBrainBit2*)(self.sensor) IrAmplitude];
}
- (void)setIrAmplitude:(NTIrAmplitude)amp{
    ((NTBrainBit2*)(self.sensor)).IrAmplitude = amp;
}
- (NTRedAmplitude)getRedAmplitude{
    return [(NTBrainBit2*)(self.sensor) RedAmplitude];
}
- (void)setRedAmplitude:(NTRedAmplitude)amp{
    ((NTBrainBit2*)(self.sensor)).RedAmplitude = amp;
}
- (NTSensorAmpMode)getAmpMode{
    return [(NTBrainBit2*)(self.sensor) AmpMode];
}
- (void)setAccSens:(NTSensorAccelerometerSensitivity)accSens{
    ((NTBrainBit2*)self.sensor).AccSens = accSens;
}
- (NTSensorAccelerometerSensitivity)getAccSens{
    return [((NTBrainBit2*)self.sensor) AccSens];
}
- (void)setGyroSens:(NTSensorGyroscopeSensitivity)gyroSens{
    ((NTBrainBit2*)self.sensor).GyroSens = gyroSens;
}
- (NTSensorGyroscopeSensitivity)getGyroSens{
    return [((NTBrainBit2*)self.sensor) GyroSens];
}
- (NSArray<NTEEGChannelInfo*>*_Nullable)getSupportedChannels{
    return [(NTBrainBit2*)self.sensor SupportedChannels];
}
- (NTBrainBit2AmplifierParam *_Nonnull)getAmplifierParamBB2{
    return [(NTBrainBit2*)self.sensor AmplifierParam];
}
- (void)setAmplifierParamBB2:(NTBrainBit2AmplifierParam*_Nonnull)param{
    ((NTBrainBit2*)self.sensor).AmplifierParam = param;
}
- (void)pingNeuroSmart:(NSInteger)marker{
    [(NTBrainBit2*)(self.sensor) PingNeuroSmart: marker];
}

@end
