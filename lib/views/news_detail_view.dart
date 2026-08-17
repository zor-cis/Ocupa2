import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final news = ModalRoute.of(context)?.settings.arguments as NewsItem?;

    if (news == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Noticia')),
        body: const Center(child: Text('No se pudo cargar la noticia')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Noticia'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.image != null)
              Image.network(
                news.image!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.article_outlined, size: 80, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        news.date != null
                            ? DateFormat('dd/MM/yyyy').format(news.date!)
                            : 'Fecha no disponible',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (news.source != null) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.source, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          news.source!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    news.summary,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: 17,
                        ),
                  ),
                  const SizedBox(height: 40),
                  if (news.url != null)
                    ElevatedButton.icon(
                      onPressed: () => _launchURL(news.url!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Leer noticia completa'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir el enlace: $url');
    }
  }
}
