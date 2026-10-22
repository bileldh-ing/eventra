# EVENTRA progress

Build plan: see the project spec (phases 0 to 8+). This file records what is
done, how to check it, and what is still open. Test counts are the number of
passing tests in the whole suite at that phase's commit.

## How to run

```bash
flutter pub get
flutter run
./tool/check.sh -j 1                         # format check + analyze + tests + coverage
flutter test --update-goldens --tags golden  # refresh screenshots after UI changes
```

Goldens: `test/features/home/goldens/home.png`,
`test/features/event_details/goldens/details.png`,
`test/features/explore/goldens/explore.png` (390x844 logical at 2x, real
fonts, fixture photos and fixture map tiles).

---

## Phase 0: Bootstrap (done)

- Flutter project, very_good_analysis lints, Urbanist fonts, design tokens
  (`EventraTokens` ThemeExtension), go_router shell with the floating nav
  pill, `tool/check.sh` single quality gate, GitHub Actions CI file.
- Gate: analyze 0 issues, **7 tests** passing.

## Phase 1: Data and images (done)

- freezed/json models (Event, TicketTier, Organizer, LineupItem, Review),
  drift SQLite database, 56-event seed across 8 categories with real Unsplash
  photos and coordinates around New City, NY (matches the reference map),
  `LocalDemoBackend` with latency and seeded fault injection, repositories
  returning `Result<T>`, Haversine helpers, image fallback widget.
- Gate: analyze 0 issues, **37 tests** passing, coverage 62.6% (incl.
  generated code).

## Phase 2: Home (done)

- Faceted gradient header, avatar, bell with unread dot, headline, glass
  search pill and filters button, category chips that filter for real,
  "Upcoming Events" PageView carousel (scale/dim/parallax, location chip,
  bookmark, avatar stack +N, date, arrow), more sections with compact cards,
  See All with sorting, live search, filters sheet with live count, pull to
  refresh, skeleton/error/empty states, favorites, notifications and profile
  tabs, Home golden.
- Polish after review: carousel titles shrink to fit on one line like the
  reference (`FitTitle`, 20 down to 16 pt) and the carousel card is a little
  wider (viewport 0.8); fixed an off-screen tap warning in the See All test;
  removed a leftover `if true; then` from `tool/check.sh`.
- Gate: analyze 0 issues, **62 tests** passing, coverage 85.6% (hand-written
  code).

## Phase 3: Event Details (done)

- Hero photo with parallax and overscroll stretch, drag-down-to-dismiss with
  an interactive scale, glass back/bookmark, top bar that turns solid with the
  event title, sheet entrance spring.
- Title, date, address, gradient price, participants (sheet), About Event
  with inline "See more...." / "See less" (animated), mini-map (tap opens the
  full map focused on the event, long-press opens directions), organizer with
  Follow, lineup timeline, ticket policy, rating summary, reviews with "See
  all", similar events, bottom bar with Share and the animated Get a Ticket
  button; sold-out state with Join waitlist.
- Routes: `/<tab>/event/:id`, `/<tab>/event/:id/tickets`,
  `/<tab>/event/:id/map`; Hero tag passed from the source card.
- Tests: layout, See more expand/collapse, bookmark through the repository,
  Get a Ticket (loading, check, navigation), Follow, Hero navigation from a
  Home card and back, mini-map opens the focused map, Details golden.
- Gate: see the Phase 3/4 gate below.

## Phase 4: Map and location (done)

- Explore tab: full-screen light-gray map with street labels, white back and
  locate-me buttons, floating preview card (tap opens details), pulsing
  marker on the selection and mini pins for other events (tap selects).
- Draggable sheet with three snap points (0.3 / 0.5 / 0.9); the camera keeps
  the selected marker centred in the visible map area while the sheet moves.
- Search (event, venue, address), Filters sheet, "Nearest Location" list
  sorted by Haversine distance with tinted pins (purple/orange alternating),
  purple selection border and an animated fly-to (zooms out slightly on long
  hops, honours reduce-motion).
- Locate me: asks for permission via `LocationService`, shows the blue user
  dot and re-sorts distances; denied/disabled shows a message and keeps the
  demo location.
