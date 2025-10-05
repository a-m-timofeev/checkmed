import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, 'Аккаунт'),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(authProvider.user?.name ?? 'Пользователь'),
                subtitle: Text(authProvider.user?.email ?? ''),
                trailing: authProvider.user?.isPremium == true
                    ? Chip(
                        label: const Text('Premium'),
                        backgroundColor: Colors.amber.shade100,
                      )
                    : null,
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user?.isPremium == true) {
                return ListTile(
                  leading: Icon(Icons.star, color: Colors.amber.shade700),
                  title: const Text('Премиум подписка'),
                  subtitle: const Text('Активна'),
                  trailing: Chip(
                    label: const Text('Premium'),
                    backgroundColor: Colors.amber.shade100,
                  ),
                );
              }
              
              return ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Премиум подписка'),
                subtitle: const Text('Без рекламы, больше проверок'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Премиум подписка'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Преимущества Premium:'),
                          SizedBox(height: 12),
                          Text('• Без рекламы'),
                          Text('• 100 проверок в день'),
                          Text('• Приоритетная поддержка'),
                          Text('• Расширенные отчёты'),
                          SizedBox(height: 12),
                          Text('Цена: 299₽/месяц'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Функция в разработке'),
                              ),
                            );
                          },
                          child: const Text('Подписаться'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const Divider(),

          // Privacy section
          _buildSectionHeader(context, 'Конфиденциальность'),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Политика конфиденциальности'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final url = Uri.parse('https://druginteractionchecker.com/privacy');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Невозможно открыть ссылку'),
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Экспорт данных'),
            subtitle: const Text('Скачать все ваши данные'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Экспорт данных...'),
                    ],
                  ),
                ),
              );

              try {
                // Call API to export data
                final response = await http.post(
                  Uri.parse('${ApiService.baseUrl}/user/export-data'),
                  headers: {
                    'Authorization': 'Bearer ${await _getToken()}',
                  },
                );

                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog

                  if (response.statusCode == 200) {
                    // Show export data
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Экспорт данных'),
                        content: SingleChildScrollView(
                          child: Text(response.body),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Закрыть'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ошибка экспорта данных'),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Удалить аккаунт'),
            subtitle: const Text('Это действие нельзя отменить'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Удалить аккаунт?'),
                  content: const Text(
                    'Все ваши данные будут удалены без возможности восстановления. '
                    'Это действие нельзя отменить.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Удаление аккаунта...'),
                      ],
                    ),
                  ),
                );

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('access_token');
                  
                  final response = await http.delete(
                    Uri.parse('${ApiService.baseUrl}/user/account'),
                    headers: {'Authorization': 'Bearer $token'},
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Close loading

                    if (response.statusCode == 200) {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.signOut();
                      
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Аккаунт успешно удалён'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ошибка удаления аккаунта'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  }
                }
              }
            },
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, 'О приложении'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Версия'),
            trailing: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Помощь и поддержка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support@druginteractionchecker.com',
                query: 'subject=Поддержка Drug Interaction Checker',
              );
              
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email: support@druginteractionchecker.com'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
          ),

          const Divider(),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выйти?'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}