#ifndef CallibriImpl_h
#define CallibriImpl_h

#import "EventHolder.h"
#import "AFullSensor.h"

@interface CallibriImpl : AFullSensor

- (nonnull instancetype)init:(NSString*_Nonnull)guid
                        sensor:(NTSensor*_Nonnull)sensor
                   eventHolder:(EventHolder* _Nonnull)eventHolder;

@end

#endif /* CallibriImpl_h */
