import 'package:flutter/material.dart';

abstract class AddRow extends StatelessWidget {
  AddRow({super.key, required this.onAdd});

  final TextEditingController addSubcategoryController =
      TextEditingController();
  final void Function(TextEditingController) onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: addSubcategoryController,
            decoration: InputDecoration(hintText: 'Add list'),
            onSubmitted: (_) => onAdd,
          ),
        ),
        IconButton(
          onPressed: () => onAdd(addSubcategoryController),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}

class AddCategoryRow extends AddRow {
  AddCategoryRow({required super.onAdd});
}

class AddSubcategoryRow extends AddRow {
  AddSubcategoryRow({required super.onAdd});
}
