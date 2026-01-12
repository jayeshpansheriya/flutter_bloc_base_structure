# Antigravity Behavior Rules

These rules define how Antigravity should behave when working on this project.

## 1. File Existence Checks

### Before Creating Files

- ✅ **ALWAYS** check if a file or class exists before creating it
- ✅ Use appropriate tools to verify file existence
- ✅ If file exists, ask user before overwriting

### Before Creating Classes

- ✅ Check if class already exists in the codebase
- ✅ Search for similar functionality before duplicating
- ✅ Reuse existing classes when possible

## 2. Dependency Verification

### Before Using Dependencies

- ✅ Check `pubspec.yaml` to verify dependency exists
- ✅ Check version compatibility
- ✅ Don't assume dependencies are installed

### Before Code Generation

- ✅ Verify `build_runner` is in `dev_dependencies`
- ✅ Verify required generators are installed (e.g., `retrofit_generator`)
- ✅ Check `pubspec.yaml` before suggesting code generation

### Adding New Dependencies

- ✅ Add to appropriate section (`dependencies` or `dev_dependencies`)
- ✅ Use specific version constraints
- ✅ Run `flutter pub get` after adding
- ✅ Document why the dependency is needed

## 3. Export Management

### Barrel Files

If the project uses barrel files (e.g., `auth.dart` exporting all auth files):

- ✅ Update barrel files when adding new files
- ✅ Maintain alphabetical order in exports
- ✅ Check if barrel file pattern is in use before creating

### Core Exports

When adding files to `core`:

- ✅ Check if there's a barrel file pattern
- ✅ Update exports if pattern exists
- ✅ Don't create barrel files unless requested

## 4. Code Generation Reminders

### After Creating Retrofit Services

- ✅ **ALWAYS** remind user to run code generation
- ✅ Provide exact command: `flutter pub run build_runner build --delete-conflicting-outputs`
- ✅ Explain what will be generated

### After Modifying Retrofit Services

- ✅ Remind user to re-run code generation
- ✅ Mention `--delete-conflicting-outputs` flag

### After JSON Serialization

- ✅ Remind user to run code generation if using `json_serializable`
- ✅ Check if `json_serializable` is in dependencies first

## 5. Project Structure Awareness

### Feature-First Architecture

- ✅ Place feature-specific code in `lib/features/[feature_name]/`
- ✅ Place shared code in `lib/core/`
- ✅ Don't mix feature code with core code
- ✅ Maintain clean architecture layers (data, domain, presentation)

### File Placement

- ✅ Retrofit services: `lib/features/[feature]/data/api/` or `lib/core/network/api/`
- ✅ Models: `lib/features/[feature]/data/models/`
- ✅ Repositories: `lib/features/[feature]/data/repositories/`
- ✅ Entities: `lib/features/[feature]/domain/entities/`
- ✅ BLoCs/Cubits: `lib/features/[feature]/presentation/bloc/`
- ✅ Pages: `lib/features/[feature]/presentation/pages/`
- ✅ Widgets: `lib/features/[feature]/presentation/widgets/`

## 6. Service Locator Updates

### When Creating New Services

- ✅ **ALWAYS** register in `lib/di/service_locator.dart`
- ✅ Use appropriate registration method:
  - `registerLazySingleton` for services, repositories, clients
  - `registerFactory` for BLoCs/Cubits
- ✅ Register dependencies in correct order (dependencies first)
- ✅ Add comments for clarity

### Registration Example

```dart
// API Services
sl.registerLazySingleton<UserApiService>(
  () => UserApiService(sl<DioClient>().dio),
);

// Repositories
sl.registerLazySingleton<UserRepository>(
  () => UserRepository(sl()),
);

// BLoCs/Cubits
sl.registerFactory<UserCubit>(
  () => UserCubit(sl()),
);
```

## 7. Error Handling Patterns

### In Repositories

- ✅ Catch `DioException`
- ✅ Convert to `ApiError` using `ApiError.fromDioException(e)`
- ✅ Don't catch generic `Exception` unless necessary

### In BLoC/Cubit

- ✅ Catch `ApiError`
- ✅ Emit appropriate error states
- ✅ Provide user-friendly error messages

## 8. Token Management

### After Login

- ✅ Remind user to call `dioClient.setTokens()`
- ✅ Explain that tokens are cached and persisted

### On Logout

- ✅ Remind user to call `dioClient.clearTokens()`
- ✅ Explain that both cache and storage are cleared

### Token Refresh

- ✅ Explain automatic token refresh is configured
- ✅ Show how to configure refresh endpoint if needed

## 9. Testing Considerations

### When Creating New Features

- ✅ Suggest creating tests
- ✅ Mention test file location: `test/features/[feature]/`
- ✅ Don't auto-create tests unless requested

### Test Structure

- ✅ Mirror source structure in test directory
- ✅ Use `_test.dart` suffix for test files

## 10. Documentation

### When Creating Complex Code

- ✅ Add doc comments for public APIs
- ✅ Explain non-obvious behavior
- ✅ Provide usage examples when helpful

### When Creating New Patterns

- ✅ Document the pattern
- ✅ Explain why it's used
- ✅ Provide examples

## 11. Communication with User

### Be Proactive

- ✅ Suggest improvements when appropriate
- ✅ Point out potential issues
- ✅ Offer alternatives when available

### Be Clear

- ✅ Explain what you're doing and why
- ✅ Provide context for decisions
- ✅ Use clear, concise language

### Ask When Uncertain

- ✅ Ask for clarification when requirements are unclear
- ✅ Confirm before making significant changes
- ✅ Present options when multiple approaches are valid

## 12. Code Quality

### Before Completing Tasks

- ✅ Run `flutter analyze` to check for errors
- ✅ Ensure no lint warnings
- ✅ Verify imports are organized
- ✅ Check for unused imports

### Code Review Checklist

- ✅ Follows project architecture
- ✅ Uses correct naming conventions
- ✅ Has proper error handling
- ✅ Includes necessary documentation
- ✅ Registered in service locator (if applicable)
- ✅ Code generation run (if applicable)

## 13. Performance Considerations

### Token Access

- ✅ Use cached token getters (synchronous)
- ✅ Don't read from storage on every request
- ✅ Explain caching benefits when relevant

### Widget Building

- ✅ Suggest `const` constructors
- ✅ Recommend extracting widgets when appropriate
- ✅ Point out potential performance issues

## 14. Security Best Practices

### Token Storage

- ✅ Always use `SecureStorageService` for tokens
- ✅ Never use `SharedPreferences` for sensitive data
- ✅ Remind about clearing tokens on logout

### API Keys

- ✅ Suggest environment variables for API keys
- ✅ Don't hardcode sensitive values
- ✅ Remind about `.gitignore` for secrets

## 15. Continuous Improvement

### Learn from Feedback

- ✅ Adapt to user preferences
- ✅ Remember project-specific patterns
- ✅ Apply lessons learned to future tasks

### Stay Updated

- ✅ Follow Flutter/Dart best practices
- ✅ Use latest stable package versions
- ✅ Suggest modern patterns and approaches
