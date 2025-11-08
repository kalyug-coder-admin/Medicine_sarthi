import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/medicine_entity.dart';
import '../../../config/theme/app_colors.dart';
import '../../bloc/medicine/medicine_bloc.dart';

class MedicineCard extends StatelessWidget {
  final MedicineEntity medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final status = medicine.statusHistory?[today] ?? MedicineStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatusIcon(status),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosage: ${medicine.dosage}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: medicine.timesOfDay
                        .map((time) => Chip(
                      label: Text(time),
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      labelStyle: const TextStyle(fontSize: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onPressed: status != MedicineStatus.taken
                      ? () => _markAsTaken(context)
                      : null,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  context,
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  onPressed: status != MedicineStatus.missed
                      ? () => _markAsMissed(context)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(MedicineStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case MedicineStatus.taken:
        color = AppColors.medicineTaken;
        icon = Icons.check_circle;
        break;
      case MedicineStatus.missed:
        color = AppColors.medicineMissed;
        icon = Icons.cancel;
        break;
      case MedicineStatus.pending:
        color = AppColors.medicinePending;
        icon = Icons.access_time;
        break;
      case MedicineStatus.skipped:
        color = AppColors.medicineSkipped;
        icon = Icons.remove_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required VoidCallback? onPressed,
      }) {
    return IconButton(
      icon: Icon(icon, size: 28),
      color: color,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  void _markAsTaken(BuildContext context) {
    context.read<MedicineBloc>().add(
      MarkMedicineTakenEvent(
        medicineId: medicine.id,
        voiceEnabled: medicine.voiceReminder,
      ),
    );
  }

  void _markAsMissed(BuildContext context) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    context.read<MedicineBloc>().add(
      UpdateMedicineStatusEvent(
        medicineId: medicine.id,
        date: today,
        status: MedicineStatus.missed,
      ),
    );
  }
}