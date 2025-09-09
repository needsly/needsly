import 'package:flutter/material.dart';

class ShareAccessButton extends StatelessWidget {
  ShareAccessButton({super.key, required this.onShareAccess});

  final void Function() onShareAccess;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: "Share access",
      onPressed: onShareAccess,
      iconSize: 40.0,
    );
  }
}
