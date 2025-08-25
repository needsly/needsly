import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needsly/auth/login.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/category_row_buttons.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';
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
      return;
    } else if (text.isNotEmpty) {
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

  void onRenameSharedProject(int idx, String toProjectName) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final fromProjectName = sharedProjects[idx];
    setState(() {
      sharedProjects[idx] = toProjectName;
    });
    prefsRepo.saveCategories(_sharedProjectsPrefix, sharedProjects);
    prefsRepo.renameCategory(
      _sharedProjectsPrefix,
      idx,
      fromProjectName,
      toProjectName,
    );
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
        prefs.loadFirebaseProjectCreds(project).then((creds) {
          
        });
        
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
            AddCategoryRow(onAdd: onAddSharedProject),
            SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: sharedProjects.length,
                itemBuilder: (_, idx) => ListTile(
                  key: Key(sharedProjects[idx]),
                  title: Text(sharedProjects[idx]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Center(child: Text(sharedProjects[idx]));
                          // return SubcategoriesPage(
                          //   category: sharedProjects[index],
                          // );
                        },
                      ),
                    );
                  },
                  trailing: CategoryRowButtons(
                    context: context,
                    category: sharedProjects[idx],
                    index: idx,
                    onRename: onRenameSharedProject,
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
