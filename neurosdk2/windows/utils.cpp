#include "include/utils.h"

int SensFamilyToOrdinal(SensorFamily family) {
	switch (family)
	{
	case SensorUnknown:
		return 7;
	case SensorLECallibri:
		return 0;
	case SensorLEKolibri:
		return 1;
	case SensorLEBrainBit:
		return 2;
	case SensorLEBrainBitBlack:
		return 3;
	case SensorLEBrainBit2:
		return 4;
	case SensorLEBrainBitPro:
		return 5;
	case SensorLEBrainBitFlex:
		return 6;
	default:
		return 7;
	}
}
flutter::EncodableList SensorInfosToList(SensorInfo* sensors, int32_t szSensors) {
	flutter::EncodableList sensorsList{};
	while (szSensors--)
	{
		SensorInfo info = sensors[szSensors];
    flutter::EncodableMap sensor;
    sensor.insert(std::make_pair(flutter::EncodableValue("Name"), flutter::EncodableValue(std::string(info.Name))));
    sensor.insert(std::make_pair(flutter::EncodableValue("Address"), flutter::EncodableValue(std::string(info.Address))));
    sensor.insert(std::make_pair(flutter::EncodableValue("SerialNumber"), flutter::EncodableValue(std::string(info.SerialNumber))));
    sensor.insert(std::make_pair(flutter::EncodableValue("SensModel"), flutter::EncodableValue((int32_t)info.SensModel)));
    sensor.insert(std::make_pair(flutter::EncodableValue("SensFamily"), flutter::EncodableValue((int32_t)SensFamilyToOrdinal(info.SensFamily))));
    sensor.insert(std::make_pair(flutter::EncodableValue("PairingRequired"), flutter::EncodableValue(info.PairingRequired ? true : false)));
    sensor.insert(std::make_pair(flutter::EncodableValue("RSSI"), flutter::EncodableValue((int32_t)info.RSSI)));
		sensorsList.push_back(sensor);
	}
	return sensorsList;
}

flutter::EncodableList CallibriSignalDataToList(CallibriSignalData* data, int32_t size)
{
	flutter::EncodableList dataList{};
	for (int i = 0; i < size; i++) {
		CallibriSignalData it = data[i];
		std::vector<double> list(it.Samples, it.Samples + it.SzSamples);
		flutter::EncodableMap map;
		map.insert(std::make_pair(flutter::EncodableValue("PackNum"), flutter::EncodableValue((int64_t)it.PackNum)));
		map.insert(std::make_pair(flutter::EncodableValue("Samples"), flutter::EncodableValue(list)));
		dataList.push_back(map);
	}
	return dataList;
}

flutter::EncodableList CallibriRespirationDataToList(CallibriRespirationData* data, int32_t size)
{
	flutter::EncodableList dataList{};
	for (int i = 0; i < size; i++) {
		CallibriRespirationData it = data[i];
		std::vector<double> list(it.Samples, it.Samples + it.SzSamples);
		flutter::EncodableMap map;
		map.insert(std::make_pair(flutter::EncodableValue("PackNum"), flutter::EncodableValue((int64_t)it.PackNum)));
		map.insert(std::make_pair(flutter::EncodableValue("Samples"), flutter::EncodableValue(list)));
		dataList.push_back(map);
	}
	return dataList;
}

flutter::EncodableList CallibriEnvelopeDataToList(CallibriEnvelopeData* data, int32_t size)
{
	flutter::EncodableList dataList{};
	for (int i = 0; i < size; i++) {
		CallibriEnvelopeData it = data[i];
		flutter::EncodableMap map;
    map.insert(std::make_pair(flutter::EncodableValue("PackNum"), flutter::EncodableValue((int64_t)it.PackNum)));
    map.insert(std::make_pair(flutter::EncodableValue("Sample"), flutter::EncodableValue(it.Sample)));
		dataList.push_back(map);
	}
	return dataList;
}

