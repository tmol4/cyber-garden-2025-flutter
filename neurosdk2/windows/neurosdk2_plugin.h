#ifndef FLUTTER_PLUGIN_NEUROSDK2_PLUGIN_H_
#define FLUTTER_PLUGIN_NEUROSDK2_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include "include/utils.h"
#include "include/event_holder.h"


#include <memory>

namespace neurosdk2 {

using namespace pigeon_neuro_api;

class Neurosdk2Plugin : public flutter::Plugin, pigeon_neuro_api::NeuroApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  Neurosdk2Plugin();

  virtual ~Neurosdk2Plugin();

  // Disallow copy and assign.
  Neurosdk2Plugin(const Neurosdk2Plugin&) = delete;
  Neurosdk2Plugin& operator=(const Neurosdk2Plugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  //void HandleMethodCall(
  //    const flutter::MethodCall<flutter::EncodableValue> &method_call,
  //    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::map<std::string, ScannerHolder> _scanners;
  std::map<std::string, SensorHolder> _sensors;

  // Унаследовано через NeuroApi
  void CreateScanner(const flutter::EncodableList& filters, std::function<void(ErrorOr<std::string>reply)> result) override;
  void CloseScanner(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result) override;
  void StartScan(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result) override;
  void StopScan(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result) override;
  void CreateSensor(const std::string& guid, const pigeon_neuro_api::FSensorInfo& sensor_info, std::function<void(ErrorOr<std::string>reply)> result) override;
  ErrorOr<flutter::EncodableList> GetSensors(const std::string& guid) override;
  void CloseSensor(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result) override;
  void ConnectSensor(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result) override;
  void DisconnectSensor(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result) override;
  ErrorOr<flutter::EncodableList> SupportedFeatures(const std::string& guid) override;
  ErrorOr<bool> IsSupportedFeature(const std::string& guid, const pigeon_neuro_api::FSensorFeature& feature) override;
  ErrorOr<flutter::EncodableList> SupportedCommands(const std::string& guid) override;
  ErrorOr<bool> IsSupportedCommand(const std::string& guid, const pigeon_neuro_api::FSensorCommand& command) override;
  ErrorOr<flutter::EncodableList> SupportedParameters(const std::string& guid) override;
  ErrorOr<bool> IsSupportedParameter(const std::string& guid, const pigeon_neuro_api::FSensorParameter& parameter) override;
  void ExecCommand(const std::string& guid, const pigeon_neuro_api::FSensorCommand& command, std::function<void(std::optional<FlutterError>reply)> result) override;
  ErrorOr<std::string> GetName(const std::string& guid) override;
  std::optional<FlutterError> SetName(const std::string& guid, const std::string& name) override;
  ErrorOr<pigeon_neuro_api::FSensorState> GetState(const std::string& guid) override;
  ErrorOr<std::string> GetAddress(const std::string& guid) override;
  ErrorOr<std::string> GetSerialNumber(const std::string& guid) override;
  std::optional<FlutterError> SetSerialNumber(const std::string& guid, const std::string& sn) override;
  ErrorOr<int64_t> GetBattPower(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> GetSamplingFrequency(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorGain> GetGain(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorDataOffset> GetDataOffset(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorFirmwareMode> GetFirmwareMode(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorVersion> GetVersion(const std::string& guid) override;
  ErrorOr<int64_t> GetChannelsCount(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorFamily> GetSensFamily(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorAmpMode> GetAmpMode(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> GetSamplingFrequencyResist(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> GetSamplingFrequencyFPG(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FIrAmplitude> GetIrAmplitude(const std::string& guid) override;
  std::optional<FlutterError> SetIrAmplitude(const std::string& guid, const pigeon_neuro_api::FIrAmplitude& amp) override;
  ErrorOr<pigeon_neuro_api::FRedAmplitude> GetRedAmplitude(const std::string& guid) override;
  std::optional<FlutterError> SetRedAmplitude(const std::string& guid, const pigeon_neuro_api::FRedAmplitude& amp) override;
  void PingNeuroSmart(const std::string& guid, int64_t marker, std::function<void(std::optional<FlutterError>reply)> result) override;
  std::optional<FlutterError> SetGain(const std::string& guid, const pigeon_neuro_api::FSensorGain& gain) override;
  ErrorOr<bool> IsSupportedFilter(const std::string& guid, const pigeon_neuro_api::FSensorFilter& filter) override;
  ErrorOr<flutter::EncodableList> GetSupportedFilters(const std::string& guid) override;
  ErrorOr<flutter::EncodableList> GetHardwareFilters(const std::string& guid) override;
  std::optional<FlutterError> SetHardwareFilters(const std::string& guid, const flutter::EncodableList& filters) override;
  std::optional<FlutterError> SetFirmwareMode(const std::string& guid, const pigeon_neuro_api::FSensorFirmwareMode& mode) override;
  std::optional<FlutterError> SetSamplingFrequency(const std::string& guid, const pigeon_neuro_api::FSensorSamplingFrequency& sf) override;
  std::optional<FlutterError> SetDataOffset(const std::string& guid, const pigeon_neuro_api::FSensorDataOffset& offset) override;
  ErrorOr<pigeon_neuro_api::FSensorExternalSwitchInput> GetExtSwInput(const std::string& guid) override;
  std::optional<FlutterError> SetExtSwInput(const std::string& guid, const pigeon_neuro_api::FSensorExternalSwitchInput& ext_sw_inp) override;
  ErrorOr<pigeon_neuro_api::FSensorADCInput> GetADCInput(const std::string& guid) override;
  std::optional<FlutterError> SetADCInput(const std::string& guid, const pigeon_neuro_api::FSensorADCInput& adc_inp) override;
  ErrorOr<pigeon_neuro_api::FCallibriStimulatorMAState> GetStimulatorMAState(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FCallibriStimulationParams> GetStimulatorParam(const std::string& guid) override;
  std::optional<FlutterError> SetStimulatorParam(const std::string& guid, const pigeon_neuro_api::FCallibriStimulationParams& param) override;
  ErrorOr<pigeon_neuro_api::FCallibriMotionAssistantParams> GetMotionAssistantParam(const std::string& guid) override;
  std::optional<FlutterError> SetMotionAssistantParam(const std::string& guid, const pigeon_neuro_api::FCallibriMotionAssistantParams& param) override;
  ErrorOr<pigeon_neuro_api::FCallibriMotionCounterParam> GetMotionCounterParam(const std::string& guid) override;
  std::optional<FlutterError> SetMotionCounterParam(const std::string& guid, const pigeon_neuro_api::FCallibriMotionCounterParam& param) override;
  ErrorOr<int64_t> GetMotionCounter(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FCallibriColorType> GetColor(const std::string& guid) override;
  ErrorOr<bool> GetMEMSCalibrateState(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> GetSamplingFrequencyResp(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> GetSamplingFrequencyEnvelope(const std::string& guid) override;
  ErrorOr<CallibriSignalType> GetSignalType(const std::string& guid) override;
  std::optional<FlutterError> SetSignalType(const std::string& guid, const CallibriSignalType& type) override;
  ErrorOr<pigeon_neuro_api::FCallibriElectrodeState> GetElectrodeState(const std::string& guid) override;
  ErrorOr<pigeon_neuro_api::FSensorAccelerometerSensitivity> GetAccSens(const std::string& guid) override;
  std::optional<FlutterError> SetAccSens(const std::string& guid, const pigeon_neuro_api::FSensorAccelerometerSensitivity& acc_sens) override;
  ErrorOr<pigeon_neuro_api::FSensorGyroscopeSensitivity> GetGyroSens(const std::string& guid) override;
  std::optional<FlutterError> SetGyroSens(const std::string& guid, const pigeon_neuro_api::FSensorGyroscopeSensitivity& gyro_sens) override;
  ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> GetSamplingFrequencyMEMS(const std::string& guid) override;
  ErrorOr<flutter::EncodableList> GetSupportedChannels(const std::string& guid) override;
  ErrorOr<BrainBit2AmplifierParamNative> GetAmplifierParamBB2(const std::string& guid) override;
  std::optional<FlutterError> SetAmplifierParamBB2(const std::string& guid, const BrainBit2AmplifierParamNative& param) override;

};

}  // namespace neurosdk2

#endif  // FLUTTER_PLUGIN_NEUROSDK2_PLUGIN_H_
