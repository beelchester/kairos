import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kairos/src/global_states.dart';
import 'package:kairos/src/widgets/appbar.dart';
import 'package:kairos/src/widgets/drawer.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late int _chosen;
  late int showingTooltip;
  @override
  void initState() {
    _chosen = 1;
    showingTooltip = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStates>(
        builder: (context, globalStates, child) => Scaffold(
            appBar: const AppBarWidget(),
            drawer: const DrawerWidget(),
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _durationPicker(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: _vertBarChart(),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: _horBarChart(),
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  BarChart _vertBarChart() {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(
          show: false,
        ),
        titlesData: const FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // leftTitles: AxisTitles(
          //   sideTitles: SideTitles(interval: 5, showTitles: true),
          // ),
        ),
        barGroups: [
          generateVerGroupData(1, 10),
          generateVerGroupData(2, 18),
          generateVerGroupData(3, 4),
          generateVerGroupData(4, 11),
          generateVerGroupData(5, 7),
          generateVerGroupData(6, 16),
          generateVerGroupData(7, 20),
          generateVerGroupData(8, 14),
          generateVerGroupData(9, 23),
          generateVerGroupData(10, 13),
        ],
        barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchCallback: (event, response) {
              if (response != null &&
                  response.spot != null &&
                  event is FlTapUpEvent) {
                setState(() {
                  final x = response.spot!.touchedBarGroup.x;
                  final isShowing = showingTooltip == x;
                  if (isShowing) {
                    showingTooltip = -1;
                  } else {
                    showingTooltip = x;
                  }
                });
              }
            },
            mouseCursorResolver: (event, response) {
              return response == null || response.spot == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click;
            }),
      ),
    );
  }

  Widget bottomHorTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 13);
    String text;
    switch (value.toInt()) {
      case 1:
        text = 'Today';
        break;
      case 2:
        text = 'Yester..';
        break;
      case 3:
        text = '2d ago';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 4.7,
      space: 11,
      child: SizedBox(
        width: 60,
        child: Text(text, style: style),
      ),
    );
  }

  BarChart _horBarChart() {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomHorTitles,
                reservedSize: 40),
          ),
        ),
        barGroups: [
          generateHorGroupData(1, 10),
          generateHorGroupData(2, 18),
          generateHorGroupData(3, 4),
        ],
        barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
                rotateAngle: 270, tooltipPadding: const EdgeInsets.all(8)),
            handleBuiltInTouches: false,
            touchCallback: (event, response) {
              if (response != null &&
                  response.spot != null &&
                  event is FlTapUpEvent) {
                setState(() {
                  final x = response.spot!.touchedBarGroup.x;
                  final isShowing = showingTooltip == x;
                  if (isShowing) {
                    showingTooltip = -1;
                  } else {
                    showingTooltip = x;
                  }
                });
              }
            },
            mouseCursorResolver: (event, response) {
              return response == null || response.spot == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click;
            }),
      ),
    );
  }

  BarChartGroupData generateHorGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [
        BarChartRodData(
            toY: y.toDouble(), color: Theme.of(context).colorScheme.secondary
            // gradient: LinearGradient(
            //   colors: [
            //     Theme.of(context).colorScheme.primary,
            //     Theme.of(context).colorScheme.secondary
            //   ],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
            ),
      ],
    );
  }

  BarChartGroupData generateVerGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  Widget _durationPicker() {
    return Container(
        margin: const EdgeInsets.all(10),
        // decoration: BoxDecoration(
        //   color: Theme.of(context).colorScheme.secondaryContainer,
        //   borderRadius: BorderRadius.circular(10),
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _chosen = 1;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _chosen == 1
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Text(
                'Day',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _chosen = 2;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _chosen == 2
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Text(
                'Week',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _chosen = 3;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _chosen == 3
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Text(
                'Month',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _chosen = 4;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _chosen == 4
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Text(
                'Year',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ));
  }
}
