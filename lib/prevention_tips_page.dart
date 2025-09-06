import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'language_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PreventionTipsPage extends StatelessWidget {
  const PreventionTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isEnglish = languageService.isEnglish;

    final Map<String, Map<String, String>> translations = {
      'title': {
        'en': 'Dengue Prevention Guide',
        'bn': 'ডেঙ্গু প্রতিরোধ নির্দেশিকা',
      },
      'subtitle': {
        'en': 'Essential steps to protect yourself and your community',
        'bn': 'নিজেকে এবং আপনার সম্প্রদায়কে সুরক্ষিত রাখার প্রয়োজনীয় পদক্ষেপ',
      },
      'tip1': {
        'en': 'Eliminate standing water',
        'bn': 'জমে থাকা পানি দূর করুন',
      },
      'tip1Desc': {
        'en': 'Remove water from containers, pots, and tires weekly',
        'bn': 'সপ্তাহে একবার পাত্র, টব এবং টায়ার থেকে পানি সরিয়ে ফেলুন',
      },
      'tip2': {
        'en': 'Use mosquito protection',
        'bn': 'মশা প্রতিরোধক ব্যবহার করুন',
      },
      'tip2Desc': {
        'en': 'Apply repellent and sleep under nets, especially for children',
        'bn': 'বিশেষ করে শিশুদের জন্য মশারি ব্যবহার করুন এবং রিপেলেন্ট প্রয়োগ করুন',
      },
      'tip3': {
        'en': 'Wear protective clothing',
        'bn': 'সুরক্ষামূলক পোশাক পরুন',
      },
      'tip3Desc': {
        'en': 'Cover skin during peak mosquito hours (dawn & dusk)',
        'bn': 'মশার সময়ে (ভোর ও সন্ধ্যা) ত্বক ঢেকে রাখুন',
      },
      'tip4': {
        'en': 'Maintain cleanliness',
        'bn': 'পরিচ্ছন্নতা বজায় রাখুন',
      },
      'tip4Desc': {
        'en': 'Keep surroundings clean and dispose garbage properly',
        'bn': 'পরিবেশ পরিষ্কার রাখুন এবং সঠিকভাবে আবর্জনা নিষ্কাশন করুন',
      },
      'tip5': {
        'en': 'Report breeding sites',
        'bn': 'প্রজনন স্থান রিপোর্ট করুন',
      },
      'tip5Desc': {
        'en': 'Notify authorities about potential mosquito breeding areas',
        'bn': 'মশার প্রজননের সম্ভাব্য স্থান সম্পর্কে কর্তৃপক্ষকে জানান',
      },
      'tip6': {
        'en': 'Community awareness',
        'bn': 'সম্প্রদায় সচেতনতা',
      },
      'tip6Desc': {
        'en': 'Educate neighbors and organize clean-up drives',
        'bn': 'প্রতিবেশীদের শিক্ষা দিন এবং পরিচ্ছন্নতা অভিযান আয়োজন করুন',
      },
      'didYouKnow': {
        'en': 'Did You Know?',
        'bn': 'আপনি কি জানেন?',
      },
      'fact1': {
        'en': 'Aedes mosquitoes breed in clean standing water',
        'bn': 'এডিস মশা পরিষ্কার জমে থাকা পানিতে প্রজনন করে',
      },
      'fact2': {
        'en': 'They bite primarily during daytime',
        'bn': 'এগুলি প্রধানত দিনের বেলায় কামড়ায়',
      },
      'fact3': {
        'en': 'One infected mosquito can affect an entire neighborhood',
        'bn': 'একটি সংক্রমিত মশা পুরো এলাকাকে প্রভাবিত করতে পারে',
      },
      'mythBusters': {
        'en': 'Dengue Myth Busters',
        'bn': 'ডেঙ্গু ভুল ধারণা ও সত্য',
      },
      'myth1': {
        'en': 'Myth: Only dirty water breeds mosquitoes',
        'bn': 'ভুল ধারণা: শুধুমাত্র নোংরা পানিতে মশা জন্মায়',
      },
      'truth1': {
        'en': 'Truth: Aedes mosquitoes breed in clean standing water',
        'bn': 'সত্য: এডিস মশা পরিষ্কার জমে থাকা পানিতে জন্মায়',
      },
      'myth2': {
        'en': 'Myth: You cannot get dengue more than once',
        'bn': 'ভুল ধারণা: ডেঙ্গু একবার হলে আর হয় না',
      },
      'truth2': {
        'en': 'Truth: You can be infected up to four times by different serotypes',
        'bn': 'সত্য: চারটি আলাদা ধরনের ভাইরাস দিয়ে আপনি চারবার পর্যন্ত আক্রান্ত হতে পারেন',
      },
      'myth3': {
        'en': 'Myth: Dengue always causes severe symptoms',
        'bn': 'ভুল ধারণা: ডেঙ্গু সবসময় মারাত্মক উপসর্গ তৈরি করে',
      },
      'truth3': {
        'en': 'Truth: Many dengue cases are mild and can be managed with rest and fluids',
        'bn': 'সত্য: বেশিরভাগ ডেঙ্গু আক্রান্ত ব্যক্তি বিশ্রাম ও তরল গ্রহণের মাধ্যমে সুস্থ হন',
      },
    };

    String tr(String key) => translations[key]?[isEnglish ? 'en' : 'bn'] ?? key;

    final tips = [
      {
        'icon': Icons.water_drop_outlined,
        'color': Colors.blue,
        'titleKey': 'tip1',
        'descKey': 'tip1Desc'
      },
      {
        'icon': Icons.medical_information_outlined,
        'color': Colors.red,
        'titleKey': 'tip2',
        'descKey': 'tip2Desc'
      },
      {
        'icon': Icons.checkroom_outlined,
        'color': Colors.green,
        'titleKey': 'tip3',
        'descKey': 'tip3Desc'
      },
      {
        'icon': Icons.cleaning_services_outlined,
        'color': Colors.orange,
        'titleKey': 'tip4',
        'descKey': 'tip4Desc'
      },
      {
        'icon': Icons.report_outlined,
        'color': Colors.purple,
        'titleKey': 'tip5',
        'descKey': 'tip5Desc'
      },
      {
        'icon': Icons.groups_outlined,
        'color': Colors.teal,
        'titleKey': 'tip6',
        'descKey': 'tip6Desc'
      },
    ];

    final facts = [
      tr('fact1'),
      tr('fact2'),
      tr('fact3'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('title')),
            Text(
              tr('subtitle'),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Text(isEnglish ? 'বাংলা' : 'ENG',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: languageService.toggleLanguage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prevention Tips Section
            Text(
              isEnglish ? 'Prevention Measures' : 'প্রতিরোধমূলক ব্যবস্থা',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            ...tips.map((tip) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tip['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tip['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(tip['titleKey'] as String),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr(tip['descKey'] as String),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Did You Know Section
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('didYouKnow'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...facts.map((fact) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fact,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            // Myth Busters Section
            const SizedBox(height: 24),
            Text(
              tr('mythBusters'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _buildMythBuster(context, tr('myth1'), tr('truth1')),
            _buildMythBuster(context, tr('myth2'), tr('truth2')),
            _buildMythBuster(context, tr('myth3'), tr('truth3')),

            // Additional Resources
            const SizedBox(height: 24),
            Text(
              isEnglish ? 'Additional Resources' : 'অতিরিক্ত সম্পদ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildResourceChip(
                  context,
                  icon: Icons.article_outlined,
                  label: isEnglish ? 'Government Guidelines' : 'সরকারি নির্দেশিকা',
                  onPressed: () => _launchURLWithFallback(
                      context,
                      'https://lgd.gov.bd/site/publications/95e60e7d-92bd-45e3-91e9-dd1c486c56bd/National-guidelines-for-prevention-of-other-mosquito-borne-diseases-including-dengue',
                      isEnglish
                          ? 'Could not open the government guidelines website'
                          : 'সরকারি নির্দেশিকা ওয়েবসাইট খোলা যায়নি'
                  ),
                ),
                _buildResourceChip(
                  context,
                  icon: Icons.phone_outlined,
                  label: isEnglish ? 'Helpline Number - 16263' : 'হেল্পলাইন নম্বর - 16263',

                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceChip(BuildContext context, {required IconData icon, required String label, VoidCallback? onPressed}) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(color: Colors.grey.shade800),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildMythBuster(BuildContext context, String myth, String truth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.close, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  myth,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  truth,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchURLWithFallback(BuildContext context, String url, String errorMessage) async {
    try {
      // Ensure the URL is properly formatted
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri uri = Uri.parse(url);

      // Try launching directly
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // If direct launch fails, try alternative methods
      final String encodedUrl = Uri.encodeFull(url);
      final Uri encodedUri = Uri.parse(encodedUrl);

      if (await canLaunchUrl(encodedUri)) {
        await launchUrl(
          encodedUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // As a last resort, try launching in a basic webview
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        return;
      } catch (e) {
        // If all else fails, show error message
        _showLaunchError(context, errorMessage);
      }
    } catch (e) {
      _showLaunchError(context, errorMessage);
    }
  }
  void _showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
