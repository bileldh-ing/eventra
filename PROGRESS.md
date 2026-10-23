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
`test/features/explore/goldens/explore.png`,
`test/features/tickets/goldens/checkout.png`,
`test/features/tickets/goldens/ticket_detail.png` (390x844 logical at 2x,
real fonts, fixture photos and fixture map tiles).

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

## Phase 7: Tickets, checkout, wallet (done)

Replaces the Phase 2 ticket placeholder with the full money flow. All money
is integer cents; nothing uses doubles after reading the seed's tier prices.

- **Tier picker** (`/<tab>/event/:id/tickets`): seed tiers (Early Bird,
  General Admission, VIP; free events have one RSVP tier) with perks, price,
  "N of M left" and a progress bar, "Only N left" at 10 or fewer, greyed
  Sold out cards. Steppers stop at the per-tier limit (Early Bird 4, VIP 4,
  GA 8, RSVP 2), at live stock and at 8 tickets per order (banner when
  reached). Bottom bar: running subtotal, fees and tax, total.
- **Holds** (`TicketingRepository.createHold`): Continue reserves the seats
  for 10 minutes, all-or-nothing, replacing the user's earlier hold for the
  same event. Each tier change is one conditional `UPDATE ... WHERE capacity
  - sold - held >= ?` inside a transaction, and `tier_stock` has a `CHECK
  (sold + held <= capacity)`, so overselling is impossible. Expired holds are
  swept (seats released) before every read and write; Back from checkout
  asks, then releases.
- **Checkout** (`/checkout/:holdId`, outside the tabs): countdown banner
  with a ring (purple, orange under 2 min, red under 1 min; on expiry Pay is
  disabled and "Choose again" returns to the picker), order summary,
  attendee name and email prefilled from the account and validated, promo
  codes, payment methods, price details, refund policy line, "Pay $X" (or
  "Confirm free reservation"; free orders skip payment).
- **Promo codes** (`domain/promo.dart`): `EVENTRA10` 10%, `WELCOME5` $5 off
  once per account with a $10 minimum, `VIP20` 20% on VIP only, `SUMMER25`
  expired, `FLASH50` fully redeemed. Validation covers the date window,
  global and per-user usage (redemptions table; a refund frees the use), tier
  restrictions and minimum spend. Codes are case and space insensitive.
- **Pricing** (`domain/pricing.dart`): discount only on eligible tiers and
  never above them; service fee $1.50 per paid ticket + 3% of the discounted
  subtotal (none when it is $0); tax 8.875% on discounted subtotal + fees;
  half-up integer rounding.
- **Payments** (`PaymentGateway` interface, `MockPaymentGateway`): saved
  demo cards (Visa 4242; Mastercard 4444 asks for 3-D Secure), or a new card
  in a sheet with Luhn, brand detection, number and MM/YY formatting, expiry
  and CVC checks. Test numbers: `4000 0000 0000 0002` declined, `...0119`
  timeout, `...3220` 3-D Secure. The 3-D Secure sheet (Approve / Cancel) is
  shown mid-charge. Only brand and last four are stored. Processing overlay,
  then an animated check, then the success page.
- **Idempotency**: one key per payment attempt. The repository dedupes
  in-flight calls by key, returns the stored order for a known key (UNIQUE
  column) and the gateway dedupes charges by key; a failed attempt gets a
  new key. If a hold lapsed during a slow 3-D Secure and the seats were
  taken, the charge is refunded instead of overselling.
- **Orders and tickets**: `orders` (with an event snapshot so tickets open
  offline), `order_items`, `tickets` (one per seat), `promo_redemptions`,
  all raw SQL in `kExtraSchema` (build_runner is unavailable here).
- **Success page** (`/booking-success/:orderId`): "You're in!", the ticket
  slides up with a bounce, the perforation draws in and a holographic shine
  sweeps once; View Ticket(s), Add to Calendar, Invite Friends, Done; back
  goes to My Tickets, never to the finished checkout.
