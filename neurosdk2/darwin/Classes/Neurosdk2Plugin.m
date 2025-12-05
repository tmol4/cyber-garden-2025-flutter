#import "Neurosdk2Plugin.h"
#import "ScannerHolder.h"
#import "SensorHolder.h"
#import "EventHolder.h"
#import "WrapperUtils.h"

@implementation Neurosdk2Plugin
{
    ScannerHolder* scannerHolder;
    SensorHolder* sensorHolder;
    EventHolder* eventHolder;
    
    bool hasListeners;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        eventHolder = [EventHolder new];
        
        scannerHolder = [[ScannerHolder alloc] init:eventHolder];
        sensorHolder = [[SensorHolder alloc] init:eventHolder];
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    Neurosdk2Plugin *plugin = [[Neurosdk2Plugin alloc] init];
    SetUpPGNNeuroApi(registrar.messenger, plugin);
    [[plugin getEventHolder] activateWithBinaryMessenger:registrar.messenger];
}

- (EventHolder*)getEventHolder {
    return eventHolder;
}

- (void)createScannerFilters:(NSArray<NSNumber *> *)filters completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->scannerHolder createScannerFilters:filters completion:completion];
        }
    });
}

- (void)startScanGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->scannerHolder startScanGuid:guid completion:completion];
        }
    });
}

- (void)stopScanGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->scannerHolder stopScanGuid:guid completion:completion];
        }
    });
}

- (void)closeScannerGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->scannerHolder closeScannerGuid:guid completion:completion];
        }
    });
}

/// @return `nil` only when `error != nil`.
- (NSArray<PGNFSensorInfo *> *)getSensorsGuid:(NSString *)guid error:(FlutterError * _Nullable * _Nonnull)error{
    return [scannerHolder getSensorsGuid:guid error:error];
}

- (void)createSensorGuid:(NSString *)guid sensorInfo:(PGNFSensorInfo *)sensorInfo completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NTSensorInfo* info = [WrapperUtils NTSensorInfoFromPGNF:sensorInfo];
            NTScanner* scanner = [self->scannerHolder getScanner:guid];
            
            if (scanner == nil) @throw [[NSException alloc] initWithName:@"NilScanner" reason:@"Scanner does not exist" userInfo:nil];
            
            NSString *uuid = [[NSUUID UUID] UUIDString];
            NTSensor *sensor = [scanner createSensor:info];
            
            if (sensor == nil) @throw [[NSException alloc] initWithName:@"NilSensor" reason:@"Unable to create sensor" userInfo:nil];
            
            @synchronized (self) {
                [self->sensorHolder addSensor:uuid sensor:sensor];
            }
            
            completion(uuid, nil);
        } @catch (NSException *e) {
            completion(nil, [FlutterError errorWithCode:@"Error while stopping scan:" message:e.description details:nil]);
        }
    });
}

- (void)closeSensorGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->sensorHolder closeSensorGuid:guid completion:completion];
        }
    });
}

- (void)connectSensorGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->sensorHolder connectSensorGuid:guid completion:completion];
        }
    });
}

- (void)disconnectSensorGuid:(NSString *)guid completion:(void (^)(FlutterError *_Nullable))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->sensorHolder disconnectSensorGuid:guid completion:completion];
        }
    });
}

-(NSArray<NSNumber *> *)supportedFeaturesGuid:(NSString *)guid error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder supportedFeaturesGuid:guid error:error];
}

-(NSNumber *)isSupportedFeatureGuid:(NSString *)guid feature:(PGNFSensorFeature)feature error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder isSupportedFeatureGuid:guid feature:feature error:error];
}

-(NSArray<NSNumber *> *)supportedCommandsGuid:(NSString *)guid error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder supportedCommandsGuid:guid error:error];
}

-(NSNumber *)isSupportedCommandGuid:(NSString *)guid command:(PGNFSensorCommand)command error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder isSupportedCommandGuid:guid command:command error:error];
}

-(NSArray<PGNFParameterInfo *> *)supportedParametersGuid:(NSString *)guid error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder supportedParametersGuid:guid error:error];
}

-(NSNumber *)isSupportedParameterGuid:(NSString *)guid parameter:(PGNFSensorParameter)parameter error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder isSupportedParameterGuid:guid parameter:parameter error:error];
}

-(void)execCommandGuid:(NSString *)guid command:(PGNFSensorCommand)command completion:(void (^)(FlutterError * _Nullable))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            return [self->sensorHolder execCommandGuid:guid command:command completion:completion];
        }
    });
}

