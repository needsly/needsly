import 'package:flutter/material.dart';
import 'package:needsly/components/rows/category_row_buttons.dart';
import 'package:needsly/views/charts/stats.dart';
import 'package:needsly/views/shared/shared_project_settings.dart';

class SharedProjectButtons extends StatelessWidget {
  SharedProjectButtons({
    super.key,
    required this.context,
    required this.sharedProject,
    required this.index,
    required this.onRemove,
  });

  final String sharedProject;
  final int index;
  final BuildContext context;
  final void Function(int) onRemove;

  CategoryRowButtons get categoryRowButtons => CategoryRowButtons(
    context: context,
    category: sharedProject,
    index: index,
    onRename: (int _, String _) => {},
    onRemove: onRemove,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          tooltip: 'Show stats',
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
          tooltip: 'Open Firebase project Settings',
        ),
      ],
    );
  }
}
