import 'package:flutter/material.dart';
import 'package:needsly/views/charts/stats.dart';

class CategoryRowButtons extends StatelessWidget {
  CategoryRowButtons({
    super.key,
    required this.context,
    required this.category,
    required this.index,
    required this.onRename,
    required this.onRemove,
  });

  final String category;
  final int index;
  final BuildContext context;
  final void Function(int, String) onRename;
  final void Function(int) onRemove;

  void withRenameCategoryDialogue() {
    final TextEditingController renameController = TextEditingController(
      text: category,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Category'),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onRename(index, renameController.text.trim());
                Navigator.of(context).pop();
                renameController.clear();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => withRenameCategoryDialogue(),
          tooltip: 'Rename',
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => onRemove(index),
          tooltip: 'Delete',
        ),
        IconButton(
          icon: Icon(Icons.auto_graph),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return StatsPage(category: category);
                },
              ),
            );
          },
          tooltip: 'Show stats',
        ),
        ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_handle),
        ),
      ],
    );
  }
}
