import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _keyController = TextEditingController();

  static const _apiKeyStorageKey = 'llm_api_key';

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final k = await _storage.read(key: _apiKeyStorageKey);
    if (k != null) _keyController.text = k;
  }

  Future<void> _saveKey() async {
    await _storage.write(key: _apiKeyStorageKey, value: _keyController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved to secure storage')));
  }

  Future<void> _clearKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
    _keyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key cleared')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('LLM / API settings (users paste their own keys here)') ,
            const SizedBox(height:12),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(labelText: 'API Key', border: OutlineInputBorder()),
              obscureText: true,
              maxLines: 1,
            ),
            const SizedBox(height:12),
            Row(
              children: [
                ElevatedButton(onPressed: _saveKey, child: const Text('Save')),
                const SizedBox(width:12),
                OutlinedButton(onPressed: _clearKey, child: const Text('Clear')),
              ],
            ),
            const SizedBox(height:18),
            const Text('Tip: do NOT share long-lived keys publicly. Each user should paste their own key.'),
          ],
        ),
      ),
    );
  }
}
