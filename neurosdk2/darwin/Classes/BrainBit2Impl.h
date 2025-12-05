#ifndef BrainBit2Impl_h
#define BrainBit2Impl_h

#import "EventHolder.h"
#import "AFullSensor.h"


@interface BrainBit2Impl : AFullSensor

- (instancetype _Nonnull )init:(NSString*_Nonnull)guid
                        sensor:(NTSensor*_Nonnull)bb
                   eventHolder:(EventHolder * _Nonnull)eventHolder;
@end

#endif /* BrainBit2Impl_h */
