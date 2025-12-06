import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class drawGraph extends StatefulWidget {
  final List<Offset> initialDots;
  
  const drawGraph({
    super.key,
    this.initialDots = const [],
  });
  
  @override
  State<drawGraph> createState() => _drawGraphState();
}

class _drawGraphState extends State<drawGraph> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
          LineChartBarData(
            spots: widget.initialDots.map((currDot) => FlSpot(currDot.dx, currDot.dy)).toList(),
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true),
          ),
        ],
        )
      ),
    );
  }
}