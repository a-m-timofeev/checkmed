import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/check_provider.dart';
import '../models/check_result.dart';
import '../widgets/interaction_card.dart';
import 'dart:async';

class CheckResultScreen extends StatefulWidget {
  const CheckResultScreen({super.key});

  @override
  State<CheckResultScreen> createState() => _CheckResultScreenState();
}

class _CheckResultScreenState extends State<CheckResultScreen> {
  Timer? _pollingTimer;
  InterstitialAd? _interstitialAd;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _adLoaded = true;
          
          // Show ad after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (_adLoaded && mounted) {
              _interstitialAd?.show();
            }
          });
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final checkProvider = Provider.of<CheckProvider>(context, listen: false);
      final result = await checkProvider.pollResult();
      
      if (result != null || !checkProvider.isChecking) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты проверки'),
      ),
      body: Consumer<CheckProvider>(
        builder: (context, provider, child) {
          if (provider.isChecking) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Анализируем взаимодействия...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Это может занять несколько секунд',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final result = provider.currentResult;
          if (result == null || result.categories == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Ошибка получения результатов'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Вернуться'),
                  ),
                ],
              ),
            );
          }

          return _buildResults(result);
        },
      ),
    );
  }

  Widget _buildResults(CheckResult result) {
    final categories = result.categories!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disclaimer
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Это информационный отчёт. Он не заменяет консультацию врача.',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          if (result.summary != null) ...[
            Text(
              'Резюме',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(result.summary!),
            const SizedBox(height: 24),
          ],

          // Danger interactions
          if (categories.danger.isNotEmpty) ...[
            _buildSectionHeader('Опасно', Colors.red, categories.danger.length),
            const SizedBox(height: 12),
            ...categories.danger.map((interaction) => InteractionCard(
                  interaction: interaction,
                  color: Colors.red,
                )),
            const SizedBox(height: 24),
          ],

          // Caution interactions
          if (categories.caution.isNotEmpty) ...[
            _buildSectionHeader('С осторожностью', Colors.orange, categories.caution.length),
            const SizedBox(height: 12),
            ...categories.caution.map((interaction) => InteractionCard(
                  interaction: interaction,
                  color: Colors.orange,
                )),
            const SizedBox(height: 24),
          ],

          // Safe/Recommendations
          if (categories.recommendation.isNotEmpty) ...[
            _buildSectionHeader('Рекомендации', Colors.green, categories.recommendation.length),
            const SizedBox(height: 12),
            ...categories.recommendation.map((interaction) => InteractionCard(
                  interaction: interaction,
                  color: Colors.green,
                )),
            const SizedBox(height: 24),
          ],

          // Confidence score
          if (result.confidenceScore != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined),
                    const SizedBox(width: 12),
                    Text(
                      'Достоверность: ${(result.confidenceScore! * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Share functionality
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Поделиться'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Готово'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}