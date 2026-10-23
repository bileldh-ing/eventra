import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Eventra'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover. Book. Feel the moment.'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get navTickets;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @priceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get priceFree;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKm(String value);

  /// No description provided for @distanceKmAway.
  ///
  /// In en, this message translates to:
  /// **'{value} km away'**
  String distanceKmAway(String value);

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'We could not reach Eventra. Check your connection.'**
  String get errNetwork;

  /// No description provided for @errEventGone.
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available.'**
  String get errEventGone;

  /// No description provided for @errStorage.
  ///
  /// In en, this message translates to:
  /// **'Local storage is unavailable.'**
  String get errStorage;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errUnknown;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @mapEventLocation.
  ///
  /// In en, this message translates to:
  /// **'Event location'**
  String get mapEventLocation;

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @catCinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get catCinema;

  /// No description provided for @catSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get catSports;

  /// No description provided for @catSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get catSocial;

  /// No description provided for @catMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get catMusic;

  /// No description provided for @catArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get catArt;

  /// No description provided for @catTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get catTech;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catComedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get catComedy;

  /// No description provided for @intOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Outdoors'**
  String get intOutdoors;

  /// No description provided for @intNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get intNightlife;

  /// No description provided for @intCharity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get intCharity;

  /// No description provided for @intBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get intBusiness;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortSoonest.
  ///
  /// In en, this message translates to:
  /// **'Soonest'**
  String get sortSoonest;

  /// No description provided for @sortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortNearest;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get sortPopular;

  /// No description provided for @dateAny.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get dateAny;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @dateThisWeekend.
  ///
  /// In en, this message translates to:
  /// **'This Weekend'**
  String get dateThisWeekend;

  /// No description provided for @dateNext7.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get dateNext7;

  /// No description provided for @datePick.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get datePick;

  /// No description provided for @rowRecommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended For You'**
  String get rowRecommendedForYou;

  /// No description provided for @rowBecauseYouLike.
  ///
  /// In en, this message translates to:
  /// **'Because You Like {interest}'**
  String rowBecauseYouLike(String interest);

  /// No description provided for @reasonBecauseYouLike.
  ///
  /// In en, this message translates to:
  /// **'Because you like {interest}'**
  String reasonBecauseYouLike(String interest);

  /// No description provided for @reasonNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get reasonNearYou;

  /// No description provided for @reasonTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get reasonTrending;

  /// No description provided for @reasonStartsSoon.
  ///
  /// In en, this message translates to:
  /// **'Starts soon'**
  String get reasonStartsSoon;

  /// No description provided for @reasonThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get reasonThisWeek;

  /// No description provided for @reasonLikeSaves.
  ///
  /// In en, this message translates to:
  /// **'Like your saves'**
  String get reasonLikeSaves;

  /// No description provided for @homeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get homeUpcoming;

  /// No description provided for @categoryEvents.
  ///
  /// In en, this message translates to:
  /// **'{category} Events'**
  String categoryEvents(String category);

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @noEventsMatch.
  ///
  /// In en, this message translates to:
  /// **'No events match'**
  String get noEventsMatch;

  /// No description provided for @loosenFilters.
  ///
  /// In en, this message translates to:
  /// **'Loosen your filters to see more events.'**
  String get loosenFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @pickDateRange.
  ///
  /// In en, this message translates to:
  /// **'Pick a date range'**
  String get pickDateRange;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @filtersCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filtersCategories;

  /// No description provided for @filtersAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filtersAll;

  /// No description provided for @filtersDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filtersDate;

  /// No description provided for @filtersPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price: {min} - {max}'**
  String filtersPriceRange(String min, String max);

  /// No description provided for @filtersDistanceAny.
  ///
  /// In en, this message translates to:
  /// **'Distance: any'**
  String get filtersDistanceAny;

  /// No description provided for @filtersDistanceWithin.
  ///
  /// In en, this message translates to:
  /// **'Distance: within {km} km'**
  String filtersDistanceWithin(String km);

  /// No description provided for @filtersAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filtersAny;

  /// No description provided for @filtersKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String filtersKm(String km);

  /// No description provided for @filtersFrom.
  ///
  /// In en, this message translates to:
  /// **'From {origin}'**
  String filtersFrom(String origin);

  /// No description provided for @filtersFreeOnly.
  ///
  /// In en, this message translates to:
  /// **'Free only'**
  String get filtersFreeOnly;

  /// No description provided for @filtersHasTickets.
  ///
  /// In en, this message translates to:
  /// **'Has tickets left'**
  String get filtersHasTickets;

  /// No description provided for @filtersSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filtersSortBy;

  /// No description provided for @filtersShowResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{Show 1 result} other{Show {count} results}}'**
  String filtersShowResults(int count);

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @tryAnotherCategory.
  ///
  /// In en, this message translates to:
  /// **'Try another category or reset your filters.'**
  String get tryAnotherCategory;

  /// No description provided for @showAllEvents.
  ///
  /// In en, this message translates to:
  /// **'Show all events'**
  String get showAllEvents;

  /// No description provided for @reasonNearYouKm.
  ///
  /// In en, this message translates to:
  /// **'Near you · {km} km'**
  String reasonNearYouKm(String km);

  /// No description provided for @homeTrendingWeek.
  ///
  /// In en, this message translates to:
  /// **'Trending This Week'**
  String get homeTrendingWeek;

  /// No description provided for @nGoing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody going yet} =1{1 going} other{{count} going}}'**
  String nGoing(int count);

  /// No description provided for @homeFreeEvents.
  ///
  /// In en, this message translates to:
  /// **'Free Events'**
  String get homeFreeEvents;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Notifications, unread'**
  String get notificationsUnread;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Amazing\nEvents Near You'**
  String get homeHeroTitle;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search events'**
  String get searchEvents;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @favUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites. Try again.'**
  String get favUpdateFailed;

  /// No description provided for @favRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favRemove;

  /// No description provided for @favSave.
  ///
  /// In en, this message translates to:
  /// **'Save to favorites'**
  String get favSave;

  /// No description provided for @openEvent.
  ///
  /// In en, this message translates to:
  /// **'Open event'**
  String get openEvent;

  /// No description provided for @nParticipants.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Participant} other{{count} Participants}}'**
  String nParticipants(int count);

  /// No description provided for @friendGoing.
  ///
  /// In en, this message translates to:
  /// **'Friend - going'**
  String get friendGoing;

  /// No description provided for @going.
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get going;

  /// No description provided for @morePeopleGoing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 more person is going} other{+{count} more people are going}}'**
  String morePeopleGoing(int count);

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriends;

  /// No description provided for @closePreview.
  ///
  /// In en, this message translates to:
  /// **'Close preview'**
  String get closePreview;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @viewEvent.
  ///
  /// In en, this message translates to:
  /// **'View event'**
  String get viewEvent;

  /// No description provided for @cardDateDistance.
  ///
  /// In en, this message translates to:
  /// **'{date}  ·  {km} km away'**
  String cardDateDistance(String date, String km);

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'{title} - {date} at {venue}, {address}. {price}. {link}'**
  String shareText(
    String title,
    String date,
    String venue,
    String address,
    String price,
    String link,
  );

  /// No description provided for @shareFreeEntry.
  ///
  /// In en, this message translates to:
  /// **'Free entry'**
  String get shareFreeEntry;

  /// No description provided for @shareTicketsFrom.
  ///
  /// In en, this message translates to:
  /// **'Tickets from {price}'**
  String shareTicketsFrom(String price);

  /// No description provided for @shareInviteText.
  ///
  /// In en, this message translates to:
  /// **'Join me at {title} on {date}! {link}'**
  String shareInviteText(String title, String date, String link);

  /// No description provided for @shareInviteSubject.
  ///
  /// In en, this message translates to:
  /// **'Come with me to {title}'**
  String shareInviteSubject(String title);

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get authWeakPassword;

  /// No description provided for @authEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Log in instead.'**
  String get authEmailTaken;

  /// No description provided for @authCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get authCodeExpired;

  /// No description provided for @authCodeWrong.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Check it and try again.'**
  String get authCodeWrong;

  /// No description provided for @authBadCredentials.
  ///
  /// In en, this message translates to:
  /// **'{left, plural, =1{Email or password is incorrect. 1 attempt left.} other{Email or password is incorrect. {left} attempts left.}}'**
  String authBadCredentials(int left);

  /// No description provided for @authUnverified.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email with the code we sent to finish signing up.'**
  String get authUnverified;

  /// No description provided for @authCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not valid. Request a new one.'**
  String get authCodeInvalid;

  /// No description provided for @authUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find an account with that email.'**
  String get authUserNotFound;

  /// No description provided for @authLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String authLockedOut(String seconds);

  /// No description provided for @valEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get valEnterEmail;

  /// No description provided for @valValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get valValidEmail;

  /// No description provided for @valEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get valEnterName;

  /// No description provided for @valNameShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get valNameShort;

  /// No description provided for @valPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get valPhone;

  /// No description provided for @valEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get valEnterPassword;

  /// No description provided for @valPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get valPasswordLength;

  /// No description provided for @valPasswordMix.
  ///
  /// In en, this message translates to:
  /// **'Add numbers, symbols or upper-case letters'**
  String get valPasswordMix;

  /// No description provided for @pwWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get pwWeak;

  /// No description provided for @pwFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get pwFair;

  /// No description provided for @pwGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get pwGood;

  /// No description provided for @pwStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get pwStrong;

  /// No description provided for @authEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get authEnterCode;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Log in with your new password.'**
  String get authPasswordUpdated;

  /// No description provided for @authSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get authSetNewPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authResetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to {email} and choose a new password.'**
  String authResetCodeSent(String email);

  /// No description provided for @authResetIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we will send you a reset code.'**
  String get authResetIntro;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get fieldNewPassword;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @authUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authUpdatePassword;

  /// No description provided for @authSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get authSendResetCode;

  /// No description provided for @authDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: codes are not emailed; nothing leaves this device.'**
  String get authDemoNotice;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authLoginToBook.
  ///
  /// In en, this message translates to:
  /// **'Log in to book tickets and keep your favorites in sync.'**
  String get authLoginToBook;

  /// No description provided for @authLoginContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue where you left off.'**
  String get authLoginContinue;

  /// No description provided for @authNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get authNewHere;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @authTryAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Try again in {seconds}s'**
  String authTryAgainIn(String seconds);

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get authLoggingIn;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLogIn;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authTryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try demo account'**
  String get authTryDemo;

  /// No description provided for @authContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueGuest;

  /// No description provided for @authNewCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new code to {email}'**
  String authNewCodeSent(String email);

  /// No description provided for @authCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authCheckEmail;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {email}.'**
  String authOtpSubtitle(String email);

  /// No description provided for @authVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get authVerifying;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authDidntGetIt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get authDidntGetIt;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in 0:{seconds}'**
  String authResendIn(String seconds);

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authCodesExpire.
  ///
  /// In en, this message translates to:
  /// **'Codes expire after 10 minutes.'**
  String get authCodesExpire;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountTitle;

  /// No description provided for @authJoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Eventra to book tickets and follow organizers.'**
  String get authJoinSubtitle;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get fieldPhoneOptional;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPassword;

  /// No description provided for @valPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get valPasswordsMismatch;

  /// No description provided for @authAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get authAgreeTerms;

  /// No description provided for @authCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get authCreatingAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @pwStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get pwStrengthLabel;

  /// No description provided for @pwStrengthValue.
  ///
  /// In en, this message translates to:
  /// **'Password strength {level}'**
  String pwStrengthValue(String level);

  /// No description provided for @authDebugCode.
  ///
  /// In en, this message translates to:
  /// **'Debug build: the demo code is {code}'**
  String authDebugCode(String code);

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you into?'**
  String get interestsTitle;

  /// No description provided for @interestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick at least {min} so we can tailor your feed. You can change them later in Profile.'**
  String interestsSubtitle(String min);

  /// No description provided for @interestsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String interestsSelected(int count);

  /// No description provided for @interestsChooseMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Choose 1 more} other{Choose {count} more}}'**
  String interestsChooseMore(int count);

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @locNearestArea.
  ///
  /// In en, this message translates to:
  /// **'Nearest area to you: {city}'**
  String locNearestArea(String city);

  /// No description provided for @locOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off, so pick your city below.'**
  String get locOff;

  /// No description provided for @locWhere.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get locWhere;

  /// No description provided for @locWhy.
  ///
  /// In en, this message translates to:
  /// **'We use it to show events near you and measure distances.'**
  String get locWhy;

  /// No description provided for @locUseCurrent.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get locUseCurrent;

  /// No description provided for @locSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get locSkip;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover events near you'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Concerts, games, talks and food markets around you, picked for what you love.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Book in seconds'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Choose your tickets, apply a promo code and pay in a couple of taps.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Enter with a tap'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Your QR ticket lives in the app, ready at the door.'**
  String get onb3Body;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String onbPageOf(int page, int total);

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbGetStarted;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @exploreDistancesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Distances updated from your location'**
  String get exploreDistancesUpdated;

  /// No description provided for @exploreServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Showing distances from {place}.'**
  String exploreServicesOff(String place);

  /// No description provided for @exploreLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable. Showing distances from {place}.'**
  String exploreLocationUnavailable(String place);

  /// No description provided for @exploreShowMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Show my location'**
  String get exploreShowMyLocation;

  /// No description provided for @nUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No upcoming events} =1{1 upcoming event} other{{count} upcoming events}}'**
  String nUpcomingEvents(int count);

  /// No description provided for @openNamed.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openNamed(String name);

  /// No description provided for @exploreNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest Location'**
  String get exploreNearest;

  /// No description provided for @exploreNoPlaces.
  ///
  /// In en, this message translates to:
  /// **'No places match your search'**
  String get exploreNoPlaces;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Your Location...'**
  String get exploreSearchHint;

  /// No description provided for @explorePlaceSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {address}, {distance} away'**
  String explorePlaceSemantics(String title, String address, String distance);

  /// No description provided for @favSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently saved'**
  String get favSortRecent;

  /// No description provided for @favSortSoonest.
  ///
  /// In en, this message translates to:
  /// **'Date: soonest'**
  String get favSortSoonest;

  /// No description provided for @favSortName.
  ///
  /// In en, this message translates to:
  /// **'Name: A to Z'**
  String get favSortName;

  /// No description provided for @favRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {title}'**
  String favRemoved(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @favShowGrid.
  ///
  /// In en, this message translates to:
  /// **'Show as grid'**
  String get favShowGrid;

  /// No description provided for @favShowList.
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get favShowList;

  /// No description provided for @favEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favEmptyTitle;

  /// No description provided for @favEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on any event to save it here.'**
  String get favEmptyBody;

  /// No description provided for @exploreEvents.
  ///
  /// In en, this message translates to:
  /// **'Explore events'**
  String get exploreEvents;

  /// No description provided for @nResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String nResults(int count);

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @searchFullHint.
  ///
  /// In en, this message translates to:
  /// **'Search events, venues, places'**
  String get searchFullHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @recentCleared.
  ///
  /// In en, this message translates to:
  /// **'Recent searches cleared'**
  String get recentCleared;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @removedTerm.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{term}\"'**
  String removedTerm(String term);

  /// No description provided for @trendingSearches.
  ///
  /// In en, this message translates to:
  /// **'Trending searches'**
  String get trendingSearches;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @searchFiltersHiding.
  ///
  /// In en, this message translates to:
  /// **'Your filters may be hiding matches. Clear them or try one of these:'**
  String get searchFiltersHiding;

  /// No description provided for @searchCheckSpelling.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling or try one of these:'**
  String get searchCheckSpelling;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @notifRemoved.
  ///
  /// In en, this message translates to:
  /// **'Notification removed'**
  String get notifRemoved;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New reminders and updates will appear here.'**
  String get notifEmptyBody;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @seedFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'2 friends are going'**
  String get seedFriendsTitle;

  /// No description provided for @seedFriendsBody.
  ///
  /// In en, this message translates to:
  /// **'Sarah and Liam saved {title}.'**
  String seedFriendsBody(String title);

  /// No description provided for @seedSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming up soon'**
  String get seedSoonTitle;

  /// No description provided for @seedSoonBody.
  ///
  /// In en, this message translates to:
  /// **'{title} is one of the next events near you.'**
  String seedSoonBody(String title);

  /// No description provided for @seedReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'How was {title}?'**
  String seedReviewTitle(String title);

  /// No description provided for @seedReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Attendees are sharing reviews. Tap to read them.'**
  String get seedReviewBody;

  /// No description provided for @seedNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New in Music near you'**
  String get seedNewTitle;

  /// No description provided for @seedNewBody.
  ///
  /// In en, this message translates to:
  /// **'{title} was just announced.'**
  String seedNewBody(String title);

  /// No description provided for @seedPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Bird price available'**
  String get seedPriceTitle;

  /// No description provided for @seedPriceBody.
  ///
  /// In en, this message translates to:
  /// **'Save 20% on {title} while Early Bird lasts.'**
  String seedPriceBody(String title);

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events Details'**
  String get detailsTitle;

  /// No description provided for @plusParticipants.
  ///
  /// In en, this message translates to:
  /// **'+{count} Participants'**
  String plusParticipants(String count);

  /// No description provided for @detailsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Event'**
  String get detailsAbout;

  /// No description provided for @detailsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get detailsLocation;

  /// No description provided for @detailsOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get detailsOrganizer;

  /// No description provided for @detailsLineup.
  ///
  /// In en, this message translates to:
  /// **'Lineup & Schedule'**
  String get detailsLineup;

  /// No description provided for @detailsPolicy.
  ///
  /// In en, this message translates to:
  /// **'Ticket Policy'**
  String get detailsPolicy;

  /// No description provided for @detailsSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar events'**
  String get detailsSimilar;

  /// No description provided for @shareEvent.
  ///
  /// In en, this message translates to:
  /// **'Share event'**
  String get shareEvent;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold Out'**
  String get soldOut;

  /// No description provided for @waitlistJoined.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the waitlist. We\'ll tell you when a spot opens.'**
  String get waitlistJoined;

  /// No description provided for @waitlistLeft.
  ///
  /// In en, this message translates to:
  /// **'You left the waitlist.'**
  String get waitlistLeft;

  /// No description provided for @onWaitlist.
  ///
  /// In en, this message translates to:
  /// **'On waitlist'**
  String get onWaitlist;

  /// No description provided for @joinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get joinWaitlist;

  /// No description provided for @verifiedOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Verified organizer'**
  String get verifiedOrganizer;

  /// No description provided for @organizerFollowers.
  ///
  /// In en, this message translates to:
  /// **'Organizer - {followers} followers'**
  String organizerFollowers(String followers);

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @openMapFor.
  ///
  /// In en, this message translates to:
  /// **'Open map for {venue}. Long press for directions.'**
  String openMapFor(String venue);

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more....'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @getTicket.
  ///
  /// In en, this message translates to:
  /// **'Get a Ticket'**
  String get getTicket;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable.'**
  String get profileUnavailable;

  /// No description provided for @profileLoginToEdit.
  ///
  /// In en, this message translates to:
  /// **'Log in to edit your profile.'**
  String get profileLoginToEdit;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get couldNotSave;

  /// No description provided for @avatarColor.
  ///
  /// In en, this message translates to:
  /// **'Avatar color'**
  String get avatarColor;

  /// No description provided for @avatarColorN.
  ///
  /// In en, this message translates to:
  /// **'Avatar color {n}'**
  String avatarColorN(String n);

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get fieldCity;

  /// No description provided for @fieldCityHint.
  ///
  /// In en, this message translates to:
  /// **'Where you go out'**
  String get fieldCityHint;

  /// No description provided for @fieldBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get fieldBio;

  /// No description provided for @fieldBioHint.
  ///
  /// In en, this message translates to:
  /// **'A line about you'**
  String get fieldBioHint;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @profileGuestPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to buy tickets and sync favorites'**
  String get profileGuestPrompt;

  /// No description provided for @statTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get statTickets;

  /// No description provided for @statSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get statSaved;

  /// No description provided for @statReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get statReviews;

  /// No description provided for @loginOrSignup.
  ///
  /// In en, this message translates to:
  /// **'Log in or sign up'**
  String get loginOrSignup;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @inviteFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriendsTitle;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'I find events on Eventra - Discover. Book. Feel the moment. https://eventra.app'**
  String get inviteShareText;

  /// No description provided for @interestsTitleShort.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsTitleShort;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutQ.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutQ;

  /// No description provided for @logOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your tickets and favorites stay on this device for when you are back.'**
  String get logOutBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @setReminders.
  ///
  /// In en, this message translates to:
  /// **'Event reminders'**
  String get setReminders;

  /// No description provided for @setRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'24 hours and 2 hours before events you have tickets for'**
  String get setRemindersSub;

  /// No description provided for @setOrders.
  ///
  /// In en, this message translates to:
  /// **'Order updates'**
  String get setOrders;

  /// No description provided for @setOrdersSub.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmations and refunds in your inbox'**
  String get setOrdersSub;

  /// No description provided for @setRecs.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get setRecs;

  /// No description provided for @setRecsSub.
  ///
  /// In en, this message translates to:
  /// **'New events and price drops you might like'**
  String get setRecsSub;

  /// No description provided for @setPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized feed'**
  String get setPersonalized;

  /// No description provided for @setPersonalizedSub.
  ///
  /// In en, this message translates to:
  /// **'Use your interests to rank events'**
  String get setPersonalizedSub;

  /// No description provided for @setClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get setClearCache;

  /// No description provided for @setClearCacheSub.
  ///
  /// In en, this message translates to:
  /// **'Cached images and recent searches'**
  String get setClearCacheSub;

  /// No description provided for @setCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get setCacheCleared;

  /// No description provided for @setAbout.
  ///
  /// In en, this message translates to:
  /// **'About Eventra'**
  String get setAbout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountQ.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountQ;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile, tickets, reviews and notifications are removed from this device. Tickets are not refunded. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteConfirmWord;

  /// No description provided for @typeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type {word}'**
  String typeToConfirm(String word);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @setAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get setAppearance;

  /// No description provided for @setLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setLanguage;

  /// No description provided for @setNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get setNotifications;

  /// No description provided for @setPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get setPrivacy;

  /// No description provided for @setStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get setStorage;

  /// No description provided for @setAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get setAboutSection;

  /// No description provided for @setAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get setAccount;

  /// No description provided for @sortReviews.
  ///
  /// In en, this message translates to:
  /// **'Sort reviews'**
  String get sortReviews;

  /// No description provided for @revNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get revNewest;

  /// No description provided for @revHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get revHighest;

  /// No description provided for @revLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest rated'**
  String get revLowest;

  /// No description provided for @revLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Reviews could not load.'**
  String get revLoadFailed;

  /// No description provided for @revNoneHere.
  ///
  /// In en, this message translates to:
  /// **'No reviews here'**
  String get revNoneHere;

  /// No description provided for @revTryAnotherStar.
  ///
  /// In en, this message translates to:
  /// **'Try another star filter.'**
  String get revTryAnotherStar;

  /// No description provided for @nReviews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}'**
  String nReviews(int count);

  /// No description provided for @revYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String revYou(String name);

  /// No description provided for @revOptions.
  ///
  /// In en, this message translates to:
  /// **'Review options'**
  String get revOptions;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @seeAllLower.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllLower;

  /// No description provided for @revNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get revNoneYet;

  /// No description provided for @revWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get revWrite;

  /// No description provided for @revEditYours.
  ///
  /// In en, this message translates to:
  /// **'Edit your review'**
  String get revEditYours;

  /// No description provided for @revSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Log in with a ticket for this event to leave a review.'**
  String get revSignedOut;

  /// No description provided for @revOnlyAttendees.
  ///
  /// In en, this message translates to:
  /// **'Only attendees with a ticket can review this event.'**
  String get revOnlyAttendees;

  /// No description provided for @revAfterEnd.
  ///
  /// In en, this message translates to:
  /// **'You can review this event after it ends.'**
  String get revAfterEnd;

  /// No description provided for @revDeleteQ.
  ///
  /// In en, this message translates to:
  /// **'Delete your review?'**
  String get revDeleteQ;

  /// No description provided for @cannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotUndo;

  /// No description provided for @revDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get revDeleted;

  /// No description provided for @revThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get revThanks;

  /// No description provided for @revUpdated.
  ///
  /// In en, this message translates to:
  /// **'Review updated'**
  String get revUpdated;

  /// No description provided for @revRateEvent.
  ///
  /// In en, this message translates to:
  /// **'Rate this event'**
  String get revRateEvent;

  /// No description provided for @nStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String nStars(int count);

  /// No description provided for @revHint.
  ///
  /// In en, this message translates to:
  /// **'What did you like? What could be better?'**
  String get revHint;

  /// No description provided for @revMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least {n} characters'**
  String revMinChars(String n);

  /// No description provided for @revPost.
  ///
  /// In en, this message translates to:
  /// **'Post review'**
  String get revPost;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @revEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get revEdited;

  /// No description provided for @revLoginToWrite.
  ///
  /// In en, this message translates to:
  /// **'Log in to write a review.'**
  String get revLoginToWrite;

  /// No description provided for @tkBadQuantity.
  ///
  /// In en, this message translates to:
  /// **'Bad quantity.'**
  String get tkBadQuantity;

  /// No description provided for @tkUnknownTier.
  ///
  /// In en, this message translates to:
  /// **'Unknown ticket type.'**
  String get tkUnknownTier;

  /// No description provided for @tkTierMax.
  ///
  /// In en, this message translates to:
  /// **'You can buy up to {max} {tier} tickets.'**
  String tkTierMax(String max, String tier);

  /// No description provided for @tkChooseFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a ticket first.'**
  String get tkChooseFirst;

  /// No description provided for @tkOrderMax.
  ///
  /// In en, this message translates to:
  /// **'You can buy up to {max} tickets per order.'**
  String tkOrderMax(String max);

  /// No description provided for @tkNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough {tier} tickets left. Update your selection.'**
  String tkNotEnough(String tier);

  /// No description provided for @tkSelectionLost.
  ///
  /// In en, this message translates to:
  /// **'Your selection was lost.'**
  String get tkSelectionLost;

  /// No description provided for @tkHoldEnded.
  ///
  /// In en, this message translates to:
  /// **'Your 10-minute hold ended and the tickets were released.'**
  String get tkHoldEnded;

  /// No description provided for @tkChoosePay.
  ///
  /// In en, this message translates to:
  /// **'Choose how to pay.'**
  String get tkChoosePay;

  /// No description provided for @tkPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment failed.'**
  String get tkPaymentFailed;

  /// No description provided for @tkSoldOutPaying.
  ///
  /// In en, this message translates to:
  /// **'Those tickets sold out while you were paying. You have not been charged.'**
  String get tkSoldOutPaying;

  /// No description provided for @tkOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get tkOrderNotFound;

  /// No description provided for @tkTicketUsed.
  ///
  /// In en, this message translates to:
  /// **'A ticket in this order was already used.'**
  String get tkTicketUsed;

  /// No description provided for @tkRefundFailed.
  ///
  /// In en, this message translates to:
  /// **'The refund could not be processed. Try again.'**
  String get tkRefundFailed;

  /// No description provided for @cardEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your card number.'**
  String get cardEnterNumber;

  /// No description provided for @cardIncomplete.
  ///
  /// In en, this message translates to:
  /// **'That {brand} number is incomplete.'**
  String cardIncomplete(String brand);

  /// No description provided for @cardInvalid.
  ///
  /// In en, this message translates to:
  /// **'That card number is not valid.'**
  String get cardInvalid;

  /// No description provided for @cardUseMmYy.
  ///
  /// In en, this message translates to:
  /// **'Use MM/YY.'**
  String get cardUseMmYy;

  /// No description provided for @cardExpired.
  ///
  /// In en, this message translates to:
  /// **'This card expired.'**
  String get cardExpired;

  /// No description provided for @cardCheckYear.
  ///
  /// In en, this message translates to:
  /// **'Check the expiry year.'**
  String get cardCheckYear;

  /// No description provided for @cardCvcDigits.
  ///
  /// In en, this message translates to:
  /// **'{n} digits.'**
  String cardCvcDigits(String n);

  /// No description provided for @cardGeneric.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardGeneric;

  /// No description provided for @payAuthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Card authentication was cancelled. You were not charged.'**
  String get payAuthCancelled;

  /// No description provided for @payDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your card was declined. Try another card.'**
  String get payDeclined;

  /// No description provided for @payTimeout.
  ///
  /// In en, this message translates to:
  /// **'The payment timed out. You were not charged; try again.'**
  String get payTimeout;

  /// No description provided for @promoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a promo code.'**
  String get promoEmpty;

  /// No description provided for @promoUnknown.
  ///
  /// In en, this message translates to:
  /// **'That code does not exist.'**
  String get promoUnknown;

  /// No description provided for @promoNotYet.
  ///
  /// In en, this message translates to:
  /// **'This code is not active yet.'**
  String get promoNotYet;

  /// No description provided for @promoExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired.'**
  String get promoExpired;

  /// No description provided for @promoExhausted.
  ///
  /// In en, this message translates to:
  /// **'This code has been fully redeemed.'**
  String get promoExhausted;

  /// No description provided for @promoUsed.
  ///
  /// In en, this message translates to:
  /// **'You have already used this code.'**
  String get promoUsed;

  /// No description provided for @promoNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'This code does not apply to the selected tickets.'**
  String get promoNotApplicable;

  /// No description provided for @promoMinSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Add more tickets to use this code.'**
  String get promoMinSubtotal;

  /// No description provided for @promoL10.
  ///
  /// In en, this message translates to:
  /// **'10% off'**
  String get promoL10;

  /// No description provided for @promoL5.
  ///
  /// In en, this message translates to:
  /// **'\$5 off your first order'**
  String get promoL5;

  /// No description provided for @promoL20.
  ///
  /// In en, this message translates to:
  /// **'20% off VIP tickets'**
  String get promoL20;

  /// No description provided for @promoL25.
  ///
  /// In en, this message translates to:
  /// **'25% off summer events'**
  String get promoL25;

  /// No description provided for @promoL50.
  ///
  /// In en, this message translates to:
  /// **'50% flash sale'**
  String get promoL50;

  /// No description provided for @refundSummary.
  ///
  /// In en, this message translates to:
  /// **'Full refund when you cancel more than 48 hours before the event starts. No refunds within 48 hours of the start time.'**
  String get refundSummary;

  /// No description provided for @refundStarted.
  ///
  /// In en, this message translates to:
  /// **'This event has already started.'**
  String get refundStarted;

  /// No description provided for @refundFreeAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Free reservation: cancel any time before the event.'**
  String get refundFreeAnyTime;

  /// No description provided for @refundFullUntil.
  ///
  /// In en, this message translates to:
  /// **'Full refund available until 48 hours before the event.'**
  String get refundFullUntil;

  /// No description provided for @refundClosed.
  ///
  /// In en, this message translates to:
  /// **'Refunds close 48 hours before the event starts.'**
  String get refundClosed;

  /// No description provided for @remChannel.
  ///
  /// In en, this message translates to:
  /// **'Event reminders'**
  String get remChannel;

  /// No description provided for @remChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders 24 hours and 2 hours before events'**
  String get remChannelDesc;

  /// No description provided for @remTitleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{title} starts tomorrow'**
  String remTitleTomorrow(String title);

  /// No description provided for @remTitleSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} starts in 2 hours'**
  String remTitleSoon(String title);

  /// No description provided for @remBody.
  ///
  /// In en, this message translates to:
  /// **'{venue}. Your ticket is ready in Eventra.'**
  String remBody(String venue);

  /// No description provided for @stValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get stValid;

  /// No description provided for @stUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get stUsed;

  /// No description provided for @stExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get stExpired;

  /// No description provided for @stCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get stCancelled;

  /// No description provided for @ntBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get ntBookingConfirmed;

  /// No description provided for @ntBookingBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ticket for {title}. Your QR code is ready.} other{{count} tickets for {title}. Your QR code is ready.}}'**
  String ntBookingBody(int count, String title);

  /// No description provided for @ntRefundIssued.
  ///
  /// In en, this message translates to:
  /// **'Refund issued'**
  String get ntRefundIssued;

  /// No description provided for @ntRefundBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} for {title} is on its way to your card.'**
  String ntRefundBody(String amount, String title);

  /// No description provided for @bsOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get bsOrderNotFound;

  /// No description provided for @bsInMyTickets.
  ///
  /// In en, this message translates to:
  /// **'Your tickets are in My Tickets.'**
  String get bsInMyTickets;

  /// No description provided for @bsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load your order.'**
  String get bsLoadFailed;

  /// No description provided for @bsYoureIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re in!'**
  String get bsYoureIn;

  /// No description provided for @bsFreeReserved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 free spot reserved} other{{count} free spots reserved}}'**
  String bsFreeReserved(int count);

  /// No description provided for @bsPaid.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ticket · {amount} paid} other{{count} tickets · {amount} paid}}'**
  String bsPaid(int count, String amount);

  /// No description provided for @bsRemindBoth.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you 24 hours and 2 hours before.'**
  String get bsRemindBoth;

  /// No description provided for @bsRemind2h.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you 2 hours before.'**
  String get bsRemind2h;

  /// No description provided for @bsViewTickets.
  ///
  /// In en, this message translates to:
  /// **'View Tickets'**
  String get bsViewTickets;

  /// No description provided for @bsViewTicket.
  ///
  /// In en, this message translates to:
  /// **'View Ticket'**
  String get bsViewTicket;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @coCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get coCheckout;

  /// No description provided for @coLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load your checkout.'**
  String get coLoadFailed;

  /// No description provided for @coNotFound.
  ///
  /// In en, this message translates to:
  /// **'Checkout not found'**
  String get coNotFound;

  /// No description provided for @coSelectionGone.
  ///
  /// In en, this message translates to:
  /// **'This selection is no longer available. Pick your tickets again.'**
  String get coSelectionGone;

  /// No description provided for @coAlreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'Already booked'**
  String get coAlreadyBooked;

  /// No description provided for @coInWallet.
  ///
  /// In en, this message translates to:
  /// **'These tickets are in your wallet.'**
  String get coInWallet;

  /// No description provided for @coLeaveQ.
  ///
  /// In en, this message translates to:
  /// **'Leave checkout?'**
  String get coLeaveQ;

  /// No description provided for @coLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your tickets are held for you. Leaving releases them for other fans.'**
  String get coLeaveBody;

  /// No description provided for @coStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get coStay;

  /// No description provided for @coRelease.
  ///
  /// In en, this message translates to:
  /// **'Release tickets'**
  String get coRelease;

  /// No description provided for @coPriceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price details'**
  String get coPriceDetails;

  /// No description provided for @coAttendee.
  ///
  /// In en, this message translates to:
  /// **'Attendee details'**
  String get coAttendee;

  /// No description provided for @coEnterHolder.
  ///
  /// In en, this message translates to:
  /// **'Enter the name on the tickets.'**
  String get coEnterHolder;

  /// No description provided for @coEmailForTickets.
  ///
  /// In en, this message translates to:
  /// **'Email for your tickets'**
  String get coEmailForTickets;

  /// No description provided for @coValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get coValidEmail;

  /// No description provided for @coPromo.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get coPromo;

  /// No description provided for @coPromoSaves.
  ///
  /// In en, this message translates to:
  /// **'{label} · saves {amount}'**
  String coPromoSaves(String label, String amount);

  /// No description provided for @coRemovePromo.
  ///
  /// In en, this message translates to:
  /// **'Remove promo code'**
  String get coRemovePromo;

  /// No description provided for @coEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get coEnterCode;

  /// No description provided for @coApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get coApply;

  /// No description provided for @coPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get coPayment;

  /// No description provided for @coDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get coDemoMode;

  /// No description provided for @coAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add a new card'**
  String get coAddCard;

  /// No description provided for @coUseAnother.
  ///
  /// In en, this message translates to:
  /// **'Use another card'**
  String get coUseAnother;

  /// No description provided for @coConfirmFree.
  ///
  /// In en, this message translates to:
  /// **'Confirm free reservation'**
  String get coConfirmFree;

  /// No description provided for @coPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String coPay(String amount);

  /// No description provided for @coExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String coExpires(String date);

  /// No description provided for @coNewCardExpires.
  ///
  /// In en, this message translates to:
  /// **'New card · expires {date}'**
  String coNewCardExpires(String date);

  /// No description provided for @coCardEnding.
  ///
  /// In en, this message translates to:
  /// **'{brand} ending {last4}'**
  String coCardEnding(String brand, String last4);

  /// No description provided for @coHoldExpired.
  ///
  /// In en, this message translates to:
  /// **'Your hold expired and the tickets were released.'**
  String get coHoldExpired;

  /// No description provided for @coHeldFor.
  ///
  /// In en, this message translates to:
  /// **'Tickets held for {time}'**
  String coHeldFor(String time);

  /// No description provided for @coChooseAgain.
  ///
  /// In en, this message translates to:
  /// **'Choose again'**
  String get coChooseAgain;

  /// No description provided for @co3dsTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your bank'**
  String get co3dsTitle;

  /// No description provided for @co3dsBody.
  ///
  /// In en, this message translates to:
  /// **'Approve a payment of {amount} to Eventra with {card}. This is a simulated 3-D Secure check.'**
  String co3dsBody(String amount, String card);

  /// No description provided for @coApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get coApprove;

  /// No description provided for @coPaymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get coPaymentConfirmed;

  /// No description provided for @coProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get coProcessing;

  /// No description provided for @coIssuing.
  ///
  /// In en, this message translates to:
  /// **'Issuing your tickets'**
  String get coIssuing;

  /// No description provided for @coKeepOpen.
  ///
  /// In en, this message translates to:
  /// **'Please keep the app open'**
  String get coKeepOpen;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tabPast;

  /// No description provided for @tabCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tabCancelled;

  /// No description provided for @mtLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not open your tickets.'**
  String get mtLoadFailed;

  /// No description provided for @mtNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming tickets'**
  String get mtNoUpcoming;

  /// No description provided for @mtNoUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'Find something you love and your tickets will live here, ready to scan even offline.'**
  String get mtNoUpcomingBody;

  /// No description provided for @mtNoPast.
  ///
  /// In en, this message translates to:
  /// **'No past events yet'**
  String get mtNoPast;

  /// No description provided for @mtNoPastBody.
  ///
  /// In en, this message translates to:
  /// **'Events you attend will be kept here.'**
  String get mtNoPastBody;

  /// No description provided for @mtNoCancelled.
  ///
  /// In en, this message translates to:
  /// **'Nothing cancelled'**
  String get mtNoCancelled;

  /// No description provided for @mtNoCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Refunded tickets show up here.'**
  String get mtNoCancelledBody;

  /// No description provided for @tabWithCount.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String tabWithCount(String label, String count);

  /// No description provided for @tdRefundQ.
  ///
  /// In en, this message translates to:
  /// **'Request a refund?'**
  String get tdRefundQ;

  /// No description provided for @tdCancelResQ.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation?'**
  String get tdCancelResQ;

  /// No description provided for @tdRefundBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The ticket in this order will be cancelled and {amount} goes back to your {card}.} other{All {count} tickets in this order will be cancelled and {amount} goes back to your {card}.}}'**
  String tdRefundBody(int count, String amount, String card);

  /// No description provided for @tdReleaseBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your spot will be released for other fans.} other{Your spots will be released for other fans.}}'**
  String tdReleaseBody(int count);

  /// No description provided for @tdKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep tickets'**
  String get tdKeep;

  /// No description provided for @tdRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get tdRefund;

  /// No description provided for @tdCancelRes.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation'**
  String get tdCancelRes;

  /// No description provided for @tdRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded {amount}. Your tickets were cancelled.'**
  String tdRefunded(String amount);

  /// No description provided for @tdResCancelled.
  ///
  /// In en, this message translates to:
  /// **'Reservation cancelled.'**
  String get tdResCancelled;

  /// No description provided for @tdYourTicket.
  ///
  /// In en, this message translates to:
  /// **'Your Ticket'**
  String get tdYourTicket;

  /// No description provided for @tdLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not open this ticket.'**
  String get tdLoadFailed;

  /// No description provided for @tdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ticket not found'**
  String get tdNotFound;

  /// No description provided for @tdOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'It may belong to another account.'**
  String get tdOtherAccount;

  /// No description provided for @tdAddCal.
  ///
  /// In en, this message translates to:
  /// **'Add to\nCalendar'**
  String get tdAddCal;

  /// No description provided for @tdDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get tdDirections;

  /// No description provided for @tdInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite\nfriends'**
  String get tdInvite;

  /// No description provided for @tdDetails.
  ///
  /// In en, this message translates to:
  /// **'Event\ndetails'**
  String get tdDetails;

  /// No description provided for @tdOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get tdOrder;

  /// No description provided for @tdRefundedChip.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get tdRefundedChip;

  /// No description provided for @tdPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get tdPaid;

  /// No description provided for @tdBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get tdBooked;

  /// No description provided for @tdPromo.
  ///
  /// In en, this message translates to:
  /// **'Promo {code}'**
  String tdPromo(String code);

  /// No description provided for @feesAndTax.
  ///
  /// In en, this message translates to:
  /// **'Fees and tax'**
  String get feesAndTax;

  /// No description provided for @tdTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get tdTotalPaid;

  /// No description provided for @tdPaidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get tdPaidWith;

  /// No description provided for @tdRefundPolicy.
  ///
  /// In en, this message translates to:
  /// **'Refund policy'**
  String get tdRefundPolicy;

  /// No description provided for @tdProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get tdProcessing;

  /// No description provided for @tdRequestRefund.
  ///
  /// In en, this message translates to:
  /// **'Request refund · {amount}'**
  String tdRequestRefund(String amount);

  /// No description provided for @fDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fDate;

  /// No description provided for @fTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fTime;

  /// No description provided for @fVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get fVenue;

  /// No description provided for @fTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get fTicket;

  /// No description provided for @tdSeqOf.
  ///
  /// In en, this message translates to:
  /// **'{seq} of {count}'**
  String tdSeqOf(String seq, String count);

  /// No description provided for @tdWasCancelled.
  ///
  /// In en, this message translates to:
  /// **'This ticket was cancelled'**
  String get tdWasCancelled;

  /// No description provided for @tdEnded.
  ///
  /// In en, this message translates to:
  /// **'This event has ended'**
  String get tdEnded;

  /// No description provided for @fHolder.
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get fHolder;

  /// No description provided for @fTier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get fTier;

  /// No description provided for @tdShowCode.
  ///
  /// In en, this message translates to:
  /// **'Show this code at the entrance. It changes every 30 seconds, so screenshots will not work.'**
  String get tdShowCode;

  /// No description provided for @tpLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load the tickets for this event.'**
  String get tpLoadFailed;

  /// No description provided for @tpStarted.
  ///
  /// In en, this message translates to:
  /// **'This event has started; tickets are no longer sold.'**
  String get tpStarted;

  /// No description provided for @tpCapReached.
  ///
  /// In en, this message translates to:
  /// **'You reached the {max}-ticket limit for one order.'**
  String tpCapReached(String max);

  /// No description provided for @tpUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {max} tickets per order. Seats are held for 10 minutes once you continue.'**
  String tpUpTo(String max);

  /// No description provided for @soldOutLower.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOutLower;

  /// No description provided for @tpAllGone.
  ///
  /// In en, this message translates to:
  /// **'All {count} tickets are gone'**
  String tpAllGone(String count);

  /// No description provided for @tpLeftOf.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} left'**
  String tpLeftOf(String left, String total);

  /// No description provided for @tpOnlyLeft.
  ///
  /// In en, this message translates to:
  /// **'Only {left} left'**
  String tpOnlyLeft(String left);

  /// No description provided for @tpMaxPer.
  ///
  /// In en, this message translates to:
  /// **'Max {max} per order'**
  String tpMaxPer(String max);

  /// No description provided for @tpChooseToSee.
  ///
  /// In en, this message translates to:
  /// **'Choose your tickets to see the total.'**
  String get tpChooseToSee;

  /// No description provided for @nTickets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ticket} other{{count} tickets}}'**
  String nTickets(int count);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @tpHolding.
  ///
  /// In en, this message translates to:
  /// **'Holding your seats…'**
  String get tpHolding;

  /// No description provided for @tpContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to checkout'**
  String get tpContinue;

  /// No description provided for @cfAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add a card'**
  String get cfAddCard;

  /// No description provided for @cfNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cfNumber;

  /// No description provided for @cfName.
  ///
  /// In en, this message translates to:
  /// **'Name on card'**
  String get cfName;

  /// No description provided for @cfEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name on the card.'**
  String get cfEnterName;

  /// No description provided for @cfDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo mode, no real charge. Test cards: 4242 4242 4242 4242 approves, 4000 0000 0000 0002 is declined, 4000 0000 0000 3220 asks for 3-D Secure. We keep only the brand and last four digits.'**
  String get cfDemo;

  /// No description provided for @cfUse.
  ///
  /// In en, this message translates to:
  /// **'Use this card'**
  String get cfUse;

  /// No description provided for @tvCalDesc.
  ///
  /// In en, this message translates to:
  /// **'Your Eventra ticket is in the app. {link}'**
  String tvCalDesc(String link);

  /// No description provided for @tvCalAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your calendar'**
  String get tvCalAdded;

  /// No description provided for @tvCalFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open your calendar.'**
  String get tvCalFailed;

  /// No description provided for @tvInviteText.
  ///
  /// In en, this message translates to:
  /// **'I\'m going to {title} on {date} at {venue}. Join me! {link}'**
  String tvInviteText(String title, String date, String venue, String link);

  /// No description provided for @tvMapsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps. {address}'**
  String tvMapsFailed(String address);

  /// No description provided for @tvQrLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket QR code. Refreshes every 30 seconds.'**
  String get tvQrLabel;

  /// No description provided for @tvRefreshIn.
  ///
  /// In en, this message translates to:
  /// **'Code refreshes in {seconds}s'**
  String tvRefreshIn(String seconds);

  /// No description provided for @tvQrFailed.
  ///
  /// In en, this message translates to:
  /// **'The secure code could not be created on this device.'**
  String get tvQrFailed;

  /// No description provided for @tvTierSeq.
  ///
  /// In en, this message translates to:
  /// **'{tier} · Ticket {seq} of {count}'**
  String tvTierSeq(String tier, String seq, String count);

  /// No description provided for @removeOne.
  ///
  /// In en, this message translates to:
  /// **'Remove one'**
  String get removeOne;

  /// No description provided for @addOne.
  ///
  /// In en, this message translates to:
  /// **'Add one'**
  String get addOne;

  /// No description provided for @subtotalN.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Subtotal (1 ticket)} other{Subtotal ({count} tickets)}}'**
  String subtotalN(int count);

  /// No description provided for @serviceFees.
  ///
  /// In en, this message translates to:
  /// **'Service fees'**
  String get serviceFees;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @valProfileName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name (2+ characters)'**
  String get valProfileName;

  /// No description provided for @valUnderN.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {n} characters'**
  String valUnderN(String n);

  /// No description provided for @revValRating.
  ///
  /// In en, this message translates to:
  /// **'Pick a rating from 1 to 5 stars.'**
  String get revValRating;

  /// No description provided for @revValShort.
  ///
  /// In en, this message translates to:
  /// **'Write at least {n} characters.'**
  String revValShort(String n);

  /// No description provided for @revValLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {n} characters.'**
  String revValLong(String n);

  /// No description provided for @revDupEdit.
  ///
  /// In en, this message translates to:
  /// **'You already reviewed this event. Edit your review instead.'**
  String get revDupEdit;

  /// No description provided for @revDup.
  ///
  /// In en, this message translates to:
  /// **'You already reviewed this event.'**
  String get revDup;

  /// No description provided for @revNotFound.
  ///
  /// In en, this message translates to:
  /// **'Review not found.'**
  String get revNotFound;

  /// No description provided for @profOrganizerMode.
  ///
  /// In en, this message translates to:
  /// **'Organizer mode'**
  String get profOrganizerMode;

  /// No description provided for @profOrganizerModeBody.
  ///
  /// In en, this message translates to:
  /// **'Publish events, track sales and check guests in'**
  String get profOrganizerModeBody;

  /// No description provided for @profOrganizerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Organizer dashboard'**
  String get profOrganizerDashboard;

  /// No description provided for @orgDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get orgDashboardTitle;

  /// No description provided for @orgCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get orgCreateEvent;

  /// No description provided for @orgRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get orgRevenue;

  /// No description provided for @orgTicketsSold.
  ///
  /// In en, this message translates to:
  /// **'Tickets sold'**
  String get orgTicketsSold;

  /// No description provided for @orgCheckInRate.
  ///
  /// In en, this message translates to:
  /// **'Check-in rate'**
  String get orgCheckInRate;

  /// No description provided for @orgOfCapacity.
  ///
  /// In en, this message translates to:
  /// **'{sold} of {capacity}'**
  String orgOfCapacity(String sold, String capacity);

  /// No description provided for @orgCheckedInOf.
  ///
  /// In en, this message translates to:
  /// **'{checkedIn} of {total} checked in'**
  String orgCheckedInOf(String checkedIn, String total);

  /// No description provided for @orgSalesOverTime.
  ///
  /// In en, this message translates to:
  /// **'Sales, last 14 days'**
  String get orgSalesOverTime;

  /// No description provided for @orgTicketsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tickets} =1{1 ticket} other{{count} tickets}}'**
  String orgTicketsCount(int count);

  /// No description provided for @orgByTier.
  ///
  /// In en, this message translates to:
  /// **'Sales by tier'**
  String get orgByTier;

  /// No description provided for @orgDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get orgDrafts;

  /// No description provided for @orgDraftUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled event'**
  String get orgDraftUntitled;

  /// No description provided for @orgDraftSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved {when}'**
  String orgDraftSavedAt(String when);

  /// No description provided for @orgDraftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted'**
  String get orgDraftDeleted;

  /// No description provided for @orgDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get orgDelete;

  /// No description provided for @orgUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get orgUpcoming;

  /// No description provided for @orgNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events yet. Create your first one.'**
  String get orgNoEvents;

  /// No description provided for @orgStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get orgStatusLive;

  /// No description provided for @orgStatusOnSale.
  ///
  /// In en, this message translates to:
  /// **'On sale'**
  String get orgStatusOnSale;

  /// No description provided for @orgStatusSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get orgStatusSoldOut;

  /// No description provided for @orgCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get orgCheckIn;

  /// No description provided for @orgEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get orgEdit;

  /// No description provided for @orgScanTab.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get orgScanTab;

  /// No description provided for @orgGuestsTab.
  ///
  /// In en, this message translates to:
  /// **'Guest list'**
  String get orgGuestsTab;

  /// No description provided for @orgScanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the attendee\'s ticket QR code.'**
  String get orgScanHint;

  /// No description provided for @orgCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera is unavailable. Enter the code by hand instead.'**
  String get orgCameraUnavailable;

  /// No description provided for @orgEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get orgEnterCode;

  /// No description provided for @orgEnterCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Paste the QR payload or type the ticket ID.'**
  String get orgEnterCodeBody;

  /// No description provided for @orgCodeHint.
  ///
  /// In en, this message translates to:
  /// **'ETK1… or ticket ID'**
  String get orgCodeHint;

  /// No description provided for @orgVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get orgVerify;

  /// No description provided for @orgSearchGuests.
  ///
  /// In en, this message translates to:
  /// **'Search by name, tier or ticket'**
  String get orgSearchGuests;

  /// No description provided for @orgNoGuests.
  ///
  /// In en, this message translates to:
  /// **'No guests'**
  String get orgNoGuests;

  /// No description provided for @orgNoGuestsBody.
  ///
  /// In en, this message translates to:
  /// **'Tickets sold for this event will appear here.'**
  String get orgNoGuestsBody;

  /// No description provided for @orgNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No guest matches your search.'**
  String get orgNoMatches;

  /// No description provided for @orgCheckInAction.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get orgCheckInAction;

  /// No description provided for @orgPendingSync.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 to sync} other{{count} to sync}}'**
  String orgPendingSync(int count);

  /// No description provided for @orgSynced.
  ///
  /// In en, this message translates to:
  /// **'All check-ins are synced.'**
  String get orgSynced;

  /// No description provided for @orgSyncOffline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Offline: 1 check-in will sync later.} other{Offline: {count} check-ins will sync later.}}'**
  String orgSyncOffline(int count);

  /// No description provided for @resValid.
  ///
  /// In en, this message translates to:
  /// **'Valid ticket. Welcome!'**
  String get resValid;

  /// No description provided for @resAlready.
  ///
  /// In en, this message translates to:
  /// **'Already checked in'**
  String get resAlready;

  /// No description provided for @resAlreadyBody.
  ///
  /// In en, this message translates to:
  /// **'This ticket was used at {time}.'**
  String resAlreadyBody(String time);

  /// No description provided for @resWrongEvent.
  ///
  /// In en, this message translates to:
  /// **'Wrong event'**
  String get resWrongEvent;

  /// No description provided for @resWrongEventBody.
  ///
  /// In en, this message translates to:
  /// **'This ticket is for a different event.'**
  String get resWrongEventBody;

  /// No description provided for @resExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired'**
  String get resExpired;

  /// No description provided for @resExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Ticket codes refresh every 30 seconds. Ask the guest to reopen their ticket.'**
  String get resExpiredBody;

  /// No description provided for @resForged.
  ///
  /// In en, this message translates to:
  /// **'Invalid ticket'**
  String get resForged;

  /// No description provided for @resForgedBody.
  ///
  /// In en, this message translates to:
  /// **'This code is not a genuine Eventra ticket.'**
  String get resForgedBody;

  /// No description provided for @resCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get resCancelled;

  /// No description provided for @resCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'This ticket was refunded or cancelled.'**
  String get resCancelledBody;

  /// No description provided for @resNextScan.
  ///
  /// In en, this message translates to:
  /// **'Scan next'**
  String get resNextScan;

  /// No description provided for @wizNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get wizNewTitle;

  /// No description provided for @wizEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get wizEditTitle;

  /// No description provided for @wizSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get wizSaveDraft;

  /// No description provided for @wizDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get wizDraftSaved;

  /// No description provided for @wizStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String wizStepOf(int step, int total);

  /// No description provided for @wizStepBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get wizStepBasics;

  /// No description provided for @wizStepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get wizStepSchedule;

  /// No description provided for @wizStepVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get wizStepVenue;

  /// No description provided for @wizStepTiers.
  ///
  /// In en, this message translates to:
  /// **'Tickets and pricing'**
  String get wizStepTiers;

  /// No description provided for @wizStepCover.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get wizStepCover;

  /// No description provided for @wizStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review and publish'**
  String get wizStepReview;

  /// No description provided for @wizNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wizNext;

  /// No description provided for @wizPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish event'**
  String get wizPublish;

  /// No description provided for @wizSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get wizSaveChanges;

  /// No description provided for @wizPublished.
  ///
  /// In en, this message translates to:
  /// **'Your event is live.'**
  String get wizPublished;

  /// No description provided for @wizUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated.'**
  String get wizUpdated;

  /// No description provided for @wizPublishFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not publish the event. Try again.'**
  String get wizPublishFailed;

  /// No description provided for @wizTitle.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get wizTitle;

  /// No description provided for @wizCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get wizCategory;

  /// No description provided for @wizDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get wizDescription;

  /// No description provided for @wizStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get wizStarts;

  /// No description provided for @wizEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get wizEnds;

  /// No description provided for @wizPick.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get wizPick;

  /// No description provided for @wizDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {hours} h {minutes} min'**
  String wizDuration(int hours, int minutes);

  /// No description provided for @wizVenueName.
  ///
  /// In en, this message translates to:
  /// **'Venue name'**
  String get wizVenueName;

  /// No description provided for @wizAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get wizAddress;

  /// No description provided for @wizPinHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the entrance pin.'**
  String get wizPinHint;

  /// No description provided for @wizPinHere.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get wizPinHere;

  /// No description provided for @wizTierN.
  ///
  /// In en, this message translates to:
  /// **'Tier {n}'**
  String wizTierN(int n);

  /// No description provided for @wizTierName.
  ///
  /// In en, this message translates to:
  /// **'Tier name'**
  String get wizTierName;

  /// No description provided for @wizTierNameHint.
  ///
  /// In en, this message translates to:
  /// **'General Admission'**
  String get wizTierNameHint;

  /// No description provided for @wizTierPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get wizTierPrice;

  /// No description provided for @wizTierCapacity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get wizTierCapacity;

  /// No description provided for @wizFreeTier.
  ///
  /// In en, this message translates to:
  /// **'Price 0 makes this tier free (RSVP).'**
  String get wizFreeTier;

  /// No description provided for @wizAddTier.
  ///
  /// In en, this message translates to:
  /// **'Add a tier'**
  String get wizAddTier;

  /// No description provided for @wizCapacityTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No seats yet} =1{1 seat in total} other{{count} seats in total}}'**
  String wizCapacityTotal(int count);

  /// No description provided for @wizCoverN.
  ///
  /// In en, this message translates to:
  /// **'Cover photo {n}'**
  String wizCoverN(int n);

  /// No description provided for @wizCoverCredit.
  ///
  /// In en, this message translates to:
  /// **'Photos: Unsplash (Unsplash License).'**
  String get wizCoverCredit;

  /// No description provided for @wizDefaultPolicy.
  ///
  /// In en, this message translates to:
  /// **'Full refund up to 48 hours before the event. No refunds within 48 hours of the start time.'**
  String get wizDefaultPolicy;

  /// No description provided for @wizErrTitle.
  ///
  /// In en, this message translates to:
  /// **'Use {min} to {max} characters.'**
  String wizErrTitle(int min, int max);

  /// No description provided for @wizErrCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category.'**
  String get wizErrCategory;

  /// No description provided for @wizErrDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the event in at least {n} characters.'**
  String wizErrDescription(int n);

  /// No description provided for @wizErrStart.
  ///
  /// In en, this message translates to:
  /// **'Choose when the event starts.'**
  String get wizErrStart;

  /// No description provided for @wizErrStartPast.
  ///
  /// In en, this message translates to:
  /// **'The start must be in the future.'**
  String get wizErrStartPast;

  /// No description provided for @wizErrEnd.
  ///
  /// In en, this message translates to:
  /// **'Choose when the event ends.'**
  String get wizErrEnd;

  /// No description provided for @wizErrEndBefore.
  ///
  /// In en, this message translates to:
  /// **'The end must be after the start.'**
  String get wizErrEndBefore;

  /// No description provided for @wizErrTooLong.
  ///
  /// In en, this message translates to:
  /// **'An event can last at most 7 days.'**
  String get wizErrTooLong;

  /// No description provided for @wizErrVenue.
  ///
  /// In en, this message translates to:
  /// **'Enter the venue name.'**
  String get wizErrVenue;

  /// No description provided for @wizErrAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter the address.'**
  String get wizErrAddress;

  /// No description provided for @wizErrPin.
  ///
  /// In en, this message translates to:
  /// **'Place the pin on the map.'**
  String get wizErrPin;

  /// No description provided for @wizErrTiers.
  ///
  /// In en, this message translates to:
  /// **'Add between 1 and {n} tiers.'**
  String wizErrTiers(int n);

  /// No description provided for @wizErrTierName.
  ///
  /// In en, this message translates to:
  /// **'Name the tier (2 to 30 characters).'**
  String get wizErrTierName;

  /// No description provided for @wizErrTierDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Each tier needs a different name.'**
  String get wizErrTierDuplicate;

  /// No description provided for @wizErrTierPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a price from 0 to 10,000.'**
  String get wizErrTierPrice;

  /// No description provided for @wizErrTierCapacity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity from 1 to 100,000.'**
  String get wizErrTierCapacity;

  /// No description provided for @wizErrTierBelowSold.
  ///
  /// In en, this message translates to:
  /// **'The quantity can not go below the tickets already sold.'**
  String get wizErrTierBelowSold;

  /// No description provided for @wizErrTierBelowSoldN.
  ///
  /// In en, this message translates to:
  /// **'At least {n} (already sold).'**
  String wizErrTierBelowSoldN(int n);

  /// No description provided for @wizErrCover.
  ///
  /// In en, this message translates to:
  /// **'Pick a cover photo.'**
  String get wizErrCover;

  /// No description provided for @orgPctOfCapacity.
  ///
  /// In en, this message translates to:
  /// **'{pct} of {capacity} seats'**
  String orgPctOfCapacity(String pct, String capacity);

  /// No description provided for @a11yRating.
  ///
  /// In en, this message translates to:
  /// **'Rated {rating} out of 5 from {count} reviews'**
  String a11yRating(String rating, String count);

  /// No description provided for @a11yEventPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo of {title}'**
  String a11yEventPhoto(String title);

  /// No description provided for @a11ySalesChart.
  ///
  /// In en, this message translates to:
  /// **'Tickets sold over the last {days} days: {total} in total, best day {peak}'**
  String a11ySalesChart(String days, String total, String peak);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
