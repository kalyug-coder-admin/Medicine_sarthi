import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/services/notification_service.dart';
import '../../../config/routes/route_names.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../widgets/medicine/medicine_card.dart';
import '../../../domain/entities/medicine_entity.dart';
import '../../../injection_container.dart' as di;
import '../../../core/services/tts_service.dart';

class MedicineSarthiColors {
  MedicineSarthiColors._();
  // Dawarikar / temple-inspired palette
  static const Color primary = Color(0xFF7A2E2A); // deep maroon
  static const Color primaryLight = Color(0xFFD8B878); // gold sand
  static const Color accent = Color(0xFFB5743B); // warm ochre
  static const Color success = Color(0xFF2E7D32); // toned-down green
  static const Color info = Color(0xFF1565C0); // muted blue
  static const Color background = Color(0xFFF6F1E7); // stone cream
  static const Color cardBackground = Color(0xFFFFFBF4); // warm light card
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late TtsService _ttsService;
  late Animation<double> _fadeIn;
  late final YoutubePlayerController _ytController;
  final String _videoId = 'mvwZFKDPIWk';

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    _ttsService.initialize();
    _loadUserData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _ytController = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        disableDragSeek: false,
        loop: false,
      ),
    )..addListener(_youtubeListener);
  }

  void _youtubeListener() {
    if (!_ytController.value.isReady) return;
    final pos = _ytController.value.position;
    if (pos.inSeconds >= 30 && _ytController.value.isPlaying) {
      _ytController.pause();
    }
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MedicineBloc>().add(
        LoadMedicinesEvent(userId: authState.user.id),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        context.push(RouteNames.medicines).then((_) {
          if (mounted) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.read<MedicineBloc>().add(
                LoadMedicinesEvent(userId: authState.user.id),
              );
            }
            setState(() => _selectedIndex = 0);
          }
        });
        break;
      case 2:
        context.push(RouteNames.voiceAssistant).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
      case 3:
        context.push(RouteNames.appointments).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
      case 4:
        context.push(RouteNames.profile).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ytController.removeListener(_youtubeListener);
    _ytController.dispose();
    super.dispose();
  }

  bool _isForToday(MedicineEntity medicine) {
    final today = DateTime.now();
    if (today.isBefore(medicine.startDate)) return false;
    if (medicine.endDate != null && today.isAfter(medicine.endDate!)) {
      return false;
    }
    if (medicine.frequency == Frequency.asNeeded) return false;
    if (medicine.frequency == Frequency.weekly) {
      if (today.weekday != medicine.startDate.weekday) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicineSarthiColors.background,
      body: FadeTransition(
        opacity: _fadeIn,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(authState),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            di.sl<NotificationService>().showInstantNotification(
                              title: "Test Notification",
                              body: "This is a manual test notification.",
                            );
                          },
                          child: const Text("Send Test Notification"),
                        ),
                        ElevatedButton(
                          onPressed: () => NotificationService().debugScheduleIn10Seconds(),
                          child: Text("Test Alarm 10 sec"),
                        ),
                        _buildHealthStats(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final service = di.sl<NotificationService>();
                            final pending = await service.getPendingNotifications();
                            final meds = pending.where((p) => p.payload?.startsWith('medicine_') ?? false);
                            debugPrint(
                                'Pending med notifs:\n${meds.map((m) => "ID: ${m.id}, Title: ${m.title}, Payload: ${m.payload}").join("\n")}'
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Pending meds: ${meds.length}')),
                              );
                            }
                          },
                          child: const Text('Check Pending Med Notifs'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await _ttsService.speak('TTS Test Successful! Your voice service is working. This is from the button press on November 23, 2025.');
                              print('TTS test triggered successfully!');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('TTS Test: Speaking now! Check your volume.')),
                              );
                            } catch (e) {
                              print('TTS test failed: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('TTS Error: $e')),
                              );
                            }
                          },
                          child: const Text('Test TTS Voice'),
                        ),
                        const SizedBox(height: 20),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildVoiceAssistantCard(),
                        const SizedBox(height: 24),
                        _buildTodaysMedicines(context),
                        const SizedBox(height: 24),
                        _buildVideoPreviewCard(),
                        const SizedBox(height: 24),
                        _buildUpcomingAppointments(context),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------- HEADER (Dawarikar + Krishna silhouette on side) ----------------
  Widget _buildSliverAppBar(AuthAuthenticated authState) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'शुभ प्रभात'
        : hour < 17
        ? 'शुभ दुपार'
        : 'शुभ संध्या';
    return SliverAppBar(
      expandedHeight: 190,
      floating: false,
      pinned: true,
      backgroundColor: MedicineSarthiColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7A2E2A),
                Color(0xFF9B4A36),
                Color(0xFFD8B878),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left: Greeting + Name + Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          greeting,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFF2CF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authState.user.name,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right: Krishna silhouette in golden carved frame
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD8B878), Color(0xFFB8904A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF6F1E7),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/img.png',
                          height: 54,
                          width: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // ---------------- VOICE ASSISTANT CARD ----------------
  Widget _buildVoiceAssistantCard() {
    return GestureDetector(
      onTap: () => context.push(RouteNames.voiceAssistant),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7A2E2A),
              Color(0xFFB5743B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice Sarthi',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ask anything about your medicines and health in your language.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- STATS ROW ----------------
  Widget _buildHealthStats() {
    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        int todayCount = 0;
        int upcomingCount = 0;
        int completedCount = 0;
        if (state is MedicinesLoaded) {
          todayCount = state.medicines.where(_isForToday).length;
          upcomingCount =
              state.medicines.where((m) => m.startDate.isAfter(DateTime.now())).length;
          completedCount = state.medicines.fold(
            0,
                (sum, m) =>
            sum +
                (m.statusHistory?.values
                    .where((s) => s == MedicineStatus.taken)
                    .length ??
                    0),
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.medication,
                count: todayCount.toString(),
                label: 'Today',
                color: MedicineSarthiColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                count: upcomingCount.toString(),
                label: 'Upcoming',
                color: MedicineSarthiColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                count: completedCount.toString(),
                label: 'Completed',
                color: MedicineSarthiColors.primaryLight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: MedicineSarthiColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: MedicineSarthiColors.primaryLight.withOpacity(0.45),
            width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            offset: Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- QUICK ACTIONS ----------------
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': 'Add\nMedicine',
        'color': MedicineSarthiColors.success,
        'route': RouteNames.addMedicine,
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Book\nAppointment',
        'color': MedicineSarthiColors.info,
        'route': RouteNames.addAppointment,
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Seva',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.brown[800],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildLargeActionCard(
                icon: actions[0]['icon'] as IconData,
                label: actions[0]['label'] as String,
                color: actions[0]['color'] as Color,
                onTap: () => context.push(actions[0]['route'] as String).then((_) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<MedicineBloc>().add(
                      LoadMedicinesEvent(userId: authState.user.id),
                    );
                  }
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLargeActionCard(
                icon: actions[1]['icon'] as IconData,
                label: actions[1]['label'] as String,
                color: actions[1]['color'] as Color,
                onTap: () => context.push(actions[1]['route'] as String).then((_) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<MedicineBloc>().add(
                      LoadMedicinesEvent(userId: authState.user.id),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MedicineSarthiColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TODAY'S MEDICINES ----------------
  Widget _buildTodaysMedicines(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, "Today's Medicines", RouteNames.medicines),
        const SizedBox(height: 12),
        BlocBuilder<MedicineBloc, MedicineState>(
          builder: (context, state) {
            if (state is MedicineLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MedicinesLoaded) {
              final todaysMedicines =
              state.medicines.where(_isForToday).take(3).toList();
              if (todaysMedicines.isEmpty) {
                return _buildEmptyState(
                  'No medicines scheduled for today',
                  Icons.medication_outlined,
                );
              }
              return Column(
                children: todaysMedicines
                    .map(
                      (medicine) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MedicineCard(medicine: medicine),
                  ),
                )
                    .toList(),
              );
            }
            return _buildEmptyState(
              'Add your first medicine',
              Icons.add_circle_outline,
            );
          },
        ),
      ],
    );
  }

  // ---------------- VIDEO PREVIEW ----------------
  Widget _buildVideoPreviewCard() {
    final thumbnailUrl = 'https://img.youtube.com/vi/$_videoId/hqdefault.jpg';
    return GestureDetector(
      onTap: () async {
        _ytController.seekTo(const Duration(seconds: 0));
        _ytController.play();
        await showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: Colors.transparent,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: YoutubePlayer(
                    controller: _ytController,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor:
                    MedicineSarthiColors.primaryLight,
                  ),
                ),
              ),
            );
          },
        );
        if (_ytController.value.isPlaying) _ytController.pause();
      },
      child: Container(
        decoration: BoxDecoration(
          color: MedicineSarthiColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MedicineSarthiColors.primaryLight.withOpacity(0.5),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: MedicineSarthiColors.primary.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.play_arrow,
                        size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MedicineSarthiColors.primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '30 SEC',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MedicineSarthiColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Health Pravachan',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See how Medicine Sarthi makes your daily medicine seva easier.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
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
  }

  // ---------------- UPCOMING APPOINTMENTS ----------------
  Widget _buildUpcomingAppointments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
            context, 'Upcoming Appointments', RouteNames.appointments),
        const SizedBox(height: 12),
        _buildEmptyState(
          'No upcoming appointments',
          Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.brown[800],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => context.push(route),
          icon: const Text(
            'View All',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          label: const Icon(Icons.arrow_forward_ios, size: 12),
          style: TextButton.styleFrom(
            foregroundColor: MedicineSarthiColors.primary,
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: MedicineSarthiColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: MedicineSarthiColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.medication, 'Meds', 1),
              _buildVoiceNavItem(),
              _buildNavItem(Icons.calendar_today, 'Appts', 3),
              _buildNavItem(Icons.person, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? MedicineSarthiColors.primary.withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? MedicineSarthiColors.primary
                  : Colors.grey[700],
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? MedicineSarthiColors.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceNavItem() {
    final isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = 2);
        context.push(RouteNames.voiceAssistant).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
              MedicineSarthiColors.primaryLight,
              MedicineSarthiColors.primary,
            ]
                : [
              MedicineSarthiColors.primary,
              MedicineSarthiColors.primaryLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: MedicineSarthiColors.primary.withOpacity(isSelected ? 0.5 : 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}