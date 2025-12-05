#include "neurosdk2_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include "include/constants.h"

#include <future>
#include <memory>
#include <sstream>

namespace neurosdk2 {

    using namespace pigeon_neuro_api;

// callbacks //////////////////////////

    void sensorsCallback(SensorScanner* ptr, SensorInfo* sensors, int32_t szSensors, void* userInfo)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(userInfo);
        flutter::EncodableList sensorsList = SensorInfosToList(sensors, szSensors);
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), sensorsList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->scannerEventSink->Success(result);
        }
        catch (...) { }
    }

    void onBatteryCallback(Sensor* sensor, int32_t battery, void* sensor_jobj)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(sensor_jobj);
        flutter::EncodableMap power{
            {flutter::EncodableValue("power"), battery}
        };
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), power}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->battPowerEventSink->Success(result);
        }
        catch (...) {}
    }

    void onConnectionStateCallback(Sensor* sensor, SensorState State, void* sensor_jobj)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(sensor_jobj);
        flutter::EncodableMap state{
            {flutter::EncodableValue("state"), State}
        };
        flutter::EncodableMap result{
           {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
           {flutter::EncodableValue(BRIGE_DATA), state }
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->stateEventSink->Success(result);
        }
        catch (...) {}
    }

    void onCallibriSignalDataReceived(Sensor* sensor, CallibriSignalData* data, int32_t size, void* sensor_jobj)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(sensor_jobj);

        flutter::EncodableList signalList = CallibriSignalDataToList(data, size);
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), signalList}
        };

        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->signalEventSink->Success(result);
        }
        catch (...) {}
    }

    void onCallibriRespirationDataReceived(Sensor* pSensor, CallibriRespirationData* pData, int32_t size, void* pVoid)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(pVoid);

        flutter::EncodableList signalList = CallibriRespirationDataToList(pData, size);
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), signalList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->callibriRespirationEventSink->Success(result);
        }
        catch (...) {}
    }

    void onCallibriElectrodeStateChanged(Sensor* pSensor, CallibriElectrodeState state, void* pVoid)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(pVoid);
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), state}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->callibriElectrodeStateEventSink->Success(result);
        }
        catch (...) {}
    }

    void onCallibriEnvelopeDataReceived(Sensor* pSensor, CallibriEnvelopeData* pData, int32_t size,
        void* pVoid)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(pVoid);
        flutter::EncodableList signalList = CallibriEnvelopeDataToList(pData, size);
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), signalList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->callibriEnvelopeEventSink->Success(result);
        }
        catch (...) {}
    }

    void onQuaternionDataCallbackCallibri(Sensor* sensor, QuaternionData* data, int32_t size, void* sensor_jobj)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(sensor_jobj);

        flutter::EncodableList dataList{};
        for (int i = 0; i < size; i++) {
            QuaternionData it = data[i];
            flutter::EncodableMap map{
                {flutter::EncodableValue("PackNum"),  (int)it.PackNum},
                {flutter::EncodableValue("W"), (double)it.W },
                {flutter::EncodableValue("X"), (double)it.X },
                {flutter::EncodableValue("Y"), (double)it.Y },
                {flutter::EncodableValue("Z"), (double)it.Z },
            };
            dataList.push_back(map);
        }
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), dataList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->quaternionEventSink->Success(result);
        }
        catch (...) {}
    }
    
    void onBrainBitResistDataReceived(Sensor* pSensor, BrainBitResistData data, void* pVoid)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(pVoid);

        flutter::EncodableMap map{
                 {flutter::EncodableValue("O1"), data.O1 },
                 {flutter::EncodableValue("O2"), data.O2 },
                 {flutter::EncodableValue("T3"), data.T3 },
                 {flutter::EncodableValue("T4"), data.T4 },
        };
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), map}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->resistEventSink->Success(result);
        }
        catch (...) {}
    }

    void onBrainBitSignalDataReceived(Sensor* pSensor, BrainBitSignalData* pData, int32_t size,
        void* pVoid)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(pVoid);
        flutter::EncodableList dataList{};
        for (int i = 0; i < size; i++) {
            BrainBitSignalData it = pData[i];
            flutter::EncodableMap map{
                {flutter::EncodableValue("PackNum"),  (int)it.PackNum},
                {flutter::EncodableValue("Marker"), (int)it.Marker },
                {flutter::EncodableValue("O1"), (double)it.O1 },
                {flutter::EncodableValue("O2"), (double)it.O2 },
                {flutter::EncodableValue("T3"),(double) it.T3 },
                {flutter::EncodableValue("T4"), (double)it.T4 },
            };
            dataList.push_back(map);
        }
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), dataList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->signalEventSink->Success(result);
        }
        catch (...) {}
    }
    
    void onMEMSDataCallback(Sensor* sensor, MEMSData* data, int32_t size, void* sensor_jobj)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(sensor_jobj);
        flutter::EncodableList dataList{};
        for (int i = 0; i < size; i++) {
            MEMSData it = data[i];
            flutter::EncodableMap accelerometerMap{
                {flutter::EncodableValue("X"), it.Accelerometer.X},
                {flutter::EncodableValue("Y"), it.Accelerometer.Y},
                {flutter::EncodableValue("Z"), it.Accelerometer.Z},
            };
            flutter::EncodableMap gyroscopeMap{
                {flutter::EncodableValue("X"), it.Gyroscope.X},
                {flutter::EncodableValue("Y"), it.Gyroscope.Y},
                {flutter::EncodableValue("Z"), it.Gyroscope.Z},
            };
            flutter::EncodableMap map{
                {flutter::EncodableValue("PackNum"), (int) it.PackNum},
                {flutter::EncodableValue("Accelerometer"),  accelerometerMap },
                {flutter::EncodableValue("Gyroscope"),  gyroscopeMap },
            };
            dataList.push_back(map);
        }
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), dataList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->memsEventSink->Success(result);
        }
        catch (...) {}
    }
    
    void onFPGDataReceived(Sensor* pSensor, FPGData* pData, int32_t size, void* pVoid)
    {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(pVoid);
        flutter::EncodableList dataList{};
        for (int i = 0; i < size; i++) {
            FPGData it = pData[i];
            flutter::EncodableMap map{
                {flutter::EncodableValue("PackNum"),  (int) it.PackNum},
                {flutter::EncodableValue("IrAmplitude"), (double) it.IrAmplitude },
                {flutter::EncodableValue("RedAmplitude"), (double) it.RedAmplitude }
            };
            dataList.push_back(map);
        }
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), dataList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->fpgEventSink->Success(result);
        }
        catch (...) {}
    }
    
    void onBB2ResistDataReceived(Sensor* ptr, ResistRefChannelsData* data, int32_t szData, void* userData) {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(userData);

        flutter::EncodableList dataList{};
        for (int i = 0; i < szData; i++) {
            ResistRefChannelsData it = data[i];
            std::vector<double> samplesList(it.Samples, it.Samples + it.SzSamples);
            std::vector<double> refsList(it.Referents, it.Referents + it.SzReferents);
            flutter::EncodableMap map{
                {flutter::EncodableValue("PackNum"),  (int) it.PackNum},
                {flutter::EncodableValue("Samples"),  samplesList },
                {flutter::EncodableValue("Referents"), refsList }
            };
            dataList.push_back(map);
        }
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), dataList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->resistEventSink->Success(result);
        }
        catch (...) {}
    }

    void onBB2SignalDataReceived(Sensor* ptr, SignalChannelsData* data, int32_t szData, void* userData) {
        CallbackData* plugin = reinterpret_cast<CallbackData*>(userData);


        flutter::EncodableList dataList{};
        for (int i = 0; i < szData; i++) {
            SignalChannelsData it = data[i];
            std::vector<double> samplesList(it.Samples, it.Samples + it.SzSamples);
            flutter::EncodableMap map{
                {flutter::EncodableValue("PackNum"),  (int) it.PackNum},
                {flutter::EncodableValue("Marker"), (int)it.Marker },
                {flutter::EncodableValue("Samples"),  samplesList }
            };
            dataList.push_back(map);
        }
        flutter::EncodableMap result{
            {flutter::EncodableValue(BRIGE_GUID), flutter::EncodableValue(std::string(plugin->guid))},
            {flutter::EncodableValue(BRIGE_DATA), dataList}
        };
        try {
            EventHolder* eHolder = EventHolder::GetInstance();
            eHolder->signalEventSink->Success(result);
        }
        catch (...) {}
    }
    ///////////////////////////////////////

