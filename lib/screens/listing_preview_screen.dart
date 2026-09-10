import 'dart:io';
import 'package:flutter/material.dart';
import '../data/listing_store.dart';
import '../models/product_listing.dart';
import '../theme/app_theme.dart';
import 'landing_page_screen.dart';
import 'settings_screen.dart';
import '../services/landing_page_service.dart';

class ListingPreviewScreen extends StatefulWidget {
  final ProductListing listing;
  final String priceExplanation;

  const ListingPreviewScreen({
    super.key,
    required this.listing,
    required this.priceExplanation,
  });

  @override
  State<ListingPreviewScreen> createState() => _ListingPreviewScreenState();
}

class _ListingPreviewScreenState extends State<ListingPreviewScreen> {
  bool _showHindi = false;
  late double _price;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _price = widget.listing.finalPrice;
  }

  void _publish() {
    widget.listing.finalPrice = _price;
    widget.listing.published = true;
    ListingStore.instance.add(widget.listing);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Published!'),
          ],
        ),
        content: const Text(
          'Your product is now live on the digital marketplace and visible '
          'to buyers year-round — not just during the next mela.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to My Shop'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateLandingPage() async {
    setState(() => _generating = true);
    widget.listing.finalPrice = _price;
    try {
      final result = await LandingPageService.generateLandingPage(widget.listing);
      final html = result['html']!;
      // Open preview
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => LandingPageScreen(htmlContent: html, filePath: result['path'])));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate landing page: $e')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Listing'),
        actions: [
          IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(listing.imagePath),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          const _AiTag(label: 'AI-enhanced photo'),
          const SizedBox(height: 20),
          Text(listing.titleEnglish, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _buildLanguageToggle(),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _showHindi ? listing.descriptionHindi : listing.descriptionEnglish,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Suggested Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            '₹${listing.suggestedPriceLow.toStringAsFixed(0)} – ₹${listing.suggestedPriceHigh.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 15, color: AppColors.terracottaDark, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(widget.priceExplanation, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.55))),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Final price: ₹', style: TextStyle(fontWeight: FontWeight.w700)),
                  Expanded(
                    child: Slider(
                      value: _price.clamp(listing.suggestedPriceLow * 0.7, listing.suggestedPriceHigh * 1.3),
                      min: listing.suggestedPriceLow * 0.7,
                      max: listing.suggestedPriceHigh * 1.3,
                      activeColor: AppColors.terracotta,
                      onChanged: (v) => setState(() => _price = v),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      _price.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: _generating ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.web),
            label: const Text('Generate Landing Page'),
            onPressed: _generating ? null : _generateLandingPage,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('Publish to Marketplace'),
            onPressed: _publish,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Simulated GeM / ONDC listing for demo purposes',
              style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('English')),
        ButtonSegment(value: true, label: Text('हिंदी')),
      ],
      selected: {_showHindi},
      onSelectionChanged: (s) => setState(() => _showHindi = s.first),
    );
  }
}
