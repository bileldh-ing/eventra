# EVENTRA case study

## The problem

Event apps tend to split into two halves that never meet: a discovery app
that links out to someone else's checkout, and an organizer tool that lives
on a laptop. Attendees lose trust when stock, prices and refund rules differ
between screens; organizers lose time at the door when the scanner needs a
network.

EVENTRA set out to show one Flutter codebase that does the whole loop well:

1. **Discover** events that fit you, on a feed and on a map.
2. **Book** with honest stock, holds and prices, and keep a ticket that
   cannot be faked or screenshotted.
3. **Go**: get in at the door, even offline, and leave a review afterwards.
4. **Organize**: publish an event, watch sales and check guests in from the
   same app.

It also had to be credible as a product: three languages including Arabic
(RTL), light and dark themes, accessibility, a test suite and a release
pipeline, with a visual standard set by a Dribbble-style reference design.

## Key decisions

| Decision | Why | Trade-off |
|---|---|---|
| Feature-first clean architecture, Riverpod 3, go_router | Each feature owns its domain, data and UI; pure-Dart domain rules (pricing, refunds, QR, scoring, check-in) are tested without widgets | More files and providers than a single-layer app |
| Drift (SQLite) as the single source of truth | Stock, holds, orders, tickets, reviews and check-ins need transactions and constraints, not key-value storage | Raw-SQL extras (`kExtraSchema`) next to generated tables |
| Database CHECK on `tier_stock` | Overselling becomes impossible even under concurrent holds, not just unlikely | Failed writes must roll back and surface a clear error |
| Integer cents everywhere | No floating-point rounding in totals, fees, tax or promos | Parsing user prices (`12`, `12.5`, `12,50`) needs care |
| HMAC-SHA256 QR with a 30 s window | Tickets verify offline and a screenshot expires within a minute | The signing key lives on the device; a real scanner fleet needs per-event keys from a server |
| Idempotency keys on payments | A double tap never charges twice | The gateway is mocked, so this proves the client contract only |
| Local demo backend with latency and fault injection | The whole app runs without servers, and error states are real code paths | Not a production backend; sync endpoints are demos |
| flutter_map + OpenStreetMap, tile provider injected | No API key to run; tests use bundled tiles so map goldens are deterministic | Public OSM tiles are not for production traffic |
| Golden, accessibility and screenshot tests from the same harness | One `TestApp` with fakes renders every screen offline, so the README screens always match the code | Goldens are platform-specific and must be regenerated per OS |
| GitHub Actions for CI, Android, iOS and tagged releases | Every push is formatted, analyzed, tested with a coverage gate and built | iOS signing and store uploads are gated on secrets that are not set |

## Challenges and how they were solved

- **Honest stock across screens.** Cards, details, the map sheet and the
  picker originally read the catalogue snapshot. A `liveEventStatsProvider`
  now reads `tier_stock` (sold plus unexpired holds) and the `reviews` table
  in two queries and refreshes on every ticketing or review write, so "Only N
  left" and the rating are identical everywhere.
- **Rules that the copy promised but the code did not enforce.** The seed
  policies advertised a 7-day / 50 % refund tier that the app never applied.
  The text was aligned with the enforced `RefundPolicy` (full refund more
  than 48 h before the start, none after) and Event Details now renders the
  policy summary from code.
- **Exactly-once check-in.** Two scanners can read the same ticket at once.
  Verification checks signature, time window, event and holder, then performs
  an atomic `UPDATE ... WHERE status = 'valid'`; the second scan reports
  "Already checked in" with the first time. Every check-in is queued for sync
  so the door works offline.
- **Arabic and RTL.** Directional insets, mirrored icons, chart and nav pill,
  bidi isolation for addresses and counts, full Arabic plural forms, and a
  bundled Noto Sans Arabic fallback.
- **Testing without a device or network.** No emulator was available, so
  everything visual is proven through widget tests: fixture photos and map
  tiles, a fixed clock, fake location, scanner, calendar and share services.
  The same harness renders the 21 README screenshots at 1170x2532.
- **Memory-constrained tooling.** Tests are run one file at a time (`-j 1`)
  locally; CI runs the full suite with coverage on GitHub's runners.

## Metrics (Phase 10b)

| Metric | Value |
|---|---|
| Tests on CI (`--exclude-tags golden,screenshots`) | 352 passing, 0 failing (Phase 10a gate) |
| Line coverage, generated code excluded | 91.50 % (10624 / 11611 lines), threshold 89.5 % |
| Hand-written Dart in `lib/` | 147 files, 27,310 lines |
| Test files / lines | 49 `*_test.dart` files (incl. the screenshot harness), 7,239 lines |
| Golden images reviewed | 9 |
| Rendered screenshots | 21 at 1170x2532 |
| Localized keys | 666 per language (EN, FR, AR) |
| Seed catalogue | 60 events (56 upcoming, 4 past) in 8 categories |
| Feature modules | 16 under `lib/features` |
| GitHub Actions workflows | 4 (ci, android-release, ios-build, release) |
| Version | 1.0.0-rc.1+11 |

## What is not done

No real-device testing by the author, mock payments only, a local demo
backend, OSM public tiles, and no biometric login, social sign-in, voice
search, friends graph, ticket transfer or organizer image upload. No store
upload has been run. See the README's "Honest limitations".
