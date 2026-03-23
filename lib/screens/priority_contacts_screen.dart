import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../models/emergency_contact.dart';

class PriorityContactsScreen extends StatefulWidget {
  const PriorityContactsScreen({super.key});

  @override
  State<PriorityContactsScreen> createState() => _PriorityContactsScreenState();
}

class _PriorityContactsScreenState extends State<PriorityContactsScreen> {
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _contacts = storage.loadContacts();
      _isLoading = false;
    });
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Priority Contact',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(nameCtrl, 'Name (e.g. Mom, Dad)', Icons.person_rounded),
              const SizedBox(height: 12),
              _buildField(phoneCtrl, 'Phone Number', Icons.call_rounded,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildField(relCtrl, 'Role (e.g. Cardiologist)', Icons.work_rounded),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                      final contact = EmergencyContact(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        phone: phoneCtrl.text,
                        relationship: relCtrl.text,
                      );
                      final storage = await StorageService.getInstance();
                      _contacts.add(contact);
                      await storage.saveContacts(_contacts);
                      setState(() {});
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Contact',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: AppColors.secondary, fontFamily: 'Inter'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Priority Contacts',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add_rounded),
                    color: AppColors.primary,
                    onPressed: _showAddDialog,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Column(
                        children: [
                          Text(
                            'EMERGENCY QUICK-ACCESS',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Help is one tap away.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (_contacts.isEmpty)
                            _buildEmptyState()
                          else
                            ..._contacts.asMap().entries.map((entry) {
                              final i = entry.key;
                              final c = entry.value;
                              return _PriorityCard(
                                contact: c,
                                isPrimary: i == 0,
                                onCall: () => _callContact(c.phone),
                              );
                            }),
                          const SizedBox(height: 40),
                          // Add prompt
                          Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _showAddDialog,
                                  icon: const Icon(Icons.person_add_rounded),
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add trusted contacts for immediate SOS\nsharing and calls during emergencies.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.secondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.contact_phone_rounded,
              size: 48, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text(
            'No contacts yet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your emergency contacts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final EmergencyContact contact;
  final bool isPrimary;
  final VoidCallback onCall;

  const _PriorityCard({
    required this.contact,
    required this.isPrimary,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary
            ? Border.all(color: AppColors.primary.withAlpha(60), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPrimary)
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${contact.name} (Primary)',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  )
                else ...[
                  if (contact.relationship.isNotEmpty) ...[
                    Icon(Icons.local_hospital_rounded,
                        size: 16, color: AppColors.tertiary),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
                if (contact.relationship.isNotEmpty &&
                    contact.relationship != contact.name) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.relationship,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.primary.withAlpha(180),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  contact.phone,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: isPrimary ? 56 : 48,
              height: isPrimary ? 56 : 48,
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.primary : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                boxShadow: isPrimary
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.call_rounded,
                color: isPrimary ? Colors.white : AppColors.primary,
                size: isPrimary ? 26 : 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
