# Fakturino

A mobile application for managing invoices.

## Features
- Create and save invoices with details like invoice number, contractor name, amounts, and VAT rate
- Attach PDFs or images to invoices
- View a list of all saved invoices
- Search through invoices
- Preview attached documents

## Setup Instructions

### App Icon Setup
For maximum consistency across Android and iOS platforms, you should provide two versions of your app icon:

1. Standard icon (for iOS and older Android versions):
   - Place your app icon PNG file in `assets/icon/icon.png`
   - Recommended size: 1024x1024 pixels
   - Should include padding (have some empty space around the logo)

2. Adaptive icon (for modern Android devices):
   - Place your app icon PNG file in `assets/icon/icon_adaptive.png`
   - Recommended size: 1024x1024 pixels
   - Should fill the entire canvas (no padding)
   - Will be automatically masked by Android to fit device requirements

3. Run the following command to generate the app icons for both Android and iOS:
   ```
   flutter pub run flutter_launcher_icons
   ```

### Dependencies
- Flutter
- Riverpod for state management
- Isar for local database
- File picker for attachments
- Syncfusion PDF viewer for document preview
- Flutter Launcher Icons for app icon generation

## Getting Started
1. Run `flutter pub get` to install dependencies
2. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate Isar code
3. Run the app with `flutter run`

## Screens
- Home Screen: Create new invoices
- Invoices List Screen: View and search all saved invoices