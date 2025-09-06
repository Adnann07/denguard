import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_service.dart';
import 'symptom_checker.dart';
import 'prevention_tips_page.dart';
import 'admin_page.dart';
import 'BloodDonorsPage.dart';
import 'EmergencyNumbersPage.dart';
import 'hotspot_page.dart'; // Add this import for your hotspot page
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'LocalRiskPage.dart';
import 'nearby_map_screen.dart';
import 'package:intl/intl.dart';
import 'easyhospital.dart';
import 'hotspot_pred.dart';
import 'chikungunya_page.dart';
import 'ICU.dart';

class DengueHomePage extends StatefulWidget {
  const DengueHomePage({super.key, required this.title});

  final String title;

  @override
  State<DengueHomePage> createState() => _DengueHomePageState();
}
//scrolling headline here
class ScrollingHeadline extends StatefulWidget {
  final bool isEnglish;

  const ScrollingHeadline({super.key, required this.isEnglish});

  @override
  State<ScrollingHeadline> createState() => _ScrollingHeadlineState();
}

class _ScrollingHeadlineState extends State<ScrollingHeadline> {
  final ScrollController _controller = ScrollController();
  final List<String> _headlines = [];
  bool _isScrolling = true;
  bool _isLoading = true;
  final DengueStatsService _statsService = DengueStatsService();
  StreamSubscription<Map<String, dynamic>>? _statsSubscription;

  @override
  void initState() {
    super.initState();
    _setupStatsListener();
  }

  void _setupStatsListener() {
    _statsSubscription?.cancel();
    _statsSubscription = _statsService.getDengueStatsStream().listen(
          (stats) {
        _updateHeadlines(stats);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error loading headlines: $error');
        }
        _initializeDefaultHeadlines();
        setState(() {
          _isLoading = false;
        });
        _startAutoScroll();
      },
    );
  }

  void _updateHeadlines(Map<String, dynamic> stats) {
    _headlines.clear();

    // firebase theke fetch kora headline
    String lastUpdatedText = '';
    if (stats['lastUpdated'] != null) {
      final DateTime lastUpdatedDateTime = (stats['lastUpdated'] as Timestamp)
          .toDate();
      final String formattedDate = DateFormat('MMM d, yyyy – h:mm a').format(
          lastUpdatedDateTime);
      lastUpdatedText = widget.isEnglish
          ? 'Last updated: $formattedDate'
          : 'সর্বশেষ আপডেট: $formattedDate';
    }

    if (widget.isEnglish) {
      _headlines.addAll([
        "Dengue detected in last 24 hours: ${stats['last24Hours']} people",
        "Dengue detected in last 7 days: ${stats['last7Days']} people",
        "Current outbreak risk level: ${stats['riskLevel']}",
        "Prevention tips: Remove standing water weekly",
        if (lastUpdatedText.isNotEmpty) lastUpdatedText,
      ]);
    } else {
      _headlines.addAll([
        "গত ২৪ ঘণ্টায় ডেঙ্গু শনাক্ত: ${stats['last24Hours']} জন",
        "গত ৭ দিনে ডেঙ্গু শনাক্ত: ${stats['last7Days']} জন",
        "বর্তমান প্রাদুর্ভাব ঝুঁকির স্তর: ${_getRiskLevelInBangla(
            stats['riskLevel'])}",
        "প্রতিরোধ টিপস: সপ্তাহে একবার জমে থাকা পানি পরিষ্কার করুন",
        if (lastUpdatedText.isNotEmpty) lastUpdatedText,
      ]);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    _startAutoScroll();
  }

  String _getRiskLevelInBangla(String englishRiskLevel) {
    switch (englishRiskLevel) {
      case 'Low':
        return 'কম';
      case 'Moderate':
        return 'মাঝারি';
      case 'High':
        return 'উচ্চ';
      case 'Severe':
        return 'গুরুতর';
      default:
        return 'মাঝারি';
    }
  }

  void _initializeDefaultHeadlines() {
    _headlines.clear();
    if (widget.isEnglish) {
      _headlines.addAll([
        "Dengue detected in last 24 hours: 15 people",
        "Dengue detected in last 7 days: 85 people",
        "Current outbreak risk level: Moderate",
        "Prevention tips: Remove standing water weekly"
      ]);
    } else {
      _headlines.addAll([
        "গত ২৪ ঘণ্টায় ডেঙ্গু শনাক্ত: ১৫ জন",
        "গত ৭ দিনে ডেঙ্গু শনাক্ত: ৮৫ জন",
        "বর্তমান প্রাদুর্ভাব ঝুঁকির স্তর: মাঝারি",
        "প্রতিরোধ টিপস: সপ্তাহে একবার জমে থাকা পানি সরান"
      ]);
    }
  }

  @override
  void didUpdateWidget(ScrollingHeadline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnglish != widget.isEnglish) {
      _setupStatsListener();
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isScrolling && _controller.hasClients) {
        final maxScroll = _controller.position.maxScrollExtent;
        final currentScroll = _controller.position.pixels;

        if (currentScroll >= maxScroll - 50) {
          _controller.jumpTo(0);
        } else {
          _controller.animateTo(
            currentScroll + 100,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
          );
        }
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _isScrolling = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _headlines.length * 3,
        itemBuilder: (context, index) {
          final headline = _headlines[index % _headlines.length];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              minHeight: 40, // Ensure consistent height
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 18
                ),
                const SizedBox(width: 8),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    headline,
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 14, // Fixed font size
                      height: 1.0, // Consistent line height
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

//ad showcase here
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  Future<String?> fetchAdImageUrl() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ad_img')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty && snapshot.docs.first.data().containsKey('img_url')) {
        return snapshot.docs.first['img_url'];
      }
    } catch (e) {
      debugPrint('Error fetching ad image: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchAdImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox(); // No ad to show
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Failed to load ad");
            },
          ),
        );
      },
    );
  }
}

