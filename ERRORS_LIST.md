# Smart Student Planner — Complete Error & Issue List

> Generated from `dart analyze` + code review on 2026-05-25

---

## 1. CRITICAL (Build-Breaking Errors)

| # | File | Line | Error | Description |
|---|------|------|-------|-------------|
| 1 | `lib/services/notification_service.dart` | 21 | `missing_required_argument` | The `initialize()` method of `FlutterLocalNotificationsPlugin` requires the named parameter `settings`, but no argument is provided. |
| 2 | `lib/services/notification_service.dart` | 22 | `extra_positional_arguments_could_be_named` | `InitializationSettings(android: android, iOS: ios)` passes positional args — the constructor expects only named params. |
| 3 | `lib/services/notification_service.dart` | 46 | `missing_required_argument` | `_plugin.show()` requires the named parameter `id`, but it's missing. |
| 4 | `lib/services/notification_service.dart` | 46 | `extra_positional_arguments_could_be_named` | `_plugin.show(id, title, body, details)` uses positional args — the method expects only named params. |
| 5 | `test/widget_test.dart` | 9 | `uri_does_not_exist` | `package:flutter_test/flutter_test.dart` cannot be resolved (probably missing `dev_dependencies` in `pubspec.yaml`). |
| 6 | `test/widget_test.dart` | 14–28 | `undefined_function` / `undefined_class` / `undefined_identifier` | All test functions (`testWidgets`, `expect`, `find`, `findsOneWidget`, `findsNothing`) and `WidgetTester` are undefined because the import in #5 fails. |

**Total CRITICAL:** 4 unique errors (compounding into 19 analyzer violations)

---

## 2. WARNINGS

| # | File | Line | Type | Description |
|---|------|------|------|-------------|
| 7 | `analysis_options.yaml` | 10 | `include_file_not_found` | `package:flutter_lints/flutter.yaml` cannot be found — either the package is missing or not correctly resolved. |
| 8 | `lib/screens/pomodoro_screen.dart` | 23 | `unused_field` | `_totalSessions` field is declared but never read. |

---

## 3. DEPRECATED API USAGE

| # | File | Line(s) | Issue | Count |
|---|------|---------|-------|-------|
| 9 | `lib/screens/ai_assistant_screen.dart` | 219, 285 | `withOpacity` → use `withValues()` | 2 |
| 10 | `lib/screens/attendance_screen.dart` | 221 | `withOpacity` → use `withValues()` | 1 |
| 11 | `lib/screens/gpa_screen.dart` | 120, 202, 223, 273 | `withOpacity` → use `withValues()` | 4 |
| 12 | `lib/screens/home_screen.dart` | 117, 255, 284, 289, 313 | `withOpacity` → use `withValues()` | 5 |
| 13 | `lib/screens/login_screen.dart` | 67, 101 | `withOpacity` → use `withValues()` | 2 |
| 14 | `lib/screens/onboarding_screen.dart` | 199, 247, 257, 283, 287 | `withOpacity` → use `withValues()` | 5 |
| 15 | `lib/screens/planner_screen.dart` | 231, 263, 546, 576, 577, 580, 581 | `withOpacity` → use `withValues()` | 7 |
| 16 | `lib/screens/pomodoro_screen.dart` | 128, 163, 182, 198, 203, 226, 291, 293, 302 | `withOpacity` → use `withValues()` | 9 |
| 17 | `lib/screens/splash/splash_screen.dart` | 149, 166, 183, 219, 380 | `withOpacity` → use `withValues()` | 5 |
| 18 | `lib/screens/tasks_screen.dart` | 177, 196 | `withOpacity` → use `withValues()` | 2 |
| 19 | `lib/screens/timetable_screen.dart` | 179, 238, 239 | `withOpacity` → use `withValues()` | 3 |

**Total deprecated usages:** 45 occurrences across 10 files

---

## 4. SECURITY ISSUES

| # | Severity | File | Line | Issue |
|---|----------|------|------|-------|
| 20 | **HIGH** | `lib/screens/ai_assistant_screen.dart` | 23 | **Hardcoded Google Gemini API key** (`AIzaSyCPGj431mkcy1ZBwYs9qB-L8bFgnfIENx4`) exposed in source code. Should use environment variables or a backend proxy. |

