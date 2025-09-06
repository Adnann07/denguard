import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'language_service.dart';
import 'dart:math' as math;

//database page
class HotspotPage extends StatefulWidget {
  const HotspotPage({super.key});

  @override
  State<HotspotPage> createState() => _HotspotPageState();
}

class _HotspotPageState extends State<HotspotPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // English translations
  final Map<String, String> _englishTexts = {
    'title': 'Dengue Hotspots',
    'divisionCases': 'Division & City Corporation Cases',
    'fromJanuary': 'From 1 January to Till Date',
    'admittedCases': 'Admitted Cases Trend',
    'monthlyCases': 'Monthly Dengue Cases',
    'monthlyTrend': 'Cases by Month in 2025',
    'genderDistribution': 'Gender Distribution',
    'genderFrom': 'From 1 January to Till Date 2025',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'cases': 'Cases',
    'week': 'Week',
    'loading': 'Loading data...',
    'error': 'Error loading data',
    'noData': 'No data available',
    'divisionWise': 'Division-wise Cases',
  };

  // Bangla translations
  final Map<String, String> _banglaTexts = {
    'title': 'ডেঙ্গু হটস্পট',
    'divisionCases': 'বিভাগ ও সিটি কর্পোরেশন কেস',
    'fromJanuary': '১ জানুয়ারি থেকে আজ পর্যন্ত',
    'admittedCases': 'ভর্তিকৃত রোগীর প্রবণতা',
    'monthlyCases': ' ডেঙ্গু কেস',
    'monthlyTrend': '২০২৫ সালে মাস অনুযায়ী কেস',
    'genderDistribution': 'জেন্ডারভিত্তিক সনাক্তকরণ',
    'genderFrom': '১ জানুয়ারি থেকে আজ পর্যন্ত ২০২৫',
    'male': 'পুরুষ',
    'female': 'মহিলা',
    'other': 'অন্যান্য',
    'cases': 'কেস',
    'week': 'সপ্তাহ',
    'loading': 'ডেটা লোড হচ্ছে...',
    'error': 'ডেটা লোড করতে ত্রুটি',
    'noData': 'কোন ডেটা নেই',
    'divisionWise': 'বিভাগ অনুযায়ী কেস',
  };

  String _getText(String key) {
    final languageService = Provider.of<LanguageService>(
        context, listen: false);
    return languageService.isEnglish ? _englishTexts[key]! : _banglaTexts[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('title')),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDivisionCards(),
            const SizedBox(height: 20),
            _buildChartCard(
              title: _getText('divisionWise'),
              subtitle: _getText('fromJanuary'),
              child: _buildDivisionCasesChart(),
            ),
            const SizedBox(height: 20),
            _buildChartCard(
              title: _getText('monthlyCases'),
              subtitle: _getText('monthlyTrend'),
              child: _buildMonthlyCasesChart(),
            ),
            const SizedBox(height: 20),
            _buildChartCard(
              title: _getText('genderDistribution'),
              subtitle: _getText('genderFrom'),
              child: _buildGenderDistributionChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisionCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('dengue_division_cases')
          .orderBy('cases', descending: true)    // dascending order by cases count
          .snapshots(),
       builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget(height: 120);
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildErrorWidget(height: 120);
        }

        final divisions = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'division': data['division']?.toString() ?? 'Unknown',
            'cases': (data['cases'] as num?)?.toInt() ?? 0,
          };
        }).toList();

        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: divisions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final division = divisions[index]['division'] as String;
              final cases = divisions[index]['cases'] as int;

              return Container(
                width: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getDivisionGradientColors(index)[0],
                      _getDivisionGradientColors(index)[1],
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getDivisionGradientColors(index)[0].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_city,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_getText('cases')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      division,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cases.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
//chart build
  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
//division card

  Widget _buildDivisionCasesChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('dengue_division_cases').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          debugPrint('Error loading division data: ${snapshot.error}');
          return _buildErrorWidget();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoDataWidget();
        }

        // Get division data from dengue_division_cases collection
        final divisions = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'div': data['div']?.toString() ?? 'Unknown',  // Using 'div' field
            'cases': (data['cases'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();

        final maxY = divisions.isEmpty
            ? 100.0
            : (divisions.map((e) => e['cases'] as double).reduce(math.max) * 1.2).toDouble();


        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${divisions[group.x]['div']}\n${rod.toY.round()} ${_getText('cases')}',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() < divisions.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          divisions[value.toInt()]['div'] as String,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: divisions.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value['cases'] as double,
                    color: _getDivisionColor(entry.key),
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

//monthly chart
  Widget _buildMonthlyCasesChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('dengue_monthly_cases').orderBy('month').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildErrorWidget();
        }

        final data = snapshot.data!.docs.map((doc) {
          return {
            'month': doc['month_name']?.toString() ?? 'Unknown',
            'cases': (doc['cases'] as num).toDouble(),
          };
        }).toList();

        final maxY = data.map((e) => e['cases'] as double).reduce(math.max) * 1.2;

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${data[group.x]['month']}\n${rod.toY.round()} ${_getText('cases')}',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data[value.toInt()]['month'] as String,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value['cases'] as double,
                    color: _getMonthColor(entry.key),
                    width: 25,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildGenderDistributionChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('dengue_gender_distribution').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildErrorWidget();
        }

        final data = snapshot.data!.docs.map((doc) {
          return {
            'gender': doc['gender']?.toString() ?? 'Unknown',
            'cases': (doc['cases'] as num).toDouble(),
            'color': _getGenderColor(doc['gender'] as String),
          };
        }).toList();

        final total = data.fold<double>(0, (sum, item) => sum + (item['cases'] as double));

        return SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: data.map((item) {
                      final percentage = ((item['cases'] as double) / total * 100);
                      return PieChartSectionData(
                        color: item['color'] as Color,
                        value: item['cases'] as double,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGenderLabel(item['gender'] as String),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${(item['cases'] as double).toInt()} ${_getText('cases')}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Color> _getDivisionGradientColors(int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple-Blue
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Pink-Red
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue-Cyan
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green-Teal
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Pink-Yellow
      [const Color(0xFF5ee7df), const Color(0xFF66a6ff)], // Teal-Blue
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)], // Mint-Pink
      [const Color(0xFFffeaa7), const Color(0xFFfab1a0)], // Yellow-Orange
    ];
    return gradients[index % gradients.length];
  }

  Color _getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'পুরুষ':
        return Colors.blue[600]!;
      case 'female':
      case 'মহিলা':
        return Colors.pink[400]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getDivisionColor(int index) {
    final colors = [
      Colors.red[400]!,
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.teal[400]!,
      Colors.indigo[400]!,
    ];
    return colors[index % colors.length];
  }

  Color _getMonthColor(int index) {
    final colors = [
      Colors.green[600]!,
      Colors.lightGreen[600]!,
      Colors.teal[600]!,
      Colors.cyan[600]!,
      Colors.blue[600]!,
      Colors.indigo[600]!,
      Colors.purple[600]!,
      Colors.deepPurple[600]!,
      Colors.pink[600]!,
      Colors.red[600]!,
      Colors.orange[600]!,
      Colors.amber[600]!,
    ];
    return colors[index % colors.length];
  }

  String _getGenderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return _getText('male');
      case 'female':
        return _getText('female');
      default:
        return _getText('other');
    }
  }

  Widget _buildLoadingWidget({double height = 300}) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _getText('loading'),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget({double height = 300}) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getText('error'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget({double height = 300}) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getText('noData'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}