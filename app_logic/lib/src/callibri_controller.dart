import 'package:neurosdk2/neurosdk2.dart';
import 'package:rxdart/rxdart.dart';

enum CallibriDataState { signal, envelope, mems }

enum CallibriConnectionState {
  connection,
  connected,
  disconnection,
  disconnected,
  error,
}

class CallibriInfo {
  const CallibriInfo({
    required this.name,
    required this.adress,
    required this.sensorInfo,
  });

  final String name;
  final String adress;
  final FSensorInfo sensorInfo;
}

class CallibriController {
  CallibriController();

  Scanner? _scanner;

  void _onSensorsChanged(List<FSensorInfo> data) {
    print(data);
  }

  Future<Scanner> _ensureScanner() async {
    if (_scanner case final scanner?) return scanner;

    final scanner = await Scanner.create(_filters)
      ..sensorsStream.listen(_onSensorsChanged);

    return _scanner = scanner;
  }

  void search({required Duration duration}) async {
    final scanner = await _ensureScanner();
  }

  void dispose() {}

  static const _filters = <FSensorFamily>[.leCallibri, .leKolibri];
}

class CallibriGestureRecognizer {}

// public struct SimpleMEMSData
// {
//     public Accelerometer Accelerometer;
//     public NeuroSDK.Gyroscope Gyroscope;
// }

// public partial class CallibriInfo : ObservableObject
// {
//     [ObservableProperty] private string _name = "";
//     [ObservableProperty] private string _address = "";
//     public SensorInfo SensInfo { get; set; }
//     [ObservableProperty] private ConnectionState _connectionState = ConnectionState.Disconnected;
//     partial void OnConnectionStateChanged(ConnectionState value)
//     {
//         switch (value)
//         {
//             case ConnectionState.Connection:
//                 ConnectingLabel = "...";
//                 break;
//             case ConnectionState.Connected:
//                 ConnectingLabel = "";
//                 break;
//             case ConnectionState.Disconnection:
//                 ConnectingLabel = "...";
//                 break;
//             case ConnectionState.Disconnected:
//                 ConnectingLabel = "";
//                 break;
//             case ConnectionState.Error:
//                 ConnectingLabel = " ";
//                 break;
//         }
//     }
//     [ObservableProperty] string _connectingLabel = "";
// }

// public enum CallibriDataState
// {
//     Signal,
//     Envelope,
//     MEMS,
// }

// public enum ConnectionState
// {
//     Connection,
//     Connected,
//     Disconnection,
//     Disconnected,
//     Error
// }

// class CallibriAdditional
// {
//     public bool needReconnect = false;
//     public CallibriSensor CSensor;
//     public List<CallibriDataState> DataState = new();

//     public CallibriAdditional(bool needReconnect, CallibriSensor bb)
//     {
//         this.needReconnect = needReconnect;
//         this.CSensor = bb;
//     }
// }

// public class CallibriController
// {
//     #region Fields
//     private Scanner scanner;
//     private Dictionary<string, CallibriAdditional> connectedDevices = new();
//     private List<string> disconnectedDevices = new();

//     public IReadOnlyList<string> ConnectedDevices => connectedDevices.Keys.ToList();

//     #endregion

//     #region Interface
//     public event Action<string, ConnectionState> EventConnectionStateChanged;
//     public event Action<string, int> EventBatteryChanged;

//     public async Task<IEnumerable<CallibriInfo>> SearchWithResult(int seconds, List<string> addresses)
//     {
//         return await Task.Run(async () =>
//         {
//             createScanner();
//             scanner.Start();
//             await Task.Delay(seconds * 1000);
//             scanner.Stop();
//             var founded = scanner.Sensors;
//             if (founded.Count > 0)
//             {
//                 return founded.Where(si => addresses.Count() < 1 || addresses.Contains(si.Address))
//                     .Select(si => new CallibriInfo()
//                     {
//                         Name = si.Name,
//                         Address = si.Address,
//                         SensInfo = si,
//                         ConnectionState=ConnectionState.Disconnected
//                     });
//             }
//             return new List<CallibriInfo>();
//         });
//     }

//     public async Task ConnectTo(CallibriInfo info, bool needReconnect = false)
//     {
//         await Task.Run(() =>
//         {
//             createScanner();
//             SendConnectionEvent(info.Address, ConnectionState.Connection);

