import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'ambulance_status_screen.dart';

class EmergencyLoadingScreen extends StatefulWidget {
  final String emergencyType;

  const EmergencyLoadingScreen({
    super.key,
    required this.emergencyType,
  });

  @override
  State<EmergencyLoadingScreen> createState() => _EmergencyLoadingScreenState();
}

class _EmergencyLoadingScreenState extends State<EmergencyLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  int _step = 0; // 0 = locating, 1 = notifying, 2 = assigning

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate step progression
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _step = 1);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _step = 2);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AmbulanceStatusScreen(
              emergencyType: widget.emergencyType,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -40,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withAlpha(50),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiaryFixed.withAlpha(25),
              ),
            ),
          ),
          // Top accent bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.tertiary,
                    AppColors.primary,
                    AppColors.tertiary
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spinner
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _spinController,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                              ),
                              child: CustomPaint(
                                painter: _SpinnerPainter(),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, __) => Opacity(
                              opacity: _pulseAnim.value,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.tertiary.withAlpha(25),
                                ),
                                child: const Icon(
                                  Icons.health_and_safety_rounded,
                                  color: AppColors.tertiary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Finding nearest help...',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Stay calm. Help is on the way.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Status pills
                    _StatusPill(
                      icon: Icons.location_on_rounded,
                      label: 'CURRENT LOCATION',
                      value: 'GPS Coordinates Locked',
                      isActive: _step >= 0,
                      isDone: _step > 0,
                    ),
                    const SizedBox(height: 12),
                    _StatusPill(
                      icon: Icons.emergency_share_rounded,
                      label: 'NETWORK STATUS',
                      value: _step > 1
                          ? 'Emergency Services Notified'
                          : 'Contacting Emergency Services...',
                      isActive: _step >= 1,
                      isDone: _step > 1,
                    ),
                    const SizedBox(height: 12),
                    _StatusPill(
                      icon: Icons.local_shipping_rounded,
                      label: 'AMBULANCE',
                      value: _step > 2
                          ? 'Ambulance Assigned'
                          : 'Assigning Ambulance...',
                      isActive: _step >= 2,
                      isDone: _step > 2,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Your medical ID is being shared with responders',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.secondary.withAlpha(150),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isActive;
  final bool isDone;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : icon,
              color: isDone ? Colors.green : AppColors.tertiary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tertiary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width - 4,
        height: size.height - 4,
      ),
      -1.57, // start at top
      4.2, // ~3/4 of circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
