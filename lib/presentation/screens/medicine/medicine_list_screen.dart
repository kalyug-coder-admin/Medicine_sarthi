// FULL MedicineListScreen.dart — Themed with Dawarikar colors, gradient AppBar,
// premium carved cards, Home footer, and no slide animation.
//
// Note: your uploaded image path (if you need it): /mnt/data/Home_screen.jpg
// Use your pipeline to convert it to file:// or http:// when needed.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/routes/route_names.dart';
import '../../../domain/entities/medicine_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../widgets/medicine/medicine_card.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  MedicineStatus? _selectedFilter;
  int _selectedIndex = 1; // Meds tab active

  // If you want to show uploaded header image:
  static const String headerImageLocalPath = '/mnt/data/Home_screen.jpg';

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<MedicineBloc>().add(
        LoadMedicinesEvent(userId: auth.user.id),
      );
    }
  }

  List<MedicineEntity> _filterMedicines(List<MedicineEntity> list) {
    if (_selectedFilter == null) return list;
    final today = DateTime.now().toIso8601String().split('T')[0];

    return list.where((m) {
      final s = m.statusHistory?[today] ?? MedicineStatus.pending;
      return s == _selectedFilter;
    }).toList();
  }

  void _onNavTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.push(RouteNames.home);
        break;
      case 1:
      // already on medicines
        break;
      case 2:
        context.push(RouteNames.voiceAssistant);
        break;
      case 3:
        context.push(RouteNames.appointments);
        break;
      case 4:
        context.push(RouteNames.profile);
        break;
    }
  }

  Future<void> _onRefresh() async {
    _loadMedicines();
    // ensure RefreshIndicator is visible for a short time
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      appBar: _buildGradientAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addMedicine),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
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
        'My Medicines',
        style: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        PopupMenuButton<MedicineStatus?>(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onSelected: (v) => setState(() => _selectedFilter = v),
          itemBuilder: (context) => [
            _menu('All Medicines', null),
            _menu('Pending', MedicineStatus.pending),
            _menu('Taken', MedicineStatus.taken),
            _menu('Missed', MedicineStatus.missed),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<MedicineStatus?> _menu(String text, MedicineStatus? v) {
    return PopupMenuItem(
      value: v,
      child: Text(text, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }

  // ---------------- Body ----------------
  Widget _buildBody() {
    return BlocConsumer<MedicineBloc, MedicineState>(
      listener: (context, state) {
        if (state is MedicineActionSuccess) _showSnack(state.message, AppColors.success);
        if (state is MedicineError) _showSnack(state.message, AppColors.error);
      },
      builder: (context, state) {
        if (state is MedicineLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MedicinesLoaded) {
          final meds = _filterMedicines(state.medicines);
          if (meds.isEmpty) return _emptyState();

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meds.length,
              itemBuilder: (context, i) {
                final medicine = meds[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Dismissible(
                    key: Key(medicine.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Medicine'),
                          content: Text('Are you sure you want to delete ${medicine.name}?'),
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
                      return result ?? false;
                    },
                    onDismissed: (direction) {
                      context.read<MedicineBloc>().add(DeleteMedicineEvent(medicineId: medicine.id));
                    },
                    child: _buildPremiumCard(medicine),
                  ),
                );
              },
            ),
          );
        }

        // default empty
        return _emptyState();
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No medicines found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => context.push(RouteNames.addMedicine),
            icon: const Icon(Icons.add),
            label: Text('Add Medicine', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ---------------- Premium Card wrapper ----------------
  Widget _buildPremiumCard(MedicineEntity medicine) {
    return Container(
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
      child: MedicineCard(medicine: medicine),
    );
  }

  // ---------------- Snack helper ----------------
  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: bg,
      ),
    );
  }

  // ---------------- Bottom Navigation (Home style) ----------------
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
      onTap: () => _onNavTapped(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[700], size: 22),
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

  Widget _buildVoiceNavItem() {
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
