#ifndef SensorHolder_h
#define SensorHolder_h

#if TARGET_OS_OSX
#import "neurosdkOSX.h"
#else
#import <flutter_neurosdk2_ios/neurosdk.h>
#endif

#import "AFullSensor.h"
#import "pigeon_messages.g.h"

#import "CallibriImpl.h"


#import "BrainBitImpl.h"


#import "BrainBitBlackImpl.h"


#import "BrainBit2Impl.h"


@interface SensorHolder : NSObject

- (nonnull instancetype)init:(EventHolder* _Nonnull) eventHolder;

-(void) addSensor:(NSString*_Nonnull)guid sensor:(NTSensor*_Nonnull)sensor;
- (void)closeSensorGuid:(NSString * _Nonnull)guid completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;
- (void)connectSensorGuid:(NSString * _Nonnull)guid completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;
- (void)disconnectSensorGuid:(NSString * _Nonnull)guid completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;
-(NSArray<NSNumber *> * _Nullable)supportedFeaturesGuid:(NSString * _Nonnull)guid error:(FlutterError * _Nullable * _Nonnull)error;
-(NSNumber * _Nullable)isSupportedFeatureGuid:(NSString * _Nonnull)guid feature:(PGNFSensorFeature)feature error:(FlutterError * _Nullable * _Nonnull)error;
-(NSArray<NSNumber *> * _Nullable)supportedCommandsGuid:(NSString * _Nonnull)guid error:(FlutterError * _Nullable * _Nonnull)error;
-(NSNumber * _Nullable)isSupportedCommandGuid:(NSString * _Nonnull)guid command:(PGNFSensorCommand)command error:(FlutterError * _Nullable * _Nonnull)error;
-(NSArray<PGNFParameterInfo *> * _Nullable)supportedParametersGuid:(NSString * _Nonnull)guid error:(FlutterError * _Nullable * _Nonnull)error;
-(NSNumber * _Nullable)isSupportedParameterGuid:(NSString * _Nonnull)guid parameter:(PGNFSensorParameter)parameter error:(FlutterError * _Nullable * _Nonnull)error ;
-(void)execCommandGuid:(NSString * _Nonnull)guid command:(PGNFSensorCommand)command completion:(void (^ _Nonnull)(FlutterError * _Nullable))completion;
-(NSString * _Nullable)getNameGuid:(NSString * _Nonnull)guid error:(FlutterError * _Nullable * _Nonnull)error;
-(void)setNameGuid:(NSString * _Nonnull)guid name:(NSString * _Nullable)name error:(FlutterError * _Nullable * _Nonnull)error;
-(PGNFSensorStateBox * _Nullable)getStateGuid:(NSString * _Nonnull)guid error:(FlutterError * _Nullable *_Nonnull)error;
- (nullable NSString *)getAddressGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSString *)getSerialNumberGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setSerialNumberGuid:(NSString * _Nonnull)guid sn:(NSString * _Nullable)sn error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSNumber *)getBattPowerGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorGainBox *_Nullable)getGainGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorDataOffsetBox *_Nullable)getDataOffsetGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorFirmwareModeBox *_Nullable)getFirmwareModeGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable PGNFSensorVersion *)getVersionGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;

- (nullable NSNumber *)getChannelsCountGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorFamilyBox *_Nullable)getSensFamilyGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;

- (PGNFSensorAmpModeBox *_Nullable)getAmpModeGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyResistGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;


- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyFPGGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFIrAmplitudeBox *_Nullable)getIrAmplitudeGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setIrAmplitudeGuid:(NSString * _Nonnull)guid amp:(PGNFIrAmplitude)amp error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFRedAmplitudeBox *_Nullable)getRedAmplitudeGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setRedAmplitudeGuid:(NSString * _Nonnull)guid amp:(PGNFRedAmplitude)amp error:(FlutterError *_Nullable *_Nonnull)error;
- (void)pingNeuroSmartGuid:(NSString * _Nonnull)guid marker:(NSInteger)marker completion:(void (^ _Nonnull)(FlutterError *_Nullable))completion;

- (void)setFirmwareModeGuid:(NSString * _Nonnull)guid mode:(PGNFSensorFirmwareMode)mode error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setGainGuid:(NSString * _Nonnull)guid gain:(PGNFSensorGain)gain error:(FlutterError *_Nullable *_Nonnull)error;

- (nullable NSNumber *)isSupportedFilterGuid:(NSString * _Nonnull)guid filter:(PGNFSensorFilter)filter error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSArray<NSNumber *> *)getSupportedFiltersGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSArray<NSNumber *> *)getHardwareFiltersGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setHardwareFiltersGuid:(NSString * _Nonnull)guid filters:(NSArray<NSNumber *> * _Nullable)filters error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setSamplingFrequencyGuid:(NSString * _Nonnull)guid sf:(PGNFSensorSamplingFrequency)sf error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setDataOffsetGuid:(NSString * _Nonnull)guid offset:(PGNFSensorDataOffset)offset error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorExternalSwitchInputBox *_Nullable)getExtSwInputGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setExtSwInputGuid:(NSString * _Nonnull)guid extSwInp:(PGNFSensorExternalSwitchInput)extSwInp error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorADCInputBox *_Nullable)getADCInputGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setADCInputGuid:(NSString * _Nonnull)guid adcInp:(PGNFSensorADCInput)adcInp error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable PGNFCallibriStimulatorMAState *)getStimulatorMAStateGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable PGNFCallibriStimulationParams *)getStimulatorParamGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setStimulatorParamGuid:(NSString * _Nonnull)guid param:(PGNFCallibriStimulationParams * _Nonnull)param error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable PGNFCallibriMotionAssistantParams *)getMotionAssistantParamGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setMotionAssistantParamGuid:(NSString * _Nonnull)guid param:(PGNFCallibriMotionAssistantParams * _Nonnull)param error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable PGNFCallibriMotionCounterParam *)getMotionCounterParamGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setMotionCounterParamGuid:(NSString * _Nonnull)guid param:(PGNFCallibriMotionCounterParam * _Nonnull)param error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSNumber *)getMotionCounterGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFCallibriColorTypeBox *_Nullable)getColorGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSNumber *)getMEMSCalibrateStateGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyRespGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyEnvelopeGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNCallibriSignalTypeBox *_Nullable)getSignalTypeGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setSignalTypeGuid:(NSString * _Nonnull)guid type:(PGNCallibriSignalType)type error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFCallibriElectrodeStateBox *_Nullable)getElectrodeStateGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;


- (PGNFSensorAccelerometerSensitivityBox *_Nullable)getAccSensGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setAccSensGuid:(NSString * _Nonnull)guid accSens:(PGNFSensorAccelerometerSensitivity)accSens error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorGyroscopeSensitivityBox *_Nullable)getGyroSensGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setGyroSensGuid:(NSString * _Nonnull)guid gyroSens:(PGNFSensorGyroscopeSensitivity)gyroSens error:(FlutterError *_Nullable *_Nonnull)error;
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyMEMSGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;


- (nullable NSArray<PGNFEEGChannelInfo *> *)getSupportedChannelsGuid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable PGNBrainBit2AmplifierParamNative *)getAmplifierParamBB2Guid:(NSString * _Nonnull)guid error:(FlutterError *_Nullable *_Nonnull)error;
- (void)setAmplifierParamBB2Guid:(NSString * _Nonnull)guid param:(PGNBrainBit2AmplifierParamNative * _Nonnull)param error:(FlutterError *_Nullable *_Nonnull)error;

@end

#endif /* SensorHolder_h */
