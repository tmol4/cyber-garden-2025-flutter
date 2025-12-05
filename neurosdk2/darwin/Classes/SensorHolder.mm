#import "SensorHolder.h"
#import "WrapperUtils.h"

#import <Foundation/Foundation.h>

@implementation SensorHolder {
    NSMutableDictionary<NSString *, AFullSensor *> *_sensors;
    EventHolder *_eventHolder;
}

- (nonnull instancetype)init:(EventHolder *_Nonnull)eventHolder {
    self = [super init];
    if (self) {
        _sensors = [NSMutableDictionary new];
        _eventHolder = eventHolder;
    }

    return self;
}

- (void)addSensor:(NSString *)guid sensor:(NTSensor *)sensor {
    NTSensorFamily family = [sensor SensFamily];
    switch (family) {
    case NTSensorFamilyLECallibri:
    case NTSensorFamilyLEKolibri:
        [_sensors setObject:[[CallibriImpl alloc] init:guid
                                                sensor:sensor
                                           eventHolder:_eventHolder]
                     forKey:guid];
        break;
    case NTSensorFamilyLEBrainBit:
        [_sensors setObject:[[BrainBitImpl alloc] init:guid
                                                sensor:sensor
                                           eventHolder:_eventHolder]
                     forKey:guid];
        break;
    case NTSensorFamilyLEBrainBitBlack:
        [_sensors setObject:[[BrainBitBlackImpl alloc] init:guid
                                                     sensor:sensor
                                                eventHolder:_eventHolder]
                     forKey:guid];
        break;
        // rnend
        // rnst @BRAINBIT2_BLE_ON@
    case NTSensorFamilyLEBrainBit2:
    case NTSensorFamilyLEBrainBitFlex:
    case NTSensorFamilyLEBrainBitPro:
        [_sensors setObject:[[BrainBit2Impl alloc] init:guid
                                                 sensor:sensor
                                            eventHolder:_eventHolder]
                     forKey:guid];
        break;
    default:
        break;
    }
}

- (void)closeSensorGuid:(NSString *)guid
             completion:(void (^)(FlutterError *_Nullable))completion {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor closeSensor];
        [_sensors removeObjectForKey:guid];
        completion(nil);
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        completion([FlutterError errorWithCode:@"Error while closing sensor:"
                                       message:exception.description
                                       details:nil]);
    }
}

- (void)connectSensorGuid:(NSString *)guid
               completion:(void (^)(FlutterError *_Nullable))completion {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor connectSensor];
        completion(nil);
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        completion([FlutterError errorWithCode:@"Error while connecting sensor:"
                                       message:exception.description
                                       details:nil]);
    }
}

- (void)disconnectSensorGuid:(NSString *)guid
                  completion:(void (^)(FlutterError *_Nullable))completion {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor disconnectSensor];
        completion(nil);
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        completion([FlutterError
            errorWithCode:@"Error while disconnecting sensor:"
                  message:exception.description
                  details:nil]);
    }
}

- (NSArray<NSNumber *> *)
    supportedFeaturesGuid:(NSString *)guid
                    error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor supportedFeatures];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported features:"
                  message:exception.description
                  details:nil];
        return nil;
    }
}

- (NSNumber *)isSupportedFeatureGuid:(NSString *)guid
                             feature:(PGNFSensorFeature)feature
                               error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor isSupportedFeature:(NTSensorFeature)feature];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported features:"
                  message:exception.description
                  details:nil];
        return nil;
    }
}

- (NSArray<NSNumber *> *)supportedCommandsGuid:(NSString *)guid
                                         error:
                                             (FlutterError *_Nullable *)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor supportedCommands];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported commands:"
                  message:exception.description
                  details:nil];
        return nil;
    }
}

- (NSNumber *)isSupportedCommandGuid:(NSString *)guid
                             command:(PGNFSensorCommand)command
                               error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor isSupportedCommand:(NTSensorCommand)command];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported commands:"
                  message:exception.description
                  details:nil];
    }

    return nil;
}

