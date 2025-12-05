#ifndef AFullSensorProtected_h
#define AFullSensorProtected_h

#import "AFullSensor.h"
#import "EventHolder.h"

@interface AFullSensor()


@property (nonatomic,weak,readwrite) EventHolder* _Nullable eventHolder;
@property (nonatomic,strong,readwrite) NTSensor* _Nonnull sensor;
@property (nonatomic,strong,readwrite) NSString* _Nonnull guid;

@end

#endif