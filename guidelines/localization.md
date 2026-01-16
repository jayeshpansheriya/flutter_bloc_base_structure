# Flutter Localization Guide

## 📚 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Quick Start](#quick-start)
4. [Adding New Translations](#adding-new-translations)
5. [Using Translations in Code](#using-translations-in-code)
6. [Adding New Languages](#adding-new-languages)
7. [Changing Language Programmatically](#changing-language-programmatically)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## Overview

This project uses Flutter's official localization system with ARB (Application Resource Bundle) files for managing translations. The implementation follows the project's BLoC architecture pattern with `LanguageCubit` for state management.

### Technology Stack

- **`flutter_localizations`**: Official Flutter localization support
- **`intl`**: Internationalization and formatting utilities
- **ARB files**: JSON-based translation files
- **`LanguageCubit`**: BLoC-based language state management
- **`SharedPreferencesService`**: Persistent language preference storage

### Supported Languages

- 🇬🇧 **English** (`en`) - Default
- 🇮🇳 **Hindi** (`hi`)
- 🇪🇸 **Spanish** (`es`)

---

## Architecture

### Directory Structure

```
lib/
├── core/
│   ├── localization/
│   │   ├── l10n/                          # ARB files & generated code
│   │   │   ├── app_en.arb                 # English translations (template)
│   │   │   ├── app_hi.arb                 # Hindi translations
│   │   │   ├── app_es.arb                 # Spanish translations
│   │   │   ├── app_localizations.dart     # Generated (DO NOT EDIT)
│   │   │   ├── app_localizations_en.dart  # Generated (DO NOT EDIT)
│   │   │   ├── app_localizations_hi.dart  # Generated (DO NOT EDIT)
│   │   │   └── app_localizations_es.dart  # Generated (DO NOT EDIT)
│   │   ├── models/
│   │   │   └── language_model.dart        # Language metadata
│   │   └── cubit/
│   │       ├── language_cubit.dart        # Language state management
│   │       └── language_state.dart        # Language state
│   └── storage/
│       └── locale_preferences_service.dart # Locale persistence
└── app.dart                                # Localization integration
```

### Components

#### 1. **ARB Files** (`lib/core/localization/l10n/*.arb`)
- JSON-based translation files
- `app_en.arb` is the template file
- Other language files mirror the template structure

#### 2. **LanguageModel** (`lib/core/localization/models/language_model.dart`)
- Defines supported languages
- Provides helper methods for language lookup

#### 3. **LocalePreferencesService** (`lib/core/storage/locale_preferences_service.dart`)
- Persists language preference using `SharedPreferencesService`
- Provides methods to save/retrieve/clear locale

#### 4. **LanguageCubit** (`lib/core/localization/cubit/language_cubit.dart`)
- Manages language state
- Handles language switching
- Integrates with `LocalePreferencesService` for persistence

---

## Quick Start

### Accessing Translations in Widgets

```dart
import 'package:flutter/material.dart';
import 'package:contribution/core/localization/l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.welcome); // Displays "Welcome" in current language
  }
}
```

### Changing Language

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contribution/core/localization/cubit/language_cubit.dart';

// In your widget
context.read<LanguageCubit>().changeLanguage('hi'); // Switch to Hindi
context.read<LanguageCubit>().changeLanguage('es'); // Switch to Spanish
context.read<LanguageCubit>().changeLanguage('en'); // Switch to English
```

---

## Adding New Translations

### Step 1: Add to Template File

Edit `lib/core/localization/l10n/app_en.arb`:

```json
{
  "@@locale": "en",
  "myNewString": "My New String",
  "@myNewString": {
    "description": "Description of what this string is used for"
  }
}
```

### Step 2: Add to Other Language Files

Edit `lib/core/localization/l10n/app_hi.arb`:

```json
{
  "@@locale": "hi",
  "myNewString": "मेरी नई स्ट्रिंग"
}
```

Edit `lib/core/localization/l10n/app_es.arb`:

```json
{
  "@@locale": "es",
  "myNewString": "Mi Nueva Cadena"
}
```

### Step 3: Regenerate Localization Files

```bash
flutter gen-l10n
```

### Step 4: Use in Code

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.myNewString);
```

---

## Using Translations in Code

### Basic Usage

```dart
import 'package:contribution/core/localization/l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: Column(
        children: [
          Text(l10n.welcome),
          TextField(decoration: InputDecoration(labelText: l10n.email)),
          TextField(decoration: InputDecoration(labelText: l10n.password)),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }
}
```

### Translations with Parameters

**ARB File:**

```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Greeting message with user name",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

**Usage:**

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.greeting('John')); // "Hello, John!"
```

### Pluralization

**ARB File:**

```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Number of items",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  }
}
```

**Usage:**

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.itemCount(0)); // "No items"
Text(l10n.itemCount(1)); // "1 item"
Text(l10n.itemCount(5)); // "5 items"
```

---

## Adding New Languages

### Step 1: Create ARB File

Create `lib/core/localization/l10n/app_fr.arb` for French:

```json
{
  "@@locale": "fr",
  "appTitle": "Contribution",
  "welcome": "Bienvenue",
  "login": "Connexion",
  "logout": "Déconnexion",
  "email": "E-mail",
  "password": "Mot de passe"
}
```

### Step 2: Update LanguageModel

Edit `lib/core/localization/models/language_model.dart`:

```dart
static const List<LanguageModel> supportedLanguages = [
  LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    locale: Locale('en'),
  ),
  LanguageModel(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    locale: Locale('hi'),
  ),
  LanguageModel(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    locale: Locale('es'),
  ),
  LanguageModel(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    locale: Locale('fr'),
  ),
];
```

### Step 3: Update App Configuration

Edit `lib/app.dart`:

```dart
supportedLocales: const [
  Locale('en'), // English
  Locale('hi'), // Hindi
  Locale('es'), // Spanish
  Locale('fr'), // French
],
```

### Step 4: Regenerate Localization Files

```bash
flutter gen-l10n
```

---

## Changing Language Programmatically

### Using LanguageCubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contribution/core/localization/cubit/language_cubit.dart';

// Get current language
final currentLanguage = context.read<LanguageCubit>().currentLanguage;
print(currentLanguage.name); // "English"

// Change language
await context.read<LanguageCubit>().changeLanguage('hi');

// Reset to default (English)
await context.read<LanguageCubit>().resetToSystemLanguage();

// Check if a language is active
final isHindiActive = context.read<LanguageCubit>().isLanguageActive('hi');
```

### Language Selector Widget Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contribution/core/localization/cubit/language_cubit.dart';
import 'package:contribution/core/localization/models/language_model.dart';
import 'package:contribution/core/localization/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCubit = context.read<LanguageCubit>();
    
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return DropdownButton<String>(
          value: state.locale.languageCode,
          items: LanguageModel.supportedLanguages.map((language) {
            return DropdownMenuItem(
              value: language.code,
              child: Text(language.nativeName),
            );
          }).toList(),
          onChanged: (languageCode) {
            if (languageCode != null) {
              languageCubit.changeLanguage(languageCode);
            }
          },
        );
      },
    );
  }
}
```

---

## Best Practices

### 1. **Always Use Descriptive Keys**

❌ **Bad:**
```json
{
  "btn1": "Submit",
  "txt2": "Error"
}
```

✅ **Good:**
```json
{
  "submitButton": "Submit",
  "errorMessage": "Error"
}
```

### 2. **Add Descriptions to ARB Files**

```json
{
  "login": "Login",
  "@login": {
    "description": "Login button text on authentication page"
  }
}
```

### 3. **Use Parameters for Dynamic Content**

❌ **Bad:**
```dart
Text('Hello, ${userName}!'); // Not translatable
```

✅ **Good:**
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}
```

