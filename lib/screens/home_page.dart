import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../utils/app_config.dart';
import '../services/storage_service.dart';
import 'emergency_type_screen.dart';
import 'offline_mode_screen.dart';
import 'priority_contacts_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _subtlePulse;
  late AnimationController _holdProgress;
  late Animation<double> _holdAnim;

  bool _isHolding = false;
  bool _holdComplete = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();

    _subtlePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _holdProgress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _holdAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _holdProgress, curve: Curves.easeOut),
    );

    _holdProgress.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _holdComplete = true);
        // Navigate to emergency type selection
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyTypeScreen()),
        ).then((_) {
          if (mounted) {
            setState(() {
              _holdComplete = false;
              _isHolding = false;
            });
            _holdProgress.reset();
          }
        });
      }
    });

    _loadUserName();
    _checkConnectivity();
  }

  Future<void> _loadUserName() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _userName = storage.loadUserName();
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (!result.contains(ConnectivityResult.wifi) &&
        !result.contains(ConnectivityResult.mobile)) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfflineModeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _subtlePulse.dispose();
    _holdProgress.dispose();
    super.dispose();
  }

  void _onSOSDown() {
    setState(() => _isHolding = true);
    _holdProgress.forward(from: 0.0);
  }

  void _onSOSUp() {
    if (!_holdComplete) {
      _holdProgress.reset();
      setState(() => _isHolding = false);
    }
  }

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: AppConfig.emergencyNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(),
              const SizedBox(height: 36),
              _buildSOSButton(),
              const SizedBox(height: 36),
              _buildActionCards(),
              const SizedBox(height: 24),
              _buildQuickTip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withAlpha(80),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ALL SYSTEMS ONLINE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _userName.isNotEmpty
                  ? 'Hello, $_userName'
                  : 'Emergency Ready',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded,
              size: 24, color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: GestureDetector(
        onLongPressStart: (_) => _onSOSDown(),
        onLongPressEnd: (_) => _onSOSUp(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_subtlePulse, _holdAnim]),
          builder: (_, __) {
            final holdValue = _holdAnim.value;
            final pulseValue = _subtlePulse.value;
            final size = 180.0 + pulseValue * 8;

            return SizedBox(
              width: size + 40,
              height: size + 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring (subtle breathing)
                  Container(
                    width: size + 32,
                    height: size + 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(
                          _isHolding ? (holdValue * 120).toInt() + 30 : 25,
                        ),
                        width: _isHolding ? 3 + holdValue * 4 : 2,
                      ),
                    ),
                  ),

                  // Hold progress circle
                  if (_isHolding)
                    SizedBox(
                      width: size + 20,
                      height: size + 20,
                      child: CircularProgressIndicator(
                        value: holdValue,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.primary.withAlpha(30),
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.primary.withAlpha(
                            (holdValue * 255).toInt().clamp(80, 255),
                          ),
                        ),
                      ),
                    ),

                  // Main button
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withAlpha(
                            _isHolding ? 230 + (holdValue * 25).toInt() : 220,
                          ),
                          AppColors.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(
                            _isHolding
                                ? (holdValue * 150).toInt() + 40
                                : 60,
                          ),
                          blurRadius: _isHolding
                              ? 32 + holdValue * 24
                              : 24 + pulseValue * 8,
                          spreadRadius: _isHolding ? holdValue * 6 : 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emergency_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'SOS',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isHolding ? 'Keep holding...' : 'Hold for 2 seconds',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.call_rounded,
            label: 'Call 108',
            subtitle: 'Ambulance',
            color: AppColors.primary,
            bgColor: AppColors.primaryFixed,
            onTap: _callEmergency,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ActionCard(
            icon: Icons.contact_phone_rounded,
            label: 'Contacts',
            subtitle: 'Priority',
            color: AppColors.tertiary,
            bgColor: AppColors.tertiaryFixed,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PriorityContactsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tips_and_updates_rounded,
                color: AppColors.tertiary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Prepared',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add your emergency contacts for faster response during critical situations.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha(10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
