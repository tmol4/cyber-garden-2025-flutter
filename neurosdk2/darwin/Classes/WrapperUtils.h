#ifndef Utils_h
#define Utils_h

#if TARGET_OS_OSX
#import "neurosdkOSX.h"
#else
#import <flutter_neurosdk2_ios/neurosdk.h>
#endif

#import "pigeon_messages.g.h"

@interface WrapperUtils : NSObject
+ (PGNFSensorInfo *) PGNFSensorInfoFromNT:(NTSensorInfo *) info;
+ (NTSensorInfo *) NTSensorInfoFromPGNF:(PGNFSensorInfo *) info;
+ (NSDictionary *) JsonSensorInfoFromNT:(NTSensorInfo *) info;

+ (PGNFParameterInfo *) PGNFParametrInfoFromNT:(NTParameterInfo *) param;

+ (PGNFSensorVersion *) PGNFVersionFromNT:(NTSensorVersion *) version;

+ (PGNFCallibriStimulatorMAState *) PGNFMAStateFromNT:(NTCallibriStimulatorMAState *) state;

+ (PGNFCallibriStimulationParams *)PGNFStimulatorParamsFromNT:(NTCallibriStimulationParams *) param;
+ (NTCallibriStimulationParams *) NTStimulatorParamsFromPGNF:(PGNFCallibriStimulationParams *) param;

+ (PGNFCallibriMotionAssistantParams *) PGNFMotionAssistantParamsFromNT:(NTCallibriMotionAssistantParams *) param;
+ (NTCallibriMotionAssistantParams *) NTMotionAssistantParamsFromPGNF:(PGNFCallibriMotionAssistantParams *) param;

+ (PGNFCallibriMotionCounterParam *) PGNFMotionCounterParamFromNT:(NTCallibriMotionCounterParam *) param;
+ (NTCallibriMotionCounterParam *) NTMotionCounterParamFromPGNF:(PGNFCallibriMotionCounterParam *) param;


+ (PGNFEEGChannelInfo *) PGNFChanelInfoFromNT:(NTEEGChannelInfo *) info;


+ (PGNBrainBit2AmplifierParamNative *) PGNFBB2AmplifierParamFromNT:(NTBrainBit2AmplifierParam *) param;
+ (NTBrainBit2AmplifierParam *) NTBB2AmplifierParamFromPGNF:(PGNBrainBit2AmplifierParamNative *) param;

+ (PGNFSensorFamily) PGNFSensorFamilyFromNT:(NTSensorFamily) param;
+ (NTSensorFamily) NTSensorFamilyFromPGNF:(PGNFSensorFamily) param;

+ (PGNFSensorSamplingFrequency) PGNFSensorSamplingFrequencyFromNT:(NTSensorSamplingFrequency) param;
+ (NTSensorSamplingFrequency) NTSensorSamplingFrequencyFromPGNF:(PGNFSensorSamplingFrequency) param;

@end

#endif
