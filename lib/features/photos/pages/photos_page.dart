import 'package:flutter/material.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  int _selectedAlbum = 0;

  final _albums = const [
    'All Photos',
    'vs. Riverside FC',
    'Practice Mar 25',
    'Spring 2026',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _albums.length,
              itemBuilder: (_, i) {
                final isActive = i == _selectedAlbum;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAlbum = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF1A56DB)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _albums[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 21,
              itemBuilder: (_, i) => _PhotoTile(index: i),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final int index;
  const _PhotoTile({required this.index});

  static const _colors = [
    Color(0xFF1A56DB), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFF8B5CF6), Color(0xFFEF4444), Color(0xFF0EA5E9),
    Color(0xFFF97316), Color(0xFF14B8A6), Color(0xFF6366F1),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      color: color.withOpacity(0.15),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Icon(Icons.image_outlined, color: color.withOpacity(0.4), size: 32),
          if (index == 0 || index == 5)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('NEW',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