- **My Tickets tab** (new 4th nav item, `/tickets`; `/my-tickets` and
  `/profile/tickets` redirect): Upcoming / Past / Cancelled with counts,
  swipeable, wallet-style perforated cards with status chip; empty state with
  Explore events.
- **Ticket page** (`/tickets/:ticketId`): perforated ticket, status chip
  (Valid / Used / Expired / Cancelled), signed QR that rotates every 30 s
  with a countdown ring (`QrTokenService`: `ETK1.ticket.event.holder.window.sig`,
  HMAC-SHA256 with a per-event key derived from a device key kept in secure
  storage; verifies offline, accepts the previous window for clock skew,
  rejects tampering), screen brightness at max while open and restored on
  leave, Add to Calendar (`add_2_calendar`), Directions, Invite friends,
  Event details, order breakdown, refund.
- **Refunds** (`RefundPolicy`): full refund when cancelled more than 48 h
  before the start, none after (free reservations cancel any time before the
  start). Refunding marks the order Refunded, cancels its tickets, restores
  stock, frees the promo use, cancels reminders; repeating it is a no-op.
- **Reminders** (`ReminderScheduler`; `LocalReminderScheduler` on
  flutter_local_notifications + timezone, absolute UTC instants): 24 h and
  2 h before the start, skipping times already past; tapping opens the
  ticket. Android: POST_NOTIFICATIONS and RECEIVE_BOOT_COMPLETED
  permissions, the plugin's scheduled/boot receivers, core library
  desugaring (`desugar_jdk_libs` 2.1.4). Inexact alarms, so no exact-alarm
  permission.
- **Guards**: `/tickets*`, `/checkout*`, `/booking-success*` and
  `*/tickets` need an account; guests log in and return to `from`.
- Device services (brightness, calendar, share, reminders, payment, ids)
  are providers with fakes in tests.

### Tests added (Phase 7)

- `test/features/tickets/pricing_promo_test.dart` (15): cents and rounding,
  fee/tax math, percent, tier-restricted and fixed promos, free tickets,
  every promo error (empty, unknown, expired, not yet active, exhausted,
  already used, not applicable, minimum spend), tier limits and the 8 cap.
- `test/features/tickets/cards_qr_refund_test.dart` (12): Luhn, brand,
  formatting, expiry/CVC; QR sign/verify, rotation and skew window,
  tampering, wrong key, malformed; refund policy boundaries; reminder times
  and ids.
- `test/features/tickets/ticketing_repository_test.dart` (16, in-memory
  drift + fake clock): hold/release, expiry at 10:00, replacing holds,
  selection validation, all-or-nothing, **20 concurrent buyers for 5 seats
  -> exactly 5 holds**, CHECK constraint, order conversion, **3 concurrent
  + 1 repeated placeOrder with one key -> one order, one charge**, decline
  then retry, timeout and cancelled 3-D Secure not charged, promo per user,
  lapsed hold refunded, free orders, refund restores stock and promo, no
  refund within 48 h, other users cannot refund.
- `test/features/tickets/checkout_flow_test.dart` (9, widgets): picker
  totals, limits, low stock, order cap; end-to-end picker -> hold ->
  expired then valid promo -> pay -> success -> reminders, calendar, invite
  -> My Tickets -> QR ticket with brightness boost/restore; double tap pays
  once; declined new card (Luhn error first) then saved card; 3-D Secure
  cancel then approve; hold countdown expiry; leave checkout releases seats;
  attendee validation; checkout golden.
- `test/features/tickets/my_tickets_test.dart` (6): tabs with counts and
  swipe; empty state; guest redirected to login; QR rotation at 30 s with
  signature verification; calendar, share and refund restoring stock and
  cancelling reminders; ticket detail golden.
- `test/app/auth_guard_test.dart`: +1 for the new protected paths.
- Updated: Event Details "Get a Ticket" now lands on the tier picker; Home
  golden re-rendered for the 5-item nav pill.

**Gate (Phase 7):** dart format clean, `flutter analyze` No issues found,
`flutter test` **213 passed / 0 failed** across 31 files (58 new tests in 5
new files plus 1 guard test; run file-by-file with -j 1 due to sandbox
memory). Goldens: Home updated (nav pill), Checkout and Ticket added; Event
Details and Explore unchanged.

