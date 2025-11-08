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

  Widget withActionsPopup() {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Delete',
          child: Text('Delete'),
          onTap: () => onRemove(index),
        ),
        PopupMenuItem(
          value: 'Show stats',
          child: Text('Show stats'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return StatsPage(category: 'firebase.$sharedProject');
              },
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Open Firebase project settings',
          child: Text('Open Firebase project settings'),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SharedProjectSettingsPage(projectName: sharedProject);
                },
              ),
            ),
          },
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
