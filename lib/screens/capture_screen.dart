import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import 'processing_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();

  File? _image;
  String _transcript = '';
  bool _speechReady = false;
  bool _isListening = false;

  final _materialCostController = TextEditingController(text: '300');
  final _laborHoursController = TextEditingController(text: '4');

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => setState(() => _isListening = false),
    );
    setState(() {});
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (photo != null) {
      setState(() => _image = File(photo.path));
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) return;
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      // localeId can be set to a specific Indian language, e.g. 'hi_IN',
      // 'mr_IN', 'ta_IN' — left on device default here so the demo can
      // pick whichever locale is set on the phone.
      onResult: (result) {
        setState(() => _transcript = result.recognizedWords);
      },
    );
  }

  bool get _canContinue => _image != null && _transcript.trim().isNotEmpty;

  @override
  void dispose() {
    _materialCostController.dispose();
    _laborHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel('1. Take a photo of your product'),
          const SizedBox(height: 10),
          _buildPhotoPicker(),
          const SizedBox(height: 28),
          _sectionLabel('2. Describe it in your own voice'),
          const SizedBox(height: 10),
          _buildVoiceRecorder(),
          const SizedBox(height: 28),
          _sectionLabel('3. Your cost (for fair pricing)'),
          const SizedBox(height: 10),
          _buildCostInputs(),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate My Listing'),
            onPressed: _canContinue
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProcessingScreen(
                          imagePath: _image!.path,
                          transcript: _transcript.trim(),
                          materialCost: double.tryParse(_materialCostController.text) ?? 300,
                          laborHours: double.tryParse(_laborHoursController.text) ?? 4,
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.terracotta.withOpacity(0.4), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt_rounded, size: 44, color: AppColors.terracotta),
                  SizedBox(height: 8),
                  Text('Tap to take photo', style: TextStyle(color: AppColors.terracottaDark)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_image!, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: _takePhoto,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVoiceRecorder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _speechReady ? _toggleListening : null,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: _isListening ? AppColors.terracotta : AppColors.indigo,
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isListening
                ? 'Listening... tap to stop'
                : (_speechReady ? 'Tap to record (any language)' : 'Initializing microphone...'),
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 13),
          ),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('"$_transcript"', style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostInputs() {
    return Row(
      children: [
        Expanded(
          child: _numberField(
            controller: _materialCostController,
            label: 'Material cost (₹)',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _numberField(
            controller: _laborHoursController,
            label: 'Hours of work',
          ),
        ),
      ],
    );
  }

  Widget _numberField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