---

## Phase 8a: Profile, settings, favorites, notifications, reviews (done)

Version 0.8.0+8. Localization/RTL and the dark palette are Phase 8b; every
new screen reads colors from `EventraTokens`, so they inherit it.

- **Profile**: initials avatar on a chosen color, name, email, city, bio and
  live stats (valid tickets, saved events, reviews written). Edit profile
  (`/profile/edit`) validates name (2-50), city (60) and bio (160); saving
  renames the account (`users.name`) and upserts `profiles` in one
  transaction, then swaps the signed-in user so Home/checkout use the new
  name. Unread badge on the Notifications row; Settings row.
- **Settings** (`/profile/settings`, persisted in prefs via
  `SettingsController`):
  - Theme mode System/Light/Dark wired to `MaterialApp.themeMode` (dark
    theme comes from `buildEventraTheme(brightness:)` and
    `EventraTokens.forBrightness`, which returns the light tokens until the
    dark palette lands).
  - Language EN/FR/AR persisted (strings wired in 8b).
  - Notifications: *Event reminders* gates the Phase 7 scheduler (off: new
    orders schedule nothing and existing reminders are cancelled; on again:
    reminders are rescheduled for paid upcoming orders); *Order updates*
    gates the inbox items for confirmations/refunds; *Recommendations* hides
    new-event and price-drop items.
  - Privacy: *Personalized feed* off makes the smart feed ignore interests.
  - Clear cache (memory + disk image cache, recent searches), About with the
    version (`kAppVersion`, test-checked against pubspec), Log out, and
    Delete account (type DELETE to confirm): releases open holds, cancels
    reminders, deletes the user's orders/tickets/holds/promo uses/reviews/
    notifications/profile/account and per-user prefs, then signs out.
- **Favorites**: list/grid toggle and sort (recently saved, soonest, price,
  name), both persisted; swipe to remove with Undo in both views; empty
  state with a link Home.
- **Notification center**: `notifications` table + `NotificationsRepository`
  per scope (user id or guest). A welcome set is seeded once per scope
  (friends going, coming up soon, a review prompt for a finished event, new
  event, price drop). Orders add "Booking confirmed" and refunds add "Refund
  issued" (deep-link to the ticket). Unread dot on the Home bell and count on
  Profile; mark all read; swipe dismiss with Undo (persisted); tap marks read
  and opens the ticket or event.
- **Reviews**: `reviews` table with `CHECK (rating BETWEEN 1 AND 5)` and
  `UNIQUE (event_id, user_id)`. `ReviewRules` (pure) validates 1-5 stars and
  10-500 characters and decides eligibility; `ReviewsRepository` re-checks
  every rule on write: only a signed-in user holding a non-cancelled ticket
  for an event that has ended may review, once; only the author can edit or
  delete. Event Details shows average, count, a 5-to-1 histogram, the three
  newest reviews and a Write / Edit button or the reason you cannot review;
  `/<tab>/event/:id/reviews` lists all reviews with star filters and sort.
  The editor sheet has animated stars, a live character counter and inline
  errors.
- **Seed**: four past events were added (`evt-p01`..`evt-p04`, Sept-Oct
  2026, tagged `past`, sold out, not featured) so reviews have finished
  events. Catalogue reviews are imported into `reviews` once, plus seven
  attendee reviews per past event. Logging in with the demo account gives it
  a ticket to the most recent past event (`ensureDemoPastOrder`), so reviews
  can be tried right away.
- Fix: the router guard now refreshes only when the sign-in *status*
  changes, so swapping the user object (profile edit) does not re-run routing
  mid-navigation. Settings cards paint their surface with `Material` so list
  tile ink is visible.

### New dependency
| Package | Why |
| --- | --- |
| `flutter_cache_manager` (was transitive via `cached_network_image`) | Clear cache empties the on-disk image cache. |

### Tests added (Phase 8a, 43 tests in 7 files)
- `test/features/reviews/review_rules_test.dart` (5): rating and length
  rules, eligibility matrix, summary math.
