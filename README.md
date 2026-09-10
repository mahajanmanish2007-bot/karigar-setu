# Karigar Setu — SIH Prototype (PS 26090)

AI-driven market linkage & smart cataloging app for marginalized artisans.
Built as a one-day hackathon prototype — see "What's real vs simulated"
below for an honest breakdown to use when judges ask.

## Get a working APK with zero installs (recommended)

You don't need Flutter, Android Studio, or a laptop dev setup at all.
GitHub's servers build the APK for you — you just upload the code and
download the finished file.

1. Go to [github.com](https://github.com) and sign up / log in (free).
2. Click the **+** icon top-right → **New repository**. Name it anything
   (e.g. `karigar-setu`), keep it Public or Private, don't add a README,
   click **Create repository**.
3. On the new repo's page, click **uploading an existing file**.
4. Unzip `karigar_setu.zip` on your computer/phone file manager first,
   then drag the **contents** of the unzipped folder (the `lib` folder,
   `pubspec.yaml`, `README.md`, and the hidden `.github` folder — make
   sure hidden files show, e.g. `Ctrl+H` on Windows/Linux, `Cmd+Shift+.`
   on Mac) into the GitHub upload box. Commit the files.
5. Click the **Actions** tab at the top of your repo. A workflow called
   "Build APK" should already be running (it starts automatically after
   your upload). Wait 5–8 minutes — Flutter builds are slow the first time.
6. Once it shows a green checkmark, click into that workflow run, scroll
   to **Artifacts**, and download **karigar-setu-apk** (a zip containing
   your `.apk`).
7. Get the `.apk` onto your phone: email it to yourself, upload to Google
   Drive, or send it via WhatsApp/Telegram "Saved Messages" — then open
   it from your phone's file manager or Downloads app.
8. Your phone will warn about "installing from unknown sources" the first
   time — tap **Settings** in that prompt, allow it for that app (Chrome/
   Files/Gmail, whichever you used), then go back and tap **Install**.
9. Open **Karigar Setu** from your app drawer. Grant camera + microphone
   permission when asked.

That's it — no laptop setup, no Flutter install, everything ran in the
cloud. If step 5 shows a red X instead of a checkmark, click into it and
read the error log — the most common cause is a missing file from step 4
(double check the hidden `.github/workflows/build_apk.yml` made it into
the upload).

## Setup (for developers who want to run/edit it on a computer)

1. Make sure Flutter is installed (`flutter doctor` should pass).
2. Copy this whole `karigar_setu/` folder somewhere, then inside it run:
   ```
   flutter create . --platforms=android,ios
   flutter pub get
   ```
   (`flutter create .` fills in the native android/ and ios/ folders this
   zip doesn't include — you only need to do this once.)
3. Add permissions (required for camera + mic):

   **android/app/src/main/AndroidManifest.xml** — inside `<manifest>`, above `<application>`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

   **ios/Runner/Info.plist** — inside the top-level `<dict>`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Used to photograph your product</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>Used to record your voice description</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>Used to transcribe your voice description</string>
   ```

4. **Before you demo**, run the app once on Wi-Fi and trigger the Hindi
   translation model download (call `predownloadHindiModel()` from
   `lib/services/description_service.dart` — easiest is to temporarily
   call it in `main()`, or add a debug button). This downloads a small
   on-device model so translation works fully offline afterwards — do
   this well before you're on stage, not during the demo.

5. Run: `flutter run`

## What's real vs. simulated (be upfront about this with judges)

| Feature | Today's prototype | Production version |
|---|---|---|
| **AI Image Studio** | Real auto-contrast/brightness/saturation correction + vignette, running on-device via the `image` package | Fine-tuned background-removal/segmentation + relighting model |
| **Multilingual Cataloger** | Real on-device speech-to-text + real on-device EN↔HI translation (Google ML Kit, free, offline). Description text is assembled from templates using keyword extraction, not a generative model | Same voice/translation pipeline feeding an LLM (or IndicTrans2 + a fine-tuned generator) for richer, more varied descriptions |
| **Dynamic Pricing** | Real transparent formula: cost input blended with a small hardcoded reference dataset of category price bands | Regression/gradient-boosted model trained on live GeM + e-commerce marketplace data, retrained periodically |
| **Publish to marketplace** | Simulated — shows success state, doesn't call a real API | Real GeM/ONDC seller API integration |
| **Backend/persistence** | In-memory only, resets on app restart | Real backend (auth, product DB, order management) |

Framing this honestly is a strength, not a weakness — a hackathon prototype
that demonstrates the right *interaction design* and a credible upgrade
path tends to land better than one that pretends everything is production-grade.

## Project structure

```
lib/
  main.dart
  theme/app_theme.dart              # colors, button styles, high-contrast UI
  models/product_listing.dart       # data model passed between screens
  data/
    price_reference.dart            # category price bands + category keywords
    description_templates.dart      # material/color keyword lists + templates
    listing_store.dart              # in-memory "database" for the demo
  services/
    image_enhancement_service.dart  # AI Image Studio
    description_service.dart        # Multilingual Auto-Cataloger
    pricing_service.dart            # Dynamic Pricing Assistant
  screens/
    home_screen.dart
    capture_screen.dart
    processing_screen.dart
    listing_preview_screen.dart
```

## Demo script (rehearse this exact flow)

1. Open app → tap **Add New Product**.
2. Take a photo of one prepped item (e.g. a saree or pot).
3. Tap the mic, say something like: *"This is a red cotton saree, handwoven,
   very soft material"* (works in Hindi too).
4. Enter rough material cost and hours worked.
5. Tap **Generate My Listing** → let the processing animation play out.
6. On the preview screen: toggle English/Hindi, show the price slider,
   tap **Publish to Marketplace**.
7. Back on Home, point out the listing now shows as "Live."

## Next steps to mention in your pitch deck

- Swap template descriptions for an LLM call (Claude/GPT/IndicTrans2) once off free-tier constraints
- Real segmentation model for actual background removal (trained on product photo datasets)
- Real pricing model trained on scraped GeM/Amazon Karigar/Etsy listings, retrained periodically
- GeM/ONDC seller API integration for real publishing
- Backend with auth + persistent product/order database
- Offline-first sync queue so artisans in low-connectivity areas can capture now, upload later
