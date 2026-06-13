# My Daily Habits — Flutter App 📱

A beautiful daily habit tracker with:
- ✅ Background notifications (even when app is closed)
- 🔥 Streak tracking (like Duolingo)
- ⚠️ Streak-at-risk alerts
- 📋 Custom habits with categories & repeat schedules
- 💪 Pre-loaded: Gym, Cyber Security Class, German Practice

---

## 🚀 Build APK — Free (Using GitHub + Codemagic)

### Option A: Codemagic (Easiest — No setup needed)

1. Go to **codemagic.io** → Sign up free (use GitHub login)
2. Upload this entire folder as a ZIP to GitHub:
   - Go to **github.com** → New repository → Upload files
3. In Codemagic → "Add application" → Connect your GitHub repo
4. Select **Flutter** → Click **Start new build**
5. After 5-10 mins → **Download APK** ✅

### Option B: Build on Your Own Computer

Requirements:
- Flutter SDK: https://flutter.dev/docs/get-started/install
- Android Studio (for Android SDK)

```bash
cd mera_kaam_flutter
flutter pub get
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 Install on Android Phone

1. Copy APK to your phone
2. Open it — Android will ask to allow "Install from unknown sources"
3. Tap **Settings** → Enable → Go back → Install
4. Done! App icon will appear on home screen 🎉

---

## ✏️ How to Customize

All tasks are in `lib/services/storage_service.dart`:

```dart
static List<Task> _defaultTasks() => [
  Task(id: 'default_1', name: 'Go to Gym',   ...),
  Task(id: 'default_2', name: 'Your Task',   ...),
  // Add more here
];
```

---

## 📁 File Structure

```
lib/
  main.dart                    ← App entry point
  models/
    task.dart                  ← Task data model
  services/
    storage_service.dart       ← Save/load data & streak
    notification_service.dart  ← Background notifications
    app_theme.dart             ← Colors & theme
    quotes.dart                ← Motivational quotes
  screens/
    home_screen.dart           ← Main screen
  widgets/
    task_card.dart             ← Individual task UI
    streak_card.dart           ← Streak widget
    add_task_sheet.dart        ← Add/edit task form
```

---

## 🔔 Notification Features

- Reminder fires at the exact time you set
- Persists across phone restarts
- "Streak at risk" alert fires if you haven't done tasks by evening
- Works completely in background

---

Built with Flutter 3.x | Tested on Android 10+
