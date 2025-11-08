import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MedicineBloc>().add(
        LoadMedicinesEvent(userId: authState.user.id),
      );
    }
  }

  List<MedicineEntity> _filterMedicines(List<MedicineEntity> medicines) {
    if (_selectedFilter == null) return medicines;

    final today = DateTime.now().toIso8601String().split('T')[0];
    return medicines.where((medicine) {
      final status = medicine.statusHistory?[today] ?? MedicineStatus.pending;
      return status == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
        actions: [
          PopupMenuButton<MedicineStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Medicines'),
              ),
              const PopupMenuItem(
                value: MedicineStatus.pending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: MedicineStatus.taken,
                child: Text('Taken'),
              ),
              const PopupMenuItem(
                value: MedicineStatus.missed,
                child: Text('Missed'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is MedicineActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is MedicineError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MedicineLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MedicinesLoaded) {
            final filteredMedicines = _filterMedicines(state.medicines);

            if (filteredMedicines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _selectedFilter == null
                          ? 'No medicines added yet'
                          : 'No ${_selectedFilter.toString().split('.').last} medicines',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.addMedicine),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medicine'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadMedicines();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = filteredMedicines[index];
                  return Dismissible(
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
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Medicine'),
                          content: Text(
                            'Are you sure you want to delete ${medicine.name}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      context.read<MedicineBloc>().add(
                        DeleteMedicineEvent(medicineId: medicine.id),
                      );
                    },
                    child: MedicineCard(medicine: medicine),
                  );
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                Text(
                  'Add your first medicine',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push(RouteNames.addMedicine),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medicine'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.addMedicine),
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}