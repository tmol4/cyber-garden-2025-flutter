#ifndef Neurosdk2Plugin_h
#define Neurosdk2Plugin_h

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#import "neurosdkOSX.h"
#else
#import <Flutter/Flutter.h>
#import <flutter_neurosdk2_ios/neurosdk.h>
#endif

#import "pigeon_messages.g.h"

@interface Neurosdk2Plugin : NSObject<FlutterPlugin, PGNNeuroApi>
@end

#endif
