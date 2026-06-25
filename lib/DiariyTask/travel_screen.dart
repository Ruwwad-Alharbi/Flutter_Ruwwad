import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  final List<Map<String, String>> _locations = const [
    {'name': 'Paris', 'place': 'Eiffel Tower', 'description': 'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, France.'},
    {'name': 'Lyon', 'place': 'Notre-Dame de Fourvière', 'description': 'The Basilica of Notre-Dame de Fourvière is a minor basilica in Lyon, France.'},
    {'name': 'Marseille', 'place': 'Old Port of Marseille', 'description': 'The Old Port of Marseille is located at the end of the Canebière.'},
    {'name': 'Toulouse', 'place': 'Cité de l\'Espace', 'description': 'The Cité de l\'Espace is a theme park focused on space and astronautics.'},
    {'name': 'Saudi Arabia', 'place': 'AlUla', 'description': 'AlUla is a city in north-western Saudi Arabia known for its rich history.'},
  ];

  void _showLocationDialog(BuildContext context, Map<String, String> location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            height: 550,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(location['place']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(location['name']!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(location['description']!, style: const TextStyle(fontSize: 14, height: 1.5)),
                        const SizedBox(height: 16),
                        Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('IMAGE PLACEHOLDER'))),
                        const SizedBox(height: 16),
                        Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('MAP IMAGE PLACEHOLDER'))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    String locationName = location['place'] ?? location['name'] ?? 'France';
                    String query = Uri.encodeComponent(locationName);
                    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      final Uri appleUrl = Uri.parse('http://maps.apple.com/?q=$query');
                      if (await canLaunchUrl(appleUrl)) {
                        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Go Now!', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24), child: Text("Popular Locations", style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: Colors.black))),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.orange, size: 30),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showLocationDialog(context, _locations[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}