- (NSArray<PGNFParameterInfo *> *)
    supportedParametersGuid:(NSString *)guid
                      error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        NSMutableArray<PGNFParameterInfo *> *result = [NSMutableArray new];
        AFullSensor *sensor = [_sensors objectForKey:guid];

        for (NTParameterInfo *param in [sensor supportedParameters]) {
            [result addObject:[WrapperUtils PGNFParametrInfoFromNT:param]];
        }

        return result;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading supported params:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (NSNumber *)isSupportedParameterGuid:(NSString *)guid
                             parameter:(PGNFSensorParameter)parameter
                                 error:
                                     (FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor isSupportedParameter:(NTSensorParameter)parameter];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading supported params:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (void)execCommandGuid:(NSString *)guid
                command:(PGNFSensorCommand)command
             completion:(void (^)(FlutterError *_Nullable))completion {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor execCommand:(NTSensorCommand)command];
        completion(nil);
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        completion([FlutterError errorWithCode:@"Error while executing command:"
                                       message:exception.description
                                       details:nil]);
    }
}

- (NSString *)getNameGuid:(NSString *)guid
                    error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getName];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while reading sensor name:"
                                     message:exception.description
                                     details:nil];
    }
    return nil;
}

- (void)setNameGuid:(NSString *)guid
               name:(NSString *)name
              error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setName:name];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while updating sensor name:"
                                message:exception.description
                                details:nil];
    }
}

- (PGNFSensorStateBox *)getStateGuid:(NSString *)guid
                               error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorStateBox alloc]
            initWithValue:(PGNFSensorState)[sensor getState]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor state:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (nullable NSString *)getAddressGuid:(NSString *)guid
                                error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getAddress];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor address:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (nullable NSString *)getSerialNumberGuid:(NSString *)guid
                                     error:(FlutterError *_Nullable *_Nonnull)
                                               error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getSerialNumber];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor serial number:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (void)setSerialNumberGuid:(NSString *)guid
                         sn:(NSString *)sn
                      error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setSerialNumber:sn];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting sensor serial number:"
                  message:exception.description
                  details:nil];
    }
}

- (nullable NSNumber *)getBattPowerGuid:(NSString *)guid
                                  error:
                                      (FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getBattPower];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor battery:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)
    getSamplingFrequencyGuid:(NSString *)guid
                       error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorSamplingFrequencyBox alloc]
            initWithValue:[WrapperUtils PGNFSensorSamplingFrequencyFromNT:[sensor getSamplingFrequency]]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor sampling frequency:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (PGNFSensorGainBox *_Nullable)getGainGuid:(NSString *)guid
                                      error:(FlutterError *_Nullable *_Nonnull)
                                                error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorGainBox alloc]
            initWithValue:(PGNFSensorGain)[sensor getGain]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while reading sensor gain:"
                                     message:exception.description
                                     details:nil];
    }

    return nil;
}

- (PGNFSensorDataOffsetBox *_Nullable)
    getDataOffsetGuid:(NSString *)guid
                error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorDataOffsetBox alloc]
            initWithValue:(PGNFSensorDataOffset)[sensor getDataOffset]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor data offset:"
                  message:exception.description
                  details:nil];
    }

    return nil;
}

- (PGNFSensorFirmwareModeBox *_Nullable)
    getFirmwareModeGuid:(NSString *)guid
                  error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorFirmwareModeBox alloc]
            initWithValue:(PGNFSensorFirmwareMode)[sensor getFirmwareMode]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor firmware:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (nullable PGNFSensorVersion *)
    getVersionGuid:(NSString *)guid
             error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [WrapperUtils PGNFVersionFromNT:[sensor getVersion]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor version:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (nullable NSNumber *)getChannelsCountGuid:(NSString *)guid
                                      error:(FlutterError *_Nullable *_Nonnull)
                                                error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getChannelsCount];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor channels count:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (PGNFSensorFamilyBox *_Nullable)
    getSensFamilyGuid:(NSString *)guid
                error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorFamilyBox alloc]
            initWithValue:[WrapperUtils
                              PGNFSensorFamilyFromNT:[sensor getSensFamily]]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor family:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (PGNFSensorAmpModeBox *_Nullable)
    getAmpModeGuid:(NSString *)guid
             error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorAmpModeBox alloc]
            initWithValue:(PGNFSensorAmpMode)[sensor getAmpMode]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading sensor AMP mode:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)
    getSamplingFrequencyResistGuid:(NSString *)guid
                             error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorSamplingFrequencyBox alloc]
                initWithValue:[WrapperUtils PGNFSensorSamplingFrequencyFromNT:[sensor getSamplingFrequencyResist]]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:
                @"Error while reading sensor resist sampling frequency:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}


