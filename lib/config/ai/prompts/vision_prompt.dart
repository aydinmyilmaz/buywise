class VisionPrompt {
  static const String analyzeProduct = '''
Analyze this product image and extract information.

EXTRACT:
1. Product name/type (be specific, e.g., "Dyson Airwrap Complete")
2. Brand (if visible or recognizable)
3. Category (choose ONE):
   - Beauty & Self-care
   - Fashion & Accessories
   - Tech & Gadgets
   - Home & Living
   - Health & Fitness
   - Hobbies & Entertainment
   - Travel & Experiences
   - Food & Dining
   - Other
4. Quality tier: budget / midrange / premium / luxury
5. Key features you can identify
6. Estimated price range (if you can tell)

RESPOND WITH THIS EXACT JSON:
{
  "productName": "Full product name",
  "brand": "Brand name" | null,
  "category": "Category from list above",
  "qualityTier": "budget" | "midrange" | "premium" | "luxury",
  "features": ["feature 1", "feature 2"],
  "estimatedPrice": {"min": 0, "max": 0, "currency": "USD"} | null,
  "confidence": 0.0 to 1.0
}
''';
}
