#ifndef FLUTTER_PLUGIN_UTILS_H_
#define FLUTTER_PLUGIN_UTILS_H_

#include "neurosdk2/sdk_api.h"
#include "../pigeon_messages/pigeon_messages.g.h"
#include <string>
#include <memory>
#include <flutter/event_sink.h>
#include <atlstr.h>
#include <rpcdce.h>
#include <Rpc.h>
#pragma comment(lib, "Rpcrt4.lib")

struct ScannerHolder {
	SensorScanner* scanner = nullptr;
	SensorsListenerHandle scanCallbackHandle = nullptr;
};

struct SensorHolder {
	Sensor* sensor = nullptr;
	BattPowerListenerHandle battPowerHandle = nullptr;
	SensorStateListenerHandle stateHandle = nullptr;

	BrainBit2SignalDataListenerHandle bb2SignalHandle = nullptr;
	BrainBit2ResistDataListenerHandle bb2ResistHandle = nullptr;

	CallibriSignalDataListenerHandle callibriSignalHandle = nullptr;
	CallibriRespirationDataListenerHandle callibriRespirationHandle = nullptr;
	CallibriElectrodeStateListenerHandle callibriElectrodeStateHandle = nullptr;
	CallibriEnvelopeDataListenerHandle callibriEnvelopeHandle = nullptr;
	QuaternionDataListenerHandle quaternionHandle = nullptr;

	MEMSDataListenerHandle memsHandle = nullptr;

	FPGDataListenerHandle fpgHande = nullptr;

	AmpModeListenerHandle ampModeHandle = nullptr;

	BrainBitSignalDataListenerHandle bbSignalHandle = nullptr;
	BrainBitResistDataListenerHandle bbResistHandle = nullptr;
};

struct CallbackData {
	std::string guid;
};

int SensFamilyToOrdinal(SensorFamily family);
pigeon_neuro_api::FSensorFamily SensFamilyToFSensFamily(SensorFamily family);

pigeon_neuro_api::FSensorSamplingFrequency SensFreqToFSensFreq(SensorSamplingFrequency sf);
SensorSamplingFrequency FSensFreqToSensFreq(pigeon_neuro_api::FSensorSamplingFrequency sf);

pigeon_neuro_api::FSensorDataOffset DataOffsetToFDataOffset(SensorDataOffset dataOffset);
SensorDataOffset FDataOffsetToDataOffset(pigeon_neuro_api::FSensorDataOffset dataOffset);

pigeon_neuro_api::FSensorExternalSwitchInput ExtSwInpToFExtSwInp(SensorExternalSwitchInput extSwInp);
SensorExternalSwitchInput FExtSwInpToExtSwInp(pigeon_neuro_api::FSensorExternalSwitchInput extSwInp);

pigeon_neuro_api::FIrAmplitude IrAmpToFIrAmp(IrAmplitude irAmp);
IrAmplitude FIrAmpToIrAmp(pigeon_neuro_api::FIrAmplitude irAmp);

pigeon_neuro_api::FRedAmplitude RedAmpToFRedAmp(RedAmplitude redAmp);
RedAmplitude FRedAmpToRedAmp(pigeon_neuro_api::FRedAmplitude redAmp);

pigeon_neuro_api::FSensorFilter SFilterToFSFilter(SensorFilter filter);
SensorFilter FSFilterToSFilter(pigeon_neuro_api::FSensorFilter filter);

pigeon_neuro_api::FGenCurrent GenCurrentToFGenCurrent(GenCurrent current);
GenCurrent FGenCurrentToGenCurrent(pigeon_neuro_api::FGenCurrent current);

pigeon_neuro_api::FCallibriStimulatorState StimStateToFStimState(CallibriStimulatorState state);
//CallibriStimulatorState FStimStateToStimState(pigeon_neuro_api::FCallibriStimulatorState filter);

flutter::EncodableList SensorInfosToList(SensorInfo* sensors, int32_t szSensors);

flutter::EncodableList CallibriSignalDataToList(CallibriSignalData* data, int32_t size);
flutter::EncodableList CallibriRespirationDataToList(CallibriRespirationData* data, int32_t size);
flutter::EncodableList CallibriEnvelopeDataToList(CallibriEnvelopeData* data, int32_t size);

std::string CreateUUID();

#endif 