class _DengueHomePageState extends State<DengueHomePage> {
  int _selectedIndex = 0;
  Future<String> fetchRiskLevel() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('affected')
          .doc('stats')
          .get();

      if (doc.exists && doc.data()!.containsKey('riskLevel')) {
        final riskLevel = doc['riskLevel'] as String;

        // risk types
        if (!Provider.of<LanguageService>(context, listen: false).isEnglish) {
          switch (riskLevel.toLowerCase()) {
            case 'high':
              return ' উচ্চ';
            case 'moderate':
              return ' মাঝারি';
            case 'low':
              return ' কম';
            default:
              return 'মাঝারি';
          }
        }

        return riskLevel;
      } else {
        return 'Error';
      }
    } catch (e) {
      return 'Error';
    }
  }


  // English translations
  final Map<String, String> _englishTexts = {
    'title': 'Denguard',
    'risk': 'Current Dengue Risk',
    'nearbyHospitals': 'Hospitals near me',
    'hospitalLocator': 'Hospital Locator',
    'quickActions': 'Quick Actions',
    'reportCase': 'Local Risk Report',
    'symptomsCheck': 'Symptoms Check',
    'hotspotMap': 'Dengue Hotspot Regions',
    'hotspotDivision': 'Dengue Hotspot Prediction',
    'preventionTips': 'Prevention Tips',
    'nearbyHospitals': 'Dengue info',
    'ChikungunyaPage': 'Chikungunya info',
    'tip1Title': 'Remove standing water',
    'tip1Desc': 'Empty containers that can hold water to prevent mosquito breeding',
    'tip2Title': 'Use mosquito repellent',
    'tip2Desc': 'Apply EPA-approved repellent when outdoors',
    'tip3Title': 'Wear protective clothing',
    'tip3Desc': 'Long sleeves and pants can help prevent bites',
    'home': 'Home',
    'ICU':'ICU Finder',
    'bloodDonors': 'Blood Donors',
    'emergency': 'Emergency',
    'forecast2025': 'Forecast ',
    'forecastDesc': 'Considering current climatic patterns and historical data:',
    'highRiskPeriod': 'High-Risk Period',
    'highRiskDesc': 'The months of July through October are projected to be high-risk for dengue transmission.',
    'climaticConditions': 'Climatic Conditions',
    'climaticDesc': 'Forecasts indicate continued high temperatures and humidity levels during these months, conducive to mosquito breeding.',
    'urbanVulnerability': 'Urban Vulnerability',
    'urbanDesc': 'Areas with high population density and inadequate sanitation, particularly in urban centers, remain especially vulnerable.',
  };

  // Bangla translations
  final Map<String, String> _banglaTexts = {
    'title': 'ডেনগার্ড',
    'risk': 'বর্তমান ডেঙ্গু ঝুঁকি',
    'riskLevel': 'আপনার এলাকায় মাঝারি',
    'quickActions': 'দ্রুত পদক্ষেপ',
    'reportCase': 'কেস রিপোর্ট করুন',
    'symptomsCheck': 'লক্ষণ পরীক্ষা',
    'hotspotMap': 'ডেঙ্গু হটস্পট ম্যাপ',
    'hotspotDivision': 'ডেঙ্গু হটস্পট অনুমান',
    'preventionTips': 'প্রতিরোধ টিপস',
    'nearbyHospitals': 'ডেঙ্গু তথ্য',
    'tip1Title': 'জমে থাকা পানি সরান',
    'tip1Desc': 'মশার প্রজনন রোধ করতে পানি ধরে রাখতে পারে এমন পাত্র খালি করুন',
    'tip2Title': 'মশা নিবারক ব্যবহার করুন',
    'tip2Desc': 'বাইরে থাকার সময় EPA-অনুমোদিত রিপেলেন্ট প্রয়োগ করুন',
    'tip3Title': 'সুরক্ষামূলক পোশাক পরুন',
    'tip3Desc': 'লম্বা হাতা এবং প্যান্ট কামড় প্রতিরোধে সাহায্য করতে পারে',
    'home': 'হোম',

    'ICU':'আইসিইউ খুঁজুন',
    'ChikungunyaPage': 'চিকুনগুনিয়া তথ্য',
    'hospitalLocator': 'হাসপাতাল লোকেটর',
    'bloodDonors': 'রক্তদাতা',
    'emergency': 'জরুরী',
    'forecast2025': 'পূর্বাভাস',
    'forecastDesc': 'বর্তমান জলবায়ু প্রবণতা এবং ঐতিহাসিক তথ্য বিবেচনা করে:',
    'highRiskPeriod': 'উচ্চ ঝুঁকির সময়',
    'highRiskDesc': 'জুলাই থেকে অক্টোবর মাসগুলি ডেঙ্গু সংক্রমণের জন্য উচ্চ ঝুঁকিপূর্ণ হবে বলে অনুমান করা হচ্ছে।',
    'climaticConditions': 'জলবায়ু পরিস্থিতি',
    'climaticDesc': 'পূর্বাভাস অনুযায়ী এই মাসগুলিতে উচ্চ তাপমাত্রা এবং আর্দ্রতার মাত্রা অব্যাহত থাকবে, যা মশার প্রজননের জন্য অনুকূল।',
    'urbanVulnerability': 'শহুরে দুর্বলতা',
    'urbanDesc': 'বিশেষ করে শহুরে কেন্দ্রগুলিতে জনবহুল এলাকা এবং অপর্যাপ্ত স্যানিটেশন সুবিধা রয়েছে এমন এলাকাগুলি বিশেষভাবে ঝুঁকিপূর্ণ।',
  };


  String _getText(String key) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    if (languageService.isEnglish) {
      return _englishTexts[key] ?? 'Text not found';
    } else {
      return _banglaTexts[key] ?? 'টেক্সট পাওয়া যায়নি';
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodDonorsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EmergencyNumbersPage()),
      );
    }
  }

  void _navigateToAdminPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: GestureDetector(
          onLongPress: _navigateToAdminPage,
          child: Text(
            _getText('title'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Text(
              languageService.isEnglish ? 'বাংলা' : 'ENG',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
              languageService.toggleLanguage();
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getText('risk'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        FutureBuilder<String>(
                          future: fetchRiskLevel(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            } else if (snapshot.hasError || snapshot.data == 'Error') {
                              return Text(
                                languageService.isEnglish ? 'Failed to load' : 'লোড করা যায়নি',
                                style: TextStyle(color: Colors.red[400]),
                              );
                            } else {
                              return Text(
                                snapshot.data ?? (languageService.isEnglish ? 'No data' : 'কোন তথ্য নেই'),
                                style: TextStyle(color: Colors.grey[700]),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //homepage boxes here
              const SizedBox(height: 10),

              ScrollingHeadline(
                isEnglish: languageService.isEnglish,
              ),

              const SizedBox(height: 10),
              const SizedBox(height: 20),

              Text(
                _getText('quickActions'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [



                  _buildActionButton(
                    icon: Icons.map,
                    label: _getText('hotspotMap'),
                    color: Colors.green[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HotspotPage()),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.question_answer,
                    label: languageService.isEnglish ? 'Ask DengChatBot' : 'DengAI',
                    color: Colors.teal[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.local_hospital,
                    label: _getText('nearbyHospitals'),
                    color: Colors.green[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ICUDirectoryPage()),
                      );
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.local_hospital,
                    label: _getText('hospitalLocator'),
                    color: Colors.red[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EasyHospitalMap(title: _getText('hospitalLocator')),
                        ),
                      );
                    },
                  ),


                  _buildActionButton(
                    icon: Icons.report,
                    label: _getText('reportCase'),
                    color: Colors.red[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LocalRiskPage()),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.clean_hands,
                    label: _getText('preventionTips'),
                    color: Colors.purple[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PreventionTipsPage()),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.medical_services,
                    label: _getText('symptomsCheck'),
                    color: Colors.blue[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SymptomCheckerPage()),
                      );
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.map,
                    label: _getText('hotspotDivision'),
                    color: Colors.red[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  HotspotDivisionPage()),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.king_bed,
                    label: _getText('ICU'),
                    color: Colors.red[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  ICUFinderPage()),
                      );
                    },
                  ),

                  _buildActionButton(
                    icon: Icons.local_hospital,
                    label: _getText('ChikungunyaPage'),
                    color: Colors.red[400],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  ChikungunyaPage()),
                      );
                    },
                  ),







                ],
              ),


              const SizedBox(height: 20),

              //forecast section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.blue[600], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          _getText('forecast2025'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getText('forecastDesc'),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildForecastItem(
                      _getText('highRiskPeriod'),
                      _getText('highRiskDesc'),
                      Icons.dangerous,
                      Colors.red[400]!,
                    ),
                    const SizedBox(height: 8),
                    _buildForecastItem(
                      _getText('climaticConditions'),
                      _getText('climaticDesc'),
                      Icons.wb_sunny,
                      Colors.orange[400]!,
                    ),
                    const SizedBox(height: 8),
                    _buildForecastItem(
                      _getText('urbanVulnerability'),
                      _getText('urbanDesc'),
                      Icons.location_city,
                      Colors.purple[400]!,
                    ),


                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _getText('preventionTips'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              _buildTipCard(
                _getText('tip1Title'),
                _getText('tip1Desc'),
                Icons.water_drop,
              ),
              _buildTipCard(
                _getText('tip2Title'),
                _getText('tip2Desc'),
                Icons.spa,
              ),
              _buildTipCard(
                _getText('tip3Title'),
                _getText('tip3Desc'),
                Icons.checkroom,

              ),



              const SizedBox(height: 20),
              const AdBanner(),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _getText('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bloodtype),
            label: _getText('bloodDonors'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emergency),
            label: _getText('emergency'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastItem(String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //tips
  Widget _buildTipCard(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.red[300]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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
}