pigeon_neuro_api::FSensorFamily SensFamilyToFSensFamily(SensorFamily family) {
	switch (family)
	{
	case SensorUnknown:
		return pigeon_neuro_api::FSensorFamily::kUnknown;
	case SensorLECallibri:
		return pigeon_neuro_api::FSensorFamily::kLeCallibri;
	case SensorLEKolibri:
		return pigeon_neuro_api::FSensorFamily::kLeKolibri;
	case SensorLEBrainBit:
		return pigeon_neuro_api::FSensorFamily::kLeBrainBit;
	case SensorLEBrainBitBlack:
		return pigeon_neuro_api::FSensorFamily::kLeBrainBitBlack;
	case SensorLEBrainBit2:
		return pigeon_neuro_api::FSensorFamily::kLeBrainBit2;
	case SensorLEBrainBitPro:
		return pigeon_neuro_api::FSensorFamily::kLeBrainBitPro;
	case SensorLEBrainBitFlex:
		return pigeon_neuro_api::FSensorFamily::kLeBrainBitFlex;
	default:
		return pigeon_neuro_api::FSensorFamily::kUnknown;
	}
}

pigeon_neuro_api::FSensorSamplingFrequency SensFreqToFSensFreq(SensorSamplingFrequency sf) {
	switch (sf)
	{
	case FrequencyHz10:
	case FrequencyHz20:
	case FrequencyHz100:
	case FrequencyHz125:
	case FrequencyHz250:
	case FrequencyHz500:
	case FrequencyHz1000:
	case FrequencyHz2000:
	case FrequencyHz4000:
	case FrequencyHz8000:
	case FrequencyHz10000:
	case FrequencyHz12000:
	case FrequencyHz16000:
	case FrequencyHz24000:
	case FrequencyHz32000:
	case FrequencyHz48000:
	case FrequencyHz64000:
		return static_cast<pigeon_neuro_api::FSensorSamplingFrequency>(sf);
	case FrequencyUnsupported:
	default:
		return pigeon_neuro_api::FSensorSamplingFrequency::kUnsupported;
	}
}
SensorSamplingFrequency FSensFreqToSensFreq(pigeon_neuro_api::FSensorSamplingFrequency sf) {
	switch (sf)
	{
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz10:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz20:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz100:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz125:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz250:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz500:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz1000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz2000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz4000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz8000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz10000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz12000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz16000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz24000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz32000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz48000:
	case pigeon_neuro_api::FSensorSamplingFrequency::kHz64000:
		return static_cast<SensorSamplingFrequency>(sf);
	case pigeon_neuro_api::FSensorSamplingFrequency::kUnsupported:
	default:
		return SensorSamplingFrequency::FrequencyUnsupported;
	}
}

pigeon_neuro_api::FSensorDataOffset DataOffsetToFDataOffset(SensorDataOffset dataOffset) {
	switch (dataOffset)
	{
	case DataOffset0:
	case DataOffset1:
	case DataOffset2:
	case DataOffset3:
	case DataOffset4:
	case DataOffset5:
	case DataOffset6:
	case DataOffset7:
	case DataOffset8:
		return static_cast<pigeon_neuro_api::FSensorDataOffset>(dataOffset);
	case DataOffsetUnsupported:
	default:
		return pigeon_neuro_api::FSensorDataOffset::kDataOffsetUnsupported;
	}
}
SensorDataOffset FDataOffsetToDataOffset(pigeon_neuro_api::FSensorDataOffset dataOffset) {
	switch (dataOffset)
	{
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset0:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset1:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset2:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset3:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset4:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset5:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset6:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset7:
	case pigeon_neuro_api::FSensorDataOffset::kDataOffset8:
		return static_cast<SensorDataOffset>(dataOffset);
	case pigeon_neuro_api::FSensorDataOffset::kDataOffsetUnsupported:
	default:
		return SensorDataOffset::DataOffsetUnsupported;
	}
}

