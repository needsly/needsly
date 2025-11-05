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

  Widget showActionsPopup() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Rename',
          child: Text('Rename'),
          onTap: () => withRenameCategoryDialogue(),
        ),
        PopupMenuItem(
          value: 'Delete',
          child: Text('Delete'),
          onTap: () => onRemove(index),
        ),
        PopupMenuItem(
          value: 'Show stats',
          child: Text('Show stats'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return StatsPage(category: category);
              },
            ),
          ),
        ),
      ],
      child: IconButton(
        icon: Icon(Icons.arrow_circle_down_rounded),
        onPressed: null,
        tooltip: 'Actions',
        iconSize: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        showActionsPopup(),
        ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_handle),
        ),
      ],
    );
  }
}
