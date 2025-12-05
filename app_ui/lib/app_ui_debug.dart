import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:neurosdk2/neurosdk2.dart";

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  List<String> strs = [
    "ssl://213.123.4525.23",
    "ssl://213.123.4525.23",
    "ssl://213.123.4525.23",
    "ssl://213.123.4525.23",
  ];

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: ListView.builder(
    //     itemCount: strs.length,
    //     itemBuilder: (str, index) {
    //       return cardSocket(child: Text("${strs[index]}", style: TextStyle(fontSize: 15, fontWeight: .w700)));
    //     },
    //   )
    // );
    return MaterialApp(home: SimpleDeviceLoader());
  }
}

class SimpleDeviceLoader extends StatefulWidget {
  @override
  _SimpleDeviceLoaderState createState() => _SimpleDeviceLoaderState();
}

class _SimpleDeviceLoaderState extends State<SimpleDeviceLoader> {
  bool isLoading = false;
  List<String> devices = [];

  void loadDevices() async {
    Scanner sc = await Scanner.create([
      FSensorFamily.leCallibri,
      FSensorFamily.leKolibri,
    ]);
    await sc.start();
    setState(() {
      isLoading = true;
      devices = [];
    });
    await Future.delayed(Duration(seconds: 10));
    await sc.stop();
    List<FSensorInfo?> sensors = await sc.getSensors();
    List<String> newDevs = ["ssl://123.321.23.21"];
    // sensors.forEach((ls) => newDevs.add("${ls?.name} : ${ls?.address}"));
    setState(() {
      devices = newDevs;
      isLoading = false;
    });
    if (devices.isNotEmpty) {
      final currSens = await sc.createSensor(sensors.first!) as Callibri;
      await currSens.connect();
      currSens.signalDataStream.listen((data) {
        // TODO: send data to Oleg and Roma
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Устройства')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoading && devices.isEmpty) ...[
              ElevatedButton(
                onPressed: loadDevices,
                child: Text('Начать загрузку'),
              ),
            ],

            if (isLoading) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Загрузка... (всего 10 секунд)'),
            ],
            if (devices.isNotEmpty)  ...[
              SizedBox(height: 20),
              ...devices
                  .map((device) => Card(child: ListTile(title: Text(device))))
                  .toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    devices = [];
                    //TODO: stop work
                  });
                },
                child: Text('Выключить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class cardSocket extends StatefulWidget {
  const cardSocket({super.key, required this.child});

  final Widget child;

  @override
  State<cardSocket> createState() => _cardSocketState();
}

class _cardSocketState extends State<cardSocket> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(10),
      child: Material(
        color: Colors.blue,
        child: Padding(padding: .all(10), child: widget.child),
        borderRadius: .circular(28),
      ),
    );
  }
}
