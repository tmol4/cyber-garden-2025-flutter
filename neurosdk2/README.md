# neurosdk2

## Overview

Neurosdk is a powerful tool for working with neuro-sensors BrainBit, BrainBitBlack, Callibri and Kolibri. SDK allows you to connect, read the parameters of devices, as well as receive signals of various types from the selected device. 

Supported platforms:

 - Android
 - iOS
 - Windows
 - MacOs

### Errors

Here is a list of exceptions that occur when working with SDK. You need to be guided by this list in order to understand what happened in the process of executing a particular method.

| Code| Description                                             |
| ----| --------------------------------------------------------|
| 100 | Invalid scan parameters are specified                   |
| 101 | Invalid sensor types are specified for the search       |
| 102 |Failed to create sensor scanner                          |
| 103 |Failed to started sensor scanner                         |
| 104 |Failed to stopped sensor scanner                         |
| 105 |Failed to get a list of sensors                          |
| 106 |Failed to get a list of sensors                          |
| 107 |Invalid parameters for creating a sensor                 |
| 108 |Failed to create sensor                                  |
| 109 |Sensor not founded                                       |
| 110 |Failed to connect the sensor                             |
| 111 |Failed to disconnect the sensor                          |
| 112 |Failed to get a list of sensor features                  |
| 113 |Invalid parameters for get a list features of the sensor |
| 114 |Invalid parameters for get a list commands of the sensor |
| 115 |Failed to get a list of sensor commands                  |
| 116 |Invalid parameters for get a list parameters of the sensor|
| 117 |Failed to get a list of sensor parameters                |
| 118 |Failed to execute the sensor command                     |
| 119 |Failed read the sensor parameter                         |
| 120 |Failed read the sensor parameter                         |
| 121 |Failed write the sensor parameter                        |
| 122 |Failed write the sensor parameter                        |
| 123 |Failed add callback the sensor                           |
| 124 |Failed add callback the sensor                           |


## Usage

### Scanner

The scanner allows you to find devices nearby, it is also responsible for the first creation of the device. Whatever type of device you work with, the use of the scanner will be the same.

The scanner works like this:

1. Create scanner. 
When creating a scanner, you need to specify the type of device to search. It can be either one device or several. Here is example for two type of devices - BrainBit and Callibri.

```dart
Scanner sc = await Scanner.create([FSensorFamily.leBrainBit, FSensorFamily.leCallibri]);
```

2. During the search, you can get a list of found devices using a callback. To do this, you need to subscribe to receive the event, and unsubscribe after the search is completed:

```dart
StreamSubscription<List<FSensorInfo>>? scannerSubscription = scanner.sensorsStream.isten((foundedSensors) {
  for (FSensorInfo info in foundedSensors) {
    print("${info.name}");
  }
});
// remove subscription after use
scannerSubscription.cancel();
```

3. Start search

```dart
await scanner.start();
```

3. Stop search

```dart
await scanner.stop();
```

4. Additionally, a list of found devices can be obtained using a separate method.

```dart
List<FSensorInfo?> sensors = await scanner.getSensors();
```

###### Sensor info
`SensorInfo` contains information about device:

| Field | Type | Description |
|--|--|--|
|name|String|the name of device|
|address|String|MAC address of device (UUID for iOS/MacOS)|
|serialNumber|String|device's serial number|
|sensFamily|SensorFamily|type of device|
|sensModel|int|numerical value of the device model|
|pairingRequared|bool|whether the device needs to be paired or not|
|rssi|int|current signal strength in dBm. The valid range is [-127, 126]|

> Important!
> The serial number of the Callibri and Kolibri does not appear in the SensorInfo recieving during the search. To get this value, you need to connect to the device and request the serial number manually:
>

```dart
String serialNumber = await sensor.serialNumber.value;
```

5. After you finish working with the scanner, you need to clean up the resources used. 

```dart
scanner.dispose();
```

> Important!
> When restarting the search, the callback will only be called when a new device is found. If you need to get all devices found by the current scanner instance, call the appropriate method.

### Sensor

#### Creating

You need to create a device using a scanner and info about device receiving while search. All manipulations with the device will be performed without errors only if the device is connected. When created, the device is automatically connected. In the future, the connection state can be controlled through the sensor object. The sensor allows you to monitor the status of the device, set parameters, receive a signal of various types. 

```dart
// retrieve information from a list or retrieve stored information from a callback
List<FSensorInfo?> sensors = await scanner.getSensors();
FSensorInfo? sensorInfo = sensors[0];

// BrainBit
BrainBit? sensor = await scanner.createSensor(info!) as BrainBit;

// BrainBit 2 / Flex / Flex Pro
BrainBit2? sensor = await scanner.createSensor(info!) as BrainBit2;

// Callibri
Callibri? sensor = await scanner.createSensor(info!) as Callibri;
```

> Device creation is a blocking method, so it must be called from separate thread.

> For all types of devices, you can use the same methods to control the device's connection status, invoke commands, and check for functionality.

#### Manage connection state