// static
void Neurosdk2Plugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  //auto scannerCallbackChannel =
  //    std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
  //        registrar->messenger(), "neurosdk2",
  //        &flutter::StandardMethodCodec::GetInstance());

    

  auto plugin = std::make_unique<Neurosdk2Plugin>();
  auto plugin_raw = plugin.get();

  flutter::EventChannel<> sensorScannerChannel(
      registrar->messenger(), SCANNER_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  sensorScannerChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->scannerEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->scannerEventSink = nullptr;
              return nullptr;
          }));

  flutter::EventChannel<> signalChannel(
      registrar->messenger(), SIGNAL_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  signalChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->signalEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->signalEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> resistChannel(
      registrar->messenger(), RESIST_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  resistChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->resistEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->resistEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> ampModeChannel(
      registrar->messenger(), AMPMODE_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  ampModeChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->ampModeEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->ampModeEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> memsChannel(
      registrar->messenger(), MEMSDATA_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  memsChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->memsEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->memsEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> fpgChannel(
      registrar->messenger(), FPGDATA_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  fpgChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->fpgEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->fpgEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> callibriElectrodesChannel(
      registrar->messenger(), CALLIBRI_ELECTRODES_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  callibriElectrodesChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->callibriElectrodeStateEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->callibriElectrodeStateEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> callibriEnvelopeChannel(
      registrar->messenger(), CALLIBRI_ENVELOPE_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  callibriEnvelopeChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->callibriEnvelopeEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->callibriEnvelopeEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> callibriRespirationChannel(
      registrar->messenger(), CALLIBRI_RESPIRATION_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  callibriRespirationChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->callibriRespirationEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->callibriRespirationEventSink = nullptr;
              return nullptr;
          })
  );


  flutter::EventChannel<> callibriQuaternionChannel(
      registrar->messenger(), CALLIBRI_QUATERNION_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  callibriQuaternionChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->quaternionEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->quaternionEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> connectionChannel(
      registrar->messenger(), CONNECTION_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  connectionChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->stateEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->stateEventSink = nullptr;
              return nullptr;
          })
  );

  flutter::EventChannel<> batteryChannel(
      registrar->messenger(), BATTERY_CALLBACK,
      &flutter::StandardMethodCodec::GetInstance());
  batteryChannel.SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<>>(
          [](auto arguments, auto events) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->battPowerEventSink = std::move(events);
              return nullptr;
          },
          [plugin_raw](auto arguments) {
              EventHolder* eHolder = EventHolder::GetInstance();
              eHolder->battPowerEventSink = nullptr;
              return nullptr;
          })
  );

  SetUp(registrar->messenger(), plugin_raw);

  registrar->AddPlugin(std::move(plugin));
}



Neurosdk2Plugin::Neurosdk2Plugin() {}

Neurosdk2Plugin::~Neurosdk2Plugin() {}

void Neurosdk2Plugin::CreateScanner(const flutter::EncodableList& filters, std::function<void(ErrorOr<std::string>reply)> result)
{
    size_t size = filters.size();
    SensorFamily* filtersList = new SensorFamily[size];
    int i = 0;
    for each (auto filter in filters) {
        SensorFamily nativeSensFamily;
        switch (filter.LongValue())
        {
        case 0:
            nativeSensFamily = SensorFamily::SensorLECallibri;
            break;
        case 1:
            nativeSensFamily = SensorFamily::SensorLEKolibri;
            break;
        case 2:
            nativeSensFamily = SensorFamily::SensorLEBrainBit;
            break;
        case 3:
            nativeSensFamily = SensorFamily::SensorLEBrainBitBlack;
            break;
        case 4:
            nativeSensFamily = SensorFamily::SensorLEBrainBit2;
            break;
        case 5:
            nativeSensFamily = SensorFamily::SensorLEBrainBitPro;
            break;
        case 6:
            nativeSensFamily = SensorFamily::SensorLEBrainBitFlex;
            break;
        case 7:
            nativeSensFamily = SensorFamily::SensorUnknown;
            break;
        default:
            nativeSensFamily = SensorFamily::SensorUnknown;
            break;
        }
        filtersList[i] = nativeSensFamily;
        i++;
    }
    OpStatus st;
    SensorScanner* scanner = createScanner(filtersList, (int32_t)size, &st);
     if (st.Success == 1 && scanner != nullptr) {
         std::string uuid_out = CreateUUID();

         ScannerHolder holder;
         holder.scanner = scanner;
         SensorsListenerHandle lHandle = nullptr;
         CallbackData* userData = new CallbackData();
         userData->guid = uuid_out;
         addSensorsCallbackScanner(scanner, sensorsCallback, &lHandle, userData, &st);
         holder.scanCallbackHandle = lHandle;
     
         _scanners.insert_or_assign(uuid_out, holder);
         result(ErrorOr<std::string>(uuid_out));
     }
     else {
         result(ErrorOr<std::string>(FlutterError(st.ErrorMsg)));
     }
}

void Neurosdk2Plugin::CloseScanner(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _scanners.find(guid);
    if (pos == _scanners.end()) {
        result(FlutterError("Scanner does not exist!"));
    }
    else {
        SensorScanner* scanner = (pos->second).scanner;
        if ((pos->second).scanCallbackHandle != nullptr) {
            removeSensorsCallbackScanner((pos->second).scanCallbackHandle);
        }
        freeScanner(scanner);
        _scanners.erase(guid);
        result({});
    }
}

void Neurosdk2Plugin::StartScan(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _scanners.find(guid);
    if (pos == _scanners.end()) {
        result(FlutterError("Scanner does not exist!"));
    }
    else {
        OpStatus st;
        SensorScanner* scanner = (pos->second).scanner;
        startScanner(scanner, &st, 1);
        if (st.Success) {
            result({});
        }
        else {
            result(FlutterError(st.ErrorMsg));
        }
    }
}

void Neurosdk2Plugin::StopScan(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _scanners.find(guid);
    if (pos == _scanners.end()) {
        result(FlutterError("Scanner does not exist!"));
    }
    else {
        OpStatus st;
        SensorScanner* scanner = (pos->second).scanner;
        stopScanner(scanner, &st);
        if (st.Success) {
            result({});
        }
        else {
            result(FlutterError(st.ErrorMsg));
        }
    }
}

void Neurosdk2Plugin::CreateSensor(const std::string& guid, const FSensorInfo& sensor_info, std::function<void(ErrorOr<std::string>reply)> result)
{
    auto pos = _scanners.find(guid);
    if (pos == _scanners.end()) {
        result(FlutterError("Scanner does not exist!"));
    }
    else {
        OpStatus st;
        std::string uuid_out = CreateUUID();

        SensorInfo info;
        strcpy_s(info.Name, sizeof info.Name, sensor_info.name().c_str());
        strcpy_s(info.SerialNumber, sizeof info.SerialNumber, sensor_info.serial_number().c_str());
        strcpy_s(info.Address, sizeof info.Address, sensor_info.address().c_str());
        info.SensModel = static_cast<uint8_t>(sensor_info.sens_model());
        info.PairingRequired = sensor_info.pairing_required() ? 1 : 0;
        info.RSSI = static_cast<int16_t>(sensor_info.rssi());
        SensorFamily nativeSensFamily;
        switch (sensor_info.sens_family())
        {
        case FSensorFamily::kLeCallibri:
            nativeSensFamily = SensorFamily::SensorLECallibri;
            break;
        case FSensorFamily::kLeKolibri:
            nativeSensFamily = SensorFamily::SensorLEKolibri;
            break;
        case FSensorFamily::kLeBrainBit:
            nativeSensFamily = SensorFamily::SensorLEBrainBit;
            break;
        case FSensorFamily::kLeBrainBitBlack:
            nativeSensFamily = SensorFamily::SensorLEBrainBitBlack;
            break;
        case FSensorFamily::kLeBrainBit2:
            nativeSensFamily = SensorFamily::SensorLEBrainBit2;
            break;
        case FSensorFamily::kLeBrainBitPro:
            nativeSensFamily = SensorFamily::SensorLEBrainBitPro;
            break;
        case FSensorFamily::kLeBrainBitFlex:
            nativeSensFamily = SensorFamily::SensorLEBrainBitFlex;
            break;
        case FSensorFamily::kUnknown:
            nativeSensFamily = SensorFamily::SensorUnknown;
            break;
        default:
            nativeSensFamily = SensorFamily::SensorUnknown;
            break;
        }
        info.SensFamily = nativeSensFamily;

        std::async(std::launch::async, [&]()
            {
                Sensor* sensor = createSensor((pos->second).scanner, info, &st);

                if (st.Success && sensor) {
                    SensorHolder sHolder;
                    sHolder.sensor = sensor;
                    CallbackData* userData = new CallbackData();
                    userData->guid = uuid_out;

                    BattPowerListenerHandle bplHandle = nullptr;
                    addBatteryCallback(sensor, onBatteryCallback, &bplHandle, userData, &st);
                    sHolder.battPowerHandle = bplHandle;

                    SensorStateListenerHandle sslHandle = nullptr;
                    addConnectionStateCallback(sensor, onConnectionStateCallback, &sslHandle, userData, &st);
                    sHolder.stateHandle = sslHandle;

                    if (isSupportedFeatureSensor(sensor, SensorFeature::FeatureMEMS))
                    {
                        MEMSDataListenerHandle memsHandle = nullptr;
                        addMEMSDataCallback(sensor, onMEMSDataCallback, &memsHandle, userData, &st);
                        sHolder.memsHandle = memsHandle;
                    }
                    if (isSupportedFeatureSensor(sensor, SensorFeature::FeatureFPG)) {
                        FPGDataListenerHandle  fpgHandle = nullptr;
                        addFPGDataCallback(sensor, onFPGDataReceived, &fpgHandle, userData, &st);
                        sHolder.fpgHande = fpgHandle;
                    }
                    if (nativeSensFamily == SensorFamily::SensorLECallibri || nativeSensFamily == SensorFamily::SensorLEKolibri)
                    {
                        if (isSupportedFeatureSensor(sensor, SensorFeature::FeatureSignal)) {
                            CallibriSignalDataListenerHandle csdlHandle = nullptr;
                            addSignalCallbackCallibri(sensor, onCallibriSignalDataReceived, &csdlHandle, userData, &st);
                            sHolder.callibriSignalHandle = csdlHandle;

                            CallibriElectrodeStateListenerHandle ceslHandle = nullptr;
                            addElectrodeStateCallbackCallibri(sensor, onCallibriElectrodeStateChanged, &ceslHandle, userData, &st);
                            sHolder.callibriElectrodeStateHandle = ceslHandle;
                        }

                        if (isSupportedFeatureSensor(sensor, SensorFeature::FeatureRespiration))
                        {
                            CallibriRespirationDataListenerHandle crdlHandle = nullptr;
                            addRespirationCallbackCallibri(sensor, onCallibriRespirationDataReceived, &crdlHandle, userData, &st);
                            sHolder.callibriRespirationHandle = crdlHandle;
                        }

                        if (isSupportedFeatureSensor(sensor, SensorFeature::FeatureEnvelope))
                        {
                            CallibriEnvelopeDataListenerHandle cedlHandle = nullptr;
                            addEnvelopeDataCallbackCallibri(sensor, onCallibriEnvelopeDataReceived, &cedlHandle, userData, &st);
                            sHolder.callibriEnvelopeHandle = cedlHandle;
                        }

                        if (isSupportedFeatureSensor(sensor, SensorFeature::FeatureMEMS))
                        {
                            QuaternionDataListenerHandle qdlHandle = nullptr;
                            addQuaternionDataCallback(sensor, onQuaternionDataCallbackCallibri, &qdlHandle, userData, &st);
                            sHolder.quaternionHandle = qdlHandle;
                        }
                    }
                    if (nativeSensFamily == SensorFamily::SensorLEBrainBit || nativeSensFamily == SensorFamily::SensorLEBrainBitBlack)
                    {
                        BrainBitSignalDataListenerHandle bsdlHandle = nullptr;
                        addSignalDataCallbackBrainBit(sensor, onBrainBitSignalDataReceived, &bsdlHandle, userData, &st);
                        sHolder.bbSignalHandle = bsdlHandle;

                        BrainBitResistDataListenerHandle brdlHandle = nullptr;
                        addResistCallbackBrainBit(sensor, onBrainBitResistDataReceived, &brdlHandle, userData, &st);
                        sHolder.bbResistHandle = brdlHandle;
                    }
                    if (nativeSensFamily == SensorFamily::SensorLEBrainBit2 ||
                        nativeSensFamily == SensorFamily::SensorLEBrainBitPro ||
                        nativeSensFamily == SensorFamily::SensorLEBrainBitFlex)
                    {
                        BrainBit2SignalDataListenerHandle bb2sdlHandle = nullptr;
                        addSignalCallbackBrainBit2(sensor, onBB2SignalDataReceived, &bb2sdlHandle, userData, &st);
                        sHolder.bb2SignalHandle = bb2sdlHandle;

                        BrainBit2ResistDataListenerHandle bb2rdlHandle = nullptr;
                        addResistCallbackBrainBit2(sensor, onBB2ResistDataReceived, &bb2rdlHandle, userData, &st);
                        sHolder.bb2ResistHandle = bb2rdlHandle;
                    }
                    _sensors.insert_or_assign(uuid_out, sHolder);
                    result(ErrorOr<std::string>(uuid_out));
                }
                else {
                    result(FlutterError(st.ErrorMsg));
                }
            }).get();
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::GetSensors(const std::string& guid)
{
    auto pos = _scanners.find(guid);
    if (pos == _scanners.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Scanner does not exist!"));
    }
    else {
        OpStatus st;
        SensorScanner* scanner = (pos->second).scanner;
        int32_t szSensorsInOut = 32;
        SensorInfo* sensors = new SensorInfo[szSensorsInOut];
        sensorsScanner(scanner, sensors, &szSensorsInOut, &st);
        if (st.Success) {
            flutter::EncodableList list{};
            while (szSensorsInOut--)
            {
                auto elem = sensors[szSensorsInOut];
                FSensorInfo fsi(
                    std::string(elem.Name),
                    std::string(elem.Address),
                    std::string(elem.SerialNumber),
                    elem.PairingRequired ? true : false,
                    (int64_t)elem.SensModel,
                    SensFamilyToFSensFamily(elem.SensFamily),
                    (int64_t)elem.RSSI
                );
                list.push_back(flutter::CustomEncodableValue(fsi));
            }
            return ErrorOr<flutter::EncodableList>(list);
        }
        else {
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        }
    }
}

void Neurosdk2Plugin::CloseSensor(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        result(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        if ((pos->second).stateHandle != nullptr) {
            removeConnectionStateCallback((pos->second).stateHandle);
        }
        if ((pos->second).battPowerHandle != nullptr) {
            removeBatteryCallback((pos->second).battPowerHandle);
        }
        if ((pos->second).bb2SignalHandle != nullptr) {
            removeSignalCallbackBrainBit2((pos->second).bb2SignalHandle);
        }
        if ((pos->second).bb2ResistHandle != nullptr) {
            removeResistCallbackBrainBit2((pos->second).bb2ResistHandle);
        }
        if ((pos->second).callibriSignalHandle != nullptr) {
            removeSignalCallbackCallibri((pos->second).callibriSignalHandle);
        }
        if ((pos->second).callibriRespirationHandle != nullptr) {
            removeRespirationCallbackCallibri((pos->second).callibriRespirationHandle);
        }
        if ((pos->second).callibriElectrodeStateHandle != nullptr) {
            removeElectrodeStateCallbackCallibri((pos->second).callibriElectrodeStateHandle);
        }
        if ((pos->second).callibriEnvelopeHandle != nullptr) {
            removeEnvelopeDataCallbackCallibri((pos->second).callibriEnvelopeHandle);
        }
        if ((pos->second).quaternionHandle != nullptr) {
            removeQuaternionDataCallback((pos->second).quaternionHandle);
        }
        if ((pos->second).memsHandle != nullptr) {
            removeMEMSDataCallback((pos->second).memsHandle);
        }
        if ((pos->second).fpgHande != nullptr) {
            removeFPGDataCallback((pos->second).fpgHande);
        }
        if ((pos->second).ampModeHandle != nullptr) {
            removeAmpModeCallback((pos->second).ampModeHandle);
        }
        if ((pos->second).bbSignalHandle != nullptr) {
            removeSignalDataCallbackBrainBit((pos->second).bbSignalHandle);
        }
        if ((pos->second).bbResistHandle != nullptr) {
            removeResistCallbackBrainBit((pos->second).bbResistHandle);
        }
        freeSensor(sensor);
        _sensors.erase(guid);
        result({});
    }
}

void Neurosdk2Plugin::ConnectSensor(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        result(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        std::async(std::launch::async, [&]()
        {
            connectSensor(sensor, &st);
            if (st.Success) {
                result({});
            }
            else {
                result(FlutterError(st.ErrorMsg));
            }
        }).get();
    }
}

void Neurosdk2Plugin::DisconnectSensor(const std::string& guid, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        result(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        std::async(std::launch::async, [&]()
        {
            disconnectSensor(sensor, &st);
            if (st.Success) {
                result({});
            }
            else {
                result(FlutterError(st.ErrorMsg));
            }
        }).get();
        
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::SupportedFeatures(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        int32_t szSensorFeatureInOut = getFeaturesCountSensor(sensor);
        SensorFeature* features = new SensorFeature[szSensorFeatureInOut];
        getFeaturesSensor(sensor, features, &szSensorFeatureInOut, &st);
        if (st.Success) {
            flutter::EncodableList list(features, features + szSensorFeatureInOut);
            delete[] features;
            return ErrorOr<flutter::EncodableList>(list);
        }
        else {
            delete[] features;
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<bool> Neurosdk2Plugin::IsSupportedFeature(const std::string& guid, const pigeon_neuro_api::FSensorFeature& feature)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<bool>(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        return ErrorOr<bool>(isSupportedFeatureSensor(sensor, static_cast<SensorFeature>(feature)));
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::SupportedCommands(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor; 
        int32_t szSensorCommandsInOut = getCommandsCountSensor(sensor);
        SensorCommand* commands = new SensorCommand[szSensorCommandsInOut];
        getCommandsSensor(sensor, commands, &szSensorCommandsInOut, &st);
        if (st.Success) {
            flutter::EncodableList list(commands, commands + szSensorCommandsInOut);
            delete[] commands;
            return ErrorOr<flutter::EncodableList>(list);
        }
        else {
            delete[] commands;
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        }
    }
    
}

ErrorOr<bool> Neurosdk2Plugin::IsSupportedCommand(const std::string& guid, const pigeon_neuro_api::FSensorCommand& command)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<bool>(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        return ErrorOr<bool>(isSupportedCommandSensor(sensor, static_cast<SensorCommand>(command)));
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::SupportedParameters(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;

        int32_t szSensorParametersInOut = getParametersCountSensor(sensor);
        ParameterInfo* sensor_parameter = new ParameterInfo[szSensorParametersInOut];
        getParametersSensor(sensor, sensor_parameter, &szSensorParametersInOut, &st);
        if (st.Success) {
            flutter::EncodableList list{};
            while (szSensorParametersInOut--) {
                ParameterInfo nInfo = sensor_parameter[szSensorParametersInOut];
                FParameterInfo pInfo(
                    static_cast<FSensorParameter>(nInfo.Param),
                    static_cast<FSensorParamAccess>(nInfo.ParamAccess)
                );
                list.push_back(flutter::CustomEncodableValue(pInfo));
            }
            return ErrorOr<flutter::EncodableList>(list);
        }
        else {
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<bool> Neurosdk2Plugin::IsSupportedParameter(const std::string& guid, const pigeon_neuro_api::FSensorParameter& parameter)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<bool>(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        return ErrorOr<bool>(isSupportedParameterSensor(sensor, static_cast<SensorParameter>(parameter)));
    }
}

void Neurosdk2Plugin::ExecCommand(const std::string& guid, const pigeon_neuro_api::FSensorCommand& command, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        result(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        execCommandSensor(sensor, static_cast<SensorCommand>(command), &st);
        if (st.Success) {
            result({});
        }
        else {
            result(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<std::string> Neurosdk2Plugin::GetName(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<std::string>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        char name[SENSOR_NAME_LEN];
        Sensor* sensor = (pos->second).sensor;
        readNameSensor(sensor, name, SENSOR_NAME_LEN, &st);
        if (st.Success) {
            return ErrorOr<std::string>(name);
        }
        else {
            return ErrorOr<std::string>(FlutterError(st.ErrorMsg));
        }
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetName(const std::string& guid, const std::string& name)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return FlutterError("Sensor does not exist!");
    }
    else {
        OpStatus st;
        char n_name[SENSOR_NAME_LEN];
        strcpy_s(n_name, name.c_str());
        Sensor* sensor = (pos->second).sensor;
        writeNameSensor(sensor, n_name, SENSOR_NAME_LEN, &st);
        if (st.Success) {
            return {};
        }
        else {
            return FlutterError(st.ErrorMsg);
        }
    }
}

ErrorOr<pigeon_neuro_api::FSensorState> Neurosdk2Plugin::GetState(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<pigeon_neuro_api::FSensorState>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorState state;
        readStateSensor(sensor, &state, &st);
        if (st.Success) {
            return ErrorOr<pigeon_neuro_api::FSensorState>(static_cast<pigeon_neuro_api::FSensorState>(state));
        }
        else {
            return ErrorOr<pigeon_neuro_api::FSensorState>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<std::string> Neurosdk2Plugin::GetAddress(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<std::string>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        char n_addr[SENSOR_ADR_LEN];
        readAddressSensor(sensor, n_addr, SENSOR_ADR_LEN, &st);
        if (st.Success) {
            return ErrorOr<std::string>(std::string(n_addr));
        }
        else {
            return ErrorOr<std::string>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<std::string> Neurosdk2Plugin::GetSerialNumber(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<std::string>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        char n_sn[SENSOR_SN_LEN];
        readSerialNumberSensor(sensor, n_sn, SENSOR_NAME_LEN, &st);
        if (st.Success) {
            return ErrorOr<std::string>(std::string(n_sn));
        }
        else {
            return ErrorOr<std::string>(FlutterError(st.ErrorMsg));
        }
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetSerialNumber(const std::string& guid, const std::string& sn)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return FlutterError("Sensor does not exist!");
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        char n_sn[SENSOR_SN_LEN];
        strcpy_s(n_sn, sn.c_str());
        if (writeSerialNumberSensor(sensor, n_sn, SENSOR_SN_LEN, &st)) {
            return {};
        }
        else {
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<int64_t> Neurosdk2Plugin::GetBattPower(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<int64_t>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        int32_t battery = 0;
        OpStatus outStatus;
        if (readBattPowerSensor(sensor, &battery, &outStatus)) {
            return ErrorOr<int64_t>(static_cast<int64_t>(battery));
        }
        else {
            return ErrorOr<int64_t>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<FSensorSamplingFrequency> Neurosdk2Plugin::GetSamplingFrequency(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorSamplingFrequency>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorSamplingFrequency sensorSamplingFrequency;
        if (readSamplingFrequencySensor(sensor, &sensorSamplingFrequency, &st)) {
            return ErrorOr<FSensorSamplingFrequency>(static_cast<FSensorSamplingFrequency>(sensorSamplingFrequency));
        }
        else {
            return ErrorOr<FSensorSamplingFrequency>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FSensorGain> Neurosdk2Plugin::GetGain(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<pigeon_neuro_api::FSensorGain>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorGain sensorGain;
        if (readGainSensor(sensor, &sensorGain, &st)) {
            return ErrorOr<FSensorGain>(static_cast<FSensorGain>(sensorGain));
        }
        else {
            return ErrorOr<pigeon_neuro_api::FSensorGain>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FSensorDataOffset> Neurosdk2Plugin::GetDataOffset(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorDataOffset>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorDataOffset sensorOffset;
        if (readDataOffsetSensor(sensor, &sensorOffset, &st)) {
            return ErrorOr<FSensorDataOffset>(static_cast<FSensorDataOffset>(sensorOffset));
        }
        else {
            return ErrorOr<FSensorDataOffset>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FSensorFirmwareMode> Neurosdk2Plugin::GetFirmwareMode(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorFirmwareMode>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorFirmwareMode sensorFirmwareMode;
        if (readFirmwareModeSensor(sensor, &sensorFirmwareMode, &st)) {
            return ErrorOr<FSensorFirmwareMode>(static_cast<FSensorFirmwareMode>(sensorFirmwareMode));
        }
        else {
            return ErrorOr<FSensorFirmwareMode>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FSensorVersion> Neurosdk2Plugin::GetVersion(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorVersion>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorVersion n_sensorVersion;
        if (readVersionSensor(sensor, &n_sensorVersion, &st)) {
            FSensorVersion version(n_sensorVersion.FwMajor,
                                   n_sensorVersion.FwMinor,
                                   n_sensorVersion.FwPatch,
                                   n_sensorVersion.HwMajor,
                                   n_sensorVersion.HwMinor,
                                   n_sensorVersion.HwPatch,
                                   n_sensorVersion.ExtMajor);
            return ErrorOr<FSensorVersion>(version);
        }
        else {
            return ErrorOr<FSensorVersion>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<int64_t> Neurosdk2Plugin::GetChannelsCount(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<int64_t>(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        int32_t count = getChannelsCountSensor(sensor);
        return ErrorOr<int64_t>(static_cast<int64_t>(count));
    }
}

ErrorOr<pigeon_neuro_api::FSensorFamily> Neurosdk2Plugin::GetSensFamily(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorFamily>(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        SensorFamily sensor_family = getFamilySensor(sensor);
        FSensorFamily fSensFamily;
        switch (sensor_family)
        {
        case SensorLENeuroEEG:
        case SensorLEEarBuds:
        case SensorLEImpulse:
        case SensorLEP300:
        case SensorLENeurro:
        case SensorLESmartLeg:
        case SensorUnknown:
            fSensFamily = FSensorFamily::kUnknown;
            break;
        case SensorLECallibri:
            fSensFamily = FSensorFamily::kLeCallibri;
            break;
        case SensorLEKolibri:
            fSensFamily = FSensorFamily::kLeKolibri;
            break;
        case SensorLEBrainBit:
            fSensFamily = FSensorFamily::kLeBrainBit;
            break;
        case SensorLEBrainBitBlack:
            fSensFamily = FSensorFamily::kLeBrainBitBlack;
            break;
        case SensorLEBrainBit2:
            fSensFamily = FSensorFamily::kLeBrainBit2;
            break;
        case SensorLEBrainBitPro:
            fSensFamily = FSensorFamily::kLeBrainBitPro;
            break;
        case SensorLEBrainBitFlex:
            fSensFamily = FSensorFamily::kLeBrainBitFlex;
            break;
        default:
            break;
        }
        return ErrorOr<FSensorFamily>(fSensFamily);
    }
}

ErrorOr<pigeon_neuro_api::FSensorAmpMode> Neurosdk2Plugin::GetAmpMode(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorAmpMode>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorAmpMode sensorAmpMode;
        if (readAmpMode(sensor, &sensorAmpMode, &st)) {
            return ErrorOr<FSensorAmpMode>(static_cast<FSensorAmpMode>(sensorAmpMode));
        }
        else {
            return ErrorOr<FSensorAmpMode>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<FSensorSamplingFrequency> Neurosdk2Plugin::GetSamplingFrequencyResist(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorSamplingFrequency>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorSamplingFrequency sensorSamplingFrequency;
        if (readSamplingFrequencyResistSensor(sensor, &sensorSamplingFrequency, &st)) {
            return ErrorOr<FSensorSamplingFrequency>(SensFreqToFSensFreq(sensorSamplingFrequency));
        }
        else {
            return ErrorOr<FSensorSamplingFrequency>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> Neurosdk2Plugin::GetSamplingFrequencyFPG(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorSamplingFrequency>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorSamplingFrequency sensorSamplingFrequency;
        if (readSamplingFrequencyFPGSensor(sensor, &sensorSamplingFrequency, &st)) {
            return ErrorOr<FSensorSamplingFrequency>(SensFreqToFSensFreq(sensorSamplingFrequency));
        }
        else {
            return ErrorOr<FSensorSamplingFrequency>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FIrAmplitude> Neurosdk2Plugin::GetIrAmplitude(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FIrAmplitude>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        IrAmplitude irAmplitude;
        if (readIrAmplitudeFPGSensor(sensor, &irAmplitude, &st)) {
            return ErrorOr<FIrAmplitude>(IrAmpToFIrAmp(irAmplitude));
        }
        else {
            return ErrorOr<FIrAmplitude>(FlutterError(st.ErrorMsg));
        }
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetIrAmplitude(const std::string& guid, const pigeon_neuro_api::FIrAmplitude& amp)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        IrAmplitude irAmplitude = FIrAmpToIrAmp(amp);
        if (writeIrAmplitudeFPGSensor(sensor, irAmplitude, &st)) {
            return std::optional<FlutterError>({});
        }
        else {
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<pigeon_neuro_api::FRedAmplitude> Neurosdk2Plugin::GetRedAmplitude(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FRedAmplitude>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        RedAmplitude redAmplitude;
        if (readRedAmplitudeFPGSensor(sensor, &redAmplitude, &st)) {
            return ErrorOr<FRedAmplitude>(RedAmpToFRedAmp(redAmplitude));
        }
        else {
            return ErrorOr<FRedAmplitude>(FlutterError(st.ErrorMsg));
        }
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetRedAmplitude(const std::string& guid, const pigeon_neuro_api::FRedAmplitude& amp)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto redAmplitude = FRedAmpToRedAmp(amp);
        if (writeRedAmplitudeFPGSensor(sensor, redAmplitude, &st)) {
            return std::optional<FlutterError>({});
        }
        else {
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        }
    }
}

void Neurosdk2Plugin::PingNeuroSmart(const std::string& guid, int64_t marker, std::function<void(std::optional<FlutterError>reply)> result)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        result(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        if (pingNeuroSmart(sensor, static_cast<uint8_t>(marker), &st)) {
            result({});
        }
        else {
            result(FlutterError(st.ErrorMsg));
        }
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetGain(const std::string& guid, const pigeon_neuro_api::FSensorGain& gain)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorGain sensorGain = static_cast<SensorGain>(gain);
        if (writeGainSensor(sensor, sensorGain, &st)) {
            return std::optional<FlutterError>({});
        }
        else {
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        }
    }
}

ErrorOr<bool> Neurosdk2Plugin::IsSupportedFilter(const std::string& guid, const pigeon_neuro_api::FSensorFilter& filter)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<bool>(FlutterError("Sensor does not exist!"));
    }
    else {
        Sensor* sensor = (pos->second).sensor;
        auto sensorFilter = FSFilterToSFilter(filter);
        uint8_t state = isSupportedFilterSensor(sensor, sensorFilter);
        return ErrorOr<bool>(state != 0);
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::GetSupportedFilters(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        int szFilters = getSupportedFiltersCountSensor(sensor);
        SensorFilter* filtersOut = new SensorFilter[szFilters];
        if (!getSupportedFiltersSensor(sensor, filtersOut, &szFilters, &st)) {
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        }


        flutter::EncodableList list(filtersOut, filtersOut + szFilters);
        delete[] filtersOut;
        return ErrorOr<flutter::EncodableList>(list);
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::GetHardwareFilters(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        int32_t szFiltersInOut = 64;
        SensorFilter* filtersOut = new SensorFilter[szFiltersInOut];
        if (!readHardwareFiltersSensor(sensor, filtersOut, &szFiltersInOut, &st)) {
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        }

        flutter::EncodableList list(filtersOut, filtersOut + szFiltersInOut);
        delete[] filtersOut;
        return ErrorOr<flutter::EncodableList>(list);
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetHardwareFilters(const std::string& guid, const flutter::EncodableList& filters)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorFilter* sensor_filters = new SensorFilter[filters.size()];
        int i = 0;
        for each (auto filter in filters) {
            sensor_filters[i] = FSFilterToSFilter((FSensorFilter)filter.index());
            i++;
        }
        OpStatus outStatus;
        if (!writeHardwareFiltersSensor(sensor, sensor_filters, (int32_t)filters.size(), &outStatus))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetFirmwareMode(const std::string& guid, const pigeon_neuro_api::FSensorFirmwareMode& mode)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorFirmwareMode = static_cast<SensorFirmwareMode>(mode);
        if (!writeFirmwareModeSensor(sensor, sensorFirmwareMode, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetSamplingFrequency(const std::string& guid, const pigeon_neuro_api::FSensorSamplingFrequency& sf)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorSamplingFrequency = FSensFreqToSensFreq(sf);
        if (!writeSamplingFrequencySensor(sensor, sensorSamplingFrequency, &st)){
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        }
        return std::optional<FlutterError>({});
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetDataOffset(const std::string& guid, const pigeon_neuro_api::FSensorDataOffset& offset)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorDataOffset = FDataOffsetToDataOffset(offset);
        if (!writeDataOffsetSensor(sensor, sensorDataOffset, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

ErrorOr<pigeon_neuro_api::FSensorExternalSwitchInput> Neurosdk2Plugin::GetExtSwInput(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<pigeon_neuro_api::FSensorExternalSwitchInput>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorExternalSwitchInput sensorExternalSwitchInput;
        if (!readExternalSwitchSensor(sensor, &sensorExternalSwitchInput, &st))
            return ErrorOr<pigeon_neuro_api::FSensorExternalSwitchInput>(FlutterError(st.ErrorMsg));
        return ErrorOr<pigeon_neuro_api::FSensorExternalSwitchInput>(ExtSwInpToFExtSwInp(sensorExternalSwitchInput));
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetExtSwInput(const std::string& guid, const pigeon_neuro_api::FSensorExternalSwitchInput& ext_sw_inp)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorExternalSwitchInput = FExtSwInpToExtSwInp(ext_sw_inp);
        if (!writeExternalSwitchSensor(sensor, sensorExternalSwitchInput, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

ErrorOr<FSensorADCInput> Neurosdk2Plugin::GetADCInput(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorADCInput>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorADCInput sensorAdcInput;
        if (!readADCInputSensor(sensor, &sensorAdcInput, &st))
            return ErrorOr<FSensorADCInput>(FlutterError(st.ErrorMsg));
        ErrorOr<FSensorADCInput>(static_cast<FSensorADCInput>(sensorAdcInput));
    }
    return ErrorOr<pigeon_neuro_api::FSensorADCInput>(pigeon_neuro_api::FSensorADCInput::kElectrodesInp);
}

std::optional<FlutterError> Neurosdk2Plugin::SetADCInput(const std::string& guid, const pigeon_neuro_api::FSensorADCInput& adc_inp)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorAdcInput = static_cast<SensorADCInput>(adc_inp);
        if (!writeADCInputSensor(sensor, sensorAdcInput, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

ErrorOr<pigeon_neuro_api::FCallibriStimulatorMAState> Neurosdk2Plugin::GetStimulatorMAState(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FCallibriStimulatorMAState>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriStimulatorMAState callibriStimulatorMaState;
        if (!readStimulatorAndMAStateCallibri(sensor, &callibriStimulatorMaState, &st)) {
            return ErrorOr<pigeon_neuro_api::FCallibriStimulatorMAState>(FlutterError(st.ErrorMsg));
        }
        FCallibriStimulatorMAState* maSt = new FCallibriStimulatorMAState(StimStateToFStimState(callibriStimulatorMaState.StimulatorState),
            StimStateToFStimState(callibriStimulatorMaState.MAState));
        return ErrorOr<pigeon_neuro_api::FCallibriStimulatorMAState>(*maSt);
    }
}

ErrorOr<pigeon_neuro_api::FCallibriStimulationParams> Neurosdk2Plugin::GetStimulatorParam(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<pigeon_neuro_api::FCallibriStimulationParams>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriStimulationParams stParams;
        OpStatus outStatus;
        if (!readStimulatorParamCallibri(sensor, &stParams, &outStatus)) {
            return ErrorOr<pigeon_neuro_api::FCallibriStimulationParams>(FlutterError(st.ErrorMsg));
        }
        pigeon_neuro_api::FCallibriStimulationParams* p = new pigeon_neuro_api::FCallibriStimulationParams((int64_t)stParams.Current, 
            (int64_t)stParams.PulseWidth, 
            (int64_t)stParams.Frequency, 
            (int64_t)stParams.StimulusDuration);
        return ErrorOr<pigeon_neuro_api::FCallibriStimulationParams>(*p);
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetStimulatorParam(const std::string& guid, const pigeon_neuro_api::FCallibriStimulationParams& param)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriStimulationParams nParams;
        nParams.Current = (uint8_t)param.current();
        nParams.Frequency = (uint8_t)param.frequency();
        nParams.PulseWidth = (uint16_t)param.pulse_width();
        nParams.StimulusDuration = (uint16_t)param.stimulus_duration();
        if (!writeStimulatorParamCallibri(sensor, nParams, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

ErrorOr<pigeon_neuro_api::FCallibriMotionAssistantParams> Neurosdk2Plugin::GetMotionAssistantParam(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FCallibriMotionAssistantParams>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriMotionAssistantParams MAParams;
        if (!readMotionAssistantParamCallibri(sensor, &MAParams, &st)) {
            return ErrorOr<FCallibriMotionAssistantParams>(FlutterError(st.ErrorMsg));
        }
        FCallibriMotionAssistantParams params((int64_t)MAParams.GyroStart, 
            (int64_t)MAParams.GyroStop, 
            static_cast<FCallibriMotionAssistantLimb>(MAParams.Limb),
            (int64_t)MAParams.MinPauseMs);
        return ErrorOr<pigeon_neuro_api::FCallibriMotionAssistantParams>(params);
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetMotionAssistantParam(const std::string& guid, const pigeon_neuro_api::FCallibriMotionAssistantParams& param)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriMotionAssistantParams callibriMotionAssistantParams;
        callibriMotionAssistantParams.GyroStart = (uint8_t)param.gyro_start();
        callibriMotionAssistantParams.GyroStop = (uint8_t)param.gyro_stop();
        callibriMotionAssistantParams.Limb = static_cast<CallibriMotionAssistantLimb>(param.limb());
        callibriMotionAssistantParams.MinPauseMs = (uint8_t)param.min_pause_ms();
        if (!writeMotionAssistantParamCallibri(sensor, callibriMotionAssistantParams, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>();
    }
}

ErrorOr<FCallibriMotionCounterParam> Neurosdk2Plugin::GetMotionCounterParam(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FCallibriMotionCounterParam>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriMotionCounterParam callibriMotionCounterParam;
        if (!readMotionCounterParamCallibri(sensor, &callibriMotionCounterParam, &st)) 
            return ErrorOr<FCallibriMotionCounterParam>(FlutterError(st.ErrorMsg));
        FCallibriMotionCounterParam params(callibriMotionCounterParam.InsenseThresholdMG, callibriMotionCounterParam.InsenseThresholdSample);
        return ErrorOr<pigeon_neuro_api::FCallibriMotionCounterParam>(params);
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetMotionCounterParam(const std::string& guid, const pigeon_neuro_api::FCallibriMotionCounterParam& param)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriMotionCounterParam callibriMotionCounterParam;
        callibriMotionCounterParam.InsenseThresholdMG = (uint16_t)param.insense_threshold_m_g();
        callibriMotionCounterParam.InsenseThresholdSample = (uint16_t)param.insense_threshold_sample();
        if (!writeMotionCounterParamCallibri(sensor, callibriMotionCounterParam, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>();
    }
}

ErrorOr<int64_t> Neurosdk2Plugin::GetMotionCounter(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<int64_t>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        uint32_t count = 0;
        if (!readMotionCounterCallibri(sensor, &count, &st))
            return ErrorOr<int64_t>(FlutterError(st.ErrorMsg));
        return ErrorOr<int64_t>(count);
    }
}

ErrorOr<pigeon_neuro_api::FCallibriColorType> Neurosdk2Plugin::GetColor(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FCallibriColorType>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriColorType callibriColorType;
        if (!readColorCallibri(sensor, &callibriColorType, &st))
            return ErrorOr<FCallibriColorType>(FlutterError(st.ErrorMsg));
        return ErrorOr<FCallibriColorType>(static_cast<FCallibriColorType>(callibriColorType));
    }
}

ErrorOr<bool> Neurosdk2Plugin::GetMEMSCalibrateState(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<bool>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        uint8_t state = 0;
        if (!readMEMSCalibrateStateCallibri(sensor, &state, &st))
            return ErrorOr<bool>(FlutterError(st.ErrorMsg));
        return ErrorOr<bool>(state != 0);
    }
}

ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> Neurosdk2Plugin::GetSamplingFrequencyResp(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorSamplingFrequency>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorSamplingFrequency sensorSamplingFrequency;
        if (!readSamplingFrequencyRespSensor(sensor, &sensorSamplingFrequency, &st))
            return ErrorOr<FSensorSamplingFrequency>(FlutterError(st.ErrorMsg));
        return ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency>(SensFreqToFSensFreq(sensorSamplingFrequency));
    }
}

ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> Neurosdk2Plugin::GetSamplingFrequencyEnvelope(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorSamplingFrequency>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorSamplingFrequency sensorSamplingFrequency;
        if (!readSamplingFrequencyEnvelopeSensor(sensor, &sensorSamplingFrequency, &st))
            return ErrorOr<FSensorSamplingFrequency>(FlutterError(st.ErrorMsg));
        return ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency>(SensFreqToFSensFreq(sensorSamplingFrequency));
    }
}

ErrorOr<CallibriSignalType> Neurosdk2Plugin::GetSignalType(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<CallibriSignalType>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SignalTypeCallibri signalType;
        OpStatus outStatus;

        if (!getSignalSettingsCallibri(sensor, &signalType, &outStatus))
            return ErrorOr<CallibriSignalType>(FlutterError(st.ErrorMsg));
        return ErrorOr<CallibriSignalType>(static_cast<CallibriSignalType>(signalType));
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetSignalType(const std::string& guid, const CallibriSignalType& type)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto nType = static_cast<SignalTypeCallibri>(type);
        if (!setSignalSettingsCallibri(sensor, nType, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

ErrorOr<pigeon_neuro_api::FCallibriElectrodeState> Neurosdk2Plugin::GetElectrodeState(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FCallibriElectrodeState>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        CallibriElectrodeState electrodeStateOut;
        if (!readElectrodeStateCallibri(sensor, &electrodeStateOut, &st))
            return ErrorOr<FCallibriElectrodeState>(FlutterError(st.ErrorMsg));
        return ErrorOr<FCallibriElectrodeState>(static_cast<FCallibriElectrodeState>(electrodeStateOut));
    }
}

ErrorOr<pigeon_neuro_api::FSensorAccelerometerSensitivity> Neurosdk2Plugin::GetAccSens(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<pigeon_neuro_api::FSensorAccelerometerSensitivity>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorAccelerometerSensitivity sensorAccelerometerSensitivity;
        if (!readAccelerometerSensSensor(sensor, &sensorAccelerometerSensitivity, &st))
            return ErrorOr<FSensorAccelerometerSensitivity>(FlutterError(st.ErrorMsg));
        return ErrorOr<FSensorAccelerometerSensitivity>(static_cast<FSensorAccelerometerSensitivity>(sensorAccelerometerSensitivity));
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetAccSens(const std::string& guid, const pigeon_neuro_api::FSensorAccelerometerSensitivity& acc_sens)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorAccelerometerSensitivity = static_cast<SensorAccelerometerSensitivity>(acc_sens);
        OpStatus outStatus;
        if (!writeAccelerometerSensSensor(sensor, sensorAccelerometerSensitivity, &outStatus))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>();
    }
}

ErrorOr<pigeon_neuro_api::FSensorGyroscopeSensitivity> Neurosdk2Plugin::GetGyroSens(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorGyroscopeSensitivity>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorGyroscopeSensitivity sensorGyroscopeSensitivity;
        OpStatus outStatus;
        if (!readGyroscopeSensSensor(sensor, &sensorGyroscopeSensitivity, &outStatus))
            return ErrorOr<FSensorGyroscopeSensitivity>(FlutterError(st.ErrorMsg));
        return ErrorOr<FSensorGyroscopeSensitivity>(static_cast<FSensorGyroscopeSensitivity>(sensorGyroscopeSensitivity));
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetGyroSens(const std::string& guid, const pigeon_neuro_api::FSensorGyroscopeSensitivity& gyro_sens)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        auto sensorGyroscopeSensitivity = static_cast<SensorGyroscopeSensitivity>(gyro_sens);
        if (!writeGyroscopeSensSensor(sensor, sensorGyroscopeSensitivity, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency> Neurosdk2Plugin::GetSamplingFrequencyMEMS(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<FSensorSamplingFrequency>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        SensorSamplingFrequency sensorSamplingFrequency;
        if (!readSamplingFrequencyMEMSSensor(sensor, &sensorSamplingFrequency, &st))
            return ErrorOr<FSensorSamplingFrequency>(FlutterError(st.ErrorMsg));
        return ErrorOr<pigeon_neuro_api::FSensorSamplingFrequency>(SensFreqToFSensFreq(sensorSamplingFrequency));
    }
}

ErrorOr<flutter::EncodableList> Neurosdk2Plugin::GetSupportedChannels(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<flutter::EncodableList>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        EEGChannelInfo channels[BRAINBIT2_MAX_CH_COUNT];
        int32_t szchannelsInOut = BRAINBIT2_MAX_CH_COUNT;
        if (!readSupportedChannelsBrainBit2(sensor, channels, &szchannelsInOut, &st))
            return ErrorOr<flutter::EncodableList>(FlutterError(st.ErrorMsg));
        
        flutter::EncodableList list{};
        for (int i = 0; i < szchannelsInOut; i++)
        {
            FEEGChannelInfo chInf(
                static_cast<FEEGChannelId>(channels[i].Id),
                static_cast<FEEGChannelType>(channels[i].ChType),
                std::string(channels[i].Name),
                (int64_t)channels[i].Num
            );
            list.push_back(flutter::CustomEncodableValue(chInf));
        }
        return ErrorOr<flutter::EncodableList>(list);
    }
}

ErrorOr<BrainBit2AmplifierParamNative> Neurosdk2Plugin::GetAmplifierParamBB2(const std::string& guid)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return ErrorOr<BrainBit2AmplifierParamNative>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        BrainBit2AmplifierParam ampParamOut;
        if (!readAmplifierParamBrainBit2(sensor, &ampParamOut, &st))
            return ErrorOr<BrainBit2AmplifierParamNative>(FlutterError(st.ErrorMsg));
        
        flutter::EncodableList ch_signal_mode{};
        for each (auto sMode in ampParamOut.ChSignalMode)
        {
            ch_signal_mode.push_back(flutter::CustomEncodableValue(static_cast<FBrainBit2ChannelMode>(sMode)));
        }
        flutter::EncodableList ch_resist_use{};
        for each (auto use in ampParamOut.ChResistUse)
        {
            ch_signal_mode.push_back(flutter::CustomEncodableValue(use == 1));
        }
        flutter::EncodableList ch_gain{};
        for each (auto gain in ampParamOut.ChGain)
        {
            ch_signal_mode.push_back(flutter::CustomEncodableValue(static_cast<FSensorGain>(gain)));
        }

        BrainBit2AmplifierParamNative* params = new BrainBit2AmplifierParamNative(ch_signal_mode, ch_resist_use, ch_gain, GenCurrentToFGenCurrent(ampParamOut.Current));
        return ErrorOr<BrainBit2AmplifierParamNative>(*params);
    }
}

std::optional<FlutterError> Neurosdk2Plugin::SetAmplifierParamBB2(const std::string& guid, const BrainBit2AmplifierParamNative& param)
{
    auto pos = _sensors.find(guid);
    if (pos == _sensors.end()) {
        return std::optional<FlutterError>(FlutterError("Sensor does not exist!"));
    }
    else {
        OpStatus st;
        Sensor* sensor = (pos->second).sensor;
        BrainBit2AmplifierParam ampParam;
        int i = 0;
        for each (auto sMode in param.ch_signal_mode()) {
            ampParam.ChSignalMode[i] = static_cast<BrainBit2ChannelMode>(sMode.LongValue());
            i++;
        }
        i = 0;
        for each (auto rUse in param.ch_resist_use()) {
            ampParam.ChResistUse[i] = static_cast<uint8_t>(rUse.valueless_by_exception());
            i++;
        }
        i = 0;
        for each (auto gain in param.ch_gain()) {
            ampParam.ChGain[i] = static_cast<SensorGain>(gain.LongValue());
            i++;
        }
        ampParam.Current = FGenCurrentToGenCurrent(param.current());
        if (!writeAmplifierParamBrainBit2(sensor, ampParam, &st))
            return std::optional<FlutterError>(FlutterError(st.ErrorMsg));
        return std::optional<FlutterError>({});
    }
}

}  // namespace neurosdk2
