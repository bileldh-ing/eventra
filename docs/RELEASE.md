# Releasing Eventra

This is how a build goes from `main` to the stores. The pipeline is in
`.github/workflows/`; store uploads are optional and switched on by
repository secrets. **None of the store steps has been run against a real
Google Play or App Store Connect account yet** — treat them as a starting
point to verify on the first real submission.

## Workflows

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | push to `main`/`master`, pull requests, manual | `dart format` check, `flutter gen-l10n` drift check, `flutter analyze`, `flutter test --coverage` (goldens excluded on x64 runners), coverage threshold from `tool/coverage_threshold.txt`, uploads `lcov` artifact, builds a debug APK (`eventra-debug-apk`). |
| `android-release.yml` | manual (Actions tab), called by `release.yml` | Release AAB + APK. Signed with the upload key when the signing secrets exist, otherwise with the debug key (file names end in `-debug`). Artifact `eventra-android-release` (AAB, APK, `SHA256SUMS.txt`). Optional draft upload to the Play internal track. |
| `ios-build.yml` | manual, called by `release.yml` | `flutter build ipa --no-codesign` on macOS (unsigned `.xcarchive`, zipped). With the iOS secrets: signed `.ipa` and optional TestFlight upload. Artifact `eventra-ios`. |
| `release.yml` | push of a tag `v*` | Runs the Android and iOS builds once, then publishes a GitHub Release named after the tag, with the matching `CHANGELOG.md` section (or the commit log since the previous tag) and the artifacts attached. Tags with a hyphen (`v1.0.0-rc.1`) are pre-releases. |

Flutter is pinned to **3.47.x** in every workflow (`FLUTTER_VERSION`) and in
`pubspec.yaml` (`environment.flutter`). Change both together.

## Versioning

`pubspec.yaml` `version: MAJOR.MINOR.PATCH[-pre]+BUILD`, e.g.
`1.0.0-rc.1+11`.

- The part before `+` is the user-facing version (`versionName` /
  `CFBundleShortVersionString`). Flutter passes `1.0.0-rc.1` to Android
  as-is; App Store Connect only accepts digits and dots, so for an iOS
  upload build with `--build-name=1.0.0` (or drop the suffix for the
  final release).
- `BUILD` is the integer `versionCode` / `CFBundleVersion`. It must grow with
  every upload to either store; never reuse one.
- `lib/core/app_info.dart` (`kAppVersion`, `kAppBuild`) mirrors the pubspec
  for Settings > About; a test fails if they drift.
- Add a `## [x.y.z]` section to `CHANGELOG.md`, commit, then tag:

```sh
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

## Android signing

1. Create the upload keystore once and keep it (and its passwords) somewhere
   safe — losing it means asking Google to reset the upload key:

   ```sh
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```

2. Local release builds: create `android/key.properties` (git-ignored):

   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```

   `android/app/build.gradle.kts` uses it for `release` when the file
   exists, and falls back to the debug key when it does not.

3. CI secrets (Settings > Secrets and variables > Actions):

   | Secret | Value |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` (macOS: `base64 -i upload-keystore.jks`) |
   | `KEYSTORE_PASSWORD` | keystore password |
   | `KEY_ALIAS` | e.g. `upload` |
   | `KEY_PASSWORD` | key password |
   | `PLAY_SERVICE_ACCOUNT_JSON` | optional: the JSON key of a Play Console service account with release permissions |

   With all four signing secrets the workflow writes `key.properties`,
   builds signed artifacts and deletes the key material at the end.

4. Google Play: enrol in Play App Signing. The **first** AAB of a new app
   must be uploaded by hand in the Play Console; after that the workflow's
   upload step (r0adkll/upload-google-play, draft on the `internal` track)
   or `fastlane android internal` can take over.

## iOS signing (optional)

The default iOS job needs no secrets and only proves the project builds.
For a signed build and TestFlight:

| Secret | Value |
|---|---|
| `IOS_DIST_CERT_P12_BASE64` | Apple Distribution certificate exported as .p12, base64 |
| `IOS_DIST_CERT_PASSWORD` | password of that .p12 |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile for `com.eventra.eventra`, base64 |
| `IOS_KEYCHAIN_PASSWORD` | any random string (temporary CI keychain) |
| `APPSTORE_ISSUER_ID`, `APPSTORE_API_KEY_ID`, `APPSTORE_API_PRIVATE_KEY` | App Store Connect API key (contents of the .p8) for the TestFlight upload |

Also edit `ios/ExportOptions.plist`: set `teamID` and the provisioning
profile name, and set the team / manual signing on the Runner target in
Xcode. Run **iOS build** manually with *testflight* ticked to upload.

## Fastlane

Skeletons in `android/fastlane` and `ios/fastlane` (`bundle install` in that
folder first):

- `fastlane android internal` — build AAB, upload as a draft to internal.
- `fastlane android metadata` — push `fastlane/metadata/android` text.
- `fastlane ios beta` — build signed IPA, upload to TestFlight.
- `fastlane ios metadata` — push `fastlane/metadata` text with `deliver`.

## Store listing checklist

The metadata files are placeholders written from the feature list; review
them before submitting.

- Title, short and full description (`android/fastlane/metadata/android/en-US`,
  `ios/fastlane/metadata/en-US`), plus FR/AR translations if listing in
  those markets.
- App icon 512×512 and feature graphic 1024×500 (Play); screenshots for each
  required device size (the golden images under `test/**/goldens` are a
  starting point, not store-ready).
- A public privacy policy URL (the app stores accounts, tickets and location
  on the device; the demo payment gateway never charges a card). Play Data
  safety form and App Store privacy labels to match.
- Content rating questionnaire, target audience, contact email.
- Replace the demo backend, payment gateway and QR key provisioning before a
  production launch (see the Known limits in `PROGRESS.md`).
