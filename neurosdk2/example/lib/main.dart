import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:neurosdk2/neurosdk2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (kDebugMode) {
      Scanner scanner = await Scanner.create([
        FSensorFamily.leBrainBit,
        FSensorFamily.leBrainBit2,
        FSensorFamily.leBrainBitPro,
        FSensorFamily.leBrainBitFlex,
        FSensorFamily.leCallibri,
        FSensorFamily.leBrainBitBlack,
      ]);
      print("Scanner created");
      try {
        await scanner.start();
        print("Scanner started");
        StreamSubscription<List<FSensorInfo>>? scannerSubscr = scanner.sensorsStream.listen((event) {
          for (FSensorInfo info in event) {
            print("${info.name} (${info.address})");
          }
        });

        await Future.delayed(const Duration(seconds: 10));
        await scanner.stop();
        List<FSensorInfo?> sensors = await scanner.getSensors();
        print("Sensors founded: ${sensors.length}");
        scannerSubscr.cancel();

        for (var info in sensors) {
          Sensor? sensor = await scanner.createSensor(info!).onError((error, stackTrace) {
            print(error);
          });

          if (sensor == null) continue;

          StreamSubscription<FSensorState>? stateSubscr = sensor.sensorStateStream.listen((state) => print("State event: $state"));
          StreamSubscription<int>? powerSubscr = sensor.batteryPowerStream.listen((event) => print("Battery event: $event"));

          //await Future.delayed(const Duration(seconds: 10));

          // print("Test disconnect...");
          // await sensor.disconnect();
          // print("Test connect...");
          // await sensor.connect();

          try {
            await sensor.name.set("newName").onError((error, stackTrace) {
              print("Error while setting name: $error");
            });
          } catch (ex) {
            print(ex);
          }

          FSensorState state = await sensor.state.value;
          if (state == FSensorState.inRange) {
            print("connected");
          } else {
            print("disconnected");
          }

          try {
            print("features: ${await sensor.features.value}");
            print("commands: ${await sensor.commands.value}");
            print("parameters: ${await sensor.parameters.value}");
            print("name: ${await sensor.name.value}");
            print("state: ${await sensor.state.value}");
            print("address: ${await sensor.address.value}");
            print("sensFamily: ${await sensor.sensFamily.value}");
            print("serialNumber: ${await sensor.serialNumber.value}");
            print("battPower: ${await sensor.batteryPower.value}");
            try {
              print("samplingFrequency: ${await sensor.samplingFrequency.value}");
            } catch (error) {
              print(error);
            }
            try {
              print("gain: ${await sensor.gain.value}");
            } catch (error) {
              print(error);
            }

            print("dataOffset: ${await sensor.dataOffset.value}");
            print("firmwareMode: ${await sensor.firmwareMode.value}");
            print("version: ${(await sensor.version.value).toString()}");
            print("channelsCount: ${await sensor.channelsCount.value}");
          } catch (ex) {
            print(ex);
          }
          switch (info.sensFamily) {
            case FSensorFamily.unknown:
              break;
            case FSensorFamily.leCallibri:
            case FSensorFamily.leKolibri:
              var callibri = sensor as Callibri;
              StreamSubscription<List<CallibriSignalData>>? signalSubscr = callibri.signalDataStream.listen((event) => print("Signal values: $event"));
              StreamSubscription<List<CallibriEnvelopeData>>? envelopeSubscr = callibri.envelopeDataStream.listen((event) {
                print("Envelope: $event");
              });
              StreamSubscription<FCallibriElectrodeState>? electrodeSubscr = callibri.electrodeStateStream.listen((event) {
                print("Electrode $event");
              });
              StreamSubscription<List<QuaternionData>>? qSubscr = callibri.quaternionDataStream.listen((event) {
                print("Quart $event");
              });
              StreamSubscription<List<MEMSData>>? memsSubscr = callibri.memsDataStream.listen((event) {
                print("mems $event");
              });
              StreamSubscription<List<CallibriRespirationData>>? respSubscr = callibri.respirationDataStream.listen((event) {
                print("resp $event");
              });

              await callibri.samplingFrequency.set(FSensorSamplingFrequency.hz1000);
              print("Current SF: ${await callibri.samplingFrequency.value}");

              await callibri.signalType.set(CallibriSignalType.EEG);
              print("Current signal type: ${await callibri.signalType.value}");

              if (await sensor.isSupportedParameter(FSensorParameter.externalSwitchState)) {
                await callibri.extSwInput.set(FSensorExternalSwitchInput.electrodesRespUSBInp);
                print("Current ExtSwInp: ${await callibri.extSwInput.value}");
              }

              if (await sensor.isSupportedParameter(FSensorParameter.adcInputState)) {
                await callibri.adcInput.set(FSensorADCInput.electrodesInp);
                print("Current ADCInp: ${await callibri.adcInput.value}");
              }

              if (await callibri.isSupportedFeature(FSensorFeature.signal)) {
                Set<FSensorFilter> filters = {
                  FSensorFilter.BSFBwhLvl2CutoffFreq45_55Hz,
                  FSensorFilter.BSFBwhLvl2CutoffFreq55_65Hz,
                  FSensorFilter.HPFBwhLvl1CutoffFreq1Hz, // needs for correct signal
                  FSensorFilter.LPFBwhLvl2CutoffFreq400Hz
                };

                if (await callibri.isSupportedFilter(FSensorFilter.BSFBwhLvl2CutoffFreq45_55Hz)) {
                  await callibri.hardwareFilters.set({FSensorFilter.BSFBwhLvl2CutoffFreq45_55Hz});
                }

                try {
                  await callibri.hardwareFilters.set(filters);
                  print("Current filters: ${await callibri.hardwareFilters.value}");
                } catch (error) {
                  print(error);
                }
              }


              if (await callibri.isSupportedParameter(FSensorParameter.motionCounterParamPack)) {
                await callibri.motionCounterParam.set(FCallibriMotionCounterParam(insenseThresholdMG: 1, insenseThresholdSample: 1));
                print("Current mcParam: ${(await callibri.motionCounterParam.value).toString()}");
              }
              if (await callibri.isSupportedParameter(FSensorParameter.motionCounter)) {
                print("Motion counter: ${await callibri.motionCounter.value}");
              } else {
                print("MotionCounter is not supported");
              }

              print("Supported filters: ${await callibri.supportedFilters.value}");
              print("Color: ${await callibri.color.value}");

              callibri.adcInput.set(FSensorADCInput.resistanceInp);
              print("ADCInput: ${await callibri.adcInput.value}");

              print("El state: ${await callibri.electrodeState.value}");

              if (await callibri.isSupportedFeature(FSensorFeature.mems)) {
                try {
                  await sensor.execute(FSensorCommand.calibrateMEMS);
                  print("Is MEMS calibrated: ${await sensor.memsCalibrateState.value}");
                  print("Gyro sens: ${(await callibri.gyroSens.value).toString()}");
                  print("Acc sens: ${(await callibri.accSens.value).toString()}");
                  print("MEMS freq: ${await callibri.samplingFrequencyMEMS.value}");
                } catch (error) {
                  print(error);
                }
              } else {
                print("mems is not supported");
              }

              if (await sensor.isSupportedParameter(FSensorParameter.electrodeState)) {
                print("Electrode state: ${await sensor.electrodeState.value}");
              }

              if (await callibri.isSupportedFeature(FSensorFeature.respiration)) {
                print("Resp freq: ${await callibri.samplingFrequencyResp.value}");
              } else {
                print("respiration is not supported");
              }

              if (await callibri.isSupportedFeature(FSensorFeature.envelope)) {
                print("Env freq: ${await callibri.samplingFrequencyEnvelope.value}");
              } else {
                print("envelope is not supported");
              }

              if (await callibri.isSupportedFeature(FSensorFeature.currentStimulator)) {
                print("stimMAState: ${(await callibri.stimulatorMAState.value).toString()}");

                await callibri.stimulatorParam.set(FCallibriStimulationParams(current: 5, pulseWidth: 5, frequency: 5, stimulusDuration: 5));
                print("stimParam: ${(await callibri.stimulatorParam.value).toString()}");

                await callibri.motionAssistantParam.set(FCallibriMotionAssistantParams(gyroStart: 45, gyroStop: 10, limb: FCallibriMotionAssistantLimb.rightLeg, minPauseMs: 10));

                print("motionAssistParam: ${(await callibri.motionAssistantParam.value).toString()}");
              } else {
                print("stimulator is not supported");
              }

              if (await callibri.isSupportedFeature(FSensorFeature.signal)) {
                await exec(callibri, FSensorCommand.startSignal, FSensorCommand.stopSignal);
              }
              if (await callibri.isSupportedFeature(FSensorFeature.envelope)) {
                await exec(callibri, FSensorCommand.startEnvelope, FSensorCommand.stopEnvelope);
              }
              if (await callibri.isSupportedFeature(FSensorFeature.mems)) {
                await exec(callibri, FSensorCommand.startMEMS, FSensorCommand.stopMEMS);
              }
              if (await callibri.isSupportedCommand(FSensorCommand.startAngle)) {
                await exec(callibri, FSensorCommand.startAngle, FSensorCommand.stopAngle);
              }

              respSubscr.cancel();
              memsSubscr.cancel();
              qSubscr.cancel();
              electrodeSubscr.cancel();
              envelopeSubscr.cancel();
              signalSubscr.cancel();
              break;
            case FSensorFamily.leBrainBit:
              var brainBit = sensor as BrainBit;
              StreamSubscription<List<BrainBitSignalData>>? signalSubscr = brainBit.signalDataStream.listen((event) => print("Signal values: $event"));
              StreamSubscription<BrainBitResistData>? resistSubscr = brainBit.resistDataStream.listen((event) => print("resist values: $event"));

              var testGain = FSensorGain.gain3;
              await brainBit.gain.set(testGain);

              print("Gain: ${await brainBit.gain.value}");
              if (testGain != await brainBit.gain.value) {
                print('gain not set, test value = $testGain');
              }

              if (await brainBit.isSupportedFeature(FSensorFeature.signal)) {
                await exec(brainBit, FSensorCommand.startSignal, FSensorCommand.stopSignal);
              }
              if (await brainBit.isSupportedFeature(FSensorFeature.resist)) {
                await exec(brainBit, FSensorCommand.startResist, FSensorCommand.stopResist);
              }

              signalSubscr.cancel();
              resistSubscr.cancel();
              break;
            case FSensorFamily.leBrainBitBlack:
              var brainBitBlack = sensor as BrainBitBlack;

              StreamSubscription<List<BrainBitSignalData>>? signalSubscr = brainBitBlack.signalDataStream.listen((event) => print("Signal values: $event"));
              StreamSubscription<BrainBitResistData>? resistSubscr = brainBitBlack.resistDataStream.listen((event) => print("resist values: $event"));
              // bbblack only callbacks
              StreamSubscription<List<MEMSData>>? memsSubscr = brainBitBlack.memsDataStream.listen((event) {
                print(event);
              });
              StreamSubscription<FSensorAmpMode>? ampModeSubscr = brainBitBlack.ampModeStream.listen((event) => print("amp mode: $event"));
              StreamSubscription<List<FPGData>>? fpgSubscr = brainBitBlack.fpgStream.listen((event) => print("FPG: $event"));

              print("-- start read BrainBitBlack parameters --");
              print("samplingFrequencyMEMS: ${await brainBitBlack.samplingFrequencyMEMS.value}");
              print("samplingFrequencyFPG: ${await brainBitBlack.samplingFrequencyFPG.value}");
              print("samplingFrequencyResist: ${await brainBitBlack.samplingFrequencyResist.value}");
              print("irAmplitude: ${await brainBitBlack.irAmplitude.value}");
              print("redAmplitude: ${await brainBitBlack.redAmplitude.value}");
              print("ampMode: ${await brainBitBlack.ampMode.value}");
              print("accSens: ${await brainBitBlack.accSens.value}");
              print("gyroSens: ${await brainBitBlack.gyroSens.value}");

              await brainBitBlack.pingNeuroSmart(5);
              if (await brainBitBlack.isSupportedFeature(FSensorFeature.signal)) {
                await exec(brainBitBlack, FSensorCommand.startSignal, FSensorCommand.stopSignal);
              }
              if (await brainBitBlack.isSupportedFeature(FSensorFeature.resist)) {
                await exec(brainBitBlack, FSensorCommand.startResist, FSensorCommand.stopResist);
              }
              if (await brainBitBlack.isSupportedFeature(FSensorFeature.mems)) {
                await exec(brainBitBlack, FSensorCommand.startMEMS, FSensorCommand.stopMEMS);
              }
              if (await brainBitBlack.isSupportedFeature(FSensorFeature.fpg)) {
                await exec(brainBitBlack, FSensorCommand.startFPG, FSensorCommand.stopFPG);
              }

              memsSubscr.cancel();
              ampModeSubscr.cancel();
              fpgSubscr.cancel();
              resistSubscr.cancel();
              signalSubscr.cancel();
              break;
            case FSensorFamily.leBrainBit2:
            case FSensorFamily.leBrainBitPro:
            case FSensorFamily.leBrainBitFlex:
              BrainBit2 bb2 = sensor as BrainBit2;

              print("-- setup BrainBit2 --");

              StreamSubscription<List<SignalChannelsData>>? signalSubscr = bb2.signalDataStream.listen((event) => print("Signal values: $event"));
              StreamSubscription<List<ResistRefChannelsData>>? resistSubscr = bb2.resistDataStream.listen((event) => print("resist values: $event"));
              StreamSubscription<List<MEMSData>>? memsSubscr = bb2.memsDataStream.listen((event) {
                print(event);
              });
              StreamSubscription<FSensorAmpMode>? ampModeSubscr = bb2.ampModeStream.listen((event) => print("amp mode: $event"));
              StreamSubscription<List<FPGData>>? fpgSubscr = bb2.fpgStream.listen((event) => print("amp mode: $event"));

              int chCount = await bb2.channelsCount.value;
              BrainBit2AmplifierParam bb2ampParam = BrainBit2AmplifierParam(
                  chSignalMode: List.filled(chCount, FBrainBit2ChannelMode.chModeNormal),
                  chResistUse: List.filled(chCount, true),
                  chGain: List.filled(chCount, FSensorGain.gain3),
                  current: FGenCurrent.genCurr6nA);
              await bb2.amplifierParam.set(bb2ampParam);
              print("-- start read BrainBit2 parameters --");
              try{
                print("ampMode: ${await bb2.ampMode.value}");
                print("supportedChannels ${await bb2.supportedChannels.value}");
                print("samplingFrequencyMEMS: ${await bb2.samplingFrequencyMEMS.value}");
                print("samplingFrequencyFPG: ${await bb2.samplingFrequencyFPG.value}");
                print("samplingFrequencyResist: ${await bb2.samplingFrequencyResist.value}");
                print("irAmplitude: ${await bb2.irAmplitude.value}");
                print("redAmplitude: ${await bb2.redAmplitude.value}");
                print("accSens: ${await bb2.accSens.value}");
                print("gyroSens: ${await bb2.gyroSens.value}");
              }
              catch(ex){
                  print(ex);
              }
              print("-- stop read BrainBit2 parameters --");

              if (await bb2.isSupportedFeature(FSensorFeature.signal)) {
                await exec(bb2, FSensorCommand.startSignal, FSensorCommand.stopSignal);
              }
              if (await bb2.isSupportedFeature(FSensorFeature.resist)) {
                await exec(bb2, FSensorCommand.startResist, FSensorCommand.stopResist);
              }
              if (await bb2.isSupportedFeature(FSensorFeature.mems)) {
                await exec(bb2, FSensorCommand.startMEMS, FSensorCommand.stopMEMS);
              }
              if (await bb2.isSupportedFeature(FSensorFeature.fpg)) {
                await exec(bb2, FSensorCommand.startFPG, FSensorCommand.stopFPG);
              }

              signalSubscr.cancel();
              resistSubscr.cancel();
              memsSubscr.cancel();
              ampModeSubscr.cancel();
              fpgSubscr.cancel();
              break;
          }

          stateSubscr.cancel();
          powerSubscr.cancel();

          await sensor.disconnect();
          sensor.dispose();
        }
      } on Exception catch (e){
        print(e);
      }

      scanner.dispose();
    }
    if (!mounted) return;
  }

  Future<void>? exec(Sensor? sens, FSensorCommand start, FSensorCommand stop) async {
    await sens?.execute(start);
    await Future.delayed(const Duration(seconds: 10));
    await sens?.execute(stop);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Test'),
        ),
      ),
    );
  }
}
