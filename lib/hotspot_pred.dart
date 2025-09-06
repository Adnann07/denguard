import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'language_service.dart';

class HotspotDivisionPage extends StatefulWidget {
  const HotspotDivisionPage({super.key});

  @override
  State<HotspotDivisionPage> createState() => _HotspotDivisionPageState();
}

class _HotspotDivisionPageState extends State<HotspotDivisionPage> {
  String? imageUrl;
  bool isLoading = true;
  String? errorMessage;
  DateTime? lastUpdated;

  // District risks data
  List<Map<String, dynamic>> districtRisks = [];
  bool isLoadingDistricts = true;
  String? districtErrorMessage;

  // Comprehensive translations
  Map<String, Map<String, String>> get _translations => {
    'hotspot_title': {
      'en': 'Dengue Hotspot Prediction',
      'bn': 'ডেঙ্গু হটস্পট পূর্বাভাস'
    },
    'hotspot_subtitle': {
      'en': 'Machine learning powered dengue hotspot prediction for your area',
      'bn': 'মেশিন লার্নিং দ্বারা আপনার এলাকার ডেঙ্গু হটস্পট পূর্বাভাস'
    },
    'disclaimer_title': {
      'en': 'Important Notice',
      'bn': 'গুরুত্বপূর্ণ বিজ্ঞপ্তি'
    },
    'disclaimer': {
      'en': 'This prediction is based on historical data, weather patterns, and environmental factors. It is designed for preventive measures and is not a guarantee. Always consult healthcare professionals for medical advice.',
      'bn': 'এই পূর্বাভাস ঐতিহাসিক তথ্য, আবহাওয়ার ধরন এবং পরিবেশগত কারণগুলির উপর ভিত্তি করে তৈরি। এটি প্রতিরোধমূলক ব্যবস্থার জন্য ডিজাইন করা হয়েছে এবং এটি কোনো গ্যারান্টি নয়। চিকিৎসা পরামর্শের জন্য সর্বদা স্বাস্থ্যসেবা পেশাদারদের সাথে পরামর্শ করুন।'
    },
    'district_risks_title': {
      'en': 'District-wise Risk Levels',
      'bn': 'জেলা ভিত্তিক ঝুঁকির মাত্রা'
    },
    'district_risks_subtitle': {
      'en': 'Current dengue risk assessment for each district',
      'bn': 'প্রতিটি জেলার বর্তমান ডেঙ্গু ঝুঁকি মূল্যায়ন'
    },
    'loading_districts': {
      'en': 'Loading district data...',
      'bn': 'জেলার তথ্য লোড হচ্ছে...'
    },
    'no_district_data': {
      'en': 'No district data available',
      'bn': 'কোনো জেলার তথ্য পাওয়া যায়নি'
    },
    'district_error': {
      'en': 'Failed to load district data',
      'bn': 'জেলার তথ্য লোড করতে ব্যর্থ'
    },
    'how_to_read_title': {
      'en': 'How to Read the Map',
      'bn': 'মানচিত্র কীভাবে পড়বেন'
    },
    'how_to_read_subtitle': {
      'en': 'Understanding hotspot predictions',
      'bn': 'হটস্পট পূর্বাভাস বোঝা'
    },
    'prediction_scale_title': {
      'en': 'Prediction Scale',
      'bn': 'পূর্বাভাসের স্কেল'
    },
    'no_risk_title': {
      'en': 'No Risk (0)',
      'bn': 'ঝুঁকি নেই (০)'
    },
    'no_risk_desc': {
      'en': 'Areas with low probability of dengue outbreak based on current environmental conditions',
      'bn': 'বর্তমান পরিবেশগত অবস্থার ভিত্তিতে ডেঙ্গু প্রাদুর্ভাবের সম্ভাবনা কম এমন এলাকা'
    },
    'high_risk_title': {
      'en': 'Possible Hotspot (1)',
      'bn': 'সম্ভাব্য হটস্পট (১)'
    },
    'high_risk_desc': {
      'en': 'Areas with higher probability of dengue transmission. Take extra precautions in these regions',
      'bn': 'ডেঙ্গু সংক্রমণের উচ্চ সম্ভাবনা রয়েছে এমন এলাকা। এই অঞ্চলে অতিরিক্ত সতর্কতা অবলম্বন করুন'
    },
    'factors_title': {
      'en': 'Prediction Factors',
      'bn': 'পূর্বাভাসের কারণসমূহ'
    },
    'factors_subtitle': {
      'en': 'Our machine learning model considers these key factors',
      'bn': 'আমাদের মেশিন লার্নিং মডেল এই মূল কারণগুলি বিবেচনা করে'
    },
    'weather_factor': {
      'en': 'Weather Patterns',
      'bn': 'আবহাওয়ার ধরন'
    },
    'weather_desc': {
      'en': 'Temperature, humidity, and rainfall data',
      'bn': 'তাপমাত্রা, আর্দ্রতা এবং বৃষ্টিপাতের তথ্য'
    },
    'population_factor': {
      'en': 'Population Density',
      'bn': 'জনসংখ্যার ঘনত্ব'
    },
    'population_desc': {
      'en': 'Higher density increases transmission risk',
      'bn': 'উচ্চ ঘনত্ব সংক্রমণের ঝুঁকি বাড়ায়'
    },
    'historical_factor': {
      'en': 'Historical Cases',
      'bn': 'ঐতিহাসিক ঘটনা'
    },
    'historical_desc': {
      'en': 'Previous dengue outbreak patterns',
      'bn': 'পূর্ববর্তী ডেঙ্গু প্রাদুর্ভাবের ধরন'
    },
    'environment_factor': {
      'en': 'Environmental Conditions',
      'bn': 'পরিবেশগত অবস্থা'
    },
    'environment_desc': {
      'en': 'Water stagnation and breeding sites',
      'bn': 'পানি জমা এবং প্রজনন স্থান'
    },
    'prevention_title': {
      'en': 'Prevention Tips',
      'bn': 'প্রতিরোধের উপায়'
    },
    'prevention_subtitle': {
      'en': 'Protect yourself and your community',
      'bn': 'নিজেকে এবং আপনার সম্প্রদায়কে রক্ষা করুন'
    },
    'prevention_1': {
      'en': 'Remove standing water from containers',
      'bn': 'পাত্র থেকে জমে থাকা পানি সরান'
    },
    'prevention_2': {
      'en': 'Use mosquito repellent regularly',
      'bn': 'নিয়মিত মশার প্রতিরোধক ব্যবহার করুন'
    },
    'prevention_3': {
      'en': 'Keep surroundings clean and dry',
      'bn': 'আশেপাশের পরিবেশ পরিচ্ছন্ন ও শুকনো রাখুন'
    },
    'prevention_4': {
      'en': 'Seek medical help for fever symptoms',
      'bn': 'জ্বরের লক্ষণে চিকিৎসা সহায়তা নিন'
    },
    'hotspot_map_title': {
      'en': 'Current Hotspot Prediction Map',
      'bn': 'বর্তমান হটস্পট পূর্বাভাস মানচিত্র'
    },
    'last_updated': {
      'en': 'Last Updated',
      'bn': 'সর্বশেষ আপডেট'
    },
    'loading_map': {
      'en': 'Loading prediction map...',
      'bn': 'পূর্বাভাস মানচিত্র লোড হচ্ছে...'
    },
    'map_error': {
      'en': 'Failed to load prediction map',
      'bn': 'পূর্বাভাস মানচিত্র লোড করতে ব্যর্থ'
    },
    'retry': {
      'en': 'Retry',
      'bn': 'পুনরায় চেষ্টা করুন'
    },
    'tap_to_zoom': {
      'en': 'Tap to zoom and explore',
      'bn': 'জুম করতে এবং অন্বেষণ করতে ট্যাপ করুন'
    },
    // Risk level translations
    'low_risk': {
      'en': 'Low Risk',
      'bn': 'কম ঝুঁকি'
    },
    'medium_risk': {
      'en': 'Medium Risk',
      'bn': 'মধ্যম ঝুঁকি'
    },
    'high_risk': {
      'en': 'High Risk',
      'bn': 'উচ্চ ঝুঁকি'
    },
    'very_high_risk': {
      'en': 'Very High Risk',
      'bn': 'অত্যন্ত উচ্চ ঝুঁকি'
    },
  };