```dart
Text(l10n.greeting(userName));
```

### 4. **Keep ARB Files in Sync**

- All language files should have the same keys
- Use the English file (`app_en.arb`) as the template
- Run `flutter gen-l10n` after every ARB file change

### 5. **Don't Edit Generated Files**

Never manually edit files in `lib/core/localization/l10n/` that start with `app_localizations`:
- `app_localizations.dart`
- `app_localizations_en.dart`
- `app_localizations_hi.dart`
- `app_localizations_es.dart`

These are auto-generated by `flutter gen-l10n`.

### 6. **Use Null-Safety Properly**

```dart
// Safe access
final l10n = AppLocalizations.of(context);
if (l10n != null) {
  Text(l10n.welcome);
}

// Or use bang operator if you're sure context has localization
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcome);
```

---

## Troubleshooting

### Issue: "AppLocalizations not found"

**Solution:** Run localization generation:
```bash
flutter gen-l10n
```

### Issue: "Missing translation key"

**Solution:** Ensure the key exists in ALL ARB files:
1. Check `app_en.arb` (template)
2. Add the same key to `app_hi.arb`, `app_es.arb`, etc.
3. Run `flutter gen-l10n`

### Issue: "Language not changing"

**Solution:**
1. Verify `LanguageCubit` is provided in `app.dart`
2. Check that `BlocBuilder` is wrapping `MaterialApp.router`
3. Ensure `locale` is set to `languageState.locale`

### Issue: "Translations not updating after ARB changes"

**Solution:**
1. Run `flutter gen-l10n` to regenerate files
2. Restart the app (hot reload may not be sufficient)

### Issue: "Asset directory 'assets/images/' doesn't exist"

**Solution:** This is unrelated to localization. Either:
1. Create the directory: `mkdir -p assets/images`
2. Or remove the assets section from `pubspec.yaml` if not needed

---

## Commands Reference

```bash
# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Analyze code
flutter analyze

# Run app
flutter run
```

---

## File Locations Quick Reference

| File | Purpose |
|------|---------|
| `l10n.yaml` | Localization configuration |
| `lib/core/localization/l10n/app_en.arb` | English translations (template) |
| `lib/core/localization/l10n/app_hi.arb` | Hindi translations |
| `lib/core/localization/l10n/app_es.arb` | Spanish translations |
| `lib/core/localization/models/language_model.dart` | Language metadata |
| `lib/core/localization/cubit/language_cubit.dart` | Language state management |
| `lib/core/storage/locale_preferences_service.dart` | Locale persistence |
| `lib/app.dart` | Localization integration |

---

**Need Help?** Check the [Flutter Internationalization Guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) for more details.
