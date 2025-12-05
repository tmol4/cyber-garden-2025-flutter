import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon_messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_neuro_api'),
  cppSourceOut: 'windows/pigeon_messages/pigeon_messages.g.cpp',
  cppHeaderOut: 'windows/pigeon_messages/pigeon_messages.g.h',

  javaOut: 'android/src/main/java/com/neurosdk2/PigeonMessages.java',
  javaOptions: JavaOptions(package: "com.neurosdk2"),
  objcHeaderOut: 'darwin/Classes/pigeon_messages.g.h',
  objcSourceOut: 'darwin/Classes/pigeon_messages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  objcOptions: ObjcOptions(prefix: 'PGN'),
  dartPackageName: 'pigeon_neuro_api_package',
))

enum FCallibriColorType { red, yellow, blue, white, unknown }

enum FCallibriElectrodeState { elStNormal, elStHighResistance, elStDetached }

enum FSensorFilter {
  HPFBwhLvl1CutoffFreq1Hz(idx: 0),
  HPFBwhLvl1CutoffFreq5Hz(idx: 1),
  BSFBwhLvl2CutoffFreq45_55Hz(idx: 2),
  BSFBwhLvl2CutoffFreq55_65Hz(idx: 3),
  HPFBwhLvl2CutoffFreq10Hz(idx: 4),
  LPFBwhLvl2CutoffFreq400Hz(idx: 5),
  HPFBwhLvl2CutoffFreq80Hz(idx: 6),
  unknown(idx: 0xFF);

  final int idx;

  const FSensorFilter({required this.idx});
}

enum CallibriSignalType {
  EEG,
  EMG,
  ECG,
  EDA, // GSR
  strainGaugeBreathing,
  impedanceBreathing,
  tenzoBreathing,
  unknown
}

enum FCallibriStimulatorState { noParams, disabled, enabled, unsupported }

class FCallibriStimulatorMAState {
  final FCallibriStimulatorState stimulatorState;
  final FCallibriStimulatorState maState;

  FCallibriStimulatorMAState(
      {required this.stimulatorState, required this.maState});
}

class FCallibriStimulationParams {
  // Stimulus amplitude in  mA. 1..100
  int current;
  // Duration of the stimulating pulse by us. 20..460
  int pulseWidth;
  // Frequency of stimulation impulses by Hz. 1..200.
  int frequency;
  // Maximum stimulation time by ms. 0...65535.
  int stimulusDuration;

  FCallibriStimulationParams(
      {required this.current,
      required this.pulseWidth,
      required this.frequency,
      required this.stimulusDuration});
}

enum FCallibriMotionAssistantLimb {
  rightLeg,
  leftLeg,
  rightArm,
  leftArm,
  unsupported
}

class FCallibriMotionAssistantParams {
  int gyroStart;
  int gyroStop;
  FCallibriMotionAssistantLimb limb;
  // multiple of 10. This means that the device is using the (MinPauseMs / 10) value.;</br>
  // Correct values: 10, 20, 30, 40 ...
  int minPauseMs;

  FCallibriMotionAssistantParams(
      {required this.gyroStart,
      required this.gyroStop,
      required this.limb,
      required this.minPauseMs});
}

class FCallibriMotionCounterParam {
  // Insense threshold mg. 0..500
  int insenseThresholdMG;
  // Algorithm insense threshold in time (in samples with the MEMS sampling rate) 0..500
  int insenseThresholdSample;

  FCallibriMotionCounterParam(
      {required this.insenseThresholdMG, required this.insenseThresholdSample});
}


enum FSensorADCInput { electrodesInp, shortInp, testInp, resistanceInp }

