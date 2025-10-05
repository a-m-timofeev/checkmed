import 'package:flutter/material.dart';
import '../models/medication.dart';

class AddMedicationDialog extends StatefulWidget {
  const AddMedicationDialog({super.key});

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  String _selectedUnit = 'mg';
  String _selectedFrequency = 'once_daily';
  String _selectedRoute = 'oral';

  final List<String> _units = ['mg', 'g', 'ml', 'mcg', 'IU'];
  final List<String> _frequencies = [
    'once_daily',
    'twice_daily',
    'three_times_daily',
    'as_needed',
  ];
  final List<String> _routes = ['oral', 'topical', 'injection', 'inhaled'];

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        unit: _selectedUnit,
        frequency: _selectedFrequency,
        route: _selectedRoute,
      );
      Navigator.of(context).pop(medication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить лекарство'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название лекарства',
                  hintText: 'Например: Аспирин',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _doseController,
                      decoration: const InputDecoration(
                        labelText: 'Дозировка',
                        hintText: '100',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Единицы',
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Частота приёма',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'once_daily',
                    child: Text('1 раз в день'),
                  ),
                  DropdownMenuItem(
                    value: 'twice_daily',
                    child: Text('2 раза в день'),
                  ),
                  DropdownMenuItem(
                    value: 'three_times_daily',
                    child: Text('3 раза в день'),
                  ),
                  DropdownMenuItem(
                    value: 'as_needed',
                    child: Text('По необходимости'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRoute,
                decoration: const InputDecoration(
                  labelText: 'Способ приёма',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'oral',
                    child: Text('Перорально'),
                  ),
                  DropdownMenuItem(
                    value: 'topical',
                    child: Text('Наружно'),
                  ),
                  DropdownMenuItem(
                    value: 'injection',
                    child: Text('Инъекция'),
                  ),
                  DropdownMenuItem(
                    value: 'inhaled',
                    child: Text('Ингаляция'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRoute = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}