---

## 5. CODE QUALITY & ARCHITECTURAL ISSUES

| # | Severity | File(s) | Issue |
|---|----------|---------|-------|
| 21 | **MEDIUM** | `lib/main.dart` vs `lib/theme/app_theme.dart` | **Duplicated theme code**: Both files define nearly identical light/dark `ThemeData`. `main.dart` defines `_buildLightTheme()` / `_buildDarkTheme()` inline, while `app_theme.dart` has `AppTheme.lightTheme` / `AppTheme.darkTheme` — but `app_theme.dart` is never imported anywhere. One copy should be removed. |
| 22 | **MEDIUM** | `lib/screens/planner_screen.dart` | **Local model in screen file**: `StudySession` model is defined inline inside the planner screen instead of in `lib/models/` (inconsistent with `TaskModel` and `AttendanceModel`). |
| 23 | **MEDIUM** | `lib/screens/ai_assistant_screen.dart` | **Local model in screen file**: `ChatMessage` model is defined inline inside the AI assistant screen instead of in `lib/models/`. |
| 24 | **MEDIUM** | `lib/screens/onboarding_screen.dart` | **Local model in screen file**: `OnboardingData` model is defined inline inside the onboarding screen instead of in `lib/models/`. |
| 25 | **LOW** | All screens | **No widget extraction**: The `lib/widgets/` directory is completely empty. All UI is built inline in screen files with no reusable widget components. |
| 26 | **LOW** | All screens | **No error handling in DBHelper**: `DBHelper` performs `SharedPreferences` operations without any try/catch blocks. Failures cause runtime crashes. |
| 27 | **LOW** | All screens | **No logging framework**: No logging (e.g., `logging` package, `dart:developer`) anywhere in the app. Debugging relies on no output at all. |

---

## 6. MISSING PERSISTENCE / DATA LOSS

| # | Severity | Feature | Issue |
|---|----------|---------|-------|
| 28 | **HIGH** | GPA Calculator | GPA courses are kept **only in memory** — lost on app restart. |
| 29 | **HIGH** | Timetable | Timetable schedule is kept **only in memory** — lost on app restart. |
| 30 | **LOW** | Pomodoro | Pomodoro session history is kept **only in memory** — lost on app restart. |

---

## 7. UNUSED DEPENDENCIES & DEAD CODE

| # | File | Item | Description |
|---|------|------|-------------|
| 31 | `pubspec.yaml` | `cached_network_image: ^3.3.1` | Listed but never imported in any Dart file. |
| 32 | `pubspec.yaml` | `flutter_animate: ^4.5.0` | Listed but never imported in any Dart file. |
| 33 | `pubspec.yaml` | `shimmer: ^3.0.0` | Listed but never imported in any Dart file. |
| 34 | `lib/screens/pomodoro_screen.dart` | `_totalSessions` | Field declared but never read/written meaningfully (also reported as warning). |

---

## 8. CONFIGURATION ISSUES

| # | File | Issue |
|---|------|-------|
| 35 | `pubspec.yaml` | **Missing `dev_dependencies`**: No `flutter_test` or `flutter_lints` in `dev_dependencies`, causing the analysis_options.yaml warning and test import failures. |
| 36 | `pubspec.yaml` | **Missing `flutter:` assets section**: The `assets/images/` directory exists but is not declared in `pubspec.yaml`, so images cannot be bundled or used. |
| 37 | `test/widget_test.dart` | **Outdated smoke test**: Tests a counter app that doesn't exist — will always fail. Should be removed or rewritten for the actual app. |

---

## 9. SUMMARY

| Category | Count |
|----------|-------|
| 🔴 Critical (build-breaking) errors | 4 |
| 🟡 Warnings | 2 |
| 🔵 Deprecated API usages | 45 |
| 🛡️ Security issues | 1 |
| 🏗️ Architectural / Code quality issues | 7 |
| 💾 Missing persistence | 3 |
| 🗑️ Unused code / dependencies | 4 |
| ⚙️ Configuration issues | 3 |
| **Total** | **68 analyzer issues + ~25 non-analyzer issues** |
