import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_service.dart';
//icu finder page
class ICUFinderPage extends StatefulWidget {
  const ICUFinderPage({super.key});

  @override
  State<ICUFinderPage> createState() => _ICUFinderPageState();
}

class _ICUFinderPageState extends State<ICUFinderPage> {
  // State variables for filter selections
  String selectedDistrict = 'All';
  String selectedOwnership = 'All';
  List<String> districts = ['All', 'Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna', 'Barishal', 'Rangpur', 'Mymensingh'];
  List<String> ownerships = ['All', 'Govt', 'Private'];

  Stream<QuerySnapshot> getICUHospitalsStream() {
    return FirebaseFirestore.instance
        .collection('icu_hospitals')
        .snapshots();
  }
//available districts
  List<QueryDocumentSnapshot> filterHospitals(List<QueryDocumentSnapshot> hospitals) {
    return hospitals.where((hospital) {
      final district = hospital['district'] ?? '';
      final ownership = hospital['ownership'] ?? '';

      bool matchesDistrict = selectedDistrict == 'All' || district == selectedDistrict;
      bool matchesOwnership = selectedOwnership == 'All' || ownership == selectedOwnership;

      return matchesDistrict && matchesOwnership;
    }).toList();
  }

  String formatCurrency(dynamic cost) {
    if (cost == null) return 'Not specified';
    if (cost is String) {
      if (cost.toLowerCase().contains('not specified')) return 'Not specified';
      return cost;
    }
    return cost.toString();
  }

  //language pref
  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isEnglish = languageService.isEnglish;
    final isBangla = !isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'আইসিইউ খুঁজুন' : 'ICU Finder'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getICUHospitalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          }

          //error handling
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isBangla ? 'ডেটা লোড করতে সমস্যা হয়েছে।' : 'Error loading data.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          //empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isBangla ? 'কোনো আইসিইউ তথ্য পাওয়া যায়নি।' : 'No ICU information found.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collection: icu_hospitals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          //data load
          final allHospitals = snapshot.data!.docs;
          final filteredHospitals = filterHospitals(allHospitals);

          return Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    //drop down
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedDistrict,
                                hint: Text(isBangla ? 'জেলা' : 'District'),
                                isExpanded: true,
                                items: districts.map((district) {
                                  return DropdownMenuItem<String>(
                                    value: district,
                                    child: Text(
                                      district == 'All'
                                          ? (isBangla ? 'সব জেলা' : 'All Districts')
                                          : district,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDistrict = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedOwnership,
                                hint: Text(isBangla ? 'মালিকানা' : 'Ownership'),
                                isExpanded: true,
                                items: ownerships.map((ownership) {
                                  String displayText;
                                  if (ownership == 'All') {
                                    displayText = isBangla ? 'সব ধরনের' : 'All Types';
                                  } else if (ownership == 'Govt') {
                                    displayText = isBangla ? 'সরকারি' : 'Government';
                                  } else {
                                    displayText = isBangla ? 'বেসরকারি' : 'Private';
                                  }
                                  return DropdownMenuItem<String>(
                                    value: ownership,
                                    child: Text(displayText),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedOwnership = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      //hospitals row
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isBangla
                                ? '${filteredHospitals.length}টি হাসপাতাল পাওয়া গেছে'
                                : '${filteredHospitals.length} hospitals found',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Hospital List
              Expanded(
                child: filteredHospitals.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isBangla
                              ? 'এই ফিল্টারে কোনো হাসপাতাল পাওয়া যায়নি।'
                              : 'No hospitals found with current filters.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filteredHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = filteredHospitals[index];
                    final name = hospital['name'] ?? '';
                    final district = hospital['district'] ?? '';
                    final ownership = hospital['ownership'] ?? '';
                    final icuBeds = hospital['icu_beds'] ?? 0;
                    final costPerBed = hospital['cost_per_bed'] ?? 'Not specified';
                    final contactNumber = hospital['contact_number'] ?? '';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hospital Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: ownership.toLowerCase() == 'govt'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital,
                                    color: ownership.toLowerCase() == 'govt'
                                        ? Colors.green[600]
                                        : Colors.blue[600],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            district,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 2.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ownership.toLowerCase() == 'govt'
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              ownership.toLowerCase() == 'govt'
                                                  ? (isBangla ? 'সরকারি' : 'Government')
                                                  : (isBangla ? 'বেসরকারি' : 'Private'),
                                              style: TextStyle(
                                                color: ownership.toLowerCase() == 'govt'
                                                    ? Colors.green[700]
                                                    : Colors.orange[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ICU Information
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.red.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.hotel,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isBangla ? 'আইসিইউ বেড' : 'ICU Beds',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red[600],
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          icuBeds.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isBangla ? 'খরচ প্রতিদিন' : 'Cost per Day',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatCurrency(costPerBed),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Contact Section
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.grey[600],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          contactNumber,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final cleanNumber = contactNumber.replaceAll(RegExp(r'[^\d+]'), '');

                                    try {
                                      final Uri phoneUri = Uri.parse('tel:$cleanNumber');
                                      await launchUrl(
                                        phoneUri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isBangla
                                                  ? 'নাম্বার ডায়াল করতে সমস্যা হয়েছে: $cleanNumber'
                                                  : 'Could not dial: $cleanNumber',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.call, size: 18),
                                  label: Text(isBangla ? 'কল করুন' : 'Call'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}