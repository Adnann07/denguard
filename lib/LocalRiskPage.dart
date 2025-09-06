import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'language_service.dart';

class LocalRiskPage extends StatefulWidget {
  const LocalRiskPage({super.key});

  @override
  State<LocalRiskPage> createState() => _LocalRiskPageState();
}

class _LocalRiskPageState extends State<LocalRiskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Image upload variables
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  // Location input controller
  final TextEditingController _locationController = TextEditingController();

  // Translations
  Map<String, Map<String, String>> get _translations => {
    'title': {
      'en': 'Authority Contacts',
      'bn': 'কর্তৃপক্ষের যোগাযোগ'
    },
    'subtitle': {
      'en': 'Contact authorities to report dengue-related issues in your area',
      'bn': 'আপনার এলাকার ডেঙ্গু সংক্রান্ত সমস্যা রিপোর্ট করতে কর্তৃপক্ষের সাথে যোগাযোগ করুন'
    },
    'emergency_contacts': {
      'en': 'Emergency Contacts',
      'bn': 'জরুরি যোগাযোগ'
    },
    'authority_contacts': {
      'en': 'Authority Contacts',
      'bn': 'কর্তৃপক্ষের যোগাযোগ'
    },
    'call': {
      'en': 'Call',
      'bn': 'কল করুন'
    },
    'email': {
      'en': 'Email',
      'bn': 'ইমেইল'
    },
    'loading': {
      'en': 'Loading contacts...',
      'bn': 'যোগাযোগ লোড হচ্ছে...'
    },
    'error': {
      'en': 'Error loading contacts',
      'bn': 'যোগাযোগ লোড করতে ত্রুটি'
    },
    'no_contacts': {
      'en': 'No authority contacts available',
      'bn': 'কোন কর্তৃপক্ষের যোগাযোগ উপলব্ধ নেই'
    },
    'retry': {
      'en': 'Retry',
      'bn': 'পুনরায় চেষ্টা করুন'
    },
    'call_error': {
      'en': 'Unable to make call',
      'bn': 'কল করতে পারছি না'
    },
    'email_error': {
      'en': 'Unable to send email',
      'bn': 'ইমেইল পাঠাতে পারছি না'
    },
    // New translations for image upload
    'report_issue': {
      'en': 'Report Issue with Photo',
      'bn': 'ছবি সহ সমস্যা রিপোর্ট করুন'
    },
    'pick_image': {
      'en': 'Pick Image',
      'bn': 'ছবি নির্বাচন করুন'
    },
    'upload_image': {
      'en': 'Upload & Save Report',
      'bn': 'আপলোড ও রিপোর্ট সেভ করুন'
    },
    'uploading': {
      'en': 'Uploading...',
      'bn': 'আপলোড হচ্ছে...'
    },
    'image_uploaded': {
      'en': 'Report saved successfully!',
      'bn': 'রিপোর্ট সফলভাবে সেভ হয়েছে!'
    },
    'upload_failed': {
      'en': 'Report save failed',
      'bn': 'রিপোর্ট সেভ ব্যর্থ হয়েছে'
    },
    'select_image_first': {
      'en': 'Please select an image first',
      'bn': 'প্রথমে একটি ছবি নির্বাচন করুন'
    },
    'location_required': {
      'en': 'Please enter the location',
      'bn': 'অনুগ্রহ করে স্থান লিখুন'
    },
    'image_url': {
      'en': 'Image URL:',
      'bn': 'ছবির URL:'
    },
    'attach_photo_description': {
      'en': 'Attach a photo of dengue breeding sites or related issues to help authorities understand the problem better',
      'bn': 'কর্তৃপক্ষকে সমস্যা ভালোভাবে বুঝতে সাহায্য করার জন্য ডেঙ্গু প্রজনন স্থান বা সংশ্লিষ্ট সমস্যার একটি ছবি সংযুক্ত করুন'
    },
    'location_label': {
      'en': 'Location of the issue',
      'bn': 'সমস্যার স্থান'
    },
    'location_hint': {
      'en': 'e.g., Road 5, Mirpur, Dhaka',
      'bn': 'যেমন: রোড ৫, মিরপুর, ঢাকা'
    },
    'report_saved': {
      'en': 'Report saved to database',
      'bn': 'রিপোর্ট ডাটাবেসে সেভ হয়েছে'
    }
  };

  String _getText(String key) {
    final isEnglish = Provider.of<LanguageService>(context).isEnglish;
    return _translations[key]?[isEnglish ? 'en' : 'bn'] ?? key;
  }