- `test/features/reviews/reviews_repository_test.dart` (8): no ticket,
  not ended, cancelled ticket, create/duplicate/edit/delete and ownership,
  validation on create and update, DB unique constraint, seeding, summary.
- `test/features/reviews/reviews_screen_test.dart` (4, widgets): details
  summary/histogram, no ticket on upcoming events, write -> edit -> delete,
  See all with star filter and sort.
- `test/features/notifications/notifications_repository_test.dart` (5):
  seed once per scope, scopes isolated, add/mark read/mark all, remove and
  restore, kind parsing.
- `test/features/notifications/notifications_screen_test.dart` (3,
  widgets): swipe dismiss persisted + undo, tap opens event and marks read,
  purchase adds a confirmation that opens the ticket.
- `test/features/settings/settings_test.dart` (11): defaults, persistence
  across relaunch, corrupt values, version vs pubspec, reminders on/off
  gating and reschedule, order-update items on purchase/refund and when off,
  theme mode wired to `MaterialApp`, recommendations hidden, clear cache,
  delete account confirm.
- `test/features/profile/profile_favorites_test.dart` (7): initials and
  validators, edit profile end to end (persisted), Settings entry, favorites
  empty state, grid/list + sort persisted, swipe remove + undo, sort logic.
- Updated: seed integrity allows `evt-p*` past events; Home/filter tests use
  upcoming events.

**Gate (Phase 8a):** dart format clean, `flutter analyze` No issues found,
`flutter test` 256 passed / 0 failed across 38 files (run file-by-file with
-j 1).

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
- Ticketing (Phase 7) runs on the device: the mock gateway never charges a
  real card, and the QR signing key lives in this device's secure storage,
  so an organizer scanner (Phase 9) needs the same per-event key provisioned
  from a backend. Not built in Phase 7: ticket transfer to a friend,
  Apple/Google Pay and cash-at-venue methods, a debug outcome switcher for
  payments, gyroscope tilt on the ticket shine, waitlists, saving new cards.
- Live stock is tracked in `tier_stock`; since Phase 10a the cards, Event
  Details CTA and the map sheet read it too (sold + running holds). The
  Home "tickets left" filter still uses the catalogue snapshot.
- Phase 8a: language choice is stored but strings are English until 8b;
  dark mode uses the light tokens until the dark palette lands (8b). Review
  tags and helpful votes from the spec are not built. Since Phase 10a event
  cards, details and the map sheet show the live average from the `reviews`
  table (the catalogue aggregate only while an event has no stored reviews). Deleting an account does not refund or
  restock its tickets (the dialog says so).
- Goldens are rendered on Linux (arm64) with the Flutter test font stack; on
  another OS, regenerate them before comparing.
- Device-only behaviour (real GPS permission prompts, share sheet, opening
  the maps app) is covered through abstractions in tests, not on a device.

## Phase 8b: i18n (EN/FR/AR), RTL, dark palette

- 551 ARB keys in `lib/l10n/app_{en,fr,ar}.arb` (18 plurals with full Arabic plural forms), generated with `flutter gen-l10n` into `lib/l10n/gen`.
- Locale wired to `MaterialApp`; context-free code reads `AppLocale` (`lib/l10n/l10n.dart`). Dates, times, numbers and currency follow the locale.
- Full RTL: directional insets/alignment, mirrored icons and nav pill, bidi isolation for addresses and counts. Bundled Noto Sans Arabic (OFL 1.1) as fallback.
- Dark token set across every screen, dimmed/inverted map tiles, WCAG AA contrast checked by test.
- New goldens: `test/l10n/goldens/home_dark.png`, `home_ar.png`, `details_dark.png` (reviewed).
- Known limits: Design System dev screen is English-only; notifications keep the language active when created; seed event content is English.

**Gate (Phase 8b):** dart format clean (187 files), `flutter analyze` No issues found, `flutter test` 300 passed / 0 failed (file by file, -j 1). Version 0.8.1+9.

## Phase 9: Organizer mode (done)

