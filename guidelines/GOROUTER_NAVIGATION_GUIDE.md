# 🧭 GoRouter Navigation Guide

## Overview

Your app uses **GoRouter** for declarative, type-safe navigation with deep linking support.

## 📁 File Structure

```
lib/routes/
├── app_router.dart           # Main router configuration
└── navigation_extension.dart # Navigation helpers
```

## 🎯 Key Features

✅ **Type-safe routing** with named constants  
✅ **Error handling** with custom error page  
✅ **Navigation extensions** for easy routing  
✅ **Redirect logic** template for authentication  
✅ **Debug logging** enabled

## 🚀 Basic Usage

### 1. Navigate Using Context

```dart
import 'package:contribution/routes/navigation_extension.dart';

// Using extension methods
context.goToHome();
context.goToLogin();
context.goToProfile();

// Using GoRouter directly
context.go('/login');
context.push('/settings');
```

### 2. Navigate Using Route Names

```dart
import 'package:contribution/routes/app_router.dart';

// Type-safe navigation
context.go(AppRoutes.login);
context.go(AppRoutes.home);
context.go(AppRoutes.settings);
```

## 📖 Route Configuration

### Current Routes

| Route | Path     | Name    | Page            |
| ----- | -------- | ------- | --------------- |
| Home  | `/`      | `home`  | `HomePage`      |
| Login | `/login` | `login` | `AuthLoginPage` |

### Adding New Routes

```dart
// In app_router.dart

// 1. Add route constant
class AppRoutes {
  static const String profile = '/profile';
}

// 2. Add route configuration
GoRoute(
  path: AppRoutes.profile,
  name: 'profile',
  builder: (context, state) => const ProfilePage(),
),

// 3. Add navigation extension (optional)
// In navigation_extension.dart
extension NavigationExtension on BuildContext {
  void goToProfile() => go(AppRoutes.profile);
}
```

## 🎨 Navigation Patterns

### 1. Simple Navigation

```dart
// Go to a route (replaces current route in history)
context.goToLogin();

// Push a route (adds to history stack)
context.pushTo('/settings');
```

### 2. Navigation with Parameters

```dart
// Query parameters
context.go('/profile?id=123');

// Path parameters
GoRoute(
  path: '/user/:id',
  builder: (context, state) {
    final userId = state.pathParameters['id'];
    return UserPage(userId: userId);
  },
),

// Usage
context.go('/user/123');
```

### 3. Navigation with Data

```dart
// Pass data using extra
context.push('/details', extra: {'user': userObject});

// Receive data
GoRoute(
  path: '/details',
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    final user = data['user'];
    return DetailsPage(user: user);
  },
),
```

### 4. Replace Navigation

```dart
// Replace current route (can't go back)
context.replaceTo('/home');

// Or using GoRouter
context.pushReplacement('/home');
```

### 5. Go Back

```dart
// Check if can go back
if (context.canGoBack()) {
  context.goBack();
}

// Or using GoRouter
if (context.canPop()) {
  context.pop();
}
```

## 🔐 Authentication Flow

### Setup Redirect Logic

Uncomment and modify the redirect logic in `app_router.dart`:

```dart
final GoRouter appRouter = GoRouter(
  // ... other config

  redirect: (context, state) async {
    // Check authentication status
    final isAuthenticated = await sl<DioClient>().isAuthenticated();
    final isLoginRoute = state.matchedLocation == AppRoutes.login;

    // Redirect to login if not authenticated
    if (!isAuthenticated && !isLoginRoute) {
      return AppRoutes.login;
    }

    // Redirect to home if already authenticated
    if (isAuthenticated && isLoginRoute) {
      return AppRoutes.home;
    }

    return null; // No redirect
  },
);
```

### Usage in BLoC

