// ProfileScreen.dart — Premium Header, Dawarikar Theme, Footer (Profile tab = 4)
// Uploaded image path (if needed): /mnt/data/Home_screen.jpg

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/routes/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/auth/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4; // Profile tab active

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.push(RouteNames.home);
        break;
      case 1:
        context.push(RouteNames.medicines);
        break;
      case 2:
        context.push(RouteNames.voiceAssistant);
        break;
      case 3:
        context.push(RouteNames.appointments);
        break;
      case 4:
      // already here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final UserEntity user = state.user;

          return CustomScrollView(
            slivers: [
              _buildPremiumHeader(user),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildQuickStats(user),
                    const SizedBox(height: 18),
                    _buildInfoSection(user),
                    const SizedBox(height: 18),
                    _buildSettingsSection(user),
                    const SizedBox(height: 18),
                    _buildSignOut(context),
                    const SizedBox(height: 36),
                  ],
                ),
              )
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------- Premium Gradient Header ----------------
  SliverAppBar _buildPremiumHeader(UserEntity user) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.transparent,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 58,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildUserRoleTag(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserRoleTag(UserEntity user) {
    final bool isElderly = user.role == UserRole.elderly;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isElderly ? Icons.elderly : Icons.family_restroom,
              color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            isElderly ? 'Elderly User' : 'Family Member',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Stats Row ----------------
  Widget _buildQuickStats(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              'Age',
              '${user.age}',
              Icons.calendar_today,
              const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              'Gender',
              user.gender,
              user.gender.toLowerCase() == 'male' ? Icons.male : Icons.female,
              const Color(0xFF1565C0),
            ),
          ),
          if (user.bloodGroup != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Blood',
                user.bloodGroup!,
                Icons.bloodtype,
                const Color(0xFFB91C1C),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8B878), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Contact / Info Section ----------------
  Widget _buildInfoSection(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (user.emergencyContact != null)
            _infoCard(
              'Emergency Contact',
              user.emergencyContact!,
              Icons.phone_in_talk,
              const Color(0xFF2E7D32),
            ),
          const SizedBox(height: 12),
          _infoCard(
            'Email',
            user.email,
            Icons.email_outlined,
            const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8B878), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800]),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
          )
        ],
      ),
    );
  }

  // ---------------- Settings Section ----------------
  Widget _buildSettingsSection(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings & More', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD8B878), width: 1.3),
            boxShadow: [
              BoxShadow(color: Colors.brown.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              _menuItem(
                icon: Icons.medical_information_outlined,
                title: 'Medical History',
                subtitle: 'View your medical records',
                color: const Color(0xFF8B5CF6),
                onTap: () => context.push(RouteNames.medicalHistory),
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification settings',
                color: const Color(0xFFF59E0B),
                onTap: () => context.push(RouteNames.notifications),
              ),
              if (user.role == UserRole.elderly) ...[
                _menuDivider(),
                _menuItem(
                  icon: Icons.family_restroom_outlined,
                  title: 'Family Members',
                  subtitle: 'Manage linked family accounts',
                  color: const Color(0xFF06B6D4),
                  onTap: () => context.push(RouteNames.familyMembers),
                ),
              ],
              _menuDivider(),
              _menuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                color: const Color(0xFF10B981),
                onTap: () => context.push(RouteNames.help),
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                color: const Color(0xFF6B7280),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Health Companion',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.medication, size: 48, color: AppColors.primary),
                    children: const [
                      Text('A comprehensive medicine reminder and health companion app for elderly users.')
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
              ]),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ]),
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  // ---------------- Sign Out ----------------
  Widget _buildSignOut(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Sign Out', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
                content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700])),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AuthBloc>().add(SignOutEvent());
                      context.go(RouteNames.login);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withOpacity(0.18)),
              boxShadow: [BoxShadow(color: AppColors.error.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Sign Out', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }

  // ---------------- Bottom Navigation (Home style) ----------------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _navItem(Icons.home, 'Home', 0),
            _navItem(Icons.medication, 'Meds', 1),
            _navMic(),
            _navItem(Icons.calendar_today, 'Appts', 3),
            _navItem(Icons.person, 'Profile', 4),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = index == _selectedIndex;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onNavTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.10) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: isSelected ? AppColors.primary : Colors.grey[700]),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.primary : Colors.grey[700])),
        ]),
      ),
    );
  }

  Widget _navMic() {
    return GestureDetector(
      onTap: () => _onNavTapped(2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7A2E2A), Color(0xFFD8B878)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 24),
      ),
    );
  }
}
