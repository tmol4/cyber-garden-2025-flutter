#import "WrapperUtils.h"

@implementation WrapperUtils

+ (PGNFSensorInfo *)PGNFSensorInfoFromNT:(NTSensorInfo *)info {
    PGNFSensorInfo *sensorInfo = [PGNFSensorInfo
           makeWithName:info.Name
                address:info.Address
           serialNumber:info.SerialNumber
        pairingRequired:info.PairingRequared
              sensModel:info.SensModel
             sensFamily:[WrapperUtils PGNFSensorFamilyFromNT:info.SensFamily]
                   rssi:info.RSSI];
    return sensorInfo;
}

+ (NTSensorInfo *)NTSensorInfoFromPGNF:(PGNFSensorInfo *)info {
    return [[NTSensorInfo alloc]
        initWithSensFamily:[WrapperUtils NTSensorFamilyFromPGNF:info.sensFamily]
                 sensModel:info.sensModel
                      name:info.name
                   address:info.address
              serialNumber:info.serialNumber
           pairingRequared:info.pairingRequired
                      rssi:info.rssi];
}

+ (NSDictionary *)JsonSensorInfoFromNT:(NTSensorInfo *)info {
    return @{
        @"Name" : info.Name,
        @"Address" : info.Address,
        @"SerialNumber" : info.SerialNumber,
        @"SensModel" : [NSNumber numberWithInt:info.SensModel],
        @"SensFamily" : [NSNumber
            numberWithUnsignedInteger:
                [WrapperUtils PGNFSensorFamilyFromNT:info.SensFamily]],
        @"PairingRequired" : [NSNumber numberWithBool:info.PairingRequared],
        @"RSSI" : [NSNumber numberWithShort:info.RSSI]
    };
}

+ (PGNFParameterInfo *)PGNFParametrInfoFromNT:(NTParameterInfo *)param {
    return [PGNFParameterInfo
        makeWithParam:(PGNFSensorParameter)param.Param
          paramAccess:(PGNFSensorParamAccess)param.ParamAccess];
}

+ (PGNFSensorVersion *)PGNFVersionFromNT:(NTSensorVersion *)version {
    return [PGNFSensorVersion makeWithFwMajor:version.FwMajor
                                      fwMinor:version.FwMinor
                                      fwPatch:version.FwPatch
                                      hwMajor:version.HwMajor
                                      hwMinor:version.HwMinor
                                      hwPatch:version.HwMinor
                                     extMajor:version.ExtMajor];
}

+ (PGNFCallibriStimulatorMAState *)PGNFMAStateFromNT:
    (NTCallibriStimulatorMAState *)state {
    return [PGNFCallibriStimulatorMAState
        makeWithStimulatorState:(PGNFCallibriStimulatorState)
                                    state.stimulatorState
                        maState:(PGNFCallibriStimulatorState)state.MAState];
}

+ (PGNFCallibriStimulationParams *)PGNFStimulatorParamsFromNT:
    (NTCallibriStimulationParams *)param {
    return
        [PGNFCallibriStimulationParams makeWithCurrent:param.Current
                                            pulseWidth:param.PulseWidth
                                             frequency:param.Frequency
                                      stimulusDuration:param.StimulusDuration];
}

+ (NTCallibriStimulationParams *)NTStimulatorParamsFromPGNF:
    (PGNFCallibriStimulationParams *)param {
    return [[NTCallibriStimulationParams alloc]
         initWithCurrent:param.current
              pulseWidth:param.pulseWidth
               frequency:param.frequency
        stimulusDuration:param.stimulusDuration];
}

+ (PGNFCallibriMotionAssistantParams *)PGNFMotionAssistantParamsFromNT:
    (NTCallibriMotionAssistantParams *)param {
    return [PGNFCallibriMotionAssistantParams
        makeWithGyroStart:param.GyroStart
                 gyroStop:param.GyroStop
                     limb:(PGNFCallibriMotionAssistantLimb)param.Limb
               minPauseMs:param.MinPauseMs];
}

+ (NTCallibriMotionAssistantParams *)NTMotionAssistantParamsFromPGNF:
    (PGNFCallibriMotionAssistantParams *)param {
    return [[NTCallibriMotionAssistantParams alloc]
        initWithGyroStart:param.gyroStart
                 gyroStop:param.gyroStop
                     limb:(NTCallibriMotionAssistantLimb)param.limb
               minPauseMs:param.minPauseMs];
}

+ (PGNFCallibriMotionCounterParam *)PGNFMotionCounterParamFromNT:
    (NTCallibriMotionCounterParam *)param {
    return [PGNFCallibriMotionCounterParam
        makeWithInsenseThresholdMG:param.InsenseThresholdMG
            insenseThresholdSample:param.InsenseThresholdSample];
}

+ (NTCallibriMotionCounterParam *)NTMotionCounterParamFromPGNF:
    (PGNFCallibriMotionCounterParam *)param {
    return [[NTCallibriMotionCounterParam alloc]
        initWithInsenseThresholdMG:param.insenseThresholdMG
            insenseThresholdSample:param.insenseThresholdSample];
}


+ (PGNFEEGChannelInfo *)PGNFChanelInfoFromNT:(NTEEGChannelInfo *)info {
    return [PGNFEEGChannelInfo makeWithId:(PGNFEEGChannelId)info.Id
                                   chType:(PGNFEEGChannelType)info.ChType
                                     name:info.Name
                                      num:info.Num];
}


