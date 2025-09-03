import 'package:flutter/material.dart';
import 'package:needsly/auth/google/google_signin.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/shared_project_buttons.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';
import 'package:needsly/views/shared/shared_project_settings.dart';
import 'package:provider/provider.dart';

class SharedProjectsPage extends StatefulWidget {
  const SharedProjectsPage({super.key});

  @override
  State<StatefulWidget> createState() => SharedProjectsPageState();
}

class SharedProjectsPageState extends State<SharedProjectsPage> {
  // TODO: move to global constants
  final _sharedProjectsPrefix = 'needsly.firebase.projects';
  final List<String> sharedProjects = [];

  final TextEditingController addSharedProjectController =
      TextEditingController();

  void showNewProjectSettingsDialog(String projectName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog.fullscreen(
          child: SharedProjectSettingsPage(projectName: projectName),
        );
      },
    );
  }

  void onAddSharedProject(TextEditingController controller) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final text = controller.text.trim();
    if (sharedProjects.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Option already exists!')));
    } else if (text.isNotEmpty) {
      showNewProjectSettingsDialog(text);
      setState(() {
        sharedProjects.add(text);
        controller.clear();
      });
      prefs.saveCategories(_sharedProjectsPrefix, sharedProjects);
    }
  }

  void onRemoveSharedProject(int idx) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    setState(() {
      sharedProjects.removeAt(idx);
    });
    prefs.removeCategory(_sharedProjectsPrefix, idx);
  }

  void onReorderSharedProjects(int oldIdx, int newIdx) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final reorderedSharedProjects = reorderList(sharedProjects, oldIdx, newIdx);
    setState(() {
      sharedProjects.setAll(0, reorderedSharedProjects);
    });
    prefsRepo.saveCategories(_sharedProjectsPrefix, reorderedSharedProjects);
  }

  @override
  void initState() {
    super.initState();
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    loadSharedProjectsFromStorage(prefsRepo);
  }

  void loadSharedProjectsFromStorage(SharedPreferencesRepository prefs) {
    prefs.loadCategories(_sharedProjectsPrefix).then((projects) {
      setState(() {
        sharedProjects.addAll(projects.isNotEmpty ? projects : []);
      });
      for (var project in projects) {
        prefs.loadFirebaseProjectOptions(project).then((creds) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shared projects')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 12),
            AddListRow(
              onAdd: onAddSharedProject,
              hintText: 'Add shared project',
            ),
            SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: sharedProjects.length,
                itemBuilder: (_, idx) => ListTile(
                  key: Key(sharedProjects[idx]),
                  title: Text(sharedProjects[idx]),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) {
                          return getGoogleSignInPage(sharedProjects[idx]);
                        },
                      ),
                    );
                  },
                  trailing: SharedProjectButtons(
                    context: context,
                    sharedProject: sharedProjects[idx],
                    index: idx,
                    onRemove: onRemoveSharedProject,
                  ),
                ),
                onReorder: (oldIdx, newIdx) =>
                    onReorderSharedProjects(oldIdx, newIdx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
