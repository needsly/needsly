import 'package:flutter/material.dart';

class AddListRow extends StatelessWidget {
  AddListRow({super.key, required this.onAdd, required this.hintText});

  final String hintText;
  final TextEditingController addController = TextEditingController();
  final void Function(TextEditingController) onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            textInputAction: TextInputAction.done,
            controller: addController,
            decoration: InputDecoration(hintText: hintText),
            onSubmitted: (_) => onAdd(addController),
          ),
        ),
        IconButton(
          onPressed: () => onAdd(addController),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
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
