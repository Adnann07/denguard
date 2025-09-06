import 'package:flutter/material.dart';

class ChikungunyaPage extends StatefulWidget {
  const ChikungunyaPage({super.key});

  @override
  State<ChikungunyaPage> createState() => _ChikungunyaPageState();
}

class _ChikungunyaPageState extends State<ChikungunyaPage> {
  bool _showSymptomChecker = false;

  // Symptom checker points
  final Map<String, bool> _symptoms = {
    'উচ্চ জ্বর': false,
    'জয়েন্টে তীব্র ব্যথা': false,
    'মাংসপেশীতে ব্যথা': false,
    'ত্বকে র‍্যাশ': false,
    'চোখে ব্যথা বা লালচে ভাব': false,
    'মাথাব্যথা': false,
    'অত্যন্ত ক্লান্তি': false,
  };
  String _result = '';

  void _checkSymptoms() {
    int count = _symptoms.values.where((e) => e).length;
    setState(() {
      if (count >= 4) {
        _result = 'আপনার উপসর্গগুলোর বেশিরভাগই চিকুনগুনিয়ার সাথে মিলে যায়। দ্রুত ডাক্তারের পরামর্শ নিন।';
      } else if (count >= 2) {
        _result = 'আপনার কিছু উপসর্গ রয়েছে। সতর্ক থাকুন এবং প্রয়োজনে পরীক্ষা করুন।';
      } else {
        _result = 'আপনার উপসর্গগুলি গুরুতর নয়। তবুও সতর্কতা অবলম্বন করুন।';
      }
    });
  }

  void _toggleSymptomChecker() {
    setState(() {
      _showSymptomChecker = !_showSymptomChecker;
      if (!_showSymptomChecker) {
        // Reset symptom checker
        _symptoms.updateAll((key, value) => false);
        _result = '';
      }
    });
  }

  //symptom checker functionalities
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _showSymptomChecker
              ? 'চিকুনগুনিয়া লক্ষণ চেকার (Symptom Checker)'
              : 'চিকুনগুনিয়া সম্পর্কিত তথ্য (Chikungunya Info)',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        leading: _showSymptomChecker
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _toggleSymptomChecker,
        )
            : null,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _showSymptomChecker ? _buildSymptomChecker() : _buildMainContent(),
    );
  }
