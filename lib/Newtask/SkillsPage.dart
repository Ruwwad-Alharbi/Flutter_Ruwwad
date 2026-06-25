import 'package:flutter/material.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final List<Map<String, dynamic>> skills = [
    {
      'type': 'Digital Skills',
      'items': [
        {'name': 'Web Development', 'description': 'Build websites and web apps'},
        {'name': 'Mobile Development', 'description': 'Build iOS and Android apps'},
        {'name': 'UI/UX Design', 'description': 'Design user interfaces'},
      ],
    },
    {
      'type': 'Design Skills',
      'items': [
        {'name': 'Graphic Design', 'description': 'Create visual content'},
        {'name': '3D Modeling', 'description': 'Create 3D objects and scenes'},
        {'name': 'Animation', 'description': 'Create motion graphics'},
      ],
    },
    {
      'type': 'Creative Skills',
      'items': [
        {'name': 'Photography', 'description': 'Capture stunning images with professional techniques'},
        {'name': 'Video Editing', 'description': 'Edit and produce high-quality videos'},
        {'name': 'Music Production', 'description': 'Create and produce music tracks'},
      ],
    },
  ];

  void _showSkillDialog(int typeIndex, int itemIndex) {
    final skill = skills[typeIndex]['items'][itemIndex];
    int currentIndex = itemIndex;
    int maxIndex = skills[typeIndex]['items'].length - 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentSkill = skills[typeIndex]['items'][currentIndex];
            return AlertDialog(
              title: Text(currentSkill['name']),
              content: Text(currentSkill['description']),
              actions: [
                if (currentIndex < maxIndex)
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        currentIndex++;
                      });
                    },
                    child: const Text('Next'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: skills.length,
      itemBuilder: (context, typeIndex) {
        final type = skills[typeIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                type['type'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...type['items'].asMap().entries.map((entry) {
              int itemIndex = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(item['name']),
                onTap: () {
                  _showSkillDialog(typeIndex, itemIndex);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }
}