- **Mode switch**: Profile shows an Attendee/Organizer switch for signed-in accounts (persisted per account in prefs, `organizer.mode.<userId>`); turning it on opens the dashboard. All `/organizer/*` routes are guarded in `authRedirect` (guest -> login, mode off -> `/profile`). The demo account publishes as the seeded organizer *Pulse Live Co.* (`org-pulse`, 5 seeded events); any other account publishes under its own name.
- **Dashboard** (`/organizer/dashboard`): gradient cards for revenue, tickets sold (with sell-through of capacity) and check-in rate; 14-day sales area chart (`SalesLinePainter`, CustomPainter, mirrored in RTL); sales by tier with fill bars; drafts (resume/delete); upcoming events with status chips (On sale / Live / Sold out), Check-in and Edit actions. Aggregates are a pure function (`computeDashboard`): catalogue sales already on each tier (spread deterministically over the 21 days before the seed date) + paid app orders (refunds and demo history excluded); check-in rate = used / non-cancelled tickets on the door lists.
- **Create/edit wizard** (`/organizer/events/new`, `/organizer/drafts/:id`, `/organizer/events/:id/edit`): 6 steps with progress bar — basics (title 3-80, category, description 20-2000), date and time (future start, end after start, max 7 days; editing a started event keeps its date), venue (name, address, pin placed by tapping a flutter_map map or "Use my location"), tiers and pricing (1-5 tiers, unique names, integer-cent prices 0-10,000 parsed from `12`, `12.5`, `12,50`, quantity 1-100,000 and never below seats sold), cover from the bundled Unsplash set, review and publish. Draft autosave (800 ms debounce + on leave + explicit Save draft) in `event_drafts`. Publishing writes `organizer_events` + `tier_stock` in one transaction (the stock CHECK rejects shrinking below sold/held and rolls the edit back); published events join `eventsProvider`, so they appear in the attendee feed, search, map and are bookable.
- **Check-in** (`/organizer/events/:id/check-in`): camera scanning via `mobile_scanner` 7.4.2 (resolved from the pub mirror) behind `CodeScannerBackend`, rounded scan frame with sweeping line, typed-code fallback (QR payload or ticket id) and a camera-unavailable state. Verification = HMAC-SHA256 signature + 30 s window (current or previous) offline, then event match, ticket exists and belongs to the signed holder, not cancelled, then an atomic `UPDATE tickets SET status='used' WHERE status='valid'` (exactly-once even under concurrent scans). States: Valid (green), Already checked in with first time (amber), Wrong event (red), Expired / Invalid-forged (red), Cancelled (gray), with haptics and a colored result sheet. Attendee list with search (name, tier, ticket id) and manual check-in; counter "x of y checked in". Every check-in is queued in `checkins` (`synced = 0`) and pushed through `CheckInSync` (demo endpoint); a pending chip shows the backlog and retries. Demo door lists are seeded for the demo organizer's events (4 guests per tier).
- **i18n**: 112 new keys (EN/FR/AR, 4 new plurals with full Arabic forms), 663 keys total; all organizer screens use tokens (dark-mode aware) and directional layout.
- **Schema**: `organizer_events`, `event_drafts`, `checkins`, index `tickets_event` added to `kExtraSchema` (raw SQL, created idempotently).
- **Tests** (new files `test/features/organizer/`): `check_in_test.dart` (13: valid, skew window, expired, future, tampered/foreign key/malformed, unknown ticket and holder mismatch, wrong event, cancelled, already checked in, concurrent idempotency, door list, guest seeding, offline queue), `wizard_dashboard_test.dart` (16: per-step validation, price parsing, JSON round-trip, drafts, publish, edit with stock CHECK rollback, ramp split, aggregates, series), `organizer_screens_test.dart` (10: guard, scan-result widget EN/FR/AR and colors, Profile switch -> dashboard, deep-link guard, check-in screen scan/duplicate/manual/forged/list/search, camera fallback, wizard validation + autosave, resumed draft publishes into the feed and is bookable, dashboard golden `test/features/organizer/goldens/dashboard.png`, reviewed).
- **Known limits**: cover images are picked from the bundled set (no image_picker/upload); the sync endpoint is the local demo; organizer "live" status uses the device clock; no per-event dashboard drill-down yet.

