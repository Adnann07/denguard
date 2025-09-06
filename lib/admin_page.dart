import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_service.dart';
import 'language_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final DengueStatsService _statsService = DengueStatsService();

  final TextEditingController _last24HoursController = TextEditingController();
  final TextEditingController _last7DaysController = TextEditingController();
  String _riskLevel = 'Moderate';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _riskLevels = ['Low', 'Moderate', 'High', 'Severe'];

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
  }

  Future<void> _loadCurrentStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _statsService.getDengueStats();

      setState(() {
        _last24HoursController.text = stats['last24Hours'].toString();
        _last7DaysController.text = stats['last7Days'].toString();
        _riskLevel = stats['riskLevel'] ?? 'Moderate';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load current statistics: $e')),
        );
      }
    }
  }

  Future<void> _saveStats() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final last24Hours = int.parse(_last24HoursController.text);
      final last7Days = int.parse(_last7DaysController.text);

      await _statsService.updateDengueStats(
        last24Hours: last24Hours,
        last7Days: last7Days,
        riskLevel: _riskLevel,
      );

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistics updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update statistics: $e')),
        );
      }
    }
  }

  String _getText(String key) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    return languageService.isEnglish ? _englishTexts[key]! : _banglaTexts[key]!;
  }

  // English translations
  final Map<String, String> _englishTexts = {
    'title': 'Admin Dashboard',
    'last24Hours': 'Cases in Last 24 Hours',
    'last7Days': 'Cases in Last 7 Days',
    'riskLevel': 'Current Risk Level',
    'save': 'Save Changes',
    'refresh': 'Refresh Data',
    'loading': 'Loading...',
    'saving': 'Saving...',
    'numberRequired': 'Please enter a number',
    'numberPositive': 'Must be a positive number',
  };

  // Bangla translations
  final Map<String, String> _banglaTexts = {
    'title': 'অ্যাডমিন ড্যাশবোর্ড',
    'last24Hours': 'গত ২৪ ঘণ্টায় কেস',
    'last7Days': 'গত ৭ দিনে কেস',
    'riskLevel': 'বর্তমান ঝুঁকির স্তর',
    'save': 'পরিবর্তন সংরক্ষণ করুন',
    'refresh': 'ডাটা রিফ্রেশ করুন',
    'loading': 'লোড হচ্ছে...',
    'saving': 'সংরক্ষণ হচ্ছে...',
    'numberRequired': 'একটি সংখ্যা লিখুন',
    'numberPositive': 'ইতিবাচক সংখ্যা হতে হবে',
  };

  @override
  void dispose() {
    _last24HoursController.dispose();
    _last7DaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _getText('title'),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadCurrentStats,
            tooltip: _getText('refresh'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_getText('loading')),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _last24HoursController,
                decoration: InputDecoration(
                  labelText: _getText('last24Hours'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _getText('numberRequired');
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 0) {
                    return _getText('numberPositive');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _last7DaysController,
                decoration: InputDecoration(
                  labelText: _getText('last7Days'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _getText('numberRequired');
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 0) {
                    return _getText('numberPositive');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _riskLevel,
                decoration: InputDecoration(
                  labelText: _getText('riskLevel'),
                  border: const OutlineInputBorder(),
                ),
                items: _riskLevels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _riskLevel = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveStats,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(_getText('saving')),
                    ],
                  )
                      : Text(_getText('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
