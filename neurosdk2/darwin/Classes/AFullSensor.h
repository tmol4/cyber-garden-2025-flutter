#ifndef AFullSensor_h
#define AFullSensor_h

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#import "neurosdkOSX.h"
#else
#import <Flutter/Flutter.h>
#import <flutter_neurosdk2_ios/neurosdk.h>
#endif

@interface AFullSensor : NSObject

- (void) addCallbacks;
- (void) removeCallbacks;

- (void)closeSensor;

- (void)connectSensor;

- (void)disconnectSensor;

- (void)execCommand:(NTSensorCommand)command;

- (NSString *_Nonnull)getAddress;

- (NSNumber *_Nonnull)getBattPower;

- (NSNumber *_Nonnull)getChannelsCount;

- (NTSensorFirmwareMode)getFirmwareMode;

- (NSString *_Nonnull)getName;

- (NTSensorSamplingFrequency)getSamplingFrequency;

- (NTSensorFamily)getSensFamily;

- (NSString *_Nonnull)getSerialNumber;

- (NTSensorState)getState;

- (NTSensorVersion *_Nonnull)getVersion;

- (NSNumber *_Nonnull)isSupportedCommand:(NTSensorCommand)command;

- (NSNumber *_Nonnull)isSupportedFeature:(NTSensorFeature)feature;

- (NSNumber *_Nonnull)isSupportedParameter:(NTSensorParameter)parameter;

- (void)setName:(NSString *_Nonnull)name;

- (void)setSerialNumber:(NSString *_Nonnull)sn;

- (NSArray<NSNumber *> *_Nonnull)supportedFeatures;

- (NSArray<NTParameterInfo*> *_Nonnull)supportedParameters;

- (NSArray<NSNumber *> *_Nonnull)supportedCommands;

- (NTSensorAmpMode)getAmpMode;

- (NTSensorSamplingFrequency)getSamplingFrequencyResist;

- (NTSensorSamplingFrequency)getSamplingFrequencyFPG;

- (NTIrAmplitude)getIrAmplitude;

- (NTRedAmplitude)getRedAmplitude;

- (void)setRedAmplitude:(NTRedAmplitude)amp;

- (void)setIrAmplitude:(NTIrAmplitude)amp;

- (void)pingNeuroSmart:(NSInteger)marker;

- (NSNumber *_Nonnull)isSupportedFilter:(NTSensorFilter)filter;

- (NTSensorADCInput)getADCInput;

- (NTCallibriColorType)getColor;

- (NTSensorDataOffset)getDataOffset;

- (NTSensorExternalSwitchInput)getExtSwInput;

- (NTSensorGain)getGain;

- (NSNumber *_Nonnull)getMotionCounter;

- (NSNumber *_Nonnull)getMEMSCalibrateState;

- (NTSensorSamplingFrequency)getSamplingFrequencyResp;

- (NTSensorSamplingFrequency)getSamplingFrequencyEnvelope;

- (NTCallibriElectrodeState)getElectrodeState;

- (NTCallibriSignalType)getSignalType;

- (NTCallibriStimulatorMAState* _Nullable)getStimulatorMAState;

- (NTCallibriStimulationParams* _Nullable)getStimulatorParam;

- (NTCallibriMotionAssistantParams* _Nullable)getMotionAssistantParam;

- (NTCallibriMotionCounterParam* _Nullable)getMotionCounterParam;

- (void)getSupportedFilters:(NSMutableArray<NSNumber *> *_Nonnull)result;

- (void)getHardwareFilters:(NSMutableArray<NSNumber *> *_Nonnull)result;

- (void)setGain:(NTSensorGain)gain;

- (void)setADCInput:(NTSensorADCInput)adcInp;

- (void)setDataOffset:(NTSensorDataOffset)offset;

- (void)setFirmwareMode:(NTSensorFirmwareMode)mode;

- (void)setSamplingFrequency:(NTSensorSamplingFrequency)sf;

- (void)setExtSwInput:(NTSensorExternalSwitchInput)extSwInp;

- (void)setMotionAssistantParam:(NTCallibriMotionAssistantParams*_Nonnull)param;

- (void)setMotionCounterParam:(NTCallibriMotionCounterParam*_Nonnull)param;

- (void)setHardwareFilters:(NSArray *_Nonnull)filters;

- (void)setSignalType:(NTCallibriSignalType)type;

- (void)setStimulatorParam:(NTCallibriStimulationParams*_Nonnull)param;


- (NTSensorAccelerometerSensitivity)getAccSens;

- (NTSensorGyroscopeSensitivity)getGyroSens;

- (void)setAccSens:(NTSensorAccelerometerSensitivity)accSens;

- (void)setGyroSens:(NTSensorGyroscopeSensitivity)gyroSens;

- (NTSensorSamplingFrequency)getSamplingFrequencyMEMS;


- (NSNumber *_Nonnull)getSurveyId;

- (void)setSurveyId:(NSNumber*_Nonnull)id;

- (NSArray<NTEEGChannelInfo*>*_Nullable)getSupportedChannels;



- (NTBrainBit2AmplifierParam *_Nonnull)getAmplifierParamBB2;

- (void)setAmplifierParamBB2:(NTBrainBit2AmplifierParam*_Nonnull)param;

@end


#endif