- (PGNFSensorSamplingFrequencyBox *_Nullable)
    getSamplingFrequencyFPGGuid:(NSString *)guid
                          error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorSamplingFrequencyBox alloc]
            initWithValue:[WrapperUtils PGNFSensorSamplingFrequencyFromNT:[sensor getSamplingFrequencyFPG]]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor FPG sampling frequency:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (PGNFIrAmplitudeBox *_Nullable)
    getIrAmplitudeGuid:(NSString *)guid
                 error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFIrAmplitudeBox alloc]
            initWithValue:(PGNFIrAmplitude)[sensor getIrAmplitude]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor Irl amplitude:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (void)setIrAmplitudeGuid:(NSString *)guid
                       amp:(PGNFIrAmplitude)amp
                     error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setIrAmplitude:(NTIrAmplitude)amp];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting sensor Irl amplitude:"
                  message:exception.description
                  details:nil];
    }
}

- (PGNFRedAmplitudeBox *_Nullable)
    getRedAmplitudeGuid:(NSString *)guid
                  error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFRedAmplitudeBox alloc]
            initWithValue:(PGNFRedAmplitude)[sensor getRedAmplitude]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading sensor red amplitude:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (void)setRedAmplitudeGuid:(NSString *)guid
                        amp:(PGNFRedAmplitude)amp
                      error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setRedAmplitude:(NTRedAmplitude)amp];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting sensor Irl amplitude:"
                  message:exception.description
                  details:nil];
    }
}

- (void)pingNeuroSmartGuid:(NSString *)guid
                    marker:(NSInteger)marker
                completion:(void (^)(FlutterError *_Nullable))completion {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor pingNeuroSmart:marker];
        completion(nil);
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        completion([FlutterError
            errorWithCode:@"Error while trying to ping neuro smart:"
                  message:exception.description
                  details:nil]);
    }
}

- (void)setGainGuid:(NSString *)guid
               gain:(PGNFSensorGain)gain
              error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setGain:(NTSensorGain)gain];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while trying set gain:"
                                     message:exception.description
                                     details:nil];
    }
}

- (nullable NSNumber *)isSupportedFilterGuid:(NSString *)guid
                                      filter:(PGNFSensorFilter)filter
                                       error:(FlutterError *_Nullable *_Nonnull)
                                                 error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor isSupportedFilter:(NTSensorFilter)filter];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported filters:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (nullable NSArray<NSNumber *> *)
    getSupportedFiltersGuid:(NSString *)guid
                      error:(FlutterError *_Nullable *_Nonnull)error {

    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];

        NSMutableArray *result = [NSMutableArray new];
        [sensor getSupportedFilters:result];
        return result;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported filters:"
                  message:exception.description
                  details:nil];
    }

    return nil;
}

- (nullable NSArray<NSNumber *> *)
    getHardwareFiltersGuid:(NSString *)guid
                     error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];

        NSMutableArray *result = [NSMutableArray new];
        [sensor getHardwareFilters:result];
        return result;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading supported filters:"
                  message:exception.description
                  details:nil];
    }

    return nil;
}

- (void)setHardwareFiltersGuid:(NSString *)guid
                       filters:(NSArray<NSNumber *> *)filters
                         error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setHardwareFilters:filters];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while setting filters:"
                                     message:exception.description
                                     details:nil];
    }
}

- (void)setFirmwareModeGuid:(NSString *)guid
                       mode:(PGNFSensorFirmwareMode)mode
                      error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setFirmwareMode:(NTSensorFirmwareMode)mode];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while setting firmware mode:"
                                message:exception.description
                                details:nil];
    }
}

- (void)setSamplingFrequencyGuid:(NSString *)guid
                              sf:(PGNFSensorSamplingFrequency)sf
                           error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setSamplingFrequency:[WrapperUtils NTSensorSamplingFrequencyFromPGNF:sf]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting sampling frequency:"
                  message:exception.description
                  details:nil];
    }
}

- (void)setDataOffsetGuid:(NSString *)guid
                   offset:(PGNFSensorDataOffset)offset
                    error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setDataOffset:(NTSensorDataOffset)offset];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while setting data offset:"
                                     message:exception.description
                                     details:nil];
    }
}