enum FSensorCommand {
  startSignal,
  stopSignal,
  startResist,
  stopResist,
  startMEMS,
  stopMEMS,
  startRespiration,
  stopRespiration,
  startCurrentStimulation,
  stopCurrentStimulation,
  enableMotionAssistant,
  disableMotionAssistant,
  findMe,
  startAngle,
  stopAngle,
  calibrateMEMS,
  resetQuaternion,
  startEnvelope,
  stopEnvelope,
  resetMotionCounter,
  calibrateStimulation,
  idle,
  powerDown,
  startFPG,
  stopFPG,
  startSignalAndResist,
  stopSignalAndResist,
  startPhotoStimulation,
  stopPhotoStimulation,
  startAcousticStimulation,
  stopAcousticStimulation,
  fileSystemEnable,
  fileSystemDisable,
  fileSystemStreamClose,
  startCalibrateSignal,
  stopCalibrateSignal,
  photoStimEnable,
	photoStimDisable
}

enum FSensorDataOffset {
  dataOffset0,
  dataOffset1,
  dataOffset2,
  dataOffset3,
  dataOffset4,
  dataOffset5,
  dataOffset6,
  dataOffset7,
  dataOffset8,
  dataOffsetUnsupported;
}

enum FSensorExternalSwitchInput {
  electrodesRespUSBInp,
  electrodesInp,
  usbInp,
  respUSBInp,
  shortInp,
  unknownInp
}

enum FSensorFamily {
  leCallibri,
  leKolibri,
  leBrainBit,
  leBrainBitBlack,
  leBrainBit2,
  leBrainBitPro,
  leBrainBitFlex,
  unknown;
}

enum FSensorFeature {
  signal,
  mems,
  currentStimulator,
  respiration,
  resist,
  fpg,
  envelope,
  photoStimulator,
  acousticStimulator,
  flashCard,
  ledChannels,
  signalWithResist
}


enum FSensorFirmwareMode { modeBootloader, modeApplication }

enum FSensorGain {
  gain1,
  gain2,
  gain3,
  gain4,
  gain6,
  gain8,
  gain12,
  gain24,
  gain5,
  gain2x,
  gain4x,
  gainUnsupported
}

const int sensorNameLength = 256;
const int sensorAddressLength = 128;
const int sensorSerialNumberLength = 128;

class FSensorInfo {
  final String name;
  final String address;
  final String serialNumber;
  final bool pairingRequired;
  final int sensModel;
  final FSensorFamily sensFamily;
  final int rssi;

  FSensorInfo(
      {required this.name,
      required this.address,
      required this.serialNumber,
      required this.pairingRequired,
      required this.sensModel,
      required this.sensFamily,
      required this.rssi});
}

enum FSensorParameter {
  name, //0
  state, //1
  address, //2
  serialNumber, //3
  hardwareFilterState, //4
  firmwareMode, //5
  samplingFrequency, //6
  gain, //7
  offset, //8
  externalSwitchState, //9
  adcInputState, //10
  accelerometerSens, //11
  gyroscopeSens, //12
  stimulatorAndMAState, //13
  stimulatorParamPack, //14
  motionAssistantParamPack, //15
  firmwareVersion, //16
  memsCalibrationStatus, //17
  motionCounterParamPack, //18
  motionCounter, //19
  battPower, //20
  sensorFamily, //21
  sensorMode, //22
  irAmplitude, //23
  redAmplitude, //24
  envelopeAvgWndSz, //25
  envelopeDecimation, //26
  samplingFrequencyResist, //27
  samplingFrequencyMEMS, //28
  samplingFrequencyFPG, //29
  amplifier, //30
  sensorChannels, //31
  samplingFrequencyResp, //32
  surveyId, //33
  fileSystemStatus, //34
  fileSystemDiskInfo, //35
  referentsShort, //36
  referentsGround, //37
  samplingFrequencyEnvelope, //38
  channelConfiguration, //39
  electrodeState, //40
  channelResistConfiguration,
	battVoltage,
	photoStimTimeDefer,
	photoStimSyncState,
	sensorPhotoStim,
	stimMode,
	ledChannels,
	ledState
}