//contact list
  List<ContactInfo> get _emergencyContacts => [
    ContactInfo(
      name: _getText('emergency_contacts'),
      phone: '999',
      description: Provider.of<LanguageService>(context).isEnglish
          ? 'National Emergency Hotline'
          : 'জাতীয় জরুরি হটলাইন',
      location: Provider.of<LanguageService>(context).isEnglish
          ? 'Nationwide'
          : 'সারাদেশে',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    ContactInfo(
      name: Provider.of<LanguageService>(context).isEnglish
          ? 'Directorate General of Health Services'
          : 'স্বাস্থ্য অধিদপ্তর',
      phone: '16263',
      description: Provider.of<LanguageService>(context).isEnglish
          ? 'DGHS Dengue Control'
          : 'স্বাস্থ্য অধিদপ্তর ডেঙ্গু নিয়ন্ত্রণ',
      location: Provider.of<LanguageService>(context).isEnglish
          ? 'Dhaka'
          : 'ঢাকা',
      icon: Icons.bug_report,
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // Image picker function
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _uploadedImageUrl = null; // Reset previous upload
        });
      }
    } catch (e) {
      _showSnackBar(_getText('error'), isError: true);
    }
  }

  // Save report to Firestore
  Future<void> _saveReportToFirestore(String imageUrl, String location) async {
    try {
      await _firestore.collection('dengue_reports').add({
        'imageUrl': imageUrl,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      _showSnackBar(_getText('report_saved'));
    } catch (e) {
      throw Exception('Failed to save report to database: $e');
    }
  }

  //  image upload function with Firestore integration
  Future<void> _uploadImageAndSaveReport() async {
    if (_selectedImage == null) {
      _showSnackBar(_getText('select_image_first'), isError: true);
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      _showSnackBar(_getText('location_required'), isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // First upload the image
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      //  ImgBB API key
      const apiKey = '967403ccacf09d45d6cd66987ff26457';
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

      final response = await http.post(url, body: {
        'image': base64Image,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final imageUrl = data['data']['url'];

          // Save to Firestore
          await _saveReportToFirestore(imageUrl, _locationController.text.trim());

          setState(() {
            _uploadedImageUrl = imageUrl;
          });

          _showSnackBar(_getText('image_uploaded'));

          // Clear the form
          setState(() {
            _selectedImage = null;
            _locationController.clear();
          });
        } else {
          throw Exception('Upload failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar(_getText('upload_failed'), isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Helper function to show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }

  // Phone call function
  void _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      final Uri phoneUri = Uri.parse('tel:$cleanNumber');
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageService>(context, listen: false).isEnglish
                  ? 'Could not dial: $cleanNumber'
                  : 'নাম্বার ডায়াল করতে সমস্যা হয়েছে: $cleanNumber',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    }
  }

  // Email function
  void _sendEmail(String email) async {
    String emailBody = 'Dengue Risk Report\n\n';

    // Add image URL
    if (_uploadedImageUrl != null) {
      emailBody += '${_getText('image_url')} $_uploadedImageUrl\n\n';
    }

    emailBody += 'Please describe the dengue-related issue in your area.';

    try {
      final Uri emailUri = Uri.parse(
          'mailto:$email?subject=Dengue Risk Report&body=${Uri.encodeComponent(emailBody)}'
      );
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageService>(context, listen: false).isEnglish
                  ? 'Could not open email: $email'
                  : 'ইমেইল খুলতে পারছি না: $email',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    }
  }

  IconData _getIconForOrganization(String organization) {
    final orgLower = organization.toLowerCase();
    if (orgLower.contains('city') || orgLower.contains('corporation')) {
      return Icons.location_city;
    } else if (orgLower.contains('health') || orgLower.contains('hospital')) {
      return Icons.health_and_safety;
    } else if (orgLower.contains('ward') || orgLower.contains('office')) {
      return Icons.account_balance;
    } else if (orgLower.contains('fire')) {
      return Icons.local_fire_department;
    } else {
      return Icons.business;
    }
  }

  Color _getColorForOrganization(String organization) {
    final orgLower = organization.toLowerCase();
    if (orgLower.contains('city') || orgLower.contains('corporation')) {
      return Colors.blue;
    } else if (orgLower.contains('health') || orgLower.contains('hospital')) {
      return Colors.green;
    } else if (orgLower.contains('ward') || orgLower.contains('office')) {
      return Colors.purple;
    } else if (orgLower.contains('police')) {
      return Colors.indigo;
    } else if (orgLower.contains('fire')) {
      return Colors.red;
    } else if (orgLower.contains('water') || orgLower.contains('wasa')) {
      return Colors.cyan;
    } else if (orgLower.contains('environment')) {
      return Colors.teal;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('title')),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton.icon(
                onPressed: languageService.toggleLanguage,
                icon: const Icon(Icons.language, color: Colors.white),
                label: Text(
                  languageService.isEnglish ? 'বাংলা' : 'English',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade100, Colors.orange.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 48,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getText('subtitle'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Image Upload Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.green.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getText('report_issue'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getText('attach_photo_description'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Location input field
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: _getText('location_label'),
                      hintText: _getText('location_hint'),
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 16),

                  // Image preview
                  if (_selectedImage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: Text(_getText('pick_image')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _uploadImageAndSaveReport,
                          icon: _isUploading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Icon(Icons.cloud_upload),
                          label: Text(_isUploading ? _getText('uploading') : _getText('upload_image')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Upload result
                  if (_uploadedImageUrl != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Text(
                                _getText('image_uploaded'),
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            '${_getText('image_url')}\n$_uploadedImageUrl',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Contacts Section
            Text(
              _getText('emergency_contacts'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._emergencyContacts.map((contact) => _buildContactCard(contact)),

            const SizedBox(height: 24),

            // Authority Contacts Section
            Text(
              _getText('authority_contacts'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Firebase Authority Contacts
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('authority').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorWidget();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingWidget();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildNoDataWidget();
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final contact = ContactInfo(
                      name: data['Organization'] ?? 'Unknown Organization',
                      phone: data['contact'] ?? '',
                      email: data['email'] ?? '',
                      description: data['Organization'] ?? 'Government Authority',
                      location: data['location'] ?? '',
                      icon: _getIconForOrganization(data['Organization'] ?? ''),
                      color: _getColorForOrganization(data['Organization'] ?? ''),
                    );
                    return _buildContactCard(contact);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(_getText('loading')),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              _getText('error'),
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {}); // Trigger rebuild to retry
              },
              icon: const Icon(Icons.refresh),
              label: Text(_getText('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              _getText('no_contacts'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(ContactInfo contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: contact.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                contact.icon,
                color: contact.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (contact.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact.location,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (contact.phone.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(contact.phone),
                          icon: const Icon(Icons.phone, size: 18),
                          label: Text(_getText('call')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: contact.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (contact.email.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _sendEmail(contact.email),
                          icon: const Icon(Icons.email, size: 18),
                          label: Text(_getText('email')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: contact.color,
                            side: BorderSide(color: contact.color),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                          ),
                        ),
                    ],
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

class ContactInfo {
  final String name;
  final String phone;
  final String email;
  final String description;
  final String location;
  final IconData icon;
  final Color color;

  ContactInfo({
    required this.name,
    this.phone = '',
    this.email = '',
    required this.description,
    this.location = '',
    required this.icon,
    required this.color,
  });
}