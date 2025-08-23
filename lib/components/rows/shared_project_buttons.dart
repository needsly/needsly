import 'package:flutter/material.dart';
import 'package:needsly/components/rows/category_row_buttons.dart';
import 'package:needsly/views/charts/stats.dart';
import 'package:needsly/views/shared_project_settings.dart';

class SharedProjectButtons extends StatelessWidget {
  SharedProjectButtons({
    super.key,
    required this.context,
    required this.sharedProject,
    required this.index,
    required this.onRename,
    required this.onRemove,
  });

  final String sharedProject;
  final int index;
  final BuildContext context;
  final void Function(int, String) onRename;
  final void Function(int) onRemove;

  CategoryRowButtons get categoryRowButtons => CategoryRowButtons(
    context: context,
    category: sharedProject,
    index: index,
    onRename: onRename,
    onRemove: onRemove,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => categoryRowButtons.withRenameCategoryDialogue(),
        ),
        IconButton(icon: Icon(Icons.delete), onPressed: () => onRemove(index)),
        IconButton(
          icon: Icon(Icons.auto_graph),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return StatsPage(category: sharedProject);
                },
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SharedProjectSettingsPage(projectName: sharedProject);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
