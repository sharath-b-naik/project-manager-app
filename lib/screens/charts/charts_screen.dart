import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../utils/app_colors.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Project Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ChartTypeButton(
                      title: 'Line Chart',
                      isSelected: _selectedChartIndex == 0,
                      onTap: () => setState(() => _selectedChartIndex = 0),
                    ),
                    const SizedBox(width: 8),
                    _ChartTypeButton(
                      title: 'Bar Chart',
                      isSelected: _selectedChartIndex == 1,
                      onTap: () => setState(() => _selectedChartIndex = 1),
                    ),
                    const SizedBox(width: 8),
                    _ChartTypeButton(
                      title: 'Pie Chart',
                      isSelected: _selectedChartIndex == 2,
                      onTap: () => setState(() => _selectedChartIndex = 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildSelectedChart(projectProvider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedChart(ProjectProvider projectProvider) {
    switch (_selectedChartIndex) {
      case 0:
        return _buildLineChart();
      case 1:
        return _buildBarChart(projectProvider);
      case 2:
        return _buildPieChart(projectProvider);
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Progress Over Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                          Widget text;
                          switch (value.toInt()) {
                            case 1:
                              text = const Text('Jan', style: style);
                              break;
                            case 2:
                              text = const Text('Feb', style: style);
                              break;
                            case 3:
                              text = const Text('Mar', style: style);
                              break;
                            case 4:
                              text = const Text('Apr', style: style);
                              break;
                            case 5:
                              text = const Text('May', style: style);
                              break;
                            case 6:
                              text = const Text('Jun', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(meta: meta, child: text);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                          return Text('${value.toInt()}', style: style);
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!, width: 1)),
                  minX: 0,
                  maxX: 7,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(1, 1.5),
                        FlSpot(2, 2.8),
                        FlSpot(3, 3.1),
                        FlSpot(4, 4.2),
                        FlSpot(5, 4.8),
                        FlSpot(6, 5.2),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.8), AppColors.primary]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(ProjectProvider projectProvider) {
    final projects = projectProvider.projects;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Projects by Media Count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey,
                      tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                      tooltipMargin: -10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String projectName =
                            projects.isNotEmpty && groupIndex < projects.length
                                ? projects[groupIndex].name
                                : 'Project ${groupIndex + 1}';
                        return BarTooltipItem(
                          '$projectName\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${rod.toY.round()} items',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                          String text =
                              projects.isNotEmpty && value.toInt() < projects.length
                                  ? projects[value.toInt()].name.split(' ').first
                                  : 'P${value.toInt() + 1}';
                          return SideTitleWidget(meta: meta, child: Text(text, style: style));
                        },
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                          return Text('${value.toInt()}', style: style);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateBarGroups(projects),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List projects) {
    if (projects.isEmpty) {
      return [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 5,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 3,
              color: AppColors.secondary,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 7,
              color: Colors.orange,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      ];
    }

    return projects.asMap().entries.map<BarChartGroupData>((entry) {
      int index = entry.key;
      var project = entry.value;
      double mediaCount = (project.images.length + project.videos.length).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: mediaCount > 0 ? mediaCount : 1,
            color: _getBarColor(index),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(int index) {
    final colors = [AppColors.primary, AppColors.secondary, Colors.orange, Colors.green, Colors.purple];
    return colors[index % colors.length];
  }

  Widget _buildPieChart(ProjectProvider projectProvider) {
    final projects = projectProvider.projects;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            // Handle touch events if needed
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _generatePieSections(projects),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildLegend(projects),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(List projects) {
    if (projects.isEmpty) {
      return [
        PieChartSectionData(
          color: AppColors.primary,
          value: 40,
          title: '40%',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        PieChartSectionData(
          color: AppColors.secondary,
          value: 30,
          title: '30%',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        PieChartSectionData(
          color: Colors.orange,
          value: 30,
          title: '30%',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }

    double total = projects.length.toDouble();
    return projects.asMap().entries.map<PieChartSectionData>((entry) {
      int index = entry.key;
      double percentage = (1 / total) * 100;

      return PieChartSectionData(
        color: _getBarColor(index),
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<Widget> _buildLegend(List projects) {
    if (projects.isEmpty) {
      return [
        _LegendItem(color: AppColors.primary, text: 'Sample A'),
        _LegendItem(color: AppColors.secondary, text: 'Sample B'),
        _LegendItem(color: Colors.orange, text: 'Sample C'),
      ];
    }

    return projects.asMap().entries.map<Widget>((entry) {
      int index = entry.key;
      var project = entry.value;

      return _LegendItem(color: _getBarColor(index), text: project.name.split(' ').first);
    }).toList();
  }
}

class _ChartTypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTypeButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