**Gate (Phase 9):** dart format clean (202 files), `flutter analyze` No issues found, `flutter test` 339 passed / 0 failed across 45 files (file by file, -j 1; +39 tests: 13 check-in, 16 wizard/dashboard, 10 organizer screens incl. golden). New dependency `mobile_scanner` ^7.1.0 (resolved 7.4.2). Version 0.9.0+10.

## Phase 10a: polish, consistency, coverage, app-store CI/CD

- **Consistency**: the 47 seed policies promised a 7-day / 50% tier the app never applied; seed text now matches `RefundPolicy` (full refund more than 48 h before the start, none after), and Event Details renders `RefundPolicy.summary` (localized) so the card always states the enforced rule. New `liveEventStatsProvider` (`lib/features/events/presentation/live_event_stats.dart`) reads `tier_stock` (sold + running, unexpired holds) and the `reviews` table in two queries, refreshed on every ticketing/review write. Cards (carousel, compact, list), the details price block and CTA, the Explore preview card, nearest list and venue sheet show live "Only N left" / "Sold out" (the CTA switches to Sold Out + waitlist) and the live review average ("★ 4.7 (3)"), falling back to the catalogue only when nothing is stored.
- **Accessibility / performance**: glass icon buttons keep a 48 dp tap target whatever their visual size; carousel avatars, details participants row and the Explore search field now meet 48 dp; event photo on details, rating labels and the sales chart carry semantic labels (QR already did); decorative card photos are excluded from semantics. `RepaintBoundary` around the Explore and wizard maps, the rotating QR and the chart; details hero image decoded at 1200 px. Compact cards give the photo the leftover height, fixing an overflow at 1.3x text. `debugPrint` replaced by `logWarning` (`dart:developer`). 3 new ARB keys (EN/FR/AR).
- **Coverage**: `tool/coverage.py` merges lcov files and excludes generated code (`*.g.dart`, `*.freezed.dart`, `lib/l10n/gen`); CI enforces `tool/coverage_threshold.txt` (89.5 %, measured 91.50 % on CI minus 2). New tests: `test/features/events/live_stats_test.dart` (8), `test/a11y/accessibility_test.dart` (9: six screens at 1.3x text, tap-target + labelled-target guidelines on Home, Details, Explore), `test/features/coverage_gaps_test.dart` (5: forgot-password flow, share text, profile model/validators).
- **CI/CD** (`.github/workflows`, Flutter pinned to 3.47.x, `environment.flutter` added to pubspec): `ci.yml` (format, gen-l10n drift, analyze, tests + coverage threshold, lcov artifact, debug APK), `android-release.yml` (AAB + APK, upload-key signing from secrets with debug-key fallback, `android/app/build.gradle.kts` reads `key.properties`, optional Play internal draft upload), `ios-build.yml` (unsigned `flutter build ipa --no-codesign`; signed IPA + TestFlight path gated on secrets, `ios/ExportOptions.plist` template), `release.yml` (tag `v*` → calls both builds → GitHub Release with the CHANGELOG section and artifacts). Fastlane skeletons with placeholder store metadata in `android/fastlane`, `ios/fastlane`; `docs/RELEASE.md` (secrets, keystore, versioning, store checklist); `CHANGELOG.md`. No store upload has been run or verified.
- **Goldens** regenerated and reviewed: `home.png`, `details.png`, `explore.png`, `l10n/home_dark.png`, `home_ar.png`, `details_dark.png` (rating label, 48 dp bookmark box, stock badges).

**Gate (Phase 10a, GitHub CI, ubuntu x64, Flutter 3.47.7):** format clean, gen-l10n up to date, `flutter analyze` No issues found, `flutter test --coverage --exclude-tags golden` 352 passed / 0 failed, line coverage 91.50 % (10624/11611, generated code excluded), threshold 89.5 %. Local (arm64, file by file, goldens included): analyze No issues found; test totals below. Version 1.0.0-rc.1+11.