- Continue: opens the selected venue's events (a sheet when the venue has
  several, details when it has one). The nav pill hides on the full-screen
  map, as in the reference; back returns Home.
- Tests: Haversine sorting and reference distances (3.11KM, 5.21KM), re-sort
  from a new origin, query and filter narrowing, layout, selection highlight +
  preview + marker, search and empty state, locate-me granted and denied,
  sheet snapping, Continue and preview navigation, back, Explore golden.

### Phase 3/4 gate

Final gate (2026-10-21, `work/gate.sh`, each test file run separately):

- `dart format lib test`: 88 files, 0 changed
- `flutter analyze`: **No issues found**
- `flutter test`: **85 passed, 0 failed** across 16 files (incl. 3 goldens:
  home, details, explore)

Fixes made to get green: the ticket button and locate-me awaited
`HapticFeedback` before updating state, which stalled the flow (the loading
state and the fly-to-user never ran in tests); haptics are now fire-and-forget.
The details tests used an ambiguous `Scrollable` finder (the sheet holds nested
horizontal scrollables); they now target the outer scroll view.

## Phase 5: Onboarding, auth, interests (done)

- **Splash** (`/splash`): faceted gradient, logo scales in with a glow,
  tagline fades in; restores the stored session (at least 1.1 s on screen)
  and hands over to the router guard.
- **Onboarding** (`/onboarding`): three photo slides with gradient overlay
  ("Discover events near you", "Book in seconds", "Enter with a tap"),
  animated page indicator, Skip, gradient Next / Get Started. Shown once per
  device (`onboarding.seen`).
- **Login** (`/auth/login`): gradient header "Welcome back", white form card,
  email + password with show/hide, inline validation, Forgot password,
  gradient Log In, **Try demo account** (`demo@eventra.app`, created on first
  use), Continue as guest, Sign Up link. Errors shake the card; 5 failed
  attempts lock that email for 30 s with a live "Try again in Ns" countdown.
- **Sign up** (`/auth/signup`): name, email, optional phone, password with an
  animated 4-bar strength meter (Weak/Fair/Good/Strong), confirm, terms
  checkbox, duplicate-email error.
- **OTP** (`/auth/otp`): 6 boxes over one hidden field (auto-advance,
  backspace, paste, iOS one-time-code autofill), auto-submit, 30 s resend
  countdown, codes expire after 10 min; the mock code `123456` is shown only
  in debug builds (`kDebugMode`).
- **Forgot password** (`/auth/forgot`): email, then code + new password
  (strength meter); local demo flow, nothing leaves the device.
- **Interests** (`/interests`): "What are you into?", 12 icon pill chips that
  spring-scale on selection, Continue enabled at 3+, stored per user (guests
  have their own set); editable from Profile (`/interests?edit=1`).
- **Location setup** (`/location-setup`): "Use my current location" (picks the
  nearest covered area via `LocationService`, denied falls back to the list)
  or a house-style city list; saved as the home city; Skip for now.
- **Guards** (`lib/app/auth_guard.dart`, pure function, unit-tested):
  everything waits on the splash until the session is restored; first launch
  goes to onboarding; signed-out users only see onboarding/auth; guests browse
  Home, Explore, Details and Favorites; `*/tickets`, `/checkout*`,
  `/my-tickets*` need an account and return to `from` after login (off-site
  `from` values are ignored). The router re-runs the guard whenever auth or
  the onboarding flag changes, so Log out lands on Login.
- **Profile** shows the signed-in user (initials avatar; the demo account
  keeps its portrait) or "Guest" with a Log in button; Interests and Log out
  (with confirmation) actions. The Home header avatar follows the user.

### Security model (local demo backend)

- `AuthRepository` interface; `LocalAuthRepository` keeps accounts in the
  drift DB (`users` table, created idempotently by raw SQL in
  `kExtraSchema` because build_runner is unavailable here).
- Passwords: PBKDF2-HMAC-SHA256, 16-byte random salt per user, 60,000
  iterations in production (run on a background isolate), iteration count
  stored per row so it can be raised later; constant-time comparison. Only
  the hash and salt are stored, never the password.
