import 'package:flutter/material.dart';
//dengue information page
class ICUDirectoryPage extends StatefulWidget {
  const ICUDirectoryPage({super.key});

  @override
  State<ICUDirectoryPage> createState() => _ICUDirectoryPageState();
}
//cards related state
class _ICUDirectoryPageState extends State<ICUDirectoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ডেঙ্গু সম্পর্কিত তথ্য',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_hospital, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ডেঙ্গু জ্বর সম্পর্কে গুরুত্বপূর্ণ তথ্য',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoCard(
              icon: Icons.coronavirus,
              title: 'ডেঙ্গু কীভাবে ছড়ায়',
              content:
              'ডেঙ্গু ভাইরাস প্রধানত Aedes aegypti মশার মাধ্যমে ছড়ায়। '
                  'এই মশা সাধারণত দিনের বেলা, বিশেষ করে সকাল ও সন্ধ্যায় কামড়ায়। '
                  'যখন একটি এডিস মশা ডেঙ্গু আক্রান্ত ব্যক্তিকে কামড়ায়, তখন সে ভাইরাসটি নিজের শরীরে ধারণ করে। '
                  'পরবর্তীতে সেই মশা অন্য সুস্থ ব্যক্তিকে কামড়ালে ভাইরাসটি তার শরীরে প্রবেশ করে এবং ডেঙ্গু জ্বরে আক্রান্ত করে। '
                  'এডিস মশা সাধারণত পরিষ্কার জমে থাকা পানিতে বংশবিস্তার করে, যেমন ফুলের টব, পরিত্যক্ত টায়ার, খোলা ড্রাম ইত্যাদি।',
              color: const Color(0xFF0891B2),
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.medical_services,
              title: 'ডেঙ্গুর লক্ষণ কীভাবে বুঝবেন',
              content:
              'ডেঙ্গুর উপসর্গ সাধারণত ভাইরাস সংক্রমণের ৪ থেকে ১০ দিনের মধ্যে প্রকাশ পায়। সাধারণ লক্ষণগুলো হলো:',
              color: const Color(0xFFEA580C),
              children: _buildBulletList([
                'উচ্চ জ্বর (১০১°F থেকে ১০২°F)',
                'মাথাব্যথা',
                'চোখের পিছনে ব্যথা',
                'মাংসপেশী ও হাড়ে ব্যথা',
                'বমি বা বমি বমি ভাব',
                'চামড়ায় লালচে র‍্যাশ',
                'কিছু ক্ষেত্রে রক্তক্ষরণ (নাক, মাড়ি বা চামড়া দিয়ে)',
              ]),
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.favorite,
              title: 'ডেঙ্গু পরবর্তী করণীয়',
              content:
              'ডেঙ্গু থেকে সুস্থ হওয়ার পর শরীর সম্পূর্ণভাবে পুনরুদ্ধার করতে কিছু সময় লাগে। এই সময়ে নিচের বিষয়গুলো মেনে চলা উচিত:',
              color: const Color(0xFF059669),
              children: _buildBulletList([
                'প্রচুর পানি ও তরল খাবার গ্রহণ করুন।',
                'পুষ্টিকর খাবার খান ও বিশ্রাম নিন।',
                'রক্ত পরীক্ষার রিপোর্ট ফলোআপ করুন।',
                'নিয়মিত চিকিৎসকের পরামর্শ নিন।',
              ]),
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.shield,
              title: 'ডেঙ্গু প্রতিরোধে করণীয়',
              content:
              'ডেঙ্গু প্রতিরোধে সচেতনতা ও সতর্কতা অত্যন্ত গুরুত্বপূর্ণ। '
                  'পরিষ্কার-পরিচ্ছন্নতা বজায় রাখা, মশার প্রজননস্থল ধ্বংস করা এবং মশার কামড় থেকে নিজেকে রক্ষা করার মাধ্যমে ডেঙ্গু সংক্রমণ প্রতিরোধ করা সম্ভব।',
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              icon: Icons.local_hospital_outlined,
              title: 'ডেঙ্গু চিকিৎসার জন্য বিশেষায়িত হাসপাতাল',
              content: '',
              color: const Color(0xFF10B981),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ডিএনসিসি হাসপাতাল, মহাখালী',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'এই ৮০০ শয্যাবিশিষ্ট হাসপাতালটি বিশেষভাবে ডেঙ্গু রোগীদের জন্য নির্ধারিত করা হয়েছে। '
                            'এখানে ডেঙ্গু রোগীরা বিশেষায়িত চিকিৎসাসেবা এবং উন্নত চিকিৎসা পেতে পারবেন।',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE11D48), width: 2),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.emergency,
                    color: Color(0xFFE11D48),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'জরুরি অবস্থায়',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'যদি গুরুতর লক্ষণ দেখা দেয়, তাহলে দেরি না করে দ্রুত চিকিৎসকের পরামর্শ নিন বা নিকটস্থ হাসপাতালে যোগাযোগ করুন',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F1D1D),
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
//informative cards slot
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
          // Header
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
          // Content
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
              style: TextStyle(
                  fontSize: 18, color: Color(0xFFEA580C))),
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
