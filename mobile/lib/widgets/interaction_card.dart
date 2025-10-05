import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/check_result.dart';

class InteractionCard extends StatefulWidget {
  final DrugInteraction interaction;
  final Color color;

  const InteractionCard({
    super.key,
    required this.interaction,
    required this.color,
  });

  @override
  State<InteractionCard> createState() => _InteractionCardState();
}

class _InteractionCardState extends State<InteractionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.color.withOpacity(0.1),
              child: Icon(
                _getIcon(),
                color: widget.color,
              ),
            ),
            title: Text(
              widget.interaction.meds.join(' + '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.interaction.shortSummary),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.interaction.mechanism.isNotEmpty) ...[
                    Text(
                      'Механизм взаимодействия',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.interaction.mechanism),
                    const SizedBox(height: 16),
                  ],
                  
                  if (widget.interaction.symptomsToMonitor.isNotEmpty) ...[
                    Text(
                      'Симптомы для контроля',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.interaction.symptomsToMonitor.map((symptom) {
                        return Chip(
                          label: Text(symptom),
                          backgroundColor: widget.color.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (widget.interaction.suggestedAction.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: widget.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Рекомендуемое действие',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(widget.interaction.suggestedAction),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Call doctor button for danger category
                  if (widget.interaction.category == 'danger') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Emergency number (example)
                          final uri = Uri.parse('tel:112');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Позвонить врачу'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  
                  // Confidence indicator
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Достоверность: ${(widget.interaction.confidence * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.interaction.category) {
      case 'danger':
        return Icons.warning;
      case 'caution':
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}