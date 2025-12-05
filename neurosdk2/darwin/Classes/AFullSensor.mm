#import "AFullSensor.h"
#import "AFullSensorProtected.h"
#import "Constants.h"

@implementation AFullSensor

- (void) addCallbacks{
    __weak AFullSensor* weakSelf = self;
    [_sensor setConnectionStateCallback:^(NTSensorState state) {
        NSMutableDictionary* res = [NSMutableDictionary new];
        [res setObject:weakSelf.guid forKey:GUID_ID];
        NSDictionary *data = @{ @"state" : [NSNumber numberWithUnsignedInt:state]};
        [res setObject:data forKey:DATA_ID];
        
        FlutterEventSink sink = weakSelf.eventHolder.sensorStateEventSink;
        if (sink) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sink(res);
            });
        }
        
    }];
    [_sensor setBatteryCallback:^(NSNumber * _Nonnull power) {
        NSMutableDictionary* res = [NSMutableDictionary new];
        [res setObject:weakSelf.guid forKey:GUID_ID];
        NSDictionary *data = @{ @"power" : power};
        [res setObject:data forKey:DATA_ID];
        FlutterEventSink sink = weakSelf.eventHolder.batteryEventSink;
        if (sink) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sink(res);
            });
        }
    }];
}
- (void) removeCallbacks{
    [_sensor setConnectionStateCallback:nil];
    [_sensor setBatteryCallback:nil];
}

- (void)closeSensor{
    [self removeCallbacks];
    _sensor = nil;
}

- (void)connectSensor{
    [self.sensor Connect];
}

- (void)disconnectSensor{
    [self.sensor Disconnect];
}

- (void)execCommand:(NTSensorCommand)command{
    [self.sensor ExecCommand:command];
}

- (NSString *_Nonnull)getAddress{
    return [_sensor Address];
}

- (NSNumber *_Nonnull)getBattPower{
    return [_sensor BattPower];
}

- (NSNumber *_Nonnull)getChannelsCount{
    return [_sensor ChannelsCount];
}

- (NTSensorDataOffset)getDataOffset{
    return [_sensor DataOffset];
}

- (NTSensorFirmwareMode)getFirmwareMode{
    return [_sensor FirmwareMode];
}

- (NTSensorGain)getGain{
    return [_sensor Gain];
}

- (NSString *_Nonnull)getName{
    return [_sensor Name];
}

- (NTSensorSamplingFrequency)getSamplingFrequency{
    return [_sensor SamplingFrequency];
}

- (NTSensorFamily)getSensFamily{
    return [_sensor SensFamily];
}

- (NSString *_Nonnull)getSerialNumber{
    return [_sensor SerialNumber];
}

- (NTSensorState)getState{
    return _sensor.State;
}

- (NTSensorVersion *_Nonnull)getVersion{
    return [_sensor Version];
}

- (NSNumber *_Nonnull)isSupportedCommand:(NTSensorCommand)command{
    BOOL supported = [_sensor IsSupportedCommand:command];
    return [[NSNumber alloc] initWithBool:supported];
}

- (NSNumber *_Nonnull)isSupportedFeature:(NTSensorFeature)feature{
    BOOL supported = [_sensor IsSupportedFeature:feature];
    return [[NSNumber alloc] initWithBool:supported];
}

- (NSNumber *_Nonnull)isSupportedParameter:(NTSensorParameter)parameter{
    BOOL supported = [_sensor IsSupportedParameter:parameter];
    return [[NSNumber alloc] initWithBool:supported];
}

- (void)setName:(NSString *_Nonnull)name{
    _sensor.Name = name;
}

- (void)setSerialNumber:(NSString *_Nonnull)sn{
    _sensor.SerialNumber = sn;
}

- (NSArray<NSNumber *> *_Nonnull)supportedCommands{
    return [_sensor Commands];
}

- (NSArray<NSNumber *> *_Nonnull)supportedFeatures{
    return [_sensor Features];
}

- (NSArray<NTParameterInfo *> *_Nonnull)supportedParameters{
    return _sensor.Parameters;
}

// throwable


- (NTSensorAmpMode)getAmpMode {
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorSamplingFrequency)getSamplingFrequencyResist{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}


- (NTSensorSamplingFrequency)getSamplingFrequencyFPG{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTIrAmplitude)getIrAmplitude{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTRedAmplitude)getRedAmplitude{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setIrAmplitude:(NTIrAmplitude)amp{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setRedAmplitude:(NTRedAmplitude)amp{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)pingNeuroSmart:(NSInteger)marker{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}


- (NSNumber * _Nonnull)isSupportedFilter:(NTSensorFilter)filter {
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)getSupportedFilters:(NSMutableArray<NSNumber *> *_Nonnull)result{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)getHardwareFilters:(NSMutableArray<NSNumber *> *_Nonnull)result{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorExternalSwitchInput)getExtSwInput{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorADCInput)getADCInput{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriStimulatorMAState* _Nullable)getStimulatorMAState{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriStimulationParams* _Nullable)getStimulatorParam{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriMotionAssistantParams* _Nullable)getMotionAssistantParam {
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriMotionCounterParam* _Nullable)getMotionCounterParam{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NSNumber *_Nonnull)getMotionCounter{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriColorType)getColor{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NSNumber *_Nonnull)getMEMSCalibrateState{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorSamplingFrequency)getSamplingFrequencyResp{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorSamplingFrequency)getSamplingFrequencyEnvelope {
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriSignalType)getSignalType{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTCallibriElectrodeState)getElectrodeState {
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setHardwareFilters:(NSArray *_Nonnull)filters{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setFirmwareMode:(NTSensorFirmwareMode)mode{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setSamplingFrequency:(NTSensorSamplingFrequency)sf{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setGain:(NTSensorGain)gain{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setDataOffset:(NTSensorDataOffset)offset{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setExtSwInput:(NTSensorExternalSwitchInput)extSwInp{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setADCInput:(NTSensorADCInput)adcInp{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setStimulatorParam:(NTCallibriStimulationParams*_Nonnull)param{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setMotionAssistantParam:(NTCallibriMotionAssistantParams*_Nonnull)param{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setMotionCounterParam:(NTCallibriMotionCounterParam*_Nonnull)param{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setSignalType:(NTCallibriSignalType)type{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}


- (NTSensorAccelerometerSensitivity)getAccSens{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorGyroscopeSensitivity)getGyroSens{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NTSensorSamplingFrequency)getSamplingFrequencyMEMS{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setAccSens:(NTSensorAccelerometerSensitivity)accSens{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setGyroSens:(NTSensorGyroscopeSensitivity)gyroSens{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}


- (NSNumber *_Nonnull)getSurveyId{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (NSDictionary *_Nonnull)getAmplifierParam{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setSurveyId:(NSNumber *_Nonnull)id{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setAmplifierParam:(NTNeuroEEGAmplifierParam*_Nonnull)param{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}


- (NSArray<NTEEGChannelInfo*>*_Nullable)getSupportedChannels{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}



- (NTBrainBit2AmplifierParam *_Nonnull)getAmplifierParamBB2{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setAmplifierParamBB2:(NTBrainBit2AmplifierParam*_Nonnull)param{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}


- (NSDictionary *_Nonnull)getAmplifierParamHP2{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

- (void)setAmplifierParamHP2:(NTHeadphones2AmplifierParam*_Nonnull)param{
    @throw([NSException exceptionWithName:@"UnsupportedOperationException" reason:@"Unsupported Sensor parameter" userInfo:nil]);
}

@end
