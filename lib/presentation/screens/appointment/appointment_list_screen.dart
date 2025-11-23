import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/routes/route_names.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/appointment/appointment_bloc.dart';
import '../../widgets/appointment/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  int _selectedIndex = 3; // Appts tab selected

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AppointmentBloc>().add(
        LoadAppointmentsEvent(userId: authState.user.id),
      );
    }
  }

  void _onNavTapped(int index) {
    if (_selectedIndex == index) return;
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
        break;
      case 4:
        context.push(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      appBar: _buildGradientAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addAppointment),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Appointment'),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------- Gradient AppBar ----------------
  PreferredSizeWidget _buildGradientAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
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
      ),
      title: Text(
        'Appointments',
        style: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------------- Body ----------------
  Widget _buildBody() {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          _toast(state.message, AppColors.success);
        } else if (state is AppointmentError) {
          _toast(state.message, AppColors.error);
        }
      },
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AppointmentsLoaded) {
          if (state.appointments.isEmpty) return _emptyState();

          final now = DateTime.now();
          final upcoming = state.appointments
              .where((a) => a.appointmentDate.isAfter(now))
              .toList();
          final past = state.appointments
              .where((a) => a.appointmentDate.isBefore(now))
              .toList();

          return RefreshIndicator(
            onRefresh: () async => _loadAppointments(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  _sectionHeader("Upcoming"),
                  const SizedBox(height: 12),
                  ...upcoming.map((a) => _buildDismissible(a)),
                ],
                if (past.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Past", faded: true),
                  const SizedBox(height: 12),
                  ...past.map((a) => _buildCard(a, isPast: true)),
                ],
              ],
            ),
          );
        }

        return _emptyState();
      },
    );
  }

  // ---------------- Premium Section Header ----------------
  Widget _sectionHeader(String title, {bool faded = false}) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: faded ? Colors.grey : Colors.brown[800],
      ),
    );
  }

  // ---------------- Premium Card Wrapper ----------------
  Widget _buildCard(appointment, {bool isPast = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8B878).withOpacity(0.55),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppointmentCard(appointment: appointment, isPast: isPast),
    );
  }

  // ---------------- Dismissible Wrapper ----------------
  Widget _buildDismissible(appointment) {
    return Dismissible(
      key: Key(appointment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Appointment'),
            content: const Text('Are you sure you want to delete this appointment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<AppointmentBloc>().add(
          DeleteAppointmentEvent(appointmentId: appointment.id),
        );
      },
      child: _buildCard(appointment),
    );
  }

  // ---------------- Empty State ----------------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No appointments scheduled',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(RouteNames.addAppointment),
            icon: const Icon(Icons.add),
            label: const Text('Add Appointment'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ---------------- SnackBar ----------------
  void _toast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  // ---------------- Footer Navigation ----------------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
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
              _navItem(Icons.home, 'Home', 0),
              _navItem(Icons.medication, 'Meds', 1),
              _navMic(),
              _navItem(Icons.calendar_today, 'Appts', 3),
              _navItem(Icons.person, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = index == _selectedIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _onNavTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 22,
                color: isSelected ? AppColors.primary : Colors.grey[700]),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navMic() {
    return GestureDetector(
      onTap: () => _onNavTapped(2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7A2E2A), Color(0xFFD8B878)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 24),
      ),
    );
  }
}