enum FSensorParamAccess { read, readWrite, readNotify }

class FParameterInfo {
  final FSensorParameter param;
  final FSensorParamAccess paramAccess;

  const FParameterInfo(this.param, this.paramAccess);
}

enum FSensorSamplingFrequency {
  hz10,
  hz20,
  hz100,
  hz125,
  hz250,
  hz500,
  hz1000,
  hz2000,
  hz4000,
  hz8000,
  hz10000,
  hz12000,
  hz16000,
  hz24000,
  hz32000,
  hz48000,
  hz64000,
  unsupported;
}

enum FSensorState { inRange, outOfRange }

class FSensorVersion {
  final int fwMajor;
  final int fwMinor;
  final int fwPatch;
  final int hwMajor;
  final int hwMinor;
  final int hwPatch;
  final int extMajor;

  const FSensorVersion(this.fwMajor, this.fwMinor, this.fwPatch, this.hwMajor,
      this.hwMinor, this.hwPatch, this.extMajor);
}


enum FSensorAccelerometerSensitivity {
  accSens2g,
  accSens4g,
  accSens8g,
  accSens16g,
  accSensUnsupported;
}

enum FSensorGyroscopeSensitivity {
  gyroSens250Grad,
  gyroSens500Grad,
  gyroSens1000Grad,
  gyroSens2000Grad,
  gyroSensUnsupported;
}


enum FSensorAmpMode {
  invalid,
  powerDown,
  idle,
  signal,
  resist,
  signalResist,
  envelope
}


enum FIrAmplitude {
  irAmp0,
  irAmp14,
  irAmp28,
  irAmp42,
  irAmp56,
  irAmp70,
  irAmp84,
  irAmp100,
  irAmpUnsupported;
}

enum FRedAmplitude {
  redAmp0,
  redAmp14,
  redAmp28,
  redAmp42,
  redAmp56,
  redAmp70,
  redAmp84,
  redAmp100,
  redAmpUnsupported;
}


enum FEEGChannelType { singleA1, singleA2, differential, ref }

enum FEEGChannelId {
  unknown,
  o1,
  p3,
  c3,
  f3,
  fp1,
  t5,
  t3,
  f7,
  f8,
  t4,
  t6,
  fp2,
  f4,
  c4,
  p4,
  o2,
  d1,
  d2,
  oZ,
  pZ,
  cZ,
  fZ,
  fpZ,
  d3
}

class FEEGChannelInfo {
  FEEGChannelId id;
  FEEGChannelType chType;
  String name;
  int num;

  FEEGChannelInfo(
      {required this.id,
      required this.chType,
      required this.name,
      required this.num});
}

enum FBrainBit2ChannelMode { chModeShort, chModeNormal }

class BrainBit2AmplifierParamNative {
  List<int?> chSignalMode;
  List<bool?> chResistUse;
  List<int?> chGain;
  FGenCurrent current;

  BrainBit2AmplifierParamNative(
      {required this.chSignalMode,
      required this.chResistUse,
      required this.chGain,
      required this.current});
}


enum FGenCurrent {
  genCurr0nA,
  genCurr6nA,
  genCurr12nA,
  genCurr18nA,
  genCurr24nA,
  genCurr6uA,
  genCurr24uA,
  unsupported;
}

@HostApi()
abstract class NeuroApi {
// Scanner
  @async
  String createScanner(List<int> filters);
  @async
  void closeScanner(String guid);
  @async
  void startScan(String guid);
  @async
  void stopScan(String guid);
  @async
  String createSensor(String guid, FSensorInfo sensorInfo);
  List<FSensorInfo> getSensors(String guid);

// Sensor
  @async
  void closeSensor(String guid);
  @async
  void connectSensor(String guid);
  @async
  void disconnectSensor(String guid);
  List<int> supportedFeatures(String guid);
  bool isSupportedFeature(String guid, FSensorFeature feature);
  List<int> supportedCommands(String guid);
  bool isSupportedCommand(String guid, FSensorCommand command);
  List<FParameterInfo> supportedParameters(String guid);
  bool isSupportedParameter(String guid, FSensorParameter parameter);
  @async
  void execCommand(String guid, FSensorCommand command);

