import 'package:flutter/material.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:provider/provider.dart';

class SharedProjectSettingsPage extends StatefulWidget {
  final String projectName;

  const SharedProjectSettingsPage({super.key, required this.projectName});

  @override
  State<SharedProjectSettingsPage> createState() =>
      _SharedProjectSettingsPageState(projectName: projectName);
}

class _SharedProjectSettingsPageState extends State<SharedProjectSettingsPage> {
  final String projectName;
  late TextEditingController _apiKeyController;
  late TextEditingController _appIdController;
  late TextEditingController _senderIdController;
  late TextEditingController _projectIdController;

  _SharedProjectSettingsPageState({required this.projectName});

  SharedPreferencesRepository get prefs =>
      Provider.of<SharedPreferencesRepository>(context, listen: false);

  @override
  void initState() {
    super.initState();

    prefs.loadFirebaseProjectCreds(projectName).then((creds) {
      _projectIdController = TextEditingController(text: creds.projectId);
      _apiKeyController = TextEditingController(text: creds.apiKey);
      _appIdController = TextEditingController(text: creds.appId);
      _senderIdController = TextEditingController(
        text: creds.messagingSenderId,
      );
    });
  }

  @override
  void dispose() {
    _projectIdController.dispose();
    _apiKeyController.dispose();
    _appIdController.dispose();
    _senderIdController.dispose();
    super.dispose();
  }

  void _save() {
    final projectId = _projectIdController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final appId = _appIdController.text.trim();
    final messagingSenderId = _senderIdController.text.trim();
    prefs.updateFirebaseProjectCreds(
      projectName,
      apiKey,
      appId,
      projectId,
      messagingSenderId,
    );
  }

  Widget getProjectName() {
    return Text(
      widget.projectName,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: _save, child: const Text("Save")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getProjectName(),
        const SizedBox(height: 20),
        TextField(
          controller: _projectIdController,
          decoration: const InputDecoration(labelText: "Project Id"),
        ),
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(labelText: "API Key"),
        ),
        TextField(
          controller: _appIdController,
          decoration: const InputDecoration(labelText: "App ID"),
        ),
        TextField(
          controller: _senderIdController,
          decoration: const InputDecoration(labelText: "Messaging Sender ID"),
        ),
        const Spacer(),
        saveButton(),
      ],
    );
  }
}