pigeon_neuro_api::FSensorExternalSwitchInput ExtSwInpToFExtSwInp(SensorExternalSwitchInput extSwInp) {
	switch (extSwInp)
	{
	case ExtSwInElectrodesRespUSB:
	case ExtSwInElectrodes:
	case ExtSwInUSB:
	case ExtSwInRespUSB:
	case ExtSwInShort:
		return static_cast<pigeon_neuro_api::FSensorExternalSwitchInput>(extSwInp);
	case ExtSwInUnknown:
	default:
		return pigeon_neuro_api::FSensorExternalSwitchInput::kUnknownInp;
	}
}
SensorExternalSwitchInput FExtSwInpToExtSwInp(pigeon_neuro_api::FSensorExternalSwitchInput extSwInp) {
	switch (extSwInp)
	{
	case pigeon_neuro_api::FSensorExternalSwitchInput::kElectrodesRespUSBInp:
	case pigeon_neuro_api::FSensorExternalSwitchInput::kElectrodesInp:
	case pigeon_neuro_api::FSensorExternalSwitchInput::kUsbInp:
	case pigeon_neuro_api::FSensorExternalSwitchInput::kRespUSBInp:
	case pigeon_neuro_api::FSensorExternalSwitchInput::kShortInp:
		return static_cast<SensorExternalSwitchInput>(extSwInp);
	case pigeon_neuro_api::FSensorExternalSwitchInput::kUnknownInp:
	default:
		return SensorExternalSwitchInput::ExtSwInUnknown;
	}
}

pigeon_neuro_api::FIrAmplitude IrAmpToFIrAmp(IrAmplitude irAmp) {
	switch (irAmp)
	{
	case IrAmp0:
	case IrAmp14:
	case IrAmp28:
	case IrAmp42:
	case IrAmp56:
	case IrAmp70:
	case IrAmp84:
	case IrAmp100:
		return static_cast<pigeon_neuro_api::FIrAmplitude>(irAmp);
	case IrAmpUnsupported:
	default:
		return pigeon_neuro_api::FIrAmplitude::kIrAmpUnsupported;
	}
}
IrAmplitude FIrAmpToIrAmp(pigeon_neuro_api::FIrAmplitude irAmp) {
	switch (irAmp)
	{
	case pigeon_neuro_api::FIrAmplitude::kIrAmp0:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp14:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp28:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp42:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp56:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp70:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp84:
	case pigeon_neuro_api::FIrAmplitude::kIrAmp100:
		return static_cast<IrAmplitude>(irAmp);
	case pigeon_neuro_api::FIrAmplitude::kIrAmpUnsupported:
	default:
		return IrAmplitude::IrAmpUnsupported;
	}
}

pigeon_neuro_api::FRedAmplitude RedAmpToFRedAmp(RedAmplitude redAmp) {
	switch (redAmp)
	{
	case RedAmp0:
	case RedAmp14:
	case RedAmp28:
	case RedAmp42:
	case RedAmp56:
	case RedAmp70:
	case RedAmp84:
	case RedAmp100:
		return static_cast<pigeon_neuro_api::FRedAmplitude>(redAmp);
	case RedAmpUnsupported:
	default:
		return pigeon_neuro_api::FRedAmplitude::kRedAmpUnsupported;
	}
}

RedAmplitude FRedAmpToRedAmp(pigeon_neuro_api::FRedAmplitude redAmp) {
	switch (redAmp)
	{
	case pigeon_neuro_api::FRedAmplitude::kRedAmp0:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp14:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp28:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp42:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp56:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp70:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp84:
	case pigeon_neuro_api::FRedAmplitude::kRedAmp100:
		return static_cast<RedAmplitude>(redAmp);
	case pigeon_neuro_api::FRedAmplitude::kRedAmpUnsupported:
	default:
		return RedAmplitude::RedAmpUnsupported;
	}
}