- (PGNFSensorExternalSwitchInputBox *_Nullable)
    getExtSwInputGuid:(NSString *)guid
                error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorExternalSwitchInputBox alloc]
            initWithValue:(PGNFSensorExternalSwitchInput)[sensor
                                                              getExtSwInput]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading external switch imput:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (void)setExtSwInputGuid:(NSString *)guid
                 extSwInp:(PGNFSensorExternalSwitchInput)extSwInp
                    error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setExtSwInput:(NTSensorExternalSwitchInput)extSwInp];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting external switch imput:"
                  message:exception.description
                  details:nil];
    }
}

- (PGNFSensorADCInputBox *_Nullable)
    getADCInputGuid:(NSString *)guid
              error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorADCInputBox alloc]
            initWithValue:(PGNFSensorADCInput)[sensor getADCInput]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while reading ADC input:"
                                     message:exception.description
                                     details:nil];
    }
    return nil;
}

- (void)setADCInputGuid:(NSString *)guid
                 adcInp:(PGNFSensorADCInput)adcInp
                  error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setADCInput:(NTSensorADCInput)adcInp];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while setting ADC input:"
                                     message:exception.description
                                     details:nil];
    }
}

- (nullable PGNFCallibriStimulatorMAState *)
    getStimulatorMAStateGuid:(NSString *)guid
                       error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [WrapperUtils PGNFMAStateFromNT:[sensor getStimulatorMAState]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while reading MA state:"
                                     message:exception.description
                                     details:nil];
    }
    return nil;
}

- (nullable PGNFCallibriStimulationParams *)
    getStimulatorParamGuid:(NSString *)guid
                     error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [WrapperUtils
            PGNFStimulatorParamsFromNT:[sensor getStimulatorParam]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading stimulator param:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (void)setStimulatorParamGuid:(NSString *)guid
                         param:(PGNFCallibriStimulationParams *)param
                         error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor
            setStimulatorParam:[WrapperUtils NTStimulatorParamsFromPGNF:param]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while setting stimulator param:"
                                message:exception.description
                                details:nil];
    }
}

- (nullable PGNFCallibriMotionAssistantParams *)
    getMotionAssistantParamGuid:(NSString *)guid
                          error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [WrapperUtils
            PGNFMotionAssistantParamsFromNT:[sensor getMotionAssistantParam]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading motion params:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (void)setMotionAssistantParamGuid:(NSString *)guid
                              param:(PGNFCallibriMotionAssistantParams *)param
                              error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor
            setMotionAssistantParam:[WrapperUtils
                                        NTMotionAssistantParamsFromPGNF:param]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting motion assistant param:"
                  message:exception.description
                  details:nil];
    }
}

- (nullable PGNFCallibriMotionCounterParam *)
    getMotionCounterParamGuid:(NSString *)guid
                        error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [WrapperUtils
            PGNFMotionCounterParamFromNT:[sensor getMotionCounterParam]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading motion counter param:"
                  message:exception.description
                  details:nil];
    }

    return nil;
}

- (void)setMotionCounterParamGuid:(NSString *)guid
                            param:(PGNFCallibriMotionCounterParam *)param
                            error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setMotionCounterParam:[WrapperUtils
                                          NTMotionCounterParamFromPGNF:param]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting motion counter param:"
                  message:exception.description
                  details:nil];
    }
}

- (nullable NSNumber *)getMotionCounterGuid:(NSString *)guid
                                      error:(FlutterError *_Nullable *_Nonnull)
                                                error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getMotionCounter];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading motion counter:"
                                message:exception.description
                                details:nil];
    }

    return nil;
}

- (PGNFCallibriColorTypeBox *_Nullable)
    getColorGuid:(NSString *)guid
           error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFCallibriColorTypeBox alloc]
            initWithValue:(PGNFCallibriColorType)[sensor getColor]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while reading color:"
                                     message:exception.description
                                     details:nil];
    }
    return nil;
}

- (nullable NSNumber *)
    getMEMSCalibrateStateGuid:(NSString *)guid
                        error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [sensor getMEMSCalibrateState];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading calibration state:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)
    getSamplingFrequencyRespGuid:(NSString *)guid
                           error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorSamplingFrequencyBox alloc]
            initWithValue:[WrapperUtils PGNFSensorSamplingFrequencyFromNT:[sensor getSamplingFrequencyResp]]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading resp sampling frequency:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)
    getSamplingFrequencyEnvelopeGuid:(NSString *)guid
                               error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorSamplingFrequencyBox alloc]
            initWithValue:[WrapperUtils PGNFSensorSamplingFrequencyFromNT:[sensor getSamplingFrequencyEnvelope]]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading envelope sampling frequency:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}