  String getName(String guid);
  void setName(String guid, String name);
  FSensorState getState(String guid);
  String getAddress(String guid);
  String getSerialNumber(String guid);
  void setSerialNumber(String guid, String sn);
  int getBattPower(String guid);
  FSensorSamplingFrequency getSamplingFrequency(String guid);
  FSensorGain getGain(String guid);
  FSensorDataOffset getDataOffset(String guid);
  FSensorFirmwareMode getFirmwareMode(String guid);
  FSensorVersion getVersion(String guid);
  int getChannelsCount(String guid);
  FSensorFamily getSensFamily(String guid);

  FSensorAmpMode getAmpMode(String guid);
  FSensorSamplingFrequency getSamplingFrequencyResist(String guid);


  FSensorSamplingFrequency getSamplingFrequencyFPG(String guid);
  FIrAmplitude getIrAmplitude(String guid);
  void setIrAmplitude(String guid, FIrAmplitude amp);
  FRedAmplitude getRedAmplitude(String guid);
  void setRedAmplitude(String guid, FRedAmplitude amp);
  @async
  void pingNeuroSmart(String guid, int marker);


  void setGain(String guid, FSensorGain gain);


  bool isSupportedFilter(String guid, FSensorFilter filter);

  List< /*SensorFilter*/ int> getSupportedFilters(String guid);
  List< /*SensorFilter*/ int> getHardwareFilters(String guid);
  void setHardwareFilters(String guid, List<int> filters);
  void setFirmwareMode(String guid, FSensorFirmwareMode mode);
  void setSamplingFrequency(String guid, FSensorSamplingFrequency sf);
  void setDataOffset(String guid, FSensorDataOffset offset);
  FSensorExternalSwitchInput getExtSwInput(String guid);
  void setExtSwInput(String guid, FSensorExternalSwitchInput extSwInp);
  FSensorADCInput getADCInput(String guid);
  void setADCInput(String guid, FSensorADCInput adcInp);
  FCallibriStimulatorMAState getStimulatorMAState(String guid);
  FCallibriStimulationParams getStimulatorParam(String guid);
  void setStimulatorParam(String guid, FCallibriStimulationParams param);
  FCallibriMotionAssistantParams getMotionAssistantParam(String guid);
  void setMotionAssistantParam(
      String guid, FCallibriMotionAssistantParams param);
  FCallibriMotionCounterParam getMotionCounterParam(String guid);
  void setMotionCounterParam(String guid, FCallibriMotionCounterParam param);
  int getMotionCounter(String guid);
  FCallibriColorType getColor(String guid);
  bool getMEMSCalibrateState(String guid);
  FSensorSamplingFrequency getSamplingFrequencyResp(String guid);
  FSensorSamplingFrequency getSamplingFrequencyEnvelope(String guid);
  CallibriSignalType getSignalType(String guid);
  void setSignalType(String guid, CallibriSignalType type);
  FCallibriElectrodeState getElectrodeState(String guid);


  FSensorAccelerometerSensitivity getAccSens(String guid);
  void setAccSens(String guid, FSensorAccelerometerSensitivity accSens);
  FSensorGyroscopeSensitivity getGyroSens(String guid);
  void setGyroSens(String guid, FSensorGyroscopeSensitivity gyroSens);
  FSensorSamplingFrequency getSamplingFrequencyMEMS(String guid);


  List<FEEGChannelInfo> getSupportedChannels(String guid);


  BrainBit2AmplifierParamNative getAmplifierParamBB2(String guid);
  void setAmplifierParamBB2(String guid, BrainBit2AmplifierParamNative param);

}
