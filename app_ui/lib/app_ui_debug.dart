import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {

  List <String> strs = ["ssl://213.123.4525.23", "ssl://213.123.4525.23", "ssl://213.123.4525.23", "ssl://213.123.4525.23"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: strs.length,
        itemBuilder: (str, index) {
          return cardSocket(child: const Text("123"));
        },
      )
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
    return Material(
      color: Colors.blue,
      child: widget.child,
      borderRadius: .circular(28),
    );
  }
}