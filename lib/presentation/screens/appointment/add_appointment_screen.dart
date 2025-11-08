import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/appointment/appointment_bloc.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _appointmentDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _appointmentTime = const TimeOfDay(hour: 10, minute: 0);
  bool _reminderSet = true;

  @override
  void dispose() {
    _doctorNameController.dispose();
    _specializationController.dispose();
    _hospitalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _appointmentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _appointmentDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _appointmentTime,
    );
    if (time != null) {
      setState(() {
        _appointmentTime = time;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final appointment = AppointmentEntity(
        id: const Uuid().v4(),
        userId: authState.user.id,
        doctorName: _doctorNameController.text.trim(),
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        hospital: _hospitalController.text.trim(),
        appointmentDate: _appointmentDate,
        appointmentTime: _appointmentTime.format(context),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        reminderSet: _reminderSet,
        createdAt: DateTime.now(),
      );

      context.read<AppointmentBloc>().add(
            AddAppointmentEvent(appointment: appointment),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Appointment'),
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _doctorNameController,
                  label: 'Doctor Name',
                  hint: 'e.g., Dr. John Smith',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _specializationController,
                  label: 'Specialization (Optional)',
                  hint: 'e.g., Cardiologist, Neurologist',
                  prefixIcon: Icons.medical_services_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _hospitalController,
                  label: 'Hospital/Clinic',
                  hint: 'e.g., City Hospital',
                  prefixIcon: Icons.local_hospital_outlined,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter hospital name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Date',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${_appointmentDate.day}/${_appointmentDate.month}/${_appointmentDate.year}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _appointmentTime.format(context),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'e.g., Regular checkup, Follow-up',
                  prefixIcon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Set Reminder'),
                  subtitle: const Text('Notify 1 hour before appointment'),
                  value: _reminderSet,
                  onChanged: (value) {
                    setState(() {
                      _reminderSet = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Save Appointment',
                  onPressed: _handleSave,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
