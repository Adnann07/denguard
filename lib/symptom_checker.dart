import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_service.dart';

class SymptomCheckerPage extends StatefulWidget {
  const SymptomCheckerPage({super.key});

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  final Map<String, bool> _selectedSymptoms = {
    'fever': false,
    'headache': false,
    'pain': false,
    'rash': false,
    'nausea': false,
    'bleeding': false,
  };

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isEnglish = languageService.isEnglish;

    final Map<String, Map<String, String>> translations = {
      'title': {'en': 'Dengue Symptom Checker', 'bn': 'ডেঙ্গু লক্ষণ পরীক্ষক'},
      'question': {'en': 'Select your symptoms:', 'bn': 'আপনার লক্ষণগুলি নির্বাচন করুন:'},
      'fever': {'en': 'High fever (104°F/40°C)', 'bn': 'উচ্চ জ্বর (১০৪°F/৪০°C)'},
      'headache': {'en': 'Severe headache', 'bn': 'তীব্র মাথাব্যথা'},
      'pain': {'en': 'Muscle/joint pain', 'bn': 'পেশী/জয়েন্টে ব্যথা'},
      'rash': {'en': 'Skin rash', 'bn': 'ত্বকে ফুসকুড়ি'},
      'nausea': {'en': 'Nausea/vomiting', 'bn': 'বমি বমি ভাব/বমি'},
      'bleeding': {'en': 'Mild bleeding', 'bn': 'হালকা রক্তপাত'},
      'check': {'en': 'Get Health Advice', 'bn': 'স্বাস্থ্য পরামর্শ পান'},
      'adviceTitle': {'en': 'Health Advice', 'bn': 'স্বাস্থ্য পরামর্শ'},
      'noSymptoms': {
        'en': 'No symptoms selected. If you\'re feeling unwell, it\'s always best to consult a healthcare professional.',
        'bn': 'কোনও লক্ষণ নির্বাচিত হয়নি। যদি আপনি অসুস্থ বোধ করেন, সর্বদা একজন স্বাস্থ্যসেবা পেশাদারের সাথে পরামর্শ করা ভাল।'
      },
      'mildSymptoms': {
        'en': 'You have selected some symptoms. While these could be related to various conditions, it\'s important to monitor your health and consider consulting a doctor if symptoms persist or worsen.',
        'bn': 'আপনি কিছু লক্ষণ নির্বাচন করেছেন। যদিও এগুলি বিভিন্ন রোগের সাথে সম্পর্কিত হতে পারে, আপনার স্বাস্থ্য পর্যবেক্ষণ করা এবং লক্ষণগুলি অব্যাহত থাকলে বা আরও খারাপ হলে একজন ডাক্তারের সাথে পরামর্শ করা গুরুত্বপূর্ণ।'
      },
      'severeSymptoms': {
        'en': 'You have selected multiple symptoms that may indicate a serious condition. We strongly recommend consulting a healthcare professional immediately for proper diagnosis and treatment.',
        'bn': 'আপনি একাধিক লক্ষণ নির্বাচন করেছেন যা একটি গুরুতর অবস্থার ইঙ্গিত দিতে পারে। আমরা যথাযথ নির্ণয় এবং চিকিৎসার জন্য অবিলম্বে একজন স্বাস্থ্যসেবা পেশাদারের সাথে পরামর্শ করার জন্য দৃঢ়ভাবে সুপারিশ করি।'
      },
      'disclaimer': {
        'en': '⚠️ Important: This is not a medical diagnosis tool. Only a qualified healthcare professional can properly diagnose medical conditions.',
        'bn': '⚠️ গুরুত্বপূর্ণ: এটি একটি চিকিৎসা নির্ণয়ের সরঞ্জাম নয়। শুধুমাত্র একজন যোগ্য স্বাস্থ্যসেবা পেশাদার চিকিৎসা অবস্থা সঠিকভাবে নির্ণয় করতে পারেন।'
      },
      'emergencyNote': {
        'en': 'If you have severe fever, persistent vomiting, or bleeding, seek immediate medical attention.',
        'bn': 'যদি আপনার তীব্র জ্বর, ক্রমাগত বমি, বা রক্তপাত হয়, অবিলম্বে চিকিৎসা সেবা নিন।'
      },
      'understand': {'en': 'I Understand', 'bn': 'আমি বুঝেছি'},
    };

    String tr(String key) => translations[key]?[isEnglish ? 'en' : 'bn'] ?? key;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('title')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Text(isEnglish ? 'বাংলা' : 'ENG',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: languageService.toggleLanguage,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.red.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr('question'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Symptom Cards
              ..._selectedSymptoms.keys.map((symptomKey) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedSymptoms[symptomKey] = !_selectedSymptoms[symptomKey]!;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _selectedSymptoms[symptomKey]!
                                  ? Colors.red.shade100
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedSymptoms[symptomKey]!
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: _selectedSymptoms[symptomKey]!
                                  ? Colors.red.shade800
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              tr(symptomKey),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedSymptoms[symptomKey]!
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedSymptoms[symptomKey]!
                                    ? Colors.red.shade900
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 32),

              // Get Health Advice Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: Colors.red.shade200,
                  ),
                  onPressed: () => _showHealthAdvice(context, tr),
                  child: Text(
                    tr('check'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
//health advise
  void _showHealthAdvice(BuildContext context, String Function(String) tr) {
    final selectedCount = _selectedSymptoms.values.where((selected) => selected).length;

    String adviceMessage;
    Color adviceColor;
    IconData adviceIcon;

    if (selectedCount == 0) {
      adviceMessage = tr('noSymptoms');
      adviceColor = Colors.blue;
      adviceIcon = Icons.info_outline;
    } else if (selectedCount <= 2) {
      adviceMessage = tr('mildSymptoms');
      adviceColor = Colors.orange;
      adviceIcon = Icons.warning_amber;
    } else {
      adviceMessage = tr('severeSymptoms');
      adviceColor = Colors.red;
      adviceIcon = Icons.error_outline;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(adviceIcon, size: 45, color: adviceColor),
                    const SizedBox(height: 12),
                    Text(
                      tr('adviceTitle'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: adviceColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Main advice message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: adviceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: adviceColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        adviceMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Emergency note
                    if (selectedCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          tr('emergencyNote'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Disclaimer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tr('disclaimer'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: adviceColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          tr('understand'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}