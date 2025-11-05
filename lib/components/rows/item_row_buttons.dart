import 'package:flutter/material.dart';

class ItemRowButtons extends StatelessWidget {
  ItemRowButtons({
    super.key,
    required this.subcategory,
    required this.itemIdx,
    required this.onRename,
    required this.onRemove,
    required this.onResolve,
  });

  final String subcategory;
  final int itemIdx;
  final void Function(String, int) onRename;
  final void Function(String, int) onRemove;
  final void Function(String, int) onResolve;

  Widget withActionsPopup() {
    return PopupMenuButton(
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'Rename',
          child: Text('Rename'),
          onTap: () => onRename(subcategory, itemIdx),
        ),
        PopupMenuItem(
          value: 'Delete',
          child: Text('Delete'),
          onTap: () => onRemove(subcategory, itemIdx),
        ),
        PopupMenuItem(
          value: 'Mark as done',
          child: Text('Mark as done'),
          onTap: () => onResolve(subcategory, itemIdx),
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
