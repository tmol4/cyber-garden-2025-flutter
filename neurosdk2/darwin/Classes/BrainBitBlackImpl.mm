#import <Foundation/Foundation.h>
#import "BrainBitBlackImpl.h"
#import "Constants.h"
#import "AFullSensorProtected.h"

@implementation BrainBitBlackImpl

- (instancetype)init:(NSString *)guid
              sensor:(id)bb
         eventHolder:(EventHolder * _Nonnull)eventHolder{
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
    __weak BrainBitBlackImpl* weakSelf = self;
    [((NTBrainBitBlack*)(self.sensor)) setFPGDataCallbackNeuroSmart:^(NSArray<NTFPGData *> * _Nonnull FPGData) {
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
    [((NTBrainBitBlack*)(self.sensor)) setMEMSDataCallback:^(NSArray<NTMEMSData *> * _Nonnull MEMSData) {
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
    [((NTBrainBitBlack*)(self.sensor)) setAmpModeCallback:^(NTSensorAmpMode ampMode) {
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
    [((NTBrainBitBlack*)(self.sensor)) setFPGDataCallbackNeuroSmart:nil];
    [((NTBrainBitBlack*)(self.sensor)) setMEMSDataCallback:nil];
    [((NTBrainBitBlack*)(self.sensor)) setAmpModeCallback:nil];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyMEMS{
    return [(NTBrainBitBlack*)(self.sensor) SamplingFrequencyMEMS];
}
- (NTSensorSamplingFrequency)getSamplingFrequencyFPG{
    return [(NTBrainBitBlack*)(self.sensor) SamplingFrequencyFPG];
}

- (NTSensorSamplingFrequency)getSamplingFrequencyResist{
    return [(NTBrainBitBlack*)(self.sensor) SamplingFrequencyResist];
}
- (void)setIrAmplitude:(NTIrAmplitude)amp{
    ((NTBrainBitBlack*)(self.sensor)).IrAmplitudeHeadband = amp;
}
- (NTRedAmplitude)getRedAmplitude{
    return [(NTBrainBitBlack*)(self.sensor) RedAmplitudeHeadband];
}
- (void)setRedAmplitude:(NTRedAmplitude)amp{
    ((NTBrainBitBlack*)(self.sensor)).RedAmplitudeHeadband = amp;
}
- (NTSensorAmpMode)getAmpMode{
    return [(NTBrainBitBlack*)(self.sensor) AmpMode];
}
- (void)setAccSens:(NTSensorAccelerometerSensitivity)accSens{
    ((NTBrainBitBlack*)self.sensor).AccSens = accSens;
}
- (NTSensorAccelerometerSensitivity)getAccSens{
    return [((NTBrainBitBlack*)self.sensor) AccSens];
}
- (void)setGyroSens:(NTSensorGyroscopeSensitivity)gyroSens{
    ((NTBrainBitBlack*)self.sensor).GyroSens = gyroSens;
}
- (NTSensorGyroscopeSensitivity)getGyroSens{
    return [((NTBrainBitBlack*)self.sensor) GyroSens];
}
- (void)pingNeuroSmart:(NSInteger)marker{
    [(NTBrainBitBlack*)(self.sensor) PingNeuroSmart: marker];
}


@end
