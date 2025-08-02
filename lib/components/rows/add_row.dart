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

class AddItemRow extends StatelessWidget {
  AddItemRow({super.key, required this.subcategory, required this.onAdd});

  final void Function(String, TextEditingController) onAdd;
  final String subcategory;
  final Map<String, TextEditingController> addItemsControllerBySubcategory = {};

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    addItemsControllerBySubcategory[subcategory] = controller;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Add item'),
            onSubmitted: (_) => onAdd(subcategory, controller),
          ),
        ),
        IconButton(
          onPressed: () => onAdd(subcategory, controller),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
