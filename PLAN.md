# Smart Student Planner — Development Plan

> Comprehensive plan for fixing, optimizing, and completing the app.

---

## Priority 1 — CRITICAL (Broken Functionality)

| # | Task | Status |
|---|------|--------|
| 1.1 | **Fix emoji rendering** — bundle NotoColorEmoji font, set as `fontFamilyFallback` in theme so emojis display instead of rectangular boxes on Linux/desktop | ✅ Done |
| 1.2 | **Replace placeholder API key** — move Gemini API key to environment-variable-based config | ✅ Done (placeholder set) |

---

## Priority 2 — PERFORMANCE (Slow Loading)

| # | Task | Description | Status |
|---|------|-------------|--------|
| 2.1 | **Reduce splash screen duration** | `SplashScreen`: logo 900→500ms, text 700→400ms, progress 2000→1000ms, delays cut 50%. Total: ~4s → ~2.2s | ✅ Done |
| 2.2 | **Reduce animate_do staggered delays** | HomeScreen: max 450ms→140ms. List items (8 screens): stagger changed from `i * 80` → `min(i * 50, 250)` / `i * 100` → `min(i * 50, 250)`. Login/Onboarding delays cut 50% | ✅ Done |
| 2.3 | **Preload Google Fonts** | Call `GoogleFonts.poppinsTextTheme()` before `runApp()` to avoid FOUT | ✅ Done |
| 2.4 | **Reduce PageRouteBuilder duration** | Fade transitions (splash→onboarding/login/home): 600ms→300ms | ✅ Done |
| 2.5 | **Replace animate_do with lighter alternatives** | Simple fades can use `AnimatedOpacity`, reducing package overhead | ⬜ Deferred |

---

## Priority 3 — CODE QUALITY (Done)

| # | Task | Status |
|---|------|--------|
| 3.1 | Fix `flutter_local_notifications` v21 API — named parameters | ✅ |
| 3.2 | Remove unused deps (`cached_network_image`, `flutter_animate`, `shimmer`) | ✅ |
| 3.3 | Add `dev_dependencies` (`flutter_test`, `flutter_lints`) + declare `assets/` | ✅ |
| 3.4 | Rewrite outdated test | ✅ |
| 3.5 | Fix 45 deprecated `withOpacity` → `withValues(alpha:)` | ✅ |
| 3.6 | Remove hardcoded Gemini API key | ✅ |
| 3.7 | Remove duplicated theme code (main.dart now uses app_theme.dart) | ✅ |
| 3.8 | Extract inline models (ChatMessage, StudySession, OnboardingData) to `lib/models/` | ✅ |
| 3.9 | Remove unused `_totalSessions` field | ✅ |
| 3.10 | Add try/catch error handling to DBHelper | ✅ |

---

## Priority 4 — NEW FEATURES

| # | Task | Description | Status |
|---|------|-------------|--------|
| 4.1 | **AI Assistant — Full upgrade** | Extracted to `AiService` with context injection (reads tasks, attendance). Added quick-action buttons (Study Tips, Study Plan, Analyze Progress, Help). Added voice input via `speech_to_text`. Full Gemini API with fallback responses | ✅ Done |
| 4.2 | **Notification System — Complete** | Added `audioplayers` for custom sounds. Created 4 WAV sound files (notification, alarm, bell, complete). Added `workmanager` for background hourly deadline checks. All notification methods wired up — `showTaskReminder`, `showStudyReminder`, `showAttendanceWarning`, `showPomodoroComplete` | ✅ Done |
| 4.3 | **Deadline Screen** | New `DeadlineScreen` with urgency color coding (red=overdue/today, orange=tomorrow/soon, yellow=week, green=far). Auto-opens when urgent tasks detected on launch. Bell badge in HomeScreen AppBar. `DeadlineService` for shared deadline logic | ✅ Done |
| 4.4 | **Task completion sound** | Playing `complete.wav` when a task is checked off | ✅ Done |
| 4.5 | **Pomodoro break sound** | Playing `bell.wav` + notification when work/break session ends | ✅ Done |
| 4.6 | **Persist GPA courses** | Save/load GPA data from SharedPreferences (currently in-memory only) | ⬜ |
| 4.7 | **Persist Timetable schedule** | Save/load timetable from SharedPreferences (currently in-memory only) | ⬜ |

---

## Priority 5 — POLISH

| # | Task | Description | Status |
|---|------|-------------|--------|
| 5.1 | Replace remaining `animate_do` with `AnimatedOpacity`/`AnimatedSlide` | Reduce package dependency, improve performance | ⬜ |
| 5.2 | Task sorting/filtering | Filter by priority, subject, due date | ⬜ |
| 5.3 | Animated chart transitions in Progress screen | Smooth bar/circle transitions on data change | ⬜ |
| 5.4 | Dark mode consistency pass | Ensure all screens follow theme properly | ⬜ |

---

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | Provider + setState | Already used, minimal refactoring needed |
| Persistence | SharedPreferences | Web-compatible, no native SQLite dependency |
| Emoji rendering | NotoColorEmoji font fallback | Zero code changes, works cross-platform |
| Font loading | Preloaded google_fonts + local fallback | Avoids FOUT while keeping Poppins |
| Navigation | Imperative push (no router package) | Simple enough for current app scope |
| AI assistant | Gemini API via AiService | Context-aware with student data injection |
| Notifications | flutter_local_notifications + audioplayers | Custom sounds + background scheduling |
| Background tasks | workmanager (hourly) | Deadline checking, cross-platform |
| Voice input | speech_to_text | Transcribe speech → send to AI |

---

## Performance Targets

| Metric | Before | After |
|--------|--------|-------|
| Splash → Home time | ~4.5s | ~2.5s |
| Home screen first paint | Staggered 450ms per item | 140ms per item (max) |
| List animation max delay | 800ms+ (for 10 items × 80ms) | 250ms (capped) |
| Page transition duration | 600ms | 300ms |
| Font loading | On every build() | Once before runApp() |
| `dart analyze` issues | 68 | 0 |
| Emoji rendering | Boxes (missing font) | NotoColorEmoji fallback |
| Deadline notifications | None | Auto via background check + sounds |
| AI assistant | Basic chat | Context-aware + quick actions + voice |
| Build | desugar_jdk_libs 2.0.4 | 2.1.4 (fixes Android build) |
