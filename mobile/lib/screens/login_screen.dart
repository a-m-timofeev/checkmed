import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка входа. Попробуйте еще раз.'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.medical_services,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Drug Interaction Checker',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Проверьте совместимость ваших лекарств',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 64),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.login),
                label: const Text('Войти через Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Гостевой режим'),
                      content: const Text(
                        'В гостевом режиме доступны ограниченные функции:\n\n'
                        '• Только 1 проверка в день\n'
                        '• История не сохраняется\n'
                        '• Нет синхронизации между устройствами\n\n'
                        'Рекомендуем войти через Google для полного доступа.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacementNamed('/main');
                          },
                          child: const Text('Продолжить'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Продолжить как гость'),
              ),
              const SizedBox(height: 32),
              Text(
                'Продолжая, вы соглашаетесь с нашей Политикой конфиденциальности',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}