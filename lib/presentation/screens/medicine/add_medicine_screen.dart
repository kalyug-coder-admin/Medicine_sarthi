import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/medicine_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  Frequency _selectedFrequency = Frequency.daily;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  bool _voiceReminder = true;
  bool _notificationEnabled = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTimes.add(time);
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
    });
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one time'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final medicine = MedicineEntity(
        id: const Uuid().v4(),
        userId: authState.user.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        timesOfDay: _selectedTimes
            .map((t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
            .toList(),
        startDate: _startDate,
        endDate: _endDate,
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        voiceReminder: _voiceReminder,
        notificationEnabled: _notificationEnabled,
        createdAt: DateTime.now(),
      );

      context.read<MedicineBloc>().add(AddMedicineEvent(medicine: medicine));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: BlocListener<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is MedicineActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is MedicineError) {
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
                  controller: _nameController,
                  label: 'Medicine Name',
                  hint: 'e.g., Aspirin, Metformin',
                  prefixIcon: Icons.medication,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _dosageController,
                  label: 'Dosage',
                  hint: 'e.g., 500mg, 1 tablet',
                  prefixIcon: Icons.local_pharmacy,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter dosage';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Frequency',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Frequency>(
                  value: _selectedFrequency,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: Frequency.daily, child: Text('Once Daily')),
                    DropdownMenuItem(
                        value: Frequency.twiceDaily, child: Text('Twice Daily')),
                    DropdownMenuItem(
                        value: Frequency.threeTimesDaily,
                        child: Text('Three Times Daily')),
                    DropdownMenuItem(
                        value: Frequency.weekly, child: Text('Weekly')),
                    DropdownMenuItem(
                        value: Frequency.asNeeded, child: Text('As Needed')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Times Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Times',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    TextButton.icon(
                      onPressed: _addTime,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTimes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final time = entry.value;
                    return Chip(
                      label: Text(time.format(context)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: _selectedTimes.length > 1
                          ? () => _removeTime(index)
                          : null,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Start & End Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectStartDate,
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
                                  Text(
                                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
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
                            'End Date (Optional)',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectEndDate,
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
                                  Text(
                                    _endDate == null
                                        ? 'Select'
                                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
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
                  controller: _instructionsController,
                  label: 'Instructions (Optional)',
                  hint: 'e.g., Take with food, after meals',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                SwitchListTile(
                  title: const Text('Voice Reminder'),
                  subtitle: const Text('Speak medicine name when due'),
                  value: _voiceReminder,
                  onChanged: (value) {
                    setState(() {
                      _voiceReminder = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                SwitchListTile(
                  title: const Text('Notification'),
                  subtitle: const Text('Send push notification'),
                  value: _notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Save Medicine',
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
