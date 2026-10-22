import 'package:eventra/features/auth/domain/auth_models.dart';

/// Pages anyone can open, signed in or not.
bool isPublicPath(String path) =>
    path == '/splash' || path == '/onboarding' || path.startsWith('/auth/');

/// Pages that need a real account (guests are sent to log in first).
bool needsAccount(String path) =>
    path.endsWith('/tickets') ||
    path == '/tickets' ||
    path.startsWith('/tickets/') ||
    path.startsWith('/checkout') ||
    path.startsWith('/booking-success') ||
    path.startsWith('/my-tickets');

String loginFor(Uri uri) => Uri(
  path: '/auth/login',
  queryParameters: {'from': uri.toString()},
).toString();

/// In-app path from a `from` query parameter, never an off-site URL.
String? safeFrom(String? from) =>
    from != null && from.startsWith('/') && !from.startsWith('//')
    ? from
    : null;

/// The go_router redirect, as a pure function so it is unit-tested directly.
///
/// - Until the stored session is restored everything waits on the splash.
/// - First launch shows onboarding once.
/// - Guests browse Home, Explore, Details and Favorites; tickets and checkout
///   need an account and come back to `from` after logging in.
/// - Signed-out users (not guests) only see onboarding and auth.
String? authRedirect({
  required AuthState auth,
  required bool onboardingSeen,
  required Uri uri,
}) {
  final path = uri.path;
  if (!auth.isRestored) {
    if (path == '/splash') return null;
    return Uri(
      path: '/splash',
      queryParameters: {'from': uri.toString()},
    ).toString();
  }
  if (path == '/splash') return null;
  final public = isPublicPath(path);
  if (!onboardingSeen && !public) return '/onboarding';
  if (auth.isSignedIn && (path == '/auth/login' || path == '/auth/signup')) {
    return safeFrom(uri.queryParameters['from']) ?? '/home';
  }
  if (public) return null;
  if (needsAccount(path) && !auth.isSignedIn) return loginFor(uri);
  if (!auth.canBrowse) return loginFor(uri);
  return null;
}
