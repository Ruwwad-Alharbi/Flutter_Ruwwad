import 'package:flutter/material.dart';

class PhotosPage extends StatelessWidget {
  const PhotosPage({super.key});

  final List<Map<String, dynamic>> photos = const [
    {
      'id': 1,
      'title': 'Boat Scene',
      'imagePath': 'assets/images/boat.jpg.jpg',
      'visits': 120,
      'popularity': 85,
    },
    {
      'id': 2,
      'title': 'Majestic Tiger',
      'imagePath': 'assets/images/tiger.jpg.jpg',
      'visits': 95,
      'popularity': 70,
    },
    {
      'id': 3,
      'title': 'Mountain View',
      'imagePath': 'assets/images/mountain.jpg.jpg',
      'visits': 200,
      'popularity': 90,
    },
    {
      'id': 4,
      'title': 'Beautiful Flower',
      'imagePath': 'assets/images/flower.jpg.jpg',
      'visits': 150,
      'popularity': 78,
    },
    {
      'id': 5,
      'title': 'Cute Cat',
      'imagePath': 'assets/images/cat.jpg.jpg',
      'visits': 80,
      'popularity': 65,
    },
    {
      'id': 6,
      'title': 'Nature Walk',
      'imagePath': 'assets/images/nature.jpg.jpg',
      'visits': 300,
      'popularity': 95,
    },
  ];

  void _showFullScreenPhoto(BuildContext context, Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Image.asset(
                    photo['imagePath'],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareMenu(BuildContext context, Map<String, dynamic> photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share this photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share this photo'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing: ${photo['title']}')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          onTap: () {
            _showFullScreenPhoto(context, photo);
          },
          onLongPress: () {
            _showShareMenu(context, photo);
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset(
                    photo['imagePath'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 14),
                          const SizedBox(width: 4),
                          Text('${photo['visits']}'),
                          const SizedBox(width: 12),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${photo['popularity']}%'),
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
    );
  }
}