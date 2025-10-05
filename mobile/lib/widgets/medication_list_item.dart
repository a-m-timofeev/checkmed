import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationListItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onDelete;

  const MedicationListItem({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.medication,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          medication.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (medication.dose != null && medication.unit != null)
              Text('${medication.dose} ${medication.unit}'),
            if (medication.frequency != null)
              Text('Частота: ${medication.frequency}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}