+ (PGNBrainBit2AmplifierParamNative *)PGNFBB2AmplifierParamFromNT:
    (NTBrainBit2AmplifierParam *)param {
    return [PGNBrainBit2AmplifierParamNative
        makeWithChSignalMode:param.ChSignalMode
                 chResistUse:param.ChResistUse
                      chGain:param.ChGain
                     current:(PGNFGenCurrent)param.Current];
}

+ (NTBrainBit2AmplifierParam *)NTBB2AmplifierParamFromPGNF:
    (PGNBrainBit2AmplifierParamNative *)param {
    NTBrainBit2AmplifierParam *res = [[NTBrainBit2AmplifierParam alloc] init];
    [res.ChSignalMode addObjectsFromArray:param.chSignalMode];
    [res.ChResistUse addObjectsFromArray:param.chResistUse];
    [res.ChGain addObjectsFromArray:param.chGain];
    res.Current = (NTGenCurrent)param.current;

    return res;
}

+ (PGNFSensorFamily)PGNFSensorFamilyFromNT:(NTSensorFamily)param {
    switch (param) {
    case NTSensorFamilyLECallibri:
        return PGNFSensorFamilyLeCallibri;
    case NTSensorFamilyLEKolibri:
        return PGNFSensorFamilyLeKolibri;
    case NTSensorFamilyLEBrainBit:
        return PGNFSensorFamilyLeBrainBit;
    case NTSensorFamilyLEBrainBitBlack:
        return PGNFSensorFamilyLeBrainBitBlack;
    case NTSensorFamilyLEBrainBit2:
        return PGNFSensorFamilyLeBrainBit2;
    case NTSensorFamilyLEBrainBitFlex:
        return PGNFSensorFamilyLeBrainBitFlex;
    case NTSensorFamilyLEBrainBitPro:
        return PGNFSensorFamilyLeBrainBitPro;
    case NTSensorFamilyUnknown:
    case NTSensorFamilyLEHeadPhones2:
    case NTSensorFamilyLEHeadband:
    case NTSensorFamilyLENeuroEEG:
    default:
        return PGNFSensorFamilyUnknown;
    }
}

+ (NTSensorFamily)NTSensorFamilyFromPGNF:(PGNFSensorFamily)param {
    switch (param) {
    case PGNFSensorFamilyLeCallibri:
        return NTSensorFamilyLECallibri;
    case PGNFSensorFamilyLeKolibri:
        return NTSensorFamilyLEKolibri;
    case PGNFSensorFamilyLeBrainBit:
        return NTSensorFamilyLEBrainBit;
    case PGNFSensorFamilyLeBrainBitBlack:
        return NTSensorFamilyLEBrainBitBlack;
    case PGNFSensorFamilyLeBrainBit2:
        return NTSensorFamilyLEBrainBit2;
    case PGNFSensorFamilyLeBrainBitPro:
        return NTSensorFamilyLEBrainBitPro;
    case PGNFSensorFamilyLeBrainBitFlex:
        return NTSensorFamilyLEBrainBitFlex;
    case PGNFSensorFamilyUnknown:
        return NTSensorFamilyUnknown;
    }
}

+ (PGNFSensorSamplingFrequency) PGNFSensorSamplingFrequencyFromNT:(NTSensorSamplingFrequency) param{
    switch (param) {
        case NTSensorSamplingFrequencyHz10:
        case NTSensorSamplingFrequencyHz20:
        case NTSensorSamplingFrequencyHz100:
        case NTSensorSamplingFrequencyHz125:
        case NTSensorSamplingFrequencyHz250:
        case NTSensorSamplingFrequencyHz500:
        case NTSensorSamplingFrequencyHz1000:
        case NTSensorSamplingFrequencyHz2000:
        case NTSensorSamplingFrequencyHz4000:
        case NTSensorSamplingFrequencyHz8000:
        case NTSensorSamplingFrequencyHz10000:
        case NTSensorSamplingFrequencyHz12000:
        case NTSensorSamplingFrequencyHz16000:
        case NTSensorSamplingFrequencyHz24000:
        case NTSensorSamplingFrequencyHz32000:
        case NTSensorSamplingFrequencyHz48000:
        case NTSensorSamplingFrequencyHz64000:
            return (PGNFSensorSamplingFrequency)param;
        case NTSensorSamplingFrequencyUnsupported:
            return PGNFSensorSamplingFrequencyUnsupported;
        default:
            break;
    }
}

+ (NTSensorSamplingFrequency) NTSensorSamplingFrequencyFromPGNF:(PGNFSensorSamplingFrequency) param{
    switch (param) {
        case PGNFSensorSamplingFrequencyHz10:
        case PGNFSensorSamplingFrequencyHz20:
        case PGNFSensorSamplingFrequencyHz100:
        case PGNFSensorSamplingFrequencyHz125:
        case PGNFSensorSamplingFrequencyHz250:
        case PGNFSensorSamplingFrequencyHz500:
        case PGNFSensorSamplingFrequencyHz1000:
        case PGNFSensorSamplingFrequencyHz2000:
        case PGNFSensorSamplingFrequencyHz4000:
        case PGNFSensorSamplingFrequencyHz8000:
        case PGNFSensorSamplingFrequencyHz10000:
        case PGNFSensorSamplingFrequencyHz12000:
        case PGNFSensorSamplingFrequencyHz16000:
        case PGNFSensorSamplingFrequencyHz24000:
        case PGNFSensorSamplingFrequencyHz32000:
        case PGNFSensorSamplingFrequencyHz48000:
        case PGNFSensorSamplingFrequencyHz64000:
            return (NTSensorSamplingFrequency)param;
        case PGNFSensorSamplingFrequencyUnsupported:
        default:
            return NTSensorSamplingFrequencyUnsupported;
    }
}

@end
