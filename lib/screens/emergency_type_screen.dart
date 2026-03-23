import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'emergency_loading_screen.dart';

class EmergencyTypeScreen extends StatefulWidget {
  const EmergencyTypeScreen({super.key});

  @override
  State<EmergencyTypeScreen> createState() => _EmergencyTypeScreenState();
}

class _EmergencyTypeScreenState extends State<EmergencyTypeScreen> {
  int? _selectedIndex;

  final List<_EmergencyType> _types = const [
    _EmergencyType(
      icon: Icons.directions_car_rounded,
      label: 'Road Accident',
      iconBg: Color(0x1ABC0100),
      iconColor: AppColors.primary,
      isTopPriority: true,
    ),
    _EmergencyType(
      icon: Icons.local_fire_department_rounded,
      label: 'Fire / Burn',
      iconBg: Color(0x1AFF6D00),
      iconColor: Color(0xFFBF360C),
      isTopPriority: false,
    ),
    _EmergencyType(
      icon: Icons.favorite_rounded,
      label: 'Cardiac',
      iconBg: Color(0x1ABA1A1A),
      iconColor: AppColors.primary,
      isTopPriority: false,
    ),
    _EmergencyType(
      icon: Icons.medical_services_rounded,
      label: 'General',
      iconBg: Color(0x1A2858B2),
      iconColor: AppColors.tertiary,
      isTopPriority: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildGrid(),
                    const SizedBox(height: 28),
                    _buildTip(),
                    const SizedBox(height: 24),
                    _buildConfirmButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.secondary,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'ResQNet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'IMMEDIATE RESPONSE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.onPrimaryFixed,
            ),
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: AppColors.onSurface,
            ),
            children: [
              TextSpan(text: 'Identify\nthe '),
              TextSpan(
                text: 'Emergency',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Select the category that best matches\nyour current situation.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.secondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: _types.length,
      itemBuilder: (context, i) {
        final type = _types[i];
        final isSelected = _selectedIndex == i;
        return _EmergencyCard(
          type: type,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedIndex = i),
        );
      },
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.tertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Tip',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecting the right category helps dispatchers send specialized medical personnel and equipment immediately.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.secondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        opacity: _selectedIndex != null ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: _selectedIndex != null
              ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmergencyLoadingScreen(
                        emergencyType: _types[_selectedIndex!].label,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Confirm Emergency',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final _EmergencyType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmergencyCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withAlpha(40)
                  : AppColors.onSurface.withAlpha(15),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (type.isTopPriority)
              Positioned(
                top: -1,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Highest Priority',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (type.isTopPriority) const SizedBox(height: 12),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: type.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(type.icon, color: type.iconColor, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    type.label,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
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

class _EmergencyType {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final bool isTopPriority;

  const _EmergencyType({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.isTopPriority,
  });
}
