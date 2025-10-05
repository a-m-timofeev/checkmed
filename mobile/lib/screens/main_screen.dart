import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../providers/check_provider.dart';
import '../models/medication.dart';
import '../widgets/medication_list_item.dart';
import '../widgets/add_medication_dialog.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
    await medicationProvider.loadMedications();
  }

  Future<void> _addMedication() async {
    final medication = await showDialog<Medication>(
      context: context,
      builder: (context) => const AddMedicationDialog(),
    );

    if (medication != null) {
      final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
      final success = await medicationProvider.addMedication(medication);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Лекарство добавлено' : 'Ошибка добавления'),
          ),
        );
      }
    }
  }

  Future<void> _checkInteractions() async {
    final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
    
    if (medicationProvider.medications.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте минимум 2 лекарства для проверки'),
        ),
      );
      return;
    }

    final checkProvider = Provider.of<CheckProvider>(context, listen: false);
    final success = await checkProvider.startCheck(medicationProvider.medications);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamed('/check-result');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка запуска проверки. Возможно, вы превысили лимит запросов.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои лекарства'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).pushNamed('/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет добавленных лекарств',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите + чтобы добавить',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadMedications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.medications.length,
                    itemBuilder: (context, index) {
                      return MedicationListItem(
                        medication: provider.medications[index],
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Удалить лекарство?'),
                              content: const Text('Это действие нельзя отменить'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && mounted) {
                            await provider.deleteMedication(provider.medications[index].id!);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              if (provider.medications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkInteractions,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Проверить взаимодействия'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        child: const Icon(Icons.add),
      ),
    );
  }
}