//             try
//             {
//                 if (scanner.CreateSensor(info.SensInfo) is CallibriSensor bb)
//                 {
//                     bb.EventSensorStateChanged += eventSensorStateChanged;
//                     bb.EventBatteryChanged += eventBatteryChanged;
//                     connectedDevices.Add(info.Address, new CallibriAdditional(needReconnect, bb));
//                     SendConnectionEvent(info.Address, ConnectionState.Connected);
//                 }
//                 else
//                 {
//                     SendConnectionEvent(info.Address, ConnectionState.Error);
//                 }
//             }
//             catch (Exception ex)
//             {
//                 SendConnectionEvent(info.Address, ConnectionState.Error);
//             }
//         });
//     }

//     private void SendConnectionEvent(string address, ConnectionState state)
//     {
//         Trace.WriteLine("SendConnectionEvent");
//         Application.Current.Dispatcher.Invoke(() => {
//             Trace.WriteLine("SendConnectionEvent from job");
//             EventConnectionStateChanged?.Invoke(address, state);
//         });
//     }

//     public async Task DisconnectFrom(string address)
//     {
//         await Task.Run(() =>
//         {
//             SendConnectionEvent(address, ConnectionState.Disconnection);
//             if (disconnectedDevices.Contains(address))
//             {
//                 disconnectedDevices.Remove(address);
//                 if (disconnectedDevices.Count() < 1) scanner.Stop();
//             }
//             var tmp = connectedDevices[address];
//             connectedDevices.Remove(address);
//             tmp.CSensor.Disconnect();
//             tmp.CSensor.Dispose();
//             tmp.CSensor = null;
//             SendConnectionEvent(address, ConnectionState.Disconnected);
//         });
//     }

// #endregion

//     #region Internal
//     private void eventBatteryChanged(ISensor sensor, int battPower)
//     {
//         Application.Current.Dispatcher.Invoke(() =>
//         {
//             EventBatteryChanged?.Invoke(sensor.Address, battPower);
//         });
//         Trace.WriteLine($"Power ({sensor.Address}): {battPower}");
//     }

//     private void eventSensorStateChanged(ISensor sensor, SensorState sensorState)
//     {
//         SendConnectionEvent(sensor.Address, sensorState == SensorState.StateInRange ? ConnectionState.Connected : ConnectionState.Disconnected);

//         if (sensorState == SensorState.StateOutOfRange && connectedDevices.ContainsKey(sensor.Address) && connectedDevices[sensor.Address].needReconnect)
//         {
//             disconnectedDevices.Add(sensor.Address);
//             Application.Current.Dispatcher.Invoke(() =>
//             {
//                 if (scanner == null) createScanner();
//                 scanner.Start();
//             });
//         }
//     }

//     private void eventSensorsChanged(IScanner scanner, IReadOnlyList<SensorInfo> sensors)
//     {
//         var founded = sensors.Where(si => disconnectedDevices.Contains(si.Address));
//         if (founded.Count() > 0)
//         {
//             scanner.Stop();
//             var cbAdditional = connectedDevices[founded.First().Address];
//             cbAdditional.CSensor.Connect();
//             if (cbAdditional.CSensor.State != SensorState.StateInRange)
//             {
//                 scanner.Start();
//             }
//             else
//             {
//                 if(cbAdditional.DataState.Contains(CallibriDataState.Signal))
//                     cbAdditional.CSensor.ExecCommand(SensorCommand.CommandStartSignal);
//                 if (cbAdditional.DataState.Contains(CallibriDataState.Envelope))
//                     cbAdditional.CSensor.ExecCommand(SensorCommand.CommandStartEnvelope);
//                 if (cbAdditional.DataState.Contains(CallibriDataState.MEMS))
//                     cbAdditional.CSensor.ExecCommand(SensorCommand.CommandStartMEMS);
//                 disconnectedDevices.Remove(founded.First().Address);
//             }
//         }
//     }

//     private void createScanner()
//     {
//         if(scanner == null)
//         {
//             scanner = new Scanner(SensorFamily.SensorLECallibri, SensorFamily.SensorLEKolibri);
//             scanner.EventSensorsChanged += eventSensorsChanged;
//         }

//     }
//     #endregion

//     #region Signal
//     public event Action<string, double[]> EventSignalDataReceived;

//     public async void ReceiveSignal(string address)
//     {
//         await Task.Run(() => {
//             var tmp = connectedDevices[address].CSensor;
//             tmp.EventCallibriSignalDataRecived += eventCallibriSignalDataRecived;
//             tmp.ExecCommand(SensorCommand.CommandStartSignal);
//             if(!connectedDevices[address].DataState.Contains(CallibriDataState.Signal))
//                 connectedDevices[address].DataState.Add(CallibriDataState.Signal);
//         });
//     }

//     private void eventCallibriSignalDataRecived(ISensor sensor, CallibriSignalData[] data)
//     {
//         var cAddition = connectedDevices[sensor.Address];

