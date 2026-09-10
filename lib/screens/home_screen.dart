import 'dart:io';
import 'package:flutter/material.dart';
import '../data/listing_store.dart';
import '../models/product_listing.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karigar Setu'),
        actions: [
          IconButton(
            tooltip: 'हिंदी / English',
            icon: const Icon(Icons.translate),
            onPressed: () {}, // language toggle stub for the demo
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ProductListing>>(
        valueListenable: ListingStore.instance.listings,
        builder: (context, listings, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, listings.length)),
              if (listings.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ListingCard(listing: listings[listings.length - 1 - i]),
                      childCount: listings.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_a_photo_rounded, size: 26),
            label: const Text('Add New Product'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CaptureScreen()),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.terracotta,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'नमस्ते, कारीगर 👋',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Digital Shop',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(icon: Icons.storefront_rounded, label: '$count products live'),
              const SizedBox(width: 10),
              const _StatChip(icon: Icons.trending_up_rounded, label: 'Year-round sales'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 72, color: AppColors.terracottaDark),
          const SizedBox(height: 16),
          const Text(
            'No products yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add New Product" below, take a photo, and describe it '
            'in your own language. We\'ll handle the rest.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ProductListing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Image.file(
              File(listing.imagePath),
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 96,
                height: 96,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.titleEnglish,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('₹${listing.finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppColors.terracottaDark, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        listing.published ? Icons.check_circle : Icons.schedule,
                        size: 14,
                        color: listing.published ? AppColors.success : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.published ? 'Live on marketplace' : 'Draft',
                        style: TextStyle(
                          fontSize: 12,
                          color: listing.published ? AppColors.success : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