- Session: random 256-bit token + expiry (30 days) in
  `flutter_secure_storage` (Keychain / Keystore); expired or corrupt sessions
  are discarded at launch.
- Lockout and OTP state are in memory (reset on app restart), which is fine
  for a local demo; a real backend enforces them server-side.

### New dependencies and why

| Package | Why |
| --- | --- |
| `crypto` | Vetted HMAC-SHA256 used by our small PBKDF2 (pure Dart, already transitive; no native code). PBKDF2 is checked against the RFC 7914 vector. |
| `flutter_secure_storage` | Spec: session token in the platform keystore, not plain prefs. |
| `shared_preferences` | Non-secret settings: onboarding flag, guest mode, interests, home city. |
| `add_2_calendar`, `flutter_local_notifications`, `timezone`, `qr_flutter`, `screen_brightness` | Resolved now for Phase 7 (calendar export, reminders, QR wallet at full brightness); not imported yet. |

### Tests added

- `test/core/pbkdf2_test.dart`: RFC 7914 vector (`passwd`/`salt`/1 iter/64
  bytes), argument checks, constant-time compare, base64url, salted hashes.
- `test/features/auth/auth_repository_test.dart` (fake clock, 2 PBKDF2
  iterations): duplicate email (case-insensitive), weak password, no
  plain text in the row, OTP wrong/right/expired, 5-strike lockout and
  recovery after 30 s, relaunch restores the session, 30-day expiry, corrupt
  storage, demo account, password reset, strength heuristic and validators.
- `test/app/auth_guard_test.dart`: splash wait, onboarding once, signed-out,
  guest and signed-in redirects, `from` round trip, off-site `from` ignored.
- `test/features/auth/auth_flow_test.dart` (widgets): first launch splash ->
  3 slides -> login; demo login -> interests (min 3) -> city -> Home, then a
  relaunch over the same DB/keychain goes straight Home; validation +
  lockout countdown; guest Get a Ticket -> login -> back to tickets; sign up
  with strength meter -> OTP (wrong, then 123456) -> interests; Profile log
  out and guest Profile.
- Test harness: in-memory prefs/secure storage, signed-in demo user by
  default, low-iteration hasher, optional shared in-memory DB.

**Gate (Phase 5):** dart format clean, `flutter analyze` No issues found, `flutter test` 111 passed / 0 failed across 20 files (run file-by-file with -j 1 due to sandbox memory).

## Phase 6: Search, filters, smart feed (done)

- **SmartFeedScorer** (`lib/features/feed/domain/smart_feed_scorer.dart`,
  pure Dart, deterministic, no clock or randomness): score 0..100 =
  interests 35 (event category covered by any chosen interest) + proximity
  25 (full within 1 km, linear to 0 at 40 km, Haversine from the origin) +
  popularity 15 (70% log-scaled attendance capped at 2,000, 30% rating) +
  recency 15 (1 once started, halves every 14 days) + social/favorites 10
  (1 for an organizer you saved before, else saved events in the same
  category / 3; the event itself never counts). Ties break on start time
  then id. Up to 3 reason chips, strongest contribution first: "Because you
  like X", "Near you" (<= 5 km), "Trending" (>= 500 going), "Starts soon" /
  "This week" (<= 7 days), "Like your saves".
- **Upcoming order** (Recommended sort): editorial picks that match your
  interests (or all of them when you have none) lead in editorial order,
  everything else follows by score. The reference card stays first for a
  music fan, while a sports-only user sees sports first.
