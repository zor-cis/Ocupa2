import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamMember {
  final String name;
  final String id;
  final String phone;
  final String telegram;
  final String photoAsset;

  TeamMember({
    required this.name,
    required this.id,
    required this.phone,
    required this.telegram,
    required this.photoAsset,
  });
}

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TeamMember> team = [
      TeamMember(
        name: 'Brian Alexander Tavarez Duarte',
        id: '2023-1553',
        phone: '+18295147420',
        telegram: 'https://t.me/briantavarez',
        photoAsset: 'Images/perfilBrian.png',
      ),
      TeamMember(
        name: 'Jean Carlos Mendoza',
        id: '2024-1487',
        phone: '+18294411404',
        telegram: 'https://t.me/Jean_Trader_FX',
        photoAsset: 'Images/Photo.jpg',
      ),
      TeamMember(
        name: 'Nombre Integrante 3',
        id: '2023-XXXX',
        phone: '+18090000003',
        telegram: 'https://t.me/username3',
        photoAsset: 'Images/perfil.png',
      ),
      TeamMember(
        name: 'Nombre Integrante 4',
        id: '2023-XXXX',
        phone: '+18090000004',
        telegram: 'https://t.me/username4',
        photoAsset: 'Images/perfil.png',
      ),
      TeamMember(
        name: 'Nombre Integrante 5',
        id: '2023-XXXX',
        phone: '+18090000005',
        telegram: 'https://t.me/username5',
        photoAsset: 'Images/perfil.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de nosotros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Equipo de Desarrollo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Las mentes creativas detrás de Ocupa2.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: team.length,
              itemBuilder: (context, index) {
                final member = team[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey[200],
                          child: ClipOval(
                            child: Image.asset(
                              member.photoAsset,
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Matrícula: ${member.id}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _ContactButton(
                                    icon: Icons.phone,
                                    color: Colors.green,
                                    onTap: () => _makeCall(member.phone),
                                  ),
                                  const SizedBox(width: 12),
                                  _ContactButton(
                                    icon: Icons.telegram,
                                    color: Colors.blue,
                                    onTap: () => _openTelegram(member.telegram),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2026 Ocupa2 App - Todos los derechos reservados.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      debugPrint('No se pudo lanzar el marcador');
    }
  }

  Future<void> _openTelegram(String telegramLink) async {
    final Uri url = Uri.parse(telegramLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo lanzar Telegram');
    }
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
