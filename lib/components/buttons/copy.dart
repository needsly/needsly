import 'package:flutter/material.dart';

class CopyInnerStructureButton extends StatelessWidget {
  CopyInnerStructureButton({super.key, required this.onCopy});

  final void Function() onCopy;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy),
      tooltip: 'Copy',
      iconSize: 40,
      onPressed: onCopy,
    );
  }
}
