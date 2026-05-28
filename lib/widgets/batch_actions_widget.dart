import 'package:flutter/material.dart';

class BatchActionsWidget extends StatelessWidget {
  final VoidCallback onClearSelection;
  final VoidCallback onDeleteSelectedNotes;
  final VoidCallback onShareSelectedNotes;
  final VoidCallback? onClose;

  const BatchActionsWidget({
    super.key,
    required this.onClearSelection,
    required this.onDeleteSelectedNotes,
    required this.onShareSelectedNotes,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDeleteSelectedNotes,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: onShareSelectedNotes,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              onClearSelection();
              if (onClose != null) {
                onClose!();
              }
            },
          ),
        ],
      ),
    );
  }
}
