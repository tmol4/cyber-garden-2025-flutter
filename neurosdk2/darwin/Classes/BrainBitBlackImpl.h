#ifndef BrainBitBlackImpl_h
#define BrainBitBlackImpl_h
#import "BrainBitImpl.h"


@interface BrainBitBlackImpl : BrainBitImpl

- (instancetype _Nonnull )init:(NSString*_Nonnull)guid
                        sensor:(NTSensor*_Nonnull)sensor
                   eventHolder:(EventHolder * _Nonnull)eventHolder;

@end


#endif /* BrainBitBlackImpl_h */
