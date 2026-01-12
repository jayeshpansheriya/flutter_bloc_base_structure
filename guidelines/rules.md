---
trigger: always_on
---

# Flutter BLoC Project Rules

This is the main rules file for Antigravity. For detailed guidelines, see the specialized rule files below.

## Quick Reference

### Project Structure

- **Architecture**: Feature-First (Clean Architecture)
- **State Management**: `flutter_bloc` (Cubit for simple, Bloc for complex)
- **DI**: `get_it` (Service Locator)
- **Routing**: `go_router`
- **Networking**: `dio` + `retrofit` with secure token storage

### Core Principles

1. ✅ Feature-first directory structure
2. ✅ Use Retrofit for all API calls (not direct Dio methods)
3. ✅ Secure token storage with in-memory caching
4. ✅ Comprehensive error handling with `ApiError`
5. ✅ Run code generation after creating Retrofit services

## Detailed Rules

For comprehensive guidelines, refer to these specialized rule files:

### 📁 [architecture.md](.agent/rules/architecture.md)

- Feature-first directory structure
- Clean architecture layers (data, domain, presentation)
- File organization and naming conventions

### 🌐 [networking.md](.agent/rules/networking.md)

- DioClient setup and configuration
- Creating Retrofit services
- Error handling with ApiError
- Authentication and token management
- Secure storage with caching

### 💻 [coding_standards.md](.agent/rules/coding_standards.md)

- File and class naming conventions
- Import organization
- Error handling patterns
- Code generation workflow

### 🤖 [antigravity_behavior.md](.agent/rules/antigravity_behavior.md)

- File existence checks
- Dependency verification
- Export management
- Code generation reminders

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (after creating Retrofit services)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Project Documentation

Additional guides are available in the project root:

- **DIO_RETROFIT_SETUP.md**: Complete Retrofit setup guide
- **SECURE_TOKEN_STORAGE_GUIDE.md**: Token management and authentication
- **PERFORMANCE_OPTIMIZATION.md**: Token caching and performance tips
- **README.md**: Project overview and structure

---

**Note**: These rules are enforced by Antigravity to ensure code consistency and best practices across the project.