- **"Because You Like X" rows** from the Phase 5 interests (up to 2 rows; an
  interest whose categories are already shown is skipped; "Recommended For
  You" when there are no interests). Compact cards show the strongest other
  reason, or the distance.
- **Origin**: the onboarding home city now drives distances (Home, Explore,
  filters, scorer) until device location is granted; changing the city
  updates everything live.
- **Filters sheet** (shared by Home, See All, Search and Explore):
  multi-select categories, date presets (Today, Tomorrow, This Weekend, Next
  7 days) plus a custom range picker (both end days included; events match
  when they overlap the window), price range slider ($0 to $150+), distance
  radius (1 to 50 km, "any" at the end, from the current origin), Free
  only, Has tickets left, sort; Reset; live "Show N results". The filter
  badge counts refinements. See All gained a filters button, sort chips that
  edit the shared sort, and a reset empty state. Explore ignores the radius
  and sort (its list is distance-sorted by design).
- **Search screen**: 250 ms debounce, ranking (title prefix > word prefix >
  title substring > venue/address > category, then soonest), highlighted
  matches in title and venue/address, result count, filters button with
  badge and "Clear filters"; recent searches persisted per account in
  settings (max 10, case-insensitive de-dupe, newest first) with swipe to
  delete + Undo and Clear all + Undo; trending chips (top categories by
  attendance, then most attended events); no-results state with suggestion
  chips and Clear filters / Clear search.
- **Quick preview**: long-press on carousel cards, compact cards and list
  tiles opens a blurred-backdrop popup with photo, price, date, distance,
  venue, reason chips, Save, Share and View event (haptic on open).
- Recent searches live in the settings store (shared_preferences) behind
  `RecentSearchesRepository`; no new DB tables were needed.

### Tests added (Phase 6)

- `test/features/feed/smart_feed_scorer_test.dart`: weights sum to 100,
  perfect event = 100 / irrelevant ~0, interest worth exactly 35,
  proximity/popularity/recency/affinity boundaries, reason thresholds and
  order (max 3), determinism under shuffling and tie-breaks, interests
  reorder the feed, editorial pinning rules.
- `test/features/feed/feed_location_test.dart`: default origin; home city
  becomes the origin and follows a new choice.
- `test/features/home/filters_logic_test.dart`: preset windows (incl. month
  roll-over), overlap matching, custom range end-day inclusion, multi
  categories, price range, distance radius, refinement count, set-order
  equality, smart Recommended sort, interest rows.
- `test/features/search/search_logic_test.dart` and
  `recent_searches_repository_test.dart`: ranking, highlight ranges,
  trending terms; add/trim/de-dupe/cap/remove/restore/clear, per-account
  scope.
- `test/features/search/search_screen_test.dart` (widgets): debounce,
  highlighted results, recents saved on open; swipe delete + undo, clear all
  + undo, tap a recent; no-results suggestions; filters narrow and clear.
- `home_screen_test.dart`: long-press quick preview (reasons, Save, View
  event) and interest rows.

**Gate (Phase 6):** dart format clean, `flutter analyze` No issues found, `flutter test` 154 passed / 0 failed across 26 files (43 new tests in 6 new files plus 2 new Home widget tests; run file-by-file with -j 1 due to sandbox memory). Home, Event Details and Explore goldens unchanged.

---

## Known limitations

- **Map tiles**: CARTO's keyless Positron raster endpoint now returns an "API
  KEY REQUIRED" watermark tile, so the default `MapStyle` uses OpenStreetMap
  tiles drawn through a grayscale "Positron" filter. It looks like the
  reference, but OSM's public tile servers are for light use only; a
  production build should point `MapStyle` at a provider with an agreement
  (CARTO with a key is already defined as `MapStyle.cartoPositron`).
- Venue search is a local index over the seed (event, venue, address);
  geocoding of arbitrary addresses is not built.
- Marker clustering and price/category mini-pins at high zoom are not built;
  the map shows the 40 nearest events as pins.
- Location setup uses a city list rather than Explore in onboarding mode;
  the chosen city is the origin for distances and the smart feed until GPS
  is allowed.
- Not built in Phase 6: voice search (needs `speech_to_text`), the "Friends
  going" filter and friends signal (there is no social graph yet; the
  social share of the score comes from your saves), reason chips on Event
  Details (they are on the quick preview).
- Not built in Phase 5: biometric login toggle (needs `local_auth`), Google /
  Apple sign-in (spec: feature-flagged, hidden when unavailable; they are
  hidden), a Firebase `AuthRepository`.
- Ticket purchase is a placeholder screen (Phase 7 in the plan).
- Goldens are rendered on Linux (arm64) with the Flutter test font stack; on
  another OS, regenerate them before comparing.
- Device-only behaviour (real GPS permission prompts, share sheet, opening
  the maps app) is covered through abstractions in tests, not on a device.