Connection status can be obtained in two ways. The first one is using the sensor property [State](#state).

The second way is in real time using a callback:

```dart
StreamSubscription<FSensorState>? stateSubscription = sensor.sensorStateStream.listen((state) => print("State: $state"));
...
stateSubscription.cancel();
```

> Important!
> The state change callback will not come after the device is created, only after disconnecting (device lost from the scope or using a method) and then connected. The device does not automatically reconnect.

You can connect and disconnect from device manually by methods `connect()` and `disconnect()`. To receive connection state in real time you need to subscribe to [stateChanged](#manage-connection-state) event. Also you can get connection state by sensor's property.

```dart
await sensor.disconnect();
...
await sensor.connect();
```

#### Device finalization

When you are done with the device, it is recommended to disconnect from the device and clear the taken resources.

```dart
await sensor.disconnect();
sensor.dispose();
```

#### Manage device parameters

##### Battery

Also, you can get power value from each device by sensor property `BattPower` or by callback in real time:

```dart
StreamSubscription<int>? powerSubscription = sensor.batteryPowerStream.listen((power) => print("Battery: $power"));
...
powerSubscription.cancel();
```

##### Parameters

Each device has its own settings, and some of them can be configured as you need. Not all settings can be changed and not every device supports all settings.

First you need to find out what parameters the device supports and whether they can be changed:

```dart
List<FParameterInfo?> pInfos = await sensor.parameters.value;
```

Info about parameter includes two fields:

**FParameterInfo**
| Field | Type | Description |
|--|--|--|
|param|FSensorParameter|the name of the parameter, represented by an enumeration|
|paramAccess|FSensorParamAccess|parameter availability for manipulation|

**FSensorParamAccess**
| Field | Value | Description |
|--|--|--|
|read|0|read-only|
|readWrite|1|parameter can be changed|
|readNotify|2|parameter is updated over time|

You can also check if the parameter is supported, for example `Gain`:

```dart
if(await sensor.isSupportedParameter(FSensorParameter.gain)){
  ...
}
```

##### Parameter description

###### Name

Name of device.

```dart
String name = await sensor.name.value;
...
await sensor.name.set("newName").onError((error, stackTrace) => print(error)); // <- catch an exception
```

###### State

Information about the connection status of a device. Can take two values:

- InRange - Device connected
- OutOfRange - The device is turned off or out of range

```dart
SensorState state = await sensor.state.value;
if (state == SensorState.inRange) {
  print("connected");
} else {
  print("disconnected");
}
```

###### Address

MAC-address of device. For iOS/MacOS represents by UUID. String value.

```dart
String address = await sensor.address.value;
```

###### SerialNumber

Serial number of device.  String value.

For callibri device families, this field is empty in [SensorInfo](#sensor-info) when searching, and you can get it immediately after connecting using this property.

```dart
String serialNumber = await sensor.serialNumber.value;
```

###### Firmware mode

Information about the current mode of operation of the device firmware. It can be in two states:

- ModeBootloader - the device is in bootloader mode
- ModeApplication - normal operation

```dart
FSensorFirmwareMode mode = await sensor.firmwareMode.value;

// only for Callibri/ Kolibri
await sensor.firmwareMode.set(FSensorFirmwareMode.modeApplication);
```

###### Sampling frequency

An property that is used to set or get the sample rate of a physiological signal. The higher the value, the more data flow from the device to the application, which means the higher the power consumption, but also the higher the range of measured frequencies. And there are also limitations on the physical communication channel (BLE) in terms of bandwidth.

Recommendations for choosing a value:

- For EEG signals not less than 250 Hz;
- For ECG signals 125 Hz;
- For EMG not less than 1000 Hz. When working with several devices at the same time, it is not recommended to increase the frequency above 1000 Hz;
- The breath channel has a fixed sampling rate of 20 Hertz. MEMS channels have a fixed sampling rate of 100 Hertz.

It is unchanged for BrainBit and BrainBitBlack and is 250 Hz. Can be changed for Signal Callibri/Kolibri and can take on the following values:

- 125 Hz
- 250 Hz
- 500 Hz
- 1000 Hz
- 2000 Hz

If you try to set an unsupported value to the device, an exception will be thrown.

```dart
FSensorSamplingFrequency samplingFrequency = await sensor.samplingFrequency.value;

// set only for Callibri/Kolibri MF
await callibri.samplingFrequency.set(FSensorSamplingFrequency.hz1000);
```

###### Gain

Gain of an ADC signal. The higher the gain of the input signal, the less noise in the signal, but also the lower the maximum amplitude of the input signal. For signal Callibi/Kolibri you can set the desired value. Not available for Callibi/Kolibri EMS.

The device uses a 24-bit ADC, but the last 3 bits are not used (discarded) to optimize the data flow over the radio channel. The weight of one bit is calculated using the following formula Wbit = (2*2.4) / ( (pow(2,21) - 1) * Gain ) volt

Available values for Callibri MF and BrainBit:
- 1
- 2
- 3
- 4
- 6
- 8
- 12

```dart
FSensorGain gain = await sensor.gain.value;
...
await sensor.gain.set(FSensorGain.gain6);
```

If you try to set an unsupported value to the device, an exception will be thrown.

###### Offset

Signal offset. It is unchanged for BrainBit and BrainBitBlack and is 0. For Callibi/Kolibri MF you can set the desired value. Not available for Callibi/Kolibri EMS.

Available values for Callibri MF:

- 0
- 1
- 2
- 3
- 4
- 5
- 6
- 7
- 8

```dart
FSensorDataOffset offset = await sensor.dataOffset.value;

// set only for Callibri/Kolibri MF
await sensor.dataOffset.set(FSensorDataOffset.dataOffset3);
```

If you try to set an unsupported value to the device, an exception will be thrown.

###### Firmware version

Information about the device firmware version.

```dart
FSensorVersion version = await sensor.version.value;
```

**FSensorVersion:**

| Field | Type | Description |
|--|--|--|
|fwMajor|int|firmware major|
|fwMinor|int|firmware minor|
|fwPatch|int|firmware patch|
|hwMajor|int|hardware major|
|hwMinor|int|hardware minor|
|hwPatch|int|hardware patch|
|extMajor|int|extension major|

###### Battery power

Battery power value. Integer value.

```dart
int battery = await sensor.battPower.value;
```

###### Sensor family

Type of device. Enumeration.

```dart
FSensorFamily sensFamily = await sensor.sensFamily.value;
```

##### Features

Each device has a specific set of modules. You can find out which modules the device has using the property `Feature`:

```dart
Set<FSensorFeature> features = await sensor.features.value;
```

You can also check if the feature is supported, for example `Signal`:

```dart
if (await callibri.isSupportedFeature(FSensorFeature.signal)) {
  ...
}
```

##### Commands

The device can execute certain commands. The list of supported commands can be obtained as follows:

```dart
Set<FSensorCommand> commands = await sensor.commands.value;
```

And also check if the device can execute the desired command:

```dart
if(await sensor.isSupportedCommand(FSensorCommand.startSignal)){
  ...              
}
```

### BrainBit, BrainBitBlack

The BrainBit and BrainBitBlack is a headband with 4 electrodes and 4 data channels - O1, O2, T3, T4. The device has a frequency of 250 Hz, which means that data on each of the channels will come at a frequency of 250 samples per second. You can only change the [gain](#gain) of the signal. The other parameters cannot be changed and you will get an exception if you try.

> You can distinguish BrainBit device from Flex by the [firmware version number](#firmware-version): if the `SensorVersion.FwMajor` is more than 100 - it's Flex, if it's less than BrainBit.

> BrainBitBlack, unlike BrainBit, requires pairing with a PC/mobile device. So, before connecting to the BrainBitBlack, you must put it into pairing mode. SDK starts the pairing process automatically. 

#### Receiving signal

To receive signal data, you need to subscribe to the corresponding callback. The values will be received as a packet from four channels at once, which will avoid desynchronization between them. The values come in volts. In order for the device to start transmitting data, you need to start a signal using the `execute` command. This method is also recommended to be run in an separate thread.

```dart
StreamSubscription<List<BrainBitSignalData>>? signalSubscription = sensor.signalDataStream.listen((data) => print("Signal values: $data"));
await sensor.execute(FSensorCommand.startSignal);
...
signalSubscription.cancel();
await sensor.execute(FSensorCommand.stopSignal);
```

You get signal values as a list of samples, each containing:

| Field | Type | Description |
|--|--|--|
|packNum|int|number for each packet|
|marker|int|marker of sample, if it was sent and this feature is supported by the device|
|o1|double|value of O1 channel in V|
|o2|double|value of O2 channel in V|
|t3|double|value of T3 channel in V|
|t4|double|value of T4 channel in V|

> `PackNum` cannot be more then 2047

#### Ping signal

Some devices support signal quality check functions using signal ping. You can send a specific value (marker) to the device and it will return that marker with the next signal data packet. Marker is small value one byte in size.

> Available to BrainBitBlack and BrainBit2 / Flex / Pro

```dart
await sensor.pingNeuroSmart(5);
```

#### Recieving resistance

BrainBit and BrainBitBlack also allow you to get resistance values. With their help, you can determine the quality of the electrodes to the skin. Initial resistance values are infinity. The values change when the BB is on the head.

For BrainBit the upper limit of resistance is 2.5 ohms.

```dart
StreamSubscription<BrainBitResistData>? resistSubscription = sensor.resistDataStream.listen((data) => print("resist values: $data"));
await sensor.execute(FSensorCommand.startResist);
...
resistSubscription.cancel();
await sensor.execute(FSensorCommand.stopResist);
```

You get resistance values structure of samples for each channel:

| Field | Type | Description |
|--|--|--|
|o1|double|value of O1 channel in Ohm|
|o2|double|value of O2 channel in Ohm|
|t3|double|value of T3 channel in Ohm|
|t4|double|value of T4 channel in Ohm|

### BrainBit 2/Flex/Pro

The BrainBit2 class is designed to work with several device families: BrainBit 2, BrainBit Pro, BrainBit Flex, BrainBit Flex Pro. All devices have a sampling frequency of 250Hz. All devices can work in two modes - signal and resistance separately. These devices have different number of channels - BrainBit2, BrainBit Flex have 4 channels each and BrainBitPro, BrainBit FlexPro have 8 channels each. The main difference from BraibBit of the first version is that they do not support gain property, but have the ability to set gain for each channel separately using `BrainBit2AmplifierParam` structure. Also, these types of devices support the [ping command](#ping-signal).

#### Info about channels

The device can have 4 or 8 channels. The number of channels can be determined as follows:

```dart
List<FEEGChannelInfo?> channels = await sensor.supportedChannels.value;
```

`FEEGChannelInfo` contains some info:

| Field | Type | Description |
|--|--|--|
|id|EEGChannelId|physical location of the channel. You will receive the values `o1`, `o2`, `t3`, `t4` or `unknown`. `unknown` means that the position of a specific electrode is free.|
|chType|EEGChannelType|type of channel, possible values `singleA1`, `singleA2`, `differential` or `ref`|
|name|String|channel name|
|num|int|channel number. By this number the channel will be located in the array of signal or resistance values|

Also you can check only channels count without info:

```dart
int channelsCount = await sensor.channelsCount.value;
```

#### AmpMode

This device can show it's current amplifier mode. It can be in the following states:

  - Invalid
  - PowerDown
  - Idle
  - Signal
  - Resist

You can check amp. mode by two ways:

1. by callback:

```dart
StreamSubscription<FSensorAmpMode>? ampModeSubscription = sensor.ampModeStream.listen((mode) => print("Amp mode: $mode"));
...
ampModeSubscription.cancel();
```

2. get value at any time:

```dart
FSensorAmpMode mode = await sensor.ampMode.value;
```

It is very important parameter for BrainBit2 device because you can set amplifier parameters only if device into `PowerDown` or `Idle` mode.

#### Amplifier parameters

You can configure each channel and whole device settings by setting amplifier parameters.

```dart
int chCount = await sensor.channelsCount.value;
BrainBit2AmplifierParam param = BrainBit2AmplifierParam(
    chSignalMode: List.filled(chCount, FBrainBit2ChannelMode.chModeNormal),
    chResistUse: List.filled(chCount, true),
    chGain: List.filled(chCount, SensorGain.gain3),
    current: GenCurrent.genCurr6nA);
await sensor.amplifierParam.set(param);
```

`BrainBit2AmplifierParam` contains:

| Field | Type | Description |
|--|--|--|
|chSignalMode|List<FBrainBit2ChannelMode>|input type|
|chResistUse|List<bool>|dont used for current version|
|chGain|List<FSensorGain>|gain of an ADC signal for each channel|
|current|GenCurrent|setting parameters of the probe current generator|

Possible values for `Current`:
 - 0nA 
 - 6nA 
 - 12nA
 - 18nA
 - 24nA

Signal modes:
 - Short - shorted input
 - Normal - bipolar input mode (used for EEG)

Possible `Gain` values:
 - 1
 - 2
 - 3
 - 4
 - 6
 - 8
 - 12

#### Receiving signal

To receive signal data, you need to subscribe to the corresponding callback. The values come in volts. In order for the device to start transmitting data, you need to start a signal using the `execute` command. This method is also recommended to be run in an separate thread.

```dart
StreamSubscription<List<SignalChannelsData>>? signalSubscription = sensor.signalDataStream.listen((data) => print("Signal values: $data"));
await sensor.execute(FSensorCommand.startSignal);
...
signalSubscription.cancel();
await sensor.execute(FSensorCommand.stopSignal);
```

You get signal values as a list of samples (`SignalChannelsData`), each containing:

|--|--|--|
|packNum|int|number for each packet|
|marker|int|marker of sample|
|samples|List<double>|array of samples in V. Each sample number into array consistent with `num` value of [FEEGChannelInfo](#info-about-channels) from `supportedChannels` field.|

#### Receiving resistance

BrainBit2 also allow you to get resistance values. With their help, you can determine the quality of the electrodes to the skin. Initial resistance values are infinity. The values change when the device is on the head.

```dart
StreamSubscription<List<ResistRefChannelsData>>? resistSubscription = sensor.resistDataStream.listen((data) => print("resist values: $data"));
await sensor.execute(FSensorCommand.startResist);
...
resistSubscription.cancel();
await sensor.execute(FSensorCommand.stopResist);
```

You get resistance values structure of samples (`ResistRefChannelsData`) for each channel:

| Field | Type | Description |
|--|--|--|
|packNum|int|number for each packet|
|samples|List<double>|array of samples in V. Each sample number into array consistent with `Num` value of [FEEGChannelInfo](#info-about-channels) from `supportedChannels` field.|
|referents|List<double>|array of values for referents channels. For BrainBit2 sensor is empty now.|

### Callibri MF/ Kolibri MF

The Callibri family of devices has a wide range of built-in modules. For each of these modules, the SDK contains its own processing area. It is recommended before using any of the modules to check if the module is supported by the device using one of the methods [IsSupportedFeature](#features), [IsSupportedCommand](#commands) or [IsSupportedParameter](#parameters)

#### Parameters

###### Motion counter parameter pack

Parameters for motion counter.

```dart
// check supported
if (await sensor.isSupportedParameter(FSensorParameter.motionCounterParamPack)) {
  // get
  FCallibriMotionCounterParam param = await sensor.motionCounterParam.value;  
  // set
  await sensor.motionCounterParam.set(CallibriMotionCounterParam(insenseThresholdMG: 100, insenseThresholdSample: 200));
}
```
**CallibriMotionCounterParam:**

| Field | Type | Description |
|--|--|--|
|insenseThresholdMG|int|Insense threshold mg. 0..500|
|insenseThresholdSample|int|Algorithm insense threshold in time (in samples with the MEMS sampling rate) 0..500|

###### Motion counter

Contains the number of motions. This parameter is available only to Callibi/Kolibri. A numeric value that cannot be changed. 

```dart
// check supported
if (await sensor.isSupportedParameter(FSensorParameter.motionCounter)) {
  // get
  int = await sensor.motionCounter.value;
}
```

###### Hardware filters

Device signal filter activity states. If the parameter is supported by the device, it becomes possible to set the desired filters using the `HardwareFilters` property. The next filters are available:

- HPFBwhLvl1CutoffFreq1Hz - high-pass filter with a frequency of 1Hz
- HPFBwhLvl1CutoffFreq5Hz - high-pass filter with a frequency of 5Hz
- BSFBwhLvl2CutoffFreq45_55Hz - 50Hz notch filter 
- BSFBwhLvl2CutoffFreq55_65Hz - 60Hz notch filter
- HPFBwhLvl2CutoffFreq10Hz - high-pass filter with a frequency of 10 Hz
- LPFBwhLvl2CutoffFreq400Hz - low-pass filter with a frequency of 400 Hz. Only for 1000 Hz sampling
- HPFBwhLvl2CutoffFreq80Hz - high-pass filter with a frequency of 80Hz

Before enabling filters, check whether the device supports the required filters.

> NOTE:
> Setting a hardware filter list that contains LPFBwhLvl2CutoffFreq400Hz will not occur in a Callibri MF sensor at a frequency other than 1000Hz

```dart
// supported filters
Set<FSensorFilter> filters = await sensor.supportedFilters.value;

// read enabled filters
Set<FSensorFilter> filtersOn = await sensor.hardwareFilters.value;

// enable filters
if(await sensor.isSupportedFilter(FSensorFilter.BSFBwhLvl2CutoffFreq45_55Hz)){
  await sensor.hardwareFilters.set({FSensorFilter.BSFBwhLvl2CutoffFreq45_55Hz});                
}
```

###### External switch state

Switched signal source. This parameter is available only to Callibi/Kolibri. It is can take on the following values:

- ExtSwInElectrodesRespUSB - Respiratory channel data source is USB connector. The source of myographic channel data are terminals.
- ExtSwInElectrodes - Terminals are the source of myographic channel data. The breathing channel is not used.
- ExtSwInUSB - The source of myographic channel data is the USB connector. The breathing channel is not used.
- ExtSwInRespUSB - Respiratory channel data source is USB connector. Myographic channel is not used.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(FSensorParameter.externalSwitchState)) {
  // get
  FSensorExternalSwitchInput sensorExternalSwitchInput = await sensor.extSwInput.value;

  // set
  await sensor.extSwInput.set(FSensorExternalSwitchInput.electrodesRespUSB);
}
```

###### ADC input state

State value of an ADC (Analog to Digital Converter) input of a device. This property is available only to Callibi/Kolibri. It is can take on the following values:

- Electrodes - Inputs to electrodes. This mode is designed to receive a physiological signal from the place of application.
- Short - Inputs are short-circuited. This mode is designed to close the outputs. The output will have noise at the baseline or 0 volt level.
- Test - Inputs to the ADC test. This mode is intended for checking the correctness of the ADC operation. The output should be a square wave signal with a frequency of 1 Hz and an amplitude of +/- 1 mV.
- Resistance - Inputs for measuring the interelectrode resistance. This mode is designed to measure the interelectrode resistance, as well as to obtain a physiological signal. This is the recommended default mode.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(FSensorParameter.adcInputState)) {
  // get
  FSensorADCInput sensorAdcInput = await sensor.adcInput.value;

  // set
  await sensor.adcInput.set(FSensorADCInput.electrodes);
}
```

###### Accelerometer sensitivity

The sensitivity value of the accelerometer, if the device supports it. This property is available only to Callibi/Kolibri. It is recommended to check the presence of the MEMS module before use. It is can take on the following values:

- 2g - Normal sensitivity. Minimum value. Sufficient for practical use
- 4g - Increased sensitivity.
- 8g - High sensitivity.
- 16g - Maximum sensitivity.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(FSensorParameter.accelerometerSens)) {

  // get  
  FSensorAccelerometerSensitivity sensorAccelerometerSensitivity = await sensor.accSens.value;

  // set
  await sensor.accSens.set(FSensorAccelerometerSensitivity.accSens2g);
}
```

###### Gyroscope sensitivity

The gyroscope gain value, if the device supports it. It is recommended to check the presence of the MEMS module before use. It is can take on the following values:

- 250Grad - The range of measured values of the angular velocity is from 0 to 2000 degrees per second. Recommended for measuring angles.
- 500Grad - The range of measured values of the angular velocity is from 0 to 1000 degrees per second.
- 1000Grad - The range of measured values of the angular velocity is from 0 to 500 degrees per second.
- 2000Grad - The range of measured values of the angular velocity is from 0 to 250 degrees per second.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(FSensorParameter.gyroscopeSens)) {

  // get  
  FSensorGyroscopeSensitivity gyroSens = await sensor.gyroSens.value;

  // set
  await sensor.gyroSens.set(FSensorGyroscopeSensitivity.gyroSens250Grad);
}
```

###### MEMS calibration status

Calibration status of MEMS sensors. Available only to Callibri/Kolibri MF. Conditional type.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(FSensorParameter.memsCalibrationStatus)) {
  // get  
  if(await sensor.memsCalibrateState.value){
    ...
  }
}
```

###### SamplingFrequency MEMS

Frequency of updating MEMS values. Immutable value. Available for Callibri/Kolibri supporting MEMS.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(FSensorParameter.samplingFrequencyMEMS)) {
  // get  
  FSensorSamplingFrequency memsFrequency = await sensor.samplingFrequencyMEMS.value;
}
```

###### SamplingFrequency respiration

Frequency of updating breath values. Immutable value. Available for Callibri/Kolibri supporting breath.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(SensorParameter.samplingFrequencyResp)) {
  // get  
  FSensorSamplingFrequency respFrequency = await sensor.samplingFrequencyResp.value;
}
```

###### SamplingFrequency envelope

Frequency of updating envelope values. Immutable value. Available for Callibri/Kolibri supporting envelope.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(SensorParameter.samplingFrequencyEnvelope)) {
  // get  
  FSensorSamplingFrequency envFreq = await sensor.samplingFrequencyEnvelope.value;
}
```

###### Electrode state

Electrode state of Callibri/Kallibri MF devices. You can check electrodes state during signal receiving.

```dart
// check supported parameter
if (await sensor.isSupportedParameter(SensorParameter.electrodeState)) {
  // get  
  FCallibriElectrodeState electrodeState = await sensor.electrodeState.value;
}
```

#### Receiving signal

To receive signal data, you need to subscribe to the corresponding callback. The values come in volts. In order for the device to start transmitting data, you need to start a signal using the `execute` command. This method is also recommended to be run in an separate thread.

The sampling rate can be controlled using the [SamplingFrequency](#sampling-frequency) property. For example, at a frequency of 1000 Hz, the device will send 1000 samples per second. Supports frequencies 125/250/500/1000/2000 Hz. You can also adjust the signal offset ([DataOffset](#offset)) and signal power ([Gain](#gain)).

```dart
StreamSubscription<List<CallibriSignalData>>? signalSubscription = sensor.signalDataStream.listen((data) => print("Signal values: $data"));
await sensor.execute(FSensorCommand.startSignal);
...
signalSubscription.cancel();
await sensor.execute(FSensorCommand.stopSignal);
```

You get  signal values as a list of samples, each containing:

| Field | Type | Description |
|--|--|--|
|packNum|int|number for each packet|
|samples|List<double>|array of samples in V|

#### Signal settings

By default, the Callibri/Kolibri gives a signal without filters. In order to receive a certain type of signal, for example, EEG or ECG, you need to configure the device in a certain way. For this there is a property `SignalTypeCallibri`. Preset signal types include:
 - EEG - parameters: Gain6, Offset = 3,  ADCInputResistance
 - EMG - parameters: Gain6, Offset = 3,  ADCInputResistance
 - ECG - parameters: Gain6, Offset = 3,  ADCInputResistance
 - EDA (GSR) - parameters: Gain6, Offset = 8,  ADCInputResistance, ExternalSwitchInElectrodes. By default the input to the terminals is set. If you want to change it to USB use the [ExtSwInput](#external-switch-state) property.
 - TenzoBreathing - parameters: Gain8, Offset = 4, ADCInputResistance, ExternalSwitchInUSB
 - StrainGaugeBreathing - parameters: Gain6, Offset = 4,  ADCInputResistance, ExternalSwitchInUSB
 - ImpedanceBreathing - parameters: Gain6, Offset = 4,  ADCInputResistance, ExternalSwitchInRespUSB

Hardware filters disabled by default for all signal types. You can enable filters by [HardwareFilters](#hardware-filters) property, for example LP filter. 

> Important!
> When using an LP filter in the sensor, you will not see the constant component of the signal.

**SignalTypeCallibri:**
| Field | Value |
|--|--|
|EEG|0|
|EMG|1|
|ECG|2|
|EDA|3|
|strainGaugeBreathing|4|
|impedanceBreathing|5|
|tenzoBreathing|6|
|unknown|7|

```dart
// get
CallibriSignalType signalType = await sensor.signalType.value;
// set
await sensor.signalType.set(CallibriSignalType.EMG);
```

#### Receiving envelope

To get the values of the envelope, you need to subscribe to a specific event and start pickup. The channel must be configured in the same way as for a normal signal, and all parameters work the same way. Then the signal is filtered and decimated at 20 Hz.

```dart
StreamSubscription<List<CallibriEnvelopeData>>? envelopeSubscription = sensor.envelopeDataStream.listen((data) { print(data); });
await sensor.execute(FSensorCommand.startEnvelope);
...
envelopeSubscription.cancel();
await sensor.execute(FSensorCommand.stopEnvelope);
```

You get signal values as a list of samples, each containing:
 - PackNum - number for each packet
 - sample in V

| Field | Type | Description |
|--|--|--|
|packNum|int|number for each packet|
|sample|double|sample in V|

#### Check electrodes state

Allows you to determine the presence of electrical contact of the device electrodes with human skin. It can be in three states:
 - Normal - The electrodes have normal skin contact. Low electrical resistance between electrodes. The expected state when working with physiological signals.
 - Detached - High electrical resistance between electrodes. High probability of interference in the physiological signal.
 - HighResistance - There is no electrical contact between the electrodes of the device.
 
To receive data, you need to subscribe to the corresponding callback and start signal pickup.

```dart
StreamSubscription<FCallibriElectrodeState>? electrodeSubscription = callibri.electrodeStateStream.listen((state) { print(state); });
await sensor.execute(FSensorCommand.startSignal);
...
electrodeSubscription.cancel();
await sensor.execute(FSensorCommand.stopSignal);
```

#### Receiving Respiration

The breathing microcircuit is optional on request. Its presence can be checked using the `IsSupportedFeature` method. To receive data, you need to connect to the device, subscribe to the notification of data receipt and start picking up.

```dart
StreamSubscription<List<CallibriRespirationData>>? respSubscription = sensor.respirationDataStream.listen((event) { print(event); });
await sensor.execute(FSensorCommand.startRespiration);
...
respSubscription.cancel()
await sensor.execute(FSensorCommand.stopRespiration);
```

You get signal values as a list of samples, each containing:

| Field | Type | Description |
|--|--|--|
|packNum|int|number for each packet|
|samples|List<double>|sample in V|

#### MEMS

The MEMS microcircuit is optional on request. Its presence can be checked using the [IsSupportedFeature](#features) method. This means that the device contains an accelerometer and a gyroscope. Contains information about the position of the device in space. Channel sampling frequency is 100 Hz.

MEMS data is a structure:

- PackNum - number for each packet
- Accelerometer - accelerometer data. Contains:
  - X - Abscissa Acceleration
  - Y - Y-axis acceleration
  - Z - Acceleration along the applicate axis
- Gyroscope - gyroscope data
  - X - The angle of inclination along the abscissa axis
  - Y - Inclination angle along the ordinate axis
  - Z - Angle of inclination along the axis of the applicate

Quaternion data is a structure:

- PackNum - number for each packet
- W - Rotation component
- X - Vector abscissa coordinate
- Y - Vector coordinate along the ordinate axis
- Z - The coordinate of the vector along the axis of the applicate

It is recommended to perform calibration on a flat, horizontal non-vibrating surface before starting work using the `CalibrateMEMS` command. Calibration state can be checked using the [MEMSCalibrateStateCallibri](#mems-calibration-status) property, it can take only two values: calibrated (true), not calibrated (false).

> MEMS and quaternion available only to Callibri/Kolibri MF!

```dart
await sensor.execute(FSensorCommand.calibrateMEMS);
bool isCalibrated = await sensor.memsCalibrateState.value;

// For receiving MEMS
StreamSubscription<List<MEMSData>>? memsSubscription = sensor.memsDataStream.listen((data) { print(data); });
await sensor.execute(FSensorCommand.startMEMS);
...
memsSubscription.cancel()
await sensor.execute(FSensorCommand.stopMEMS);

// For quarternion
StreamSubscription<List<QuaternionData>>? qSubscription = sensor.quaternionDataStream.listen((event) { print(event); });
await sensor.execute(FSensorCommand.startAngle);
...
qSubscription.cancel()
await sensor.execute(FSensorCommand.stopAngle);
```

#### Motion counter

Represents a motion counter. It can be configured using the [FCallibriMotionCounterParam](#motion-counter) property, in it:

 - InsensThreshmG – Threshold of the algorithm's deadness in amplitude (in mg). The maximum value is 500mg. The minimum value is 0.
 - InsensThreshSamp - Threshold of the algorithm's insensitivity in time (in samples with the MEMS sampling rate). The maximum value is 500 samples. The minimum value is 0.

You can find out the current number of movements using the `MotionCounterCallibri` property. You can reset the counter with the `ResetMotionCounter` command. No additional commands are needed to start the counter, it will be incremented all the time until the reset command is executed.

```dart
if (await sensor.isSupportedParameter(FSensorParameter.motionCounter)) {
  int motionCount = await sensor.motionCounter.value;
  await sensor.execute(FSensorCommand.resetMotionCounter);
}
```

### Callibri/Kolibri EMS

Kallibri is a EMS if it supports the stimulation module:

```dart
bool isStimulator = await sensor.isSupportedFeature(FSensorFeature.currentStimulator);
```

#### Stimulation

Before starting the session, you need to correctly configure the device, otherwise the current strength may be too strong or the duration of stimulation too long. The setting is done using the `StimulatorParamCallibri` property. You can set the following options:

 - Current - stimulus amplitude in  mA. 1..100
 - PulseWidth - duration of the stimulating pulse by us. 20..460
 - Frequency - frequency of stimulation impulses by Hz. 1..200.
 - StimulusDuration - maximum stimulation time by ms. 0...65535. Zero is infinitely.

You can start and stop stimulation with the following commands:

```dart
await sensor.execute(FSensorCommand.startCurrentStimulation);
...
await sensor.execute(FSensorCommand.stopCurrentStimulation);
```

> Stimulation does not stop after the `StimulusDuration` time has elapsed.

You can check the state of stimulation using the [StimulatorMAStateCallibri](#stimulator-and-motional-assistant-state) property. Contains two parameters:

- StimulatorState - Stimulation mode state
- MAState - Drive assistant mode state

Each of the parameters can be in 4 states:

- NoParams - parameter not set
- Disabled - mode disabled
- Enabled - mode enabled
- Unsupported - sensor unsupported

#### Motion assistant

The Callibri EMS, which contains the MEMS module, can act as a motion corrector. You can set the initial and final angle of the device and the limb on which the Callibri/Kolibri is installed, as well as a pause between stimulations and turn on the motion assistant. All the time while the device is tilted in the set range, stimulation will met. Stimulation will take place according to the settings of [StimulatorParamCallibri](#stimulator-parameter-pack).

The motion corrector works in the background. After turning on the motion assistant mode, it will work regardless of the connection to a mobile device/PC. You can turn on the motion corrector mode using a special command. When the device is rebooted, it is also reset.

Motion corrector parameters are a structure with fields:

 - GyroStart - Angle value in degrees at which the stimulation mode will start, if it is correctly configured.
 - GyroStop - Angle value in degrees above which the stimulation mode will stop, if it is correctly configured.
 - Limb - overlay location in stimulation mode, if supported.
 - MinPauseMs - Pause between starts of stimulation mode in milliseconds. Multiple of 10. This means that the device is using the (MinPauseMs / 10) value. Correct values: 10, 20, 30, 40 ... 

```dart
await sensor.motionAssistantParam.set(CallibriMotionAssistantParams(gyroStart: 45, gyroStop: 10, limb: FCallibriMotionAssistantLimb.rightLeg, minPauseMs: 10));

await sensor.execute(FSensorCommand.enableMotionAssistant);
...
await sensor.execute(FSensorCommand.disableMotionAssistant);
```

##### Parameters

###### Stimulator and motional assistant state

Parameter for obtaining information about the state of the stimulation mode and the motion assistant mode. This parameter is available only to Callibi/Kolibri EMS. Contains:

- StimulatorState - Stimulation mode state
- MAState - Drive assistant mode state

Each of the fields can be in four states:

| Field     | Type | Description |
|-----------|------|-------------|
|noParams   |0     |not set      |
|disabled   |1     |disabled     |
|enabled    |2     |enabled      |
|unsupported|3     |unsupported  |

```dart
// check supported future
if (await sensor.isSupportedFeature(FSensorFeature.currentStimulator)) {

}

// get
FCallibriStimulatorMAState stimMAState = await sensor.stimulatorMAState.value;
```
 
###### Stimulator parameter pack

Stimulation parameters. This property is available only to Callibi/Kolibri EMS. Parameters inncludes fields:

**CallibriStimulationParams:**

| Field | Type | Description |
|--|--|--|
|current|int|stimulus amplitude in  mA. 1..100|
|pulseWidth|int|duration of the stimulating pulse by us. 20..460|
|frequency|int|frequency of stimulation impulses by Hz. 1..200|
|stimulusDuration|int|maximum stimulation time by ms. 0...65535|

```dart
// get
FCallibriStimulationParams params = await sensor.stimulatorParam.value;
...
// set
await sensor.stimulatorParam.set(FCallibriStimulationParams(current: 5, pulseWidth: 5, frequency: 5, stimulusDuration: 5));
```

###### Motion assistant parameter pack

Parameter for describing a stimulation mode, if the device supports this mode. This structure describes the parameters for starting the stimulation mode depending on the place of application of the device, the position of the limb in space and the pause between the starts of this mode while the specified conditions are met. The parameter is available only to Callibi/Kolibri EMS. Parameters include fields:

**FCallibriMotionAssistantParams:**
| Field | Type | Description |
|--|--|--|
|gyroStart|int|Angle value in degrees at which the stimulation mode will start, if it is correctly configured|
|gyroStop|int|Angle value in degrees above which the stimulation mode will stop, if it is correctly configured|
|limb|FCallibriMotionAssistantLimb|overlay location in stimulation mode, if supported|
|minPauseMs|int|Pause between starts of stimulation mode in milliseconds. Multiple of 10. This means that the device is using the (MinPauseMs / 10) value. Correct values: 10, 20, 30, 40 |

**CallibriMotionAssistantLimb:**
| Field | Value| Description |
|--|--|--|
|rightLeg|0|right leg|
|leftLeg|1|left leg|
|rightArm|2|right arm|
|leftArm|3|left arm|
|unsupported|4|unsupported|

```dart
// get
FCallibriMotionAssistantParams params = await sensor.motionAssistantParam.value;

// set
await sensor.motionAssistantParam.set(FCallibriMotionAssistantParams(gyroStart: 45, gyroStop: 10, limb: FCallibriMotionAssistantLimb.rightLeg, minPauseMs: 10));
```
