import 'package:flutter/material.dart';

class ModifyCategoryRow extends StatelessWidget {
  ModifyCategoryRow({
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
      text: this.category,
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
        ),
        IconButton(icon: Icon(Icons.delete), onPressed: () => onRemove(index)),
      ],
    );
  }
}