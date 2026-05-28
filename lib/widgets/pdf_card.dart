import 'package:flutter/material.dart';

class PDFCard extends StatelessWidget {
  final String title;
  final String filePath;
  final DateTime updatedAt;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final Function(String) onMenuSelected;

  const PDFCard({
    super.key,
    required this.title,
    required this.filePath,
    required this.updatedAt,
    required this.onOpen,
    required this.onDelete,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Updated: ${updatedAt.toLocal()}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: onMenuSelected,
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Share',
                          child: Text('Share'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
