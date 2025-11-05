import 'package:flutter/material.dart';
import 'package:needsly/views/charts/stats.dart';

class SubcategoryRowButtons extends StatelessWidget {
  SubcategoryRowButtons({
    super.key,
    required this.context,
    required this.category,
    required this.subcategory,
    required this.onRename,
    required this.onRemove,
    required this.onCopy,
  });

  final String category;
  final String subcategory;
  final BuildContext context;
  final void Function(String, String) onRename;
  final void Function(String) onRemove;
  final void Function(String) onCopy;

  void withRenameSubcategoryDialogue() {
    final TextEditingController renameController = TextEditingController(
      text: subcategory,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename subcategory'),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(hintText: 'Enter new subcategory name'),
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
                final toSubcategory = renameController.text.trim();
                // comes from outside
                onRename(subcategory, toSubcategory);
                renameController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Widget withActionsPopup() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Rename',
          child: Text('Rename'),
          onTap: () => withRenameSubcategoryDialogue(),
        ),
        PopupMenuItem(
          value: 'Delete',
          child: Text('Delete'),
          onTap: () => onRemove(subcategory),
        ),
        PopupMenuItem(
          value: 'Show stats',
          child: Text('Show stats'),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return StatsPage(
                    category: category,
                    subcategory: subcategory,
                  );
                },
              ),
            ),
          },
        ),
        PopupMenuItem(
          value: 'Copy list',
          child: Text('Copy list'),
          onTap: () => onCopy(subcategory),
        ),
      ],
      child: IconButton(
        icon: Icon(Icons.menu_open_rounded),
        onPressed: null,
        tooltip: 'Actions',
        iconSize: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [withActionsPopup()]);
  }
}