pigeon_neuro_api::FSensorFilter SFilterToFSFilter(SensorFilter filter) {
	switch (filter)
	{
	case FilterHPFBwhLvl1CutoffFreq1Hz:
	case FilterHPFBwhLvl1CutoffFreq5Hz:
	case FilterBSFBwhLvl2CutoffFreq45_55Hz:
	case FilterBSFBwhLvl2CutoffFreq55_65Hz:
	case FilterHPFBwhLvl2CutoffFreq10Hz:
	case FilterLPFBwhLvl2CutoffFreq400Hz:
	case FilterHPFBwhLvl2CutoffFreq80Hz:
		return static_cast<pigeon_neuro_api::FSensorFilter>(filter);
	case FilterUnknown:
	default:
		return pigeon_neuro_api::FSensorFilter::kUnknown;
	}
}
SensorFilter FSFilterToSFilter(pigeon_neuro_api::FSensorFilter filter) {
	switch (filter)
	{
	case pigeon_neuro_api::FSensorFilter::kHPFBwhLvl1CutoffFreq1Hz:
	case pigeon_neuro_api::FSensorFilter::kHPFBwhLvl1CutoffFreq5Hz:
	case pigeon_neuro_api::FSensorFilter::kBSFBwhLvl2CutoffFreq45_55Hz:
	case pigeon_neuro_api::FSensorFilter::kBSFBwhLvl2CutoffFreq55_65Hz:
	case pigeon_neuro_api::FSensorFilter::kHPFBwhLvl2CutoffFreq10Hz:
	case pigeon_neuro_api::FSensorFilter::kLPFBwhLvl2CutoffFreq400Hz:
	case pigeon_neuro_api::FSensorFilter::kHPFBwhLvl2CutoffFreq80Hz:
		return static_cast<SensorFilter>(filter);
	case pigeon_neuro_api::FSensorFilter::kUnknown:
	default:
		return SensorFilter::FilterUnknown;
	}
}

pigeon_neuro_api::FCallibriStimulatorState StimStateToFStimState(CallibriStimulatorState state) {
	switch (state)
	{
	case StimStateNoParams:
	case StimStateDisabled:
	case StimStateEnabled:
		return static_cast<pigeon_neuro_api::FCallibriStimulatorState>(state);
	case StimStateUnsupported:
	default:
		return pigeon_neuro_api::FCallibriStimulatorState::kUnsupported;
	}
}

pigeon_neuro_api::FGenCurrent GenCurrentToFGenCurrent(GenCurrent current) {
	switch (current)
	{
	case GenCurr0nA:
	case GenCurr6nA:
	case GenCurr12nA:
	case GenCurr18nA:
	case GenCurr24nA:
	case GenCurr6uA:
	case GenCurr24uA:
		return static_cast<pigeon_neuro_api::FGenCurrent>(current);
	case Unsupported:
	default:
		return pigeon_neuro_api::FGenCurrent::kUnsupported;
	}
}

GenCurrent FGenCurrentToGenCurrent(pigeon_neuro_api::FGenCurrent current) {
	switch (current)
	{
	case pigeon_neuro_api::FGenCurrent::kGenCurr0nA:
	case pigeon_neuro_api::FGenCurrent::kGenCurr6nA:
	case pigeon_neuro_api::FGenCurrent::kGenCurr12nA:
	case pigeon_neuro_api::FGenCurrent::kGenCurr18nA:
	case pigeon_neuro_api::FGenCurrent::kGenCurr24nA:
	case pigeon_neuro_api::FGenCurrent::kGenCurr6uA:
	case pigeon_neuro_api::FGenCurrent::kGenCurr24uA:
		return static_cast<GenCurrent>(current);
	case pigeon_neuro_api::FGenCurrent::kUnsupported:
	default:
		return GenCurrent::Unsupported;
	}
}

std::string CreateUUID()
{
	UUID newId;
	UuidCreate(&newId);
	CString C;
	C.Format(_T("%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x"),
		newId.Data1,
		newId.Data2,
		newId.Data3,
		newId.Data4[0],
		newId.Data4[1],
		newId.Data4[2],
		newId.Data4[3],
		newId.Data4[4],
		newId.Data4[5],
		newId.Data4[6],
		newId.Data4[7]);
	CT2CA pszConvertedAnsiString(C);
	std::string strStd(pszConvertedAnsiString);
	return strStd;
}
