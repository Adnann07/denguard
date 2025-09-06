import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodDonorsPage extends StatefulWidget {
  const BloodDonorsPage({super.key});

  @override
  State<BloodDonorsPage> createState() => _BloodDonorsPageState();
}

class _BloodDonorsPageState extends State<BloodDonorsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Filter controllers
  String? _filterBloodType;
  String? _filterDivision;
  String _searchQuery = '';

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _divisions = [
    'Dhaka', 'Chittagong', 'Rajshahi', 'Khulna', 'Barisal', 'Sylhet', 'Rangpur', 'Mymensingh'
  ];

  // Color scheme
  static const Color primaryRed = Color(0xFFE53E3E);
  static const Color lightRed = Color(0xFFFED7D7);
  static const Color darkRed = Color(0xFFC53030);
  static const Color cardBackground = Color(0xFFFAFAFA);

  void _callPhoneNumber(String phone) async {
    try {
      final url = 'tel:$phone';
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        _showSnackBar('Could not open dialer. Phone: $phone', isError: true);
      }
    }
  }

  void _copyPhoneNumber(String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    _showSnackBar('Phone number copied to clipboard');
  }
//snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
//firebase connect
  Future<void> _addDonor(Map<String, dynamic> donorData) async {
    try {
      await _firestore.collection('blood_donors').add({
        ...donorData,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      _showSnackBar('Successfully added as blood donor!');
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to add donor: $e', isError: true);
    }
  }

  void _showAddDonorDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String? selectedDivision;
    String? selectedBloodType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit dialog height
            ),
            child: SingleChildScrollView( // Add scroll capability
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: lightRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.bloodtype, color: primaryRed, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Become a Blood Donor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(
                        controller: nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) => value?.trim().isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildDropdownField(
                        value: selectedDivision,
                        label: 'Division',
                        icon: Icons.location_on_outlined,
                        items: _divisions,
                        onChanged: (value) => setState(() => selectedDivision = value),
                        validator: (value) => value == null ? 'Division is required' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildDropdownField(
                        value: selectedBloodType,
                        label: 'Blood Type',
                        icon: Icons.bloodtype_outlined,
                        items: _bloodTypes,
                        onChanged: (value) => setState(() => selectedBloodType = value),
                        validator: (value) => value == null ? 'Blood type is required' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hintText: '01XXXXXXXXX',
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) return 'Phone number is required';
                          if (!RegExp(r'^(\+8801|01)[0-9]{9}$').hasMatch(value!.trim())) {
                            return 'Enter valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _addDonor({
                                    'name': nameController.text.trim(),
                                    'division': selectedDivision,
                                    'bloodType': selectedBloodType,
                                    'phone': phoneController.text.trim(),
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Add Donor', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
//dropdown
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search donors...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Blood Type',
                  _filterBloodType,
                  _bloodTypes,
                      (value) => setState(() => _filterBloodType = value),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Division',
                  _filterDivision,
                  _divisions,
                      (value) => setState(() => _filterDivision = value),
                ),
                if (_filterBloodType != null || _filterDivision != null) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Clear Filters'),
                    onPressed: () => setState(() {
                      _filterBloodType = null;
                      _filterDivision = null;
                    }),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? currentValue, List<String> options, Function(String?) onChanged) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text('All $label')),
        ...options.map((option) => PopupMenuItem(value: option, child: Text(option))),
      ],
      child: Chip(
        label: Text(currentValue ?? label),
        avatar: Icon(
          currentValue != null ? Icons.filter_alt : Icons.filter_alt_outlined,
          size: 18,
        ),
        backgroundColor: currentValue != null ? lightRed : Colors.grey[200],
        side: BorderSide(
          color: currentValue != null ? primaryRed : Colors.grey[400]!,
        ),
      ),
    );
  }

  Widget _buildDonorCard(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final name = data['name'] ?? '';
    final division = data['division'] ?? '';
    final bloodType = data['bloodType'] ?? '';
    final phone = data['phone'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        color: cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryRed, darkRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryRed.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    bloodType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

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
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          division,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  IconButton(
                    onPressed: () => _callPhoneNumber(phone),
                    icon: const Icon(Icons.call),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[700],
                    ),
                    tooltip: 'Call',
                  ),
                  IconButton(
                    onPressed: () => _copyPhoneNumber(phone),
                    icon: const Icon(Icons.copy),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                    ),
                    tooltip: 'Copy Number',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lightRed,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.bloodtype,
                size: 60,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Blood Donors Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to register as a blood donor\nand help save lives in your community',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddDonorDialog,
              icon: const Icon(Icons.add),
              label: const Text('Become a Donor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DocumentSnapshot> _filterDonors(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final division = data['division'] ?? '';
      final bloodType = data['bloodType'] ?? '';

      // Search filter
      if (_searchQuery.isNotEmpty && !name.contains(_searchQuery)) {
        return false;
      }

      // Blood type filter
      if (_filterBloodType != null && bloodType != _filterBloodType) {
        return false;
      }

      // Division filter
      if (_filterDivision != null && division != _filterDivision) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Blood Donors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('blood_donors')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryRed),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docsWithTimestamp = snapshot.data!.docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  return data['createdAt'] != null;
                }).toList();

                docsWithTimestamp.sort((a, b) {
                  final aTime = (a.data()! as Map<String, dynamic>)['createdAt'] as Timestamp;
                  final bTime = (b.data()! as Map<String, dynamic>)['createdAt'] as Timestamp;
                  return bTime.compareTo(aTime);
                });

                final filteredDocs = _filterDonors(docsWithTimestamp);

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No donors match your filters',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) => _buildDonorCard(filteredDocs[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDonorDialog,
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Become a Donor'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 4,
      ),
    );
  }
}