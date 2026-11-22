import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class NameDialog extends StatefulWidget {
  final ValueChanged<String> onSave;
  final VoidCallback onSkip;

  const NameDialog({super.key, required this.onSave, required this.onSkip});

  @override
  State<NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("Halo!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text("Siapa namamu?"),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _controller,
            placeholder: "Nama kamu",
            placeholderStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: widget.onSkip,
          child: const Text("Lewati"),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onSave(_controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}

class EditProfileSheet extends StatefulWidget {
  final bool isDark;
  final String currentName;
  final ValueChanged<String> onSave;

  const EditProfileSheet({
    super.key,
    required this.isDark,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentName == UserProfile.defaultName ? '' : widget.currentName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _error = "Nama tidak boleh kosong");
    } else if (trimmed.length < 2) {
      setState(() => _error = "Minimal 2 karakter");
    } else if (trimmed.length > 30) {
      setState(() => _error = "Maksimal 30 karakter");
    } else {
      widget.onSave(trimmed);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final secondaryTextColor = widget.isDark ? Colors.grey[400] : Colors.grey[600];
    final sheetBg = widget.isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Edit Nama Profil",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _controller,
            placeholder: "Nama baru",
            placeholderStyle: TextStyle(color: secondaryTextColor),
            style: TextStyle(color: textColor),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: _validate,
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