//         var pack = new List<double>();
//         foreach (var sample in data)
//         {
//             foreach (var it in sample.Samples)
//             {
//                 pack.Add(it * 1e6);
//             }
//         }
//         Application.Current.Dispatcher.Invoke(() =>
//         {
//             EventSignalDataReceived?.Invoke(sensor.Address, pack.ToArray());
//         });
//     }

//     public async void StopReceiveSignal(string address)
//     {
//         await Task.Run(() => {
//             var tmp = connectedDevices[address].CSensor;
//             tmp.EventCallibriSignalDataRecived -= eventCallibriSignalDataRecived;
//             tmp.ExecCommand(SensorCommand.CommandStopSignal);
//             connectedDevices[address].DataState.Remove(CallibriDataState.Signal);
//         });
//     }
//     #endregion

//     #region Envelope
//     public event Action<string, double[]> EventEnvelopeDataReceived;
//     public async void ReceiveEnvelope(string address)
//     {
//         await Task.Run(() => {
//             var tmp = connectedDevices[address].CSensor;
//             tmp.EventCallibriEnvelopeDataRecived += eventCallibriEnvelopeDataRecived;
//             tmp.ExecCommand(SensorCommand.CommandStartEnvelope);
//             if (!connectedDevices[address].DataState.Contains(CallibriDataState.Envelope))
//                 connectedDevices[address].DataState.Add(CallibriDataState.Envelope);
//         });
//     }

//     private void eventCallibriEnvelopeDataRecived(ISensor sensor, CallibriEnvelopeData[] data)
//     {
//         var cAddition = connectedDevices[sensor.Address];

//         var pack = new List<double>();
//         foreach (var sample in data)
//         {
//             pack.Add(sample.Sample * 1e6);
//         }
//         Application.Current.Dispatcher.Invoke(() =>
//         {
//             EventEnvelopeDataReceived?.Invoke(sensor.Address, pack.ToArray());
//         });
//     }

//     public async void StopReceiveEnvelope(string address)
//     {
//         await Task.Run(() => {
//             var tmp = connectedDevices[address].CSensor;
//             tmp.EventCallibriEnvelopeDataRecived -= eventCallibriEnvelopeDataRecived;
//             tmp.ExecCommand(SensorCommand.CommandStopEnvelope);
//             connectedDevices[address].DataState.Remove(CallibriDataState.Envelope);
//         });
//     }
//     #endregion

//     #region MEMS
//     public event Action<string, SimpleMEMSData[]> EventMEMSDataReceived;

//     public async void ReceiveMEMS(string address)
//     {
//         await Task.Run(() => {
//             var tmp = connectedDevices[address].CSensor;
//             tmp.EventMEMSDataRecived += eventCallibriMEMSDataRecived;
//             tmp.ExecCommand(SensorCommand.CommandStartMEMS);
//             if (!connectedDevices[address].DataState.Contains(CallibriDataState.MEMS))
//                 connectedDevices[address].DataState.Add(CallibriDataState.MEMS);
//         });
//     }

//     private void eventCallibriMEMSDataRecived(ISensor sensor, MEMSData[] data)
//     {
//         var cAddition = connectedDevices[sensor.Address];

//         var pack = new List<SimpleMEMSData>();
//         foreach (var sample in data)
//         {
//             pack.Add(new SimpleMEMSData()
//             {
//                 Accelerometer = sample.Accelerometer,
//                 Gyroscope = sample.Gyroscope,
//             });
//         }
//         Application.Current.Dispatcher.Invoke(() =>
//         {
//             EventMEMSDataReceived?.Invoke(sensor.Address, pack.ToArray());
//         });
//     }

//     public async void StopReceiveMEMS(string address)
//     {
//         await Task.Run(() => {
//             var tmp = connectedDevices[address].CSensor;
//             tmp.EventMEMSDataRecived -= eventCallibriMEMSDataRecived;
//             tmp.ExecCommand(SensorCommand.CommandStopMEMS);
//             connectedDevices[address].DataState.Remove(CallibriDataState.MEMS);
//         });
//     }
//     #endregion

//     public void StopAll()
//     {
//         if (scanner != null)
//         {
//             scanner.EventSensorsChanged -= eventSensorsChanged;
//             scanner.Stop();
//             scanner.Dispose();
//             scanner = null;
//         }
//         foreach(var bb in connectedDevices.Values)
//         {
//             bb.CSensor.Disconnect();
//             bb.CSensor.Dispose();
//         }
//         connectedDevices.Clear();
//     }
// }
