#ifndef BrainBitImpl_h
#define BrainBitImpl_h

#import "AFullSensor.h"
#import "EventHolder.h"


@interface BrainBitImpl : AFullSensor

- (instancetype _Nonnull )init:(NSString*_Nonnull)guid
                        sensor:(NTSensor*_Nonnull)bb
                   eventHolder:(EventHolder* _Nonnull)eventHolder;
@end

#endif /* BrainBitImpl_h */
