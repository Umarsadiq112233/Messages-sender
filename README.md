# Paigham — SMS Panel (Frontend)

A responsive Flutter frontend for the SMS panel. The same code runs in the browser and on mobile.
The full design plan (12 screens, rules, and open points) is in [docs/DESIGN_PLAN.md](docs/DESIGN_PLAN.md).

**Demo login:** `admin` / `admin123`. There's no backend yet: the data is sample data, and the SMS queue is a simulation.

## Run

```bash
flutter pub get
flutter run -d chrome          # browser
flutter run                    # Android / iOS device or emulator
flutter build web --release    # production web build → build/web
```

## What's built

| # | Screen | Route |
|---|--------|-------|
| — | Splash (animated) | `/splash` |
| 1 | Login | `/login` |
| 2 | Dashboard | `/dashboard` |
| 3 | Add Number | `/numbers/add` |
| 4 | Bulk Import (paste / Excel / CSV, drag & drop) | `/numbers/import` |
| 5 | Database / Numbers list | `/numbers` |
| 6 | Edit Number | `/numbers/:id` |
| 7 | Groups | `/groups` |
| 8 | Compose & Send SMS | `/send` |
| 9 | Sending Queue (live) | `/queue` |
| 10 | Reports + CSV export | `/reports` |
| 11 | Settings | `/settings` |
| 12 | Gateway / Device | `/gateway` |

Every screen also uses these shared pieces: the sidebar / top bar / bottom navigation, confirm dialogs, and toasts.

### Responsive layouts
- **Desktop ≥1024px:** full sidebar, tables, multi-column layouts, hover effects.
- **Tablet 768–1023px:** icon-only sidebar.
- **Mobile <768px:** top bar plus bottom nav (Home, Database, Send SMS, Reports, More). Lists show as cards, and the main buttons stick to the bottom of the screen.

### Animation (`lib/core/motion/motion.dart`)
Mobile and desktop deliberately use different animations:
- **Mobile ("Rise"):** sections rise in from below, list cards slide in from the right, and pages slide in sideways. Dialogs open as bottom sheets, and pressing something makes it shrink slightly.
- **Desktop ("Focus"):** sections come into focus from a slight blur and zoom, table rows appear one after another, and pages fade between each other. Dialogs pop up in the centre, and cards lift with a blue glow on hover.
- **Splash:** on mobile, the logo bounces in, ripples spread out, a paper plane flies off, and the name appears letter by letter. On desktop, the logo spins in with icons orbiting around it, the name is revealed from behind a line, the tagline types itself out, and the background follows the mouse.

## Supabase (live data)

The app has two modes:
- **Demo mode** is the default. It uses sample data and the `admin / admin123` login.
- **Live mode** turns on once a Supabase key is set. It uses the real database and real login.

### One-time setup
1. **Tables:** in the Supabase Dashboard, open **SQL Editor → New query**, paste [supabase/schema.sql](supabase/schema.sql) and press **Run**. The script is safe to run again.
2. **Admin account:** go to **Authentication → Users → Add user → Create new user**. Use email `admin@paigham.app` and a strong password, and tick *Auto Confirm User*.
3. **Turn off sign-ups (important):** go to **Authentication → Sign In / Providers** and switch off *Allow new users to sign up*. Every signed-in user sees all the data, so only the admin account should exist.
4. **Key:** go to **Project Settings → API Keys** and copy the **Publishable** key (`sb_publishable_…`). Paste it into `config/supabase.json`, which is git-ignored and must never be committed. Never use the `sb_secret_…` key.
5. **Run with the key:**

```bash
flutter run -d chrome --dart-define-from-file=config/supabase.json
```

In VS Code, pick the **"Paigham (Supabase)"** launch configuration instead.

### Logging in
Type `admin` as the username plus the password you created. The app signs in as `ADMIN_EMAIL` from `config/supabase.json`. You can also type the full email.

### What is stored
`groups`, `contacts`, `campaigns`, `delivery_logs` (one row per SMS), `activities`, `app_settings` and `gateway`.
- Every change in the panel is saved straight away.
- When you log in or reopen the app, everything loads again.
- Gateway and delivery updates arrive in realtime.

> The **sending queue is still a simulation**, and its results are saved to `delivery_logs`. Real SMS delivery needs the Android gateway app (Phase 3). That app will update the `gateway` and `delivery_logs` tables.

## Languages (Roman Urdu · English · اردو)

The panel opens in **Roman Urdu** by default. Users can switch languages in Settings, on the Login screen, or from the profile menu, and their choice is remembered. Urdu uses the Noto Naskh Arabic font and the whole layout flips right-to-left.

All texts are in three files. To change any wording, edit these files; no Dart code changes are needed:

| File | Language |
|------|----------|
| `lib/l10n/app_ur_Latn.arb` | Roman Urdu (default, master file) |
| `lib/l10n/app_en.arb` | English |
| `lib/l10n/app_ur.arb` | Urdu (اردو) |

- Keep `{placeholders}` such as `{count}` or `{name}` exactly as they are. Only the words around them should be translated.
- `flutter run` / `flutter build` regenerate the Dart classes automatically. To refresh them by hand, run `flutter gen-l10n`.
- To add a new text, add the key to **all three** files and use it in code as `context.l10n.yourKey`. The test `test/l10n_test.dart` fails if a language is missing a key or a placeholder.

## Structure

```
lib/
  app/            router + shell (sidebar, top bar, bottom nav)
  core/           theme, motion, responsive helpers, shared widgets, utils
  data/           models, sample data, AppStore (the single place the backend plugs in)
  features/       one folder per screen
assets/
  illustrations/  hand-made SVG illustrations
  fonts/          Inter (bundled, works offline)
```

## Backend hand-off (Phase 3)
All screens talk only to `lib/data/app_store.dart`. To connect the backend, swap out the in-memory lists and the simulated queue in that file for API calls. Nothing in the UI needs to change.
# Messages-sender
