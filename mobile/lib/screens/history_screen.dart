import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/check_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final checkProvider = Provider.of<CheckProvider>(context, listen: false);
    await checkProvider.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История проверок'),
      ),
      body: Consumer<CheckProvider>(
        builder: (context, provider, child) {
          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'История пуста',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ваши проверки появятся здесь',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                final result = provider.history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(result),
                      child: Icon(
                        _getStatusIcon(result),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(result.summary ?? 'Проверка'),
                    subtitle: Text(
                      'ID: ${result.jobId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Show full result
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(result) {
    final categories = result.categories;
    if (categories != null && categories.danger.isNotEmpty) {
      return Colors.red;
    } else if (categories != null && categories.caution.isNotEmpty) {
      return Colors.orange;
    }
    return Colors.green;
  }

  IconData _getStatusIcon(result) {
    final categories = result.categories;
    if (categories != null && categories.danger.isNotEmpty) {
      return Icons.warning;
    } else if (categories != null && categories.caution.isNotEmpty) {
      return Icons.info;
    }
    return Icons.check;
  }
}