  @override
  void initState() {
    super.initState();
    fetchHotspotMapUrl();
    fetchDistrictRisks();
  }

  String _getText(BuildContext context, String key) {
    final isEnglish = Provider.of<LanguageService>(context).isEnglish;
    return _translations[key]?[isEnglish ? 'en' : 'bn'] ?? key;
  }

  String convertGoogleDriveUrl(String driveUrl) {
    final fileIdRegex = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
    final match = fileIdRegex.firstMatch(driveUrl);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return driveUrl;
  }

  Future<void> fetchHotspotMapUrl() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('hotspot_map')
          .doc('current_map')
          .get();

      if (doc.exists && doc.data() != null) {
        String rawUrl = doc.data()!['image_url'];
        String processedUrl = convertGoogleDriveUrl(rawUrl);

        setState(() {
          imageUrl = processedUrl;
          lastUpdated = doc.data()!['updated_at']?.toDate();
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No map data found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> fetchDistrictRisks() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('district_risks')
          .get();

      List<Map<String, dynamic>> risks = [];
      for (var doc in querySnapshot.docs) {
        risks.add({
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unknown',
          'risk_level': doc.data()['risk_level'] ?? 'Unknown',
        });
      }

      setState(() {
        districtRisks = risks;
        isLoadingDistricts = false;
        districtErrorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoadingDistricts = false;
        districtErrorMessage = e.toString();
      });
    }
  }

  Color _getRiskColor(String riskLevel) {
    String normalizedRisk = riskLevel.toLowerCase();
    if (normalizedRisk.contains('low') || normalizedRisk.contains('কম')) {
      return Colors.green;
    } else if (normalizedRisk.contains('medium') || normalizedRisk.contains('মধ্যম')) {
      return Colors.orange;
    } else if (normalizedRisk.contains('high') || normalizedRisk.contains('উচ্চ')) {
      return Colors.red;
    } else if (normalizedRisk.contains('very') || normalizedRisk.contains('অত্যন্ত')) {
      return Colors.red.shade900;
    }
    return Colors.grey;
  }

  IconData _getRiskIcon(String riskLevel) {
    String normalizedRisk = riskLevel.toLowerCase();
    if (normalizedRisk.contains('low') || normalizedRisk.contains('কম')) {
      return Icons.check_circle;
    } else if (normalizedRisk.contains('medium') || normalizedRisk.contains('মধ্যম')) {
      return Icons.warning;
    } else if (normalizedRisk.contains('high') || normalizedRisk.contains('উচ্চ')) {
      return Icons.error;
    } else if (normalizedRisk.contains('very') || normalizedRisk.contains('অত্যন্ত')) {
      return Icons.dangerous;
    }
    return Icons.help;
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getText(context, 'hotspot_title')),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // English Button
                TextButton(
                  onPressed: () {
                    if (!languageService.isEnglish) {
                      languageService.toggleLanguage();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: languageService.isEnglish ? Colors.white : Colors.white.withOpacity(0.6),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('ENG'),
                ),
                const Text('|', style: TextStyle(color: Colors.white54)),
                // Bangla Button
                TextButton(
                  onPressed: () {
                    if (languageService.isEnglish) {
                      languageService.toggleLanguage();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: !languageService.isEnglish ? Colors.white : Colors.white.withOpacity(0.6),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('বাংলা'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(context),
            const SizedBox(height: 20),

            // Disclaimer Section
            _buildDisclaimerSection(context),
            const SizedBox(height: 20),

            // District Risks Section
            _buildDistrictRisksSection(context),
            const SizedBox(height: 20),

            // How to Read Section
            _buildHowToReadSection(context),
            const SizedBox(height: 20),

            // Hotspot Map Section
            _buildMapSection(context),
            const SizedBox(height: 20),

            // Prevention Tips Section
            _buildPreventionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 56, color: Colors.red.shade700),
          const SizedBox(height: 16),
          Text(
            _getText(context, 'hotspot_subtitle'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.red.shade800,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                _getText(context, 'disclaimer_title'),
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getText(context, 'disclaimer'),
            style: TextStyle(
              color: Colors.amber.shade800,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictRisksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.indigo.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                _getText(context, 'district_risks_title'),
                style: TextStyle(
                  color: Colors.indigo.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getText(context, 'district_risks_subtitle'),
            style: TextStyle(
              color: Colors.indigo.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          if (isLoadingDistricts)
            Container(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.indigo.shade600),
                    const SizedBox(height: 12),
                    Text(
                      _getText(context, 'loading_districts'),
                      style: TextStyle(color: Colors.indigo.shade600),
                    ),
                  ],
                ),
              ),
            )
          else if (districtErrorMessage != null)
            Container(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 32, color: Colors.red.shade400),
                    const SizedBox(height: 8),
                    Text(
                      _getText(context, 'district_error'),
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoadingDistricts = true;
                          districtErrorMessage = null;
                        });
                        fetchDistrictRisks();
                      },
                      child: Text(_getText(context, 'retry')),
                    ),
                  ],
                ),
              ),
            )
          else if (districtRisks.isEmpty)
              Container(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        _getText(context, 'no_district_data'),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: districtRisks.map((district) {
                  Color riskColor = _getRiskColor(district['risk_level']);
                  IconData riskIcon = _getRiskIcon(district['risk_level']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: riskColor.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            riskIcon,
                            color: riskColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                district['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                district['risk_level'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: riskColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            district['risk_level'].contains('উচ্চ') ? 'HIGH' :
                            district['risk_level'].contains('মধ্যম') ? 'MED' :
                            district['risk_level'].contains('কম') ? 'LOW' : 'RISK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildHowToReadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, color: Colors.purple.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                _getText(context, 'how_to_read_title'),
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getText(context, 'how_to_read_subtitle'),
            style: TextStyle(
              color: Colors.purple.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getText(context, 'prediction_scale_title'),
            style: TextStyle(
              color: Colors.purple.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Risk Level Indicators
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText(context, 'no_risk_title'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      _getText(context, 'no_risk_desc'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText(context, 'high_risk_title'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade800,
                      ),
                    ),
                    Text(
                      _getText(context, 'high_risk_desc'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getText(context, 'hotspot_map_title'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              '${_getText(context, 'last_updated')}: ${lastUpdated!.day}/${lastUpdated!.month}/${lastUpdated!.year}',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16),

          if (isLoading)
            Container(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue.shade600),
                    const SizedBox(height: 16),
                    Text(
                      _getText(context, 'loading_map'),
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            )
          else if (errorMessage != null)
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(
                      _getText(context, 'map_error'),
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        fetchHotspotMapUrl();
                      },
                      child: Text(_getText(context, 'retry')),
                    ),
                  ],
                ),
              ),
            )
          else if (imageUrl != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () => _showFullScreenMap(context),
                      child: Image.network(
                        imageUrl!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 300,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  _getText(context, 'map_error'),
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getText(context, 'tap_to_zoom'),
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildPreventionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                _getText(context, 'prevention_title'),
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getText(context, 'prevention_subtitle'),
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Prevention Tips
          _buildPreventionTip(context, Icons.water_drop, 'prevention_1'),
          const SizedBox(height: 12),
          _buildPreventionTip(context, Icons.bug_report, 'prevention_2'),
          const SizedBox(height: 12),
          _buildPreventionTip(context, Icons.cleaning_services, 'prevention_3'),
          const SizedBox(height: 12),
          _buildPreventionTip(context, Icons.medical_services, 'prevention_4'),
        ],
      ),
    );
  }

  Widget _buildPreventionTip(BuildContext context, IconData icon, String textKey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _getText(context, textKey),
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(_getText(context, 'hotspot_map_title')),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5.0,
            child: Center(
              child: Image.network(imageUrl!),
            ),
          ),
        ),
      ),
    );
  }
}