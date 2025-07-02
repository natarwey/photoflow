import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool initialDarkMode;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.initialDarkMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Как получить другую идею рандомной съемки?',
      answer:
          'Перезапустите приложение или немного подождите на странице (идея меняется каждые 3 минуты).',
    ),
    FAQItem(
      question: 'Как добавить фото в портфолио?',
      answer:
          'В разделе "Мое портфолио" нажмите кнопку "+" и выберите фото для загрузки.',
    ),
    FAQItem(
      question: 'Как связаться с фотографом?',
      answer:
          'На странице профиля фотографа перейдите по ссылке на социальную сеть фотографа.',
    ),
  ];

  Future<void> _contactSupport(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'natarwey.basharova@yandex.ru',
      queryParameters: {
        'subject': 'Поддержка PhotoFlow',
        'body': 'Опишите вашу проблему:',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      final String encodedSubject = Uri.encodeComponent('Поддержка PhotoFlow');
      final String encodedBody = Uri.encodeComponent('Опишите вашу проблему:');
      final Uri webUri = Uri.parse(
        'https://mail.yandex.ru/?compose&to=natarwey.basharova@yandex.ru&subject=$encodedSubject&body=$encodedBody',
      );

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть почту или браузер')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Переключатель темы
            // const Text(
            //   'Тема приложения',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text('Темная тема'),
            //     Switch(
            //       value: _isDarkMode,
            //       onChanged: (value) {
            //         setState(() {
            //           _isDarkMode = value;
            //         });
            //       },
            //       activeColor: Colors.blue,
            //     ),
            //   ],
            // ),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Частые вопросы',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  return FAQWidget(faq: _faqs[index]);
                },
              ),
            ),

            // Кнопка поддержки
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _contactSupport(context),
                icon: const Icon(Icons.email),
                label: const Text('Связаться с поддержкой'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class FAQWidget extends StatefulWidget {
  final FAQItem faq;

  const FAQWidget({super.key, required this.faq});

  @override
  State<FAQWidget> createState() => _FAQWidgetState();
}

class _FAQWidgetState extends State<FAQWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.faq.question,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.faq.answer),
            ),
        ],
      ),
    );
  }
}