-(NSString *)getNameGuid:(NSString *)guid error:(FlutterError * _Nullable * _Nonnull)error {
    return [sensorHolder getNameGuid:guid error:error];
}

-(void)setNameGuid:(NSString *)guid name:(NSString *)name error:(FlutterError * _Nullable *_Nonnull)error {
    [sensorHolder setNameGuid:guid name:name error:error];
}

-(PGNFSensorStateBox *)getStateGuid:(NSString *)guid error:(FlutterError * _Nullable *_Nonnull)error {
    return [sensorHolder getStateGuid:guid error:error];
}

- (nullable NSString *)getAddressGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getAddressGuid:guid error:error];
}

- (nullable NSString *)getSerialNumberGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSerialNumberGuid:guid error:error];
}

- (void)setSerialNumberGuid:(NSString *)guid sn:(NSString *)sn error:(FlutterError *_Nullable *_Nonnull)error {
    [sensorHolder setSerialNumberGuid:guid sn:sn error:error];
}

- (nullable NSNumber *)getBattPowerGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getBattPowerGuid:guid error:error];
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSamplingFrequencyGuid:guid error:error];
}

- (PGNFSensorGainBox *_Nullable)getGainGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getGainGuid:guid error:error];
}

- (PGNFSensorDataOffsetBox *_Nullable)getDataOffsetGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getDataOffsetGuid:guid error:error];
}

- (PGNFSensorFirmwareModeBox *_Nullable)getFirmwareModeGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getFirmwareModeGuid:guid error:error];
}

- (nullable PGNFSensorVersion *)getVersionGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getVersionGuid:guid error:error];
}

-(NSNumber *)getChannelsCountGuid:(NSString *)guid error:(FlutterError * _Nullable __autoreleasing *)error {
    return [sensorHolder getChannelsCountGuid:guid error:error];
}

- (PGNFSensorFamilyBox *_Nullable)getSensFamilyGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getSensFamilyGuid:guid error:error];
}

- (PGNFSensorAmpModeBox *_Nullable)getAmpModeGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getAmpModeGuid:guid error:error];
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyResistGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getSamplingFrequencyResistGuid:guid error:error];
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyFPGGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getSamplingFrequencyFPGGuid:guid error:error];
}

- (PGNFIrAmplitudeBox *_Nullable)getIrAmplitudeGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getIrAmplitudeGuid:guid error:error];
}

- (void)setIrAmplitudeGuid:(NSString *)guid amp:(PGNFIrAmplitude)amp error:(FlutterError *_Nullable *_Nonnull)error {
    [sensorHolder setIrAmplitudeGuid:guid amp:amp error:error];
}
- (PGNFRedAmplitudeBox *_Nullable)getRedAmplitudeGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getRedAmplitudeGuid:guid error:error];
}
- (void)setRedAmplitudeGuid:(NSString *)guid amp:(PGNFRedAmplitude)amp error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setRedAmplitudeGuid:guid amp:amp error:error];
}
- (void)pingNeuroSmartGuid:(NSString *)guid marker:(NSInteger)marker completion:(void (^)(FlutterError *_Nullable))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            [self->sensorHolder pingNeuroSmartGuid:guid marker:marker completion:completion];
        }
    });
}
- (void)setGainGuid:(NSString *)guid gain:(PGNFSensorGain)gain error:(FlutterError *_Nullable *_Nonnull)error {
    [sensorHolder setGainGuid:guid gain:gain error:error];
}
- (nullable NSNumber *)isSupportedFilterGuid:(NSString *)guid filter:(PGNFSensorFilter)filter error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder isSupportedFilterGuid:guid filter:filter error:error];
}
- (nullable NSArray<NSNumber *> *)getSupportedFiltersGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getSupportedFiltersGuid:guid error:error];
}
- (nullable NSArray<NSNumber *> *)getHardwareFiltersGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error {
    return [sensorHolder getHardwareFiltersGuid:guid error:error];
}
- (void)setHardwareFiltersGuid:(NSString *)guid filters:(NSArray<NSNumber *> *)filters error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setHardwareFiltersGuid:guid filters:filters error:error];
}
- (void)setFirmwareModeGuid:(NSString *)guid mode:(PGNFSensorFirmwareMode)mode error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setFirmwareModeGuid:guid mode:mode error:error];
}
- (void)setSamplingFrequencyGuid:(NSString *)guid sf:(PGNFSensorSamplingFrequency)sf error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setSamplingFrequencyGuid:guid sf:sf error:error];
}
- (void)setDataOffsetGuid:(NSString *)guid offset:(PGNFSensorDataOffset)offset error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setDataOffsetGuid:guid offset:offset error:error];
}
- (PGNFSensorExternalSwitchInputBox *_Nullable)getExtSwInputGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getExtSwInputGuid:guid error:error];
}
- (void)setExtSwInputGuid:(NSString *)guid extSwInp:(PGNFSensorExternalSwitchInput)extSwInp error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setExtSwInputGuid:guid extSwInp:extSwInp error:error];
}
- (PGNFSensorADCInputBox *_Nullable)getADCInputGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getADCInputGuid:guid error:error];
}
- (void)setADCInputGuid:(NSString *)guid adcInp:(PGNFSensorADCInput)adcInp error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setADCInputGuid:guid adcInp:adcInp error:error];
}
- (nullable PGNFCallibriStimulatorMAState *)getStimulatorMAStateGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getStimulatorMAStateGuid:guid error:error];
}
- (nullable PGNFCallibriStimulationParams *)getStimulatorParamGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getStimulatorParamGuid:guid error:error];
}
- (void)setStimulatorParamGuid:(NSString *)guid param:(PGNFCallibriStimulationParams *)param error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setStimulatorParamGuid:guid param:param error:error];
}
- (nullable PGNFCallibriMotionAssistantParams *)getMotionAssistantParamGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getMotionAssistantParamGuid:guid error:error];
}
- (void)setMotionAssistantParamGuid:(NSString *)guid param:(PGNFCallibriMotionAssistantParams *)param error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setMotionAssistantParamGuid:guid param:param error:error];
}
- (nullable PGNFCallibriMotionCounterParam *)getMotionCounterParamGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getMotionCounterParamGuid:guid error:error];
}
- (void)setMotionCounterParamGuid:(NSString *)guid param:(PGNFCallibriMotionCounterParam *)param error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setMotionCounterParamGuid:guid param:param error:error];
}
- (nullable NSNumber *)getMotionCounterGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getMotionCounterGuid:guid error:error];
}
- (PGNFCallibriColorTypeBox *_Nullable)getColorGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getColorGuid:guid error:error];
}
- (nullable NSNumber *)getMEMSCalibrateStateGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getMEMSCalibrateStateGuid:guid error:error];
}
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyRespGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSamplingFrequencyRespGuid:guid error:error];
}
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyEnvelopeGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSamplingFrequencyEnvelopeGuid:guid error:error];
}
- (PGNCallibriSignalTypeBox *_Nullable)getSignalTypeGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSignalTypeGuid:guid error:error];
}
- (void)setSignalTypeGuid:(NSString *)guid type:(PGNCallibriSignalType)type error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setSignalTypeGuid:guid type:type error:error];
}
- (PGNFCallibriElectrodeStateBox *_Nullable)getElectrodeStateGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getElectrodeStateGuid:guid error:error];
}
- (PGNFSensorAccelerometerSensitivityBox *_Nullable)getAccSensGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getAccSensGuid:guid error:error];
}
- (void)setAccSensGuid:(NSString *)guid accSens:(PGNFSensorAccelerometerSensitivity)accSens error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setAccSensGuid:guid accSens:accSens error:error];
}
- (PGNFSensorGyroscopeSensitivityBox *_Nullable)getGyroSensGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getGyroSensGuid:guid error:error];
}
- (void)setGyroSensGuid:(NSString *)guid gyroSens:(PGNFSensorGyroscopeSensitivity)gyroSens error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setGyroSensGuid:guid gyroSens:gyroSens error:error];
}
- (PGNFSensorSamplingFrequencyBox *_Nullable)getSamplingFrequencyMEMSGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSamplingFrequencyMEMSGuid:guid error:error];
}
- (nullable NSArray<PGNFEEGChannelInfo *> *)getSupportedChannelsGuid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getSupportedChannelsGuid:guid error:error];
}
- (nullable PGNBrainBit2AmplifierParamNative *)getAmplifierParamBB2Guid:(NSString *)guid error:(FlutterError *_Nullable *_Nonnull)error{
    return [sensorHolder getAmplifierParamBB2Guid:guid error:error];
}
- (void)setAmplifierParamBB2Guid:(NSString *)guid param:(PGNBrainBit2AmplifierParamNative *)param error:(FlutterError *_Nullable *_Nonnull)error{
    [sensorHolder setAmplifierParamBB2Guid:guid param:param error:error];
}


@end
