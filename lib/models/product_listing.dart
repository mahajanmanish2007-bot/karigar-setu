class ProductListing {
  final String imagePath;
  final String rawTranscript;
  final String category;
  final String titleEnglish;
  final String descriptionEnglish;
  final String descriptionHindi;
  final double suggestedPriceLow;
  final double suggestedPriceHigh;
  double finalPrice;
  bool published;

  ProductListing({
    required this.imagePath,
    required this.rawTranscript,
    required this.category,
    required this.titleEnglish,
    required this.descriptionEnglish,
    required this.descriptionHindi,
    required this.suggestedPriceLow,
    required this.suggestedPriceHigh,
    double? finalPrice,
    this.published = false,
  }) : finalPrice = finalPrice ?? ((suggestedPriceLow + suggestedPriceHigh) / 2);
}
