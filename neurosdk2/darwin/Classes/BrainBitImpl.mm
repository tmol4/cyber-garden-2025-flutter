#import <Foundation/Foundation.h>
#import "BrainBitImpl.h"
#import "AFullSensorProtected.h"
#import "Constants.h"

@implementation BrainBitImpl

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
    __weak BrainBitImpl* weakSelf = self;
    [((NTBrainBit*)(self.sensor)) setSignalDataCallbackBrainBit:^(NSArray<NTBrainBitSignalData *> * _Nonnull signals) {
        NSMutableArray* signalsArray = [[NSMutableArray alloc] initWithCapacity: [signals count]];
        @try {
            for (NTBrainBitSignalData* signal in signals) {
                NSDictionary *signalDic = @{ @"Marker" : [NSNumber numberWithInt:signal.Marker],
                                             @"PackNum" : [NSNumber numberWithInt:signal.PackNum],
                                             @"O1" : signal.O1,
                                             @"O2" : signal.O2,
                                             @"T3" : signal.T3,
                                             @"T4" : signal.T4
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

    [((NTBrainBit*)(self.sensor)) setResistCallbackBrainBit:^(NTBrainBitResistData * _Nonnull resist) {
        @try {
            NSDictionary *resistDic = @{ @"O1" : resist.O1,
                                         @"O2" : resist.O2,
                                         @"T3" : resist.T3,
                                         @"T4" : resist.T4};
            NSMutableDictionary* res = [NSMutableDictionary new];
            [res setObject:weakSelf.guid forKey:GUID_ID];
            [res setObject:resistDic forKey:DATA_ID];
            
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
}
- (void) removeCallbacks{
    [super removeCallbacks];
    [((NTBrainBit*)(self.sensor)) setSignalDataCallbackBrainBit:nil];
    [((NTBrainBit*)(self.sensor)) setResistCallbackBrainBit:nil];
}

- (void)setGain:(NTSensorGain)gain{
    ((NTBrainBit*)self.sensor).Gain = gain;
}

@end
