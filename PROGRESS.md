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

---

## Known limitations

- **Map tiles**: CARTO's keyless Positron raster endpoint now returns an "API
  KEY REQUIRED" watermark tile, so the default `MapStyle` uses OpenStreetMap
  tiles drawn through a grayscale "Positron" filter. It looks like the
  reference, but OSM's public tile servers are for light use only; a
  production build should point `MapStyle` at a provider with an agreement
  (CARTO with a key is already defined as `MapStyle.cartoPositron`).
- Venue search is a local index over the seed (event, venue, address);
  geocoding of arbitrary addresses and recent searches are not built yet.
- Marker clustering and price/category mini-pins at high zoom are not built;
  the map shows the 40 nearest events as pins.
- Onboarding-mode Continue (save a chosen city) arrives with onboarding in a
  later phase; Continue currently uses Explore-mode behaviour.
- Ticket purchase is a placeholder screen (Phase 7 in the plan).
- Goldens are rendered on Linux (arm64) with the Flutter test font stack; on
  another OS, regenerate them before comparing.
- Device-only behaviour (real GPS permission prompts, share sheet, opening
  the maps app) is covered through abstractions in tests, not on a device.