//page main content
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.bug_report,
            title: 'চিকুনগুনিয়া কী? (What is Chikungunya?)',
            content:
            'চিকুনগুনিয়া একটি ভাইরাসজনিত রোগ যা Aedes মশার কামড়ের মাধ্যমে ছড়ায়। '
                'এই ভাইরাসটি প্রথম 1952 সালে তাঞ্জানিয়ায় সনাক্ত হয়। এটি ডেঙ্গুর মতোই একই মশার মাধ্যমে ছড়ায় এবং বেশ তীব্র ব্যথার সৃষ্টি করে।',
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.transgender,
            title: 'সংক্রমণ কীভাবে ঘটে (How it Spreads)',
            content:
            'চিকুনগুনিয়া Aedes aegypti এবং Aedes albopictus মশার মাধ্যমে ছড়ায়। '
                'একজন আক্রান্ত ব্যক্তিকে মশা কামড়ালে ভাইরাসটি মশার শরীরে প্রবেশ করে এবং পরে সেই মশা অন্য কাউকে কামড়ালে ভাইরাসটি ছড়ায়।',
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.sick,
            title: 'লক্ষণসমূহ (Symptoms)',
            content:
            'চিকুনগুনিয়ার লক্ষণ সাধারণত ভাইরাসে সংক্রমিত হওয়ার ৪-৮ দিনের মধ্যে দেখা যায়:',
            color: const Color(0xFF10B981),
            children: _buildBulletList([
              'উচ্চ জ্বর (102°F বা এর বেশি)',
              'তীব্র জয়েন্টে ব্যথা',
              'মাংসপেশীতে ব্যথা',
              'মাথাব্যথা এবং ক্লান্তি',
              'ত্বকে র‍্যাশ দেখা দিতে পারে',
            ]),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.healing,
            title: 'চিকিৎসা ও সেবা (Treatment & Care)',
            content:
            'চিকুনগুনিয়ার কোনও নির্দিষ্ট ওষুধ নেই। উপসর্গ উপশমই মূল চিকিৎসা। নিচের পদ্ধতিগুলো অনুসরণ করা যেতে পারে:',
            color: const Color(0xFF2563EB),
            children: _buildBulletList([
              'প্রচুর পানি ও তরল খাবার গ্রহণ করুন',
              'জ্বর ও ব্যথা উপশমে প্যারাসিটামল গ্রহণ করুন (ডাক্তারের পরামর্শে)',
              'বিশ্রাম নিন ও শারীরিক চাপ এড়িয়ে চলুন',
            ]),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.shield_moon,
            title: 'প্রতিরোধ (Prevention)',
            content:
            'Aedes মশার কামড় থেকে রক্ষা পাওয়া এবং মশার প্রজননস্থল ধ্বংস করাই প্রতিরোধের মূল উপায়। যেমন:',
            color: const Color(0xFF9333EA),
            children: _buildBulletList([
              'মশারি ব্যবহার করা',
              'মশার স্প্রে বা ক্রিম ব্যবহার',
              'পরিষ্কার পানি জমতে না দেওয়া',
            ]),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.science,
            title: 'নির্ণয় (Diagnosis)',
            content:
            'রক্ত পরীক্ষার মাধ্যমে চিকুনগুনিয়া নির্ণয় করা হয়, যাতে ভাইরাসের অ্যান্টিবডি বা আরএনএ সনাক্ত করা যায়।',
            color: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.family_restroom,
            title: 'ঝুঁকিপূর্ণ গ্রুপ (Vulnerable Groups)',
            content:
            'শিশু, বৃদ্ধ, গর্ভবতী মহিলা এবং যাদের আগে থেকেই জয়েন্টে সমস্যা রয়েছে তাদের বিশেষ সতর্কতা অবলম্বন করা উচিত।',
            color: const Color(0xFFEC4899),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.public,
            title: 'বিশ্ব পরিস্থিতি (Global Situation)',
            content:
            'চিকুনগুনিয়া বর্তমানে আফ্রিকা, এশিয়া, ইউরোপ এবং আমেরিকার বিভিন্ন অঞ্চলে বিস্তার লাভ করেছে। জলবায়ু পরিবর্তনের ফলে Aedes মশার বিস্তার বেড়েছে।',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEA580C), width: 2),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Color(0xFFEA580C),
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'সতর্কতা (Be Cautious)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9A3412),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'যদি জ্বর দীর্ঘস্থায়ী হয় বা জয়েন্টের ব্যথা তীব্র হয়, দ্রুত চিকিৎসকের পরামর্শ নিন। শিশু ও বয়স্কদের ক্ষেত্রে বাড়তি নজর দিন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C2D12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('লক্ষণ চেক করুন (Check Symptoms)',
                  style: TextStyle(color: Colors.white)),
              onPressed: _toggleSymptomChecker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChecker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[200]!, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: Colors.red[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'লক্ষণ পরীক্ষা করুন',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'আপনার যেসব উপসর্গ আছে সেগুলো নির্বাচন করুন:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F1D1D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._symptoms.keys.map((symptom) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CheckboxListTile(
                title: Text(
                  symptom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _symptoms[symptom],
                onChanged: (val) {
                  setState(() {
                    _symptoms[symptom] = val ?? false;
                  });
                },
                activeColor: Colors.red[600],
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _checkSymptoms,
              icon: const Icon(Icons.analytics, color: Colors.white),
              label: const Text('ফলাফল দেখুন',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
          if (_result.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!, width: 1),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    color: Colors.orange[700],
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ফলাফল:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFFC2410C),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(height: 8),
                const Text(
                  'গুরুত্বপূর্ণ তথ্য:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'এই পরীক্ষা শুধুমাত্র প্রাথমিক ধারণার জন্য। সঠিক নির্ণয়ের জন্য অবশ্যই ডাক্তারের পরামর্শ নিন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    List<Widget>? children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.isNotEmpty)
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF374151),
                    ),
                  ),
                if (children != null) ...[
                  const SizedBox(height: 12),
                  ...children,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBulletList(List<String> items) {
    return items
        .map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style:
              TextStyle(fontSize: 18, color: Color(0xFFEA580C))),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    ))
        .toList();
  }
}