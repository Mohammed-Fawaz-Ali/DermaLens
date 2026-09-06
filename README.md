# Dermalens - Skin Health Assistant

An on-device AI powered mobile application for skin disease awareness, education, and support.

## Features

### 🔬 AI Skin Analysis
- On-device machine learning model for skin condition screening
- Privacy-first: all image processing happens locally on your device
- Provides educational insights about potential skin conditions

### 💬 Health Chatbot
- Conversational assistant to help understand symptoms
- Provides general information about skin conditions and care
- Suggests when to consult a healthcare professional

### 🛒 Medicine Store
- Browse skin care products categorized by concern
- Learn about ingredients and usage
- Find products relevant to your skin care needs

### 👨‍⚕️ Doctor Finder
- Locate dermatologists and skin care professionals
- View profiles, specialties, and contact information
- Book appointments (feature in development)

### 📋 Diagnosis History
- Track your skin analysis history
- Review past results and add notes
- Export or share information with healthcare providers

### ⚠️ Educational Focus
- Clear disclaimers that this app is for educational purposes only
- Not a substitute for professional medical diagnosis or treatment
- Encourages users to consult healthcare providers for medical advice

## Privacy First
All image processing for skin analysis occurs entirely on your device. No images or personal data are sent to external servers without your explicit consent.

## Getting Started

### Prerequisites
- Flutter SDK (version 3.13.2 or higher)
- Android Studio / Xcode (for mobile deployment)
- Physical device or emulator/simulator

### Installation
1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Connect a device or start an emulator
4. Run `flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY`

The Gemini key is intentionally not stored in Git. Provide it through
`GEMINI_API_KEY` when running or building the app:

```powershell
flutter build apk --release --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

### Important Notes About the AI Model
This project includes two model files in the `assets/models/` directory:
1. `skin_efficientnet_b4.onnx` - ONNX format model (used by the onnxruntime package)
2. `best_efficientnet_b4.pth` - PyTorch format model (provided by you)

**Important:** The `onnxruntime` Flutter package only works with ONNX format models. If you wish to use your `.pth` model, you will need to convert it to ONNX format first using tools like:
- `torch.onnx.export()` in PyTorch
- ONNX converter tools

Once converted, replace the `skin_efficientnet_b4.onnx` file with your converted model.

## Project Structure
- `lib/main.dart` - App entry point
- `lib/models.dart` - Data models
- `lib/data/catalog.dart` - Disease and product information
- `lib/services/` - Business logic (AI, chatbot, etc.)
- `lib/screens/` - UI screens
- `lib/widgets/` - Reusable components
- `assets/models/` - AI models (ONNX and PyTorch formats)

## Important Disclaimer

**DERMALENS IS FOR EDUCATIONAL PURPOSES ONLY.** 
This application does not provide medical diagnosis, treatment, or professional healthcare advice. 
The AI analysis and chatbot are intended to increase awareness and understanding of skin health topics. 
Always consult with a qualified healthcare professional for medical concerns, diagnosis, or treatment.

## Acknowledgments
- Disease information adapted from educational dermatology resources
- Product information for reference purposes only
- Built with Flutter and ONNX Runtime for on-device machine learning

## Version 2.0.0 (In Development)
- Planned features for next release

## Store Database Setup

The store can load products from Supabase and falls back to the bundled catalog
when database configuration is missing or unavailable.

1. Create a project at https://supabase.com.
2. Open **SQL Editor** and run `docs/supabase_products.sql`.
3. Open **Storage**, create a public bucket named `product-images`.
4. Upload the product images from `assets/products/` to that bucket.
5. Replace `YOUR_PROJECT` in the SQL image URLs with your Supabase project ID,
   then run the insert section again, or edit `image_url` in the Table Editor.
6. Copy the project URL and anon key from **Project Settings > API**.
7. Run the app with:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

For a release build:

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

Only the Supabase anon key belongs in the app. Never put a Supabase service-role
key or Gemini key in source control.
