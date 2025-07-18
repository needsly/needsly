import 'package:flutter/material.dart';

class AddCategoryRow extends StatelessWidget {
  AddCategoryRow({super.key, required this.onAdd});

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
            decoration: InputDecoration(hintText: 'Add category'),
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
