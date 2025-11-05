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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => onRename(subcategory, itemIdx),
          tooltip: 'Rename',
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => onRemove(subcategory, itemIdx),
          tooltip: 'Delete',
        ),
        IconButton(
          icon: Icon(Icons.done),
          onPressed: () => onResolve(subcategory, itemIdx),
          tooltip: 'Mark as done',
        ),
      ],
    );
  }
}