- (PGNCallibriSignalTypeBox *_Nullable)
    getSignalTypeGuid:(NSString *)guid
                error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNCallibriSignalTypeBox alloc]
            initWithValue:(PGNCallibriSignalType)[sensor getSignalType]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while reading signal type:"
                                     message:exception.description
                                     details:nil];
    }
    return nil;
}

- (void)setSignalTypeGuid:(NSString *)guid
                     type:(PGNCallibriSignalType)type
                    error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setSignalType:(NTCallibriSignalType)type];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError errorWithCode:@"Error while setting signal type:"
                                     message:exception.description
                                     details:nil];
    }
}

- (PGNFCallibriElectrodeStateBox *_Nullable)
    getElectrodeStateGuid:(NSString *)guid
                    error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFCallibriElectrodeStateBox alloc]
            initWithValue:(PGNFCallibriElectrodeState)[sensor
                                                           getElectrodeState]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading electrode state:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}


- (PGNFSensorAccelerometerSensitivityBox *_Nullable)
    getAccSensGuid:(NSString *)guid
             error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorAccelerometerSensitivityBox alloc]
            initWithValue:(PGNFSensorAccelerometerSensitivity)[sensor
                                                                   getAccSens]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading acc sensetivity:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (void)setAccSensGuid:(NSString *)guid
               accSens:(PGNFSensorAccelerometerSensitivity)accSens
                 error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setAccSens:(NTSensorAccelerometerSensitivity)accSens];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while setting acc sensetivity:"
                                message:exception.description
                                details:nil];
    }
}

- (PGNFSensorGyroscopeSensitivityBox *_Nullable)
    getGyroSensGuid:(NSString *)guid
              error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorGyroscopeSensitivityBox alloc]
            initWithValue:(PGNFSensorGyroscopeSensitivity)[sensor getGyroSens]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading gyro sensetivity:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (void)setGyroSensGuid:(NSString *)guid
               gyroSens:(PGNFSensorGyroscopeSensitivity)gyroSens
                  error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        [sensor setGyroSens:(NTSensorGyroscopeSensitivity)gyroSens];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while setting gyro sensetivity:"
                                message:exception.description
                                details:nil];
    }
}

- (PGNFSensorSamplingFrequencyBox *_Nullable)
    getSamplingFrequencyMEMSGuid:(NSString *)guid
                           error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [[PGNFSensorSamplingFrequencyBox alloc]
            initWithValue:(PGNFSensorSamplingFrequency)
                              [sensor getSamplingFrequencyMEMS]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading MEMS sampling frequency:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}


- (nullable NSArray<PGNFEEGChannelInfo *> *)
    getSupportedChannelsGuid:(NSString *)guid
                       error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        NSArray<NTEEGChannelInfo *> *channels = [sensor getSupportedChannels];
        NSMutableArray<PGNFEEGChannelInfo *> *result =
            [NSMutableArray arrayWithCapacity:channels.count];

        for (NTEEGChannelInfo *channel in channels) {
            [result addObject:[WrapperUtils PGNFChanelInfoFromNT:channel]];
        }

        return result;
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error =
            [FlutterError errorWithCode:@"Error while reading channels info:"
                                message:exception.description
                                details:nil];
    }
    return nil;
}

- (nullable PGNBrainBit2AmplifierParamNative *)
    getAmplifierParamBB2Guid:(NSString *)guid
                       error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        return [WrapperUtils
            PGNFBB2AmplifierParamFromNT:[sensor getAmplifierParamBB2]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while reading BB2 amplifier params:"
                  message:exception.description
                  details:nil];
    }
    return nil;
}

- (void)setAmplifierParamBB2Guid:(NSString *)guid
                           param:(PGNBrainBit2AmplifierParamNative *)param
                           error:(FlutterError *_Nullable *_Nonnull)error {
    @try {
        AFullSensor *sensor = [_sensors objectForKey:guid];
        // [sensor setAmplifierParamBB2:[WrapperUtils
        //                                  NTBB2AmplifierParamFromPGNF:param]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        *error = [FlutterError
            errorWithCode:@"Error while setting BB2 amplifier params:"
                  message:exception.description
                  details:nil];
    }
}

@end
