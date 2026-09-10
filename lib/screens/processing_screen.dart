import 'package:flutter/material.dart';
import '../models/product_listing.dart';
import '../services/description_service.dart';
import '../services/image_enhancement_service.dart';
import '../services/pricing_service.dart';
import '../theme/app_theme.dart';
import 'listing_preview_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String transcript;
  final double materialCost;
  final double laborHours;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.transcript,
    required this.materialCost,
    required this.laborHours,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingStep {
  final String label;
  bool done = false;
  _ProcessingStep(this.label);
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final List<_ProcessingStep> _steps = [
    _ProcessingStep('Enhancing photo lighting & clarity'),
    _ProcessingStep('Understanding your voice note'),
    _ProcessingStep('Translating to English & Hindi'),
    _ProcessingStep('Calculating a fair price'),
  ];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // Step 1: real image enhancement
    final enhancedPath = await ImageEnhancementService.enhance(widget.imagePath);
    await _markDone(0);

    // Step 2 + 3: real description generation + translation
    final generated = await DescriptionService.generate(widget.transcript);
    await _markDone(1);
    await _markDone(2);

    // Step 4: real pricing formula
    final price = PricingService.suggest(
      category: generated.category,
      materialCost: widget.materialCost,
      laborHours: widget.laborHours,
    );
    await _markDone(3);

    if (!mounted) return;

    final listing = ProductListing(
      imagePath: enhancedPath,
      rawTranscript: widget.transcript,
      category: generated.category,
      titleEnglish: generated.titleEnglish,
      descriptionEnglish: generated.descriptionEnglish,
      descriptionHindi: generated.descriptionHindi,
      suggestedPriceLow: price.low,
      suggestedPriceHigh: price.high,
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ListingPreviewScreen(
          listing: listing,
          priceExplanation: price.explanation,
        ),
      ),
    );
  }

  Future<void> _markDone(int index) async {
    // Minimum dwell time per step so the pipeline reads clearly on stage,
    // even though the underlying work often finishes faster.
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _steps[index].done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 28),
              const Text(
                'Your virtual business manager is at work',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 28),
              ..._steps.map(_buildStepRow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(_ProcessingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            step.done ? Icons.check_circle : Icons.circle_outlined,
            color: step.done ? AppColors.gold : Colors.white54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.label,
              style: TextStyle(
                color: step.done ? Colors.white : Colors.white70,
                fontWeight: step.done ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