```dart
class AuthCubit extends Cubit<AuthState> {
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _repository.login(email, password);
      emit(AuthAuthenticated());

      // Navigate to home after successful login
      _context.goToHome();
    } on ApiError catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> logout() async {
    await _dioClient.clearTokens();
    emit(AuthUnauthenticated());

    // Navigate to login after logout
    _context.goToLogin();
  }
}
```

## 🎯 Nested Navigation

### Tab-Based Navigation

```dart
GoRoute(
  path: '/',
  builder: (context, state) => const MainScaffold(),
  routes: [
    GoRoute(
      path: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
),
```

### Bottom Navigation

```dart
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          ProfilePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

## 🐛 Error Handling

### Custom Error Page

The router includes a built-in error page that shows:

- Error icon
- Error message
- "Go to Home" button

### Handling 404 Errors

```dart
// The errorBuilder in app_router.dart handles all routing errors
errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
```

## 📱 Deep Linking

### Android Setup

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="myapp" />
</intent-filter>
```

### iOS Setup

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

### Usage

```dart
// Deep link: myapp://profile/123
GoRoute(
  path: '/profile/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'];
    return ProfilePage(id: id);
  },
),
```

## 🎨 Best Practices

### DO:

- ✅ Use `AppRoutes` constants for type-safe navigation
- ✅ Use navigation extensions for cleaner code
- ✅ Handle authentication in redirect logic
- ✅ Use named routes for better debugging
- ✅ Test deep links thoroughly

### DON'T:

- ❌ Hardcode route paths in widgets
- ❌ Use `Navigator.push` (use GoRouter instead)
- ❌ Forget to handle back button on login page
- ❌ Create circular navigation loops
- ❌ Pass large objects via route parameters

## 📚 Common Patterns

### Pattern 1: Login Flow

```dart
// Login button
ElevatedButton(
  onPressed: () => context.goToLogin(),
  child: const Text('Login'),
)

// After successful login
context.goToHome();
```

### Pattern 2: Logout Flow

```dart
// Logout button
IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await sl<DioClient>().clearTokens();
    if (mounted) context.goToLogin();
  },
)
```

### Pattern 3: Conditional Navigation

```dart
void navigateBasedOnAuth() async {
  final isAuth = await sl<DioClient>().isAuthenticated();

  if (mounted) {
    if (isAuth) {
      context.goToHome();
    } else {
      context.goToLogin();
    }
  }
}
```

### Pattern 4: Navigation from BLoC

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goToHome();
        } else if (state is AuthUnauthenticated) {
          context.goToLogin();
        }
      },
      child: // UI
    );
  }
}
```

## 🔧 Advanced Features

### Refresh Listener

```dart
final GoRouter appRouter = GoRouter(
  refreshListenable: authNotifier, // Rebuild routes when auth changes
  // ... other config
);
```

### Route Observers

```dart
final GoRouter appRouter = GoRouter(
  observers: [MyNavigatorObserver()],
  // ... other config
);

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('Pushed: ${route.settings.name}');
  }
}
```

## 📊 Navigation Extension API

```dart
// Navigation
context.goToLogin()      // Go to login
context.goToHome()       // Go to home
context.goToProfile()    // Go to profile
context.goToSettings()   // Go to settings

// Helpers
context.goBack()         // Go back
context.canGoBack()      // Check if can go back
context.replaceTo(path)  // Replace current route
context.pushTo(path)     // Push new route
```

## 🐛 Troubleshooting

### Route Not Found

```dart
// Make sure route is defined in app_router.dart
GoRoute(
  path: '/your-route',
  name: 'your-route',
  builder: (context, state) => YourPage(),
),
```

### Can't Go Back

```dart
// Check if can go back before calling goBack()
if (context.canGoBack()) {
  context.goBack();
} else {
  context.goToHome(); // Fallback
}
```

### Redirect Loop

```dart
// Make sure redirect logic doesn't create loops
redirect: (context, state) {
  // Always return null at the end to prevent loops
  return null;
},
```

---

**Summary**: Use GoRouter for all navigation. It's declarative, type-safe, and supports deep linking out of the box!
