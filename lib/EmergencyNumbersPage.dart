import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_service.dart';

class EmergencyNumbersPage extends StatelessWidget {
  const EmergencyNumbersPage({super.key});

  // emergency numbers data from Firestore
  Stream<QuerySnapshot> getEmergencyNumbersStream() {
    return FirebaseFirestore.instance
        .collection('emergency_numbers')
        .orderBy('type')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Get language preference from provider
    final languageService = Provider.of<LanguageService>(context);
    final isEnglish = languageService.isEnglish;
    final isBangla = !isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'জরুরি নাম্বারসমূহ' : 'Emergency Numbers'),
        centerTitle: true,
        elevation: 2,
      ),
      body: _buildEmergencyNumbersList(context, isBangla),
    );
  }

  Widget _buildEmergencyNumbersList(BuildContext context, bool isBangla) {
    return StreamBuilder<QuerySnapshot>(
      stream: getEmergencyNumbersStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isBangla);
        }

        // Data loaded state
        return _buildEmergencyContactsList(snapshot.data!.docs, isBangla, context);
      },
    );
  }

  // loading
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  // empty state message
  Widget _buildEmptyState(bool isBangla) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          isBangla ? 'কোনো তথ্য পাওয়া যায়নি।' : 'No emergency contacts found.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // list of emergency contacts
  Widget _buildEmergencyContactsList(List<DocumentSnapshot> data, bool isBangla, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final doc = data[index];
          return _buildEmergencyContactCard(doc, isBangla, context);
        },
      ),
    );
  }

  // emergency contact card
  Widget _buildEmergencyContactCard(DocumentSnapshot doc, bool isBangla, BuildContext context) {
    final name = doc['name'] ?? '';
    final number = doc['number'] ?? '';
    final type = doc['type'] ?? '';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: _buildContactIcon(type),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        trailing: _buildCallButton(number, isBangla, context),
      ),
    );
  }

  // Builds icon
  Widget _buildContactIcon(String type) {
    final isHospital = type.toLowerCase() == 'hospital';
    final iconColor = isHospital ? Colors.red : Colors.green;
    final icon = isHospital ? Icons.local_hospital : Icons.local_taxi;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
  }

  // Builds call button
  Widget _buildCallButton(String number, bool isBangla, BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.call,
          color: Colors.blue,
          size: 24,
        ),
      ),
      onPressed: () => _handleCallAction(number, isBangla, context),
    );
  }

  // phone call action
  void _handleCallAction(String number, bool isBangla, BuildContext context) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      final Uri phoneUri = Uri.parse('tel:$cleanNumber');
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, isBangla, cleanNumber);
      }
    }
  }

  // Shows error message
  void _showErrorSnackbar(BuildContext context, bool isBangla, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBangla
              ? 'নাম্বার ডায়াল করতে সমস্যা হয়েছে: $number'
              : 'Could not dial: $number',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
