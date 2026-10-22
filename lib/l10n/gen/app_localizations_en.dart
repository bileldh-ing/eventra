// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Eventra';

  @override
  String get appTagline => 'Discover. Book. Feel the moment.';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navTickets => 'Tickets';

  @override
  String get navProfile => 'Profile';

  @override
  String get priceFree => 'Free';

  @override
  String distanceKm(String value) {
    return '$value km';
  }

  @override
  String distanceKmAway(String value) {
    return '$value km away';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get errNetwork => 'We could not reach Eventra. Check your connection.';

  @override
  String get errEventGone => 'This event is no longer available.';

  @override
  String get errStorage => 'Local storage is unavailable.';

  @override
  String get errUnknown => 'Something went wrong.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get actionRetry => 'Retry';

  @override
  String get mapEventLocation => 'Event location';

  @override
  String get mapAttribution => '© OpenStreetMap contributors';

  @override
  String get yourLocation => 'Your location';

  @override
  String get catCinema => 'Cinema';

  @override
  String get catSports => 'Sports';

  @override
  String get catSocial => 'Social';

  @override
  String get catMusic => 'Music';

  @override
  String get catArt => 'Art';

  @override
  String get catTech => 'Tech';

  @override
  String get catFood => 'Food';

  @override
  String get catComedy => 'Comedy';

  @override
  String get intOutdoors => 'Outdoors';

  @override
  String get intNightlife => 'Nightlife';

  @override
  String get intCharity => 'Charity';

  @override
  String get intBusiness => 'Business';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortSoonest => 'Soonest';

  @override
  String get sortNearest => 'Nearest';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPopular => 'Most popular';

  @override
  String get dateAny => 'Any time';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateThisWeekend => 'This Weekend';

  @override
  String get dateNext7 => 'Next 7 days';

  @override
  String get datePick => 'Pick dates';

  @override
  String get rowRecommendedForYou => 'Recommended For You';

  @override
  String rowBecauseYouLike(String interest) {
    return 'Because You Like $interest';
  }

  @override
  String reasonBecauseYouLike(String interest) {
    return 'Because you like $interest';
  }

  @override
  String get reasonNearYou => 'Near you';

  @override
  String get reasonTrending => 'Trending';

  @override
  String get reasonStartsSoon => 'Starts soon';

  @override
  String get reasonThisWeek => 'This week';

  @override
  String get reasonLikeSaves => 'Like your saves';

  @override
  String get homeUpcoming => 'Upcoming Events';

  @override
  String categoryEvents(String category) {
    return '$category Events';
  }

  @override
  String get filtersTitle => 'Filters';

  @override
  String get noEventsMatch => 'No events match';

  @override
  String get loosenFilters => 'Loosen your filters to see more events.';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get pickDateRange => 'Pick a date range';

  @override
  String get actionReset => 'Reset';

  @override
  String get filtersCategories => 'Categories';

  @override
  String get filtersAll => 'All';

  @override
  String get filtersDate => 'Date';

  @override
  String filtersPriceRange(String min, String max) {
    return 'Price: $min - $max';
  }

  @override
  String get filtersDistanceAny => 'Distance: any';

  @override
  String filtersDistanceWithin(String km) {
    return 'Distance: within $km km';
  }

  @override
  String get filtersAny => 'Any';

  @override
  String filtersKm(String km) {
    return '$km km';
  }

  @override
  String filtersFrom(String origin) {
    return 'From $origin';
  }

  @override
  String get filtersFreeOnly => 'Free only';

  @override
  String get filtersHasTickets => 'Has tickets left';

  @override
  String get filtersSortBy => 'Sort by';

  @override
  String filtersShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count results',
      one: 'Show 1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'See All';

  @override
  String get tryAnotherCategory =>
      'Try another category or reset your filters.';

  @override
  String get showAllEvents => 'Show all events';

  @override
  String reasonNearYouKm(String km) {
    return 'Near you · $km km';
  }

  @override
  String get homeTrendingWeek => 'Trending This Week';

  @override
  String nGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count going',
      one: '1 going',
      zero: 'Nobody going yet',
    );
    return '$_temp0';
  }

  @override
  String get homeFreeEvents => 'Free Events';

  @override
  String get openProfile => 'Open profile';

  @override
  String get notificationsUnread => 'Notifications, unread';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get homeHeroTitle => 'Discover Amazing\nEvents Near You';

  @override
  String get searchEvents => 'Search events';

  @override
  String get searchHint => 'Search';

  @override
  String get favUpdateFailed => 'Could not update favorites. Try again.';

  @override
  String get favRemove => 'Remove from favorites';

  @override
  String get favSave => 'Save to favorites';

  @override
  String get openEvent => 'Open event';

  @override
  String nParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Participants',
      one: '1 Participant',
    );
    return '$_temp0';
  }

  @override
  String get friendGoing => 'Friend - going';

  @override
  String get going => 'Going';

  @override
  String morePeopleGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more people are going',
      one: '+1 more person is going',
    );
    return '$_temp0';
  }

  @override
  String get inviteFriends => 'Invite friends';

  @override
  String get closePreview => 'Close preview';

  @override
  String get saved => 'Saved';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get viewEvent => 'View event';

  @override
  String cardDateDistance(String date, String km) {
    return '$date  ·  $km km away';
  }

  @override
  String shareText(
    String title,
    String date,
    String venue,
    String address,
    String price,
    String link,
  ) {
    return '$title - $date at $venue, $address. $price. $link';
  }

  @override
  String get shareFreeEntry => 'Free entry';

  @override
  String shareTicketsFrom(String price) {
    return 'Tickets from $price';
  }

  @override
  String shareInviteText(String title, String date, String link) {
    return 'Join me at $title on $date! $link';
  }

  @override
  String shareInviteSubject(String title) {
    return 'Come with me to $title';
  }

  @override
  String get authWeakPassword => 'Choose a stronger password.';

  @override
  String get authEmailTaken =>
      'An account with this email already exists. Log in instead.';

  @override
  String get authCodeExpired => 'This code has expired. Request a new one.';

  @override
  String get authCodeWrong => 'That code is not right. Check it and try again.';

  @override
  String authBadCredentials(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Email or password is incorrect. $left attempts left.',
      one: 'Email or password is incorrect. 1 attempt left.',
    );
    return '$_temp0';
  }

  @override
  String get authUnverified =>
      'Confirm your email with the code we sent to finish signing up.';

  @override
  String get authCodeInvalid => 'That code is not valid. Request a new one.';

  @override
  String get authUserNotFound =>
      'We could not find an account with that email.';

  @override
  String authLockedOut(String seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String get valEnterEmail => 'Enter your email';

  @override
  String get valValidEmail => 'Enter a valid email address';

  @override
  String get valEnterName => 'Enter your name';

  @override
  String get valNameShort => 'Name is too short';

  @override
  String get valPhone => 'Enter a valid phone number';

  @override
  String get valEnterPassword => 'Enter your password';

  @override
  String get valPasswordLength => 'Use at least 8 characters';

  @override
  String get valPasswordMix => 'Add numbers, symbols or upper-case letters';

  @override
  String get pwWeak => 'Weak';

  @override
  String get pwFair => 'Fair';

  @override
  String get pwGood => 'Good';

  @override
  String get pwStrong => 'Strong';

  @override
  String get authEnterCode => 'Enter the 6-digit code.';

  @override
  String get authPasswordUpdated =>
      'Password updated. Log in with your new password.';

  @override
  String get authSetNewPassword => 'Set a new password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String authResetCodeSent(String email) {
    return 'Enter the code we sent to $email and choose a new password.';
  }

  @override
  String get authResetIntro =>
      'Enter your account email and we will send you a reset code.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get authUpdatePassword => 'Update password';

  @override
  String get authSendResetCode => 'Send reset code';

  @override
  String get authDemoNotice =>
      'Demo mode: codes are not emailed; nothing leaves this device.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authLoginToBook =>
      'Log in to book tickets and keep your favorites in sync.';

  @override
  String get authLoginContinue => 'Log in to continue where you left off.';

  @override
  String get authNewHere => 'New here?';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get fieldPassword => 'Password';

  @override
  String authTryAgainIn(String seconds) {
    return 'Try again in ${seconds}s';
  }

  @override
  String get authLoggingIn => 'Logging in...';

  @override
  String get authLogIn => 'Log In';

  @override
  String get authOr => 'or';

  @override
  String get authTryDemo => 'Try demo account';

  @override
  String get authContinueGuest => 'Continue as guest';

  @override
  String authNewCodeSent(String email) {
    return 'We sent a new code to $email';
  }

  @override
  String get authCheckEmail => 'Check your email';

  @override
  String authOtpSubtitle(String email) {
    return 'Enter the 6-digit code we sent to $email.';
  }

  @override
  String get authVerifying => 'Verifying...';

  @override
  String get authVerify => 'Verify';

  @override
  String get authDidntGetIt => 'Didn\'t get it?';

  @override
  String authResendIn(String seconds) {
    return 'Resend in 0:$seconds';
  }

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authCodesExpire => 'Codes expire after 10 minutes.';

  @override
  String get authCreateAccountTitle => 'Create account';

  @override
  String get authJoinSubtitle =>
      'Join Eventra to book tickets and follow organizers.';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldPhoneOptional => 'Phone (optional)';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get valPasswordsMismatch => 'Passwords do not match';

  @override
  String get authAgreeTerms =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get authCreatingAccount => 'Creating account...';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get back => 'Back';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get pwStrengthLabel => 'Password strength';

  @override
  String pwStrengthValue(String level) {
    return 'Password strength $level';
  }

  @override
  String authDebugCode(String code) {
    return 'Debug build: the demo code is $code';
  }

  @override
  String get interestsTitle => 'What are you into?';

  @override
  String interestsSubtitle(String min) {
    return 'Pick at least $min so we can tailor your feed. You can change them later in Profile.';
  }

  @override
  String interestsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String interestsChooseMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Choose $count more',
      one: 'Choose 1 more',
    );
    return '$_temp0';
  }

  @override
  String get actionContinue => 'Continue';

  @override
  String locNearestArea(String city) {
    return 'Nearest area to you: $city';
  }

  @override
  String get locOff => 'Location is off, so pick your city below.';

  @override
  String get locWhere => 'Where are you?';

  @override
  String get locWhy =>
      'We use it to show events near you and measure distances.';

  @override
  String get locUseCurrent => 'Use my current location';

  @override
  String get locSkip => 'Skip for now';

  @override
  String get onb1Title => 'Discover events near you';

  @override
  String get onb1Body =>
      'Concerts, games, talks and food markets around you, picked for what you love.';

  @override
  String get onb2Title => 'Book in seconds';

  @override
  String get onb2Body =>
      'Choose your tickets, apply a promo code and pay in a couple of taps.';

  @override
  String get onb3Title => 'Enter with a tap';

  @override
  String get onb3Body => 'Your QR ticket lives in the app, ready at the door.';

  @override
  String get onbSkip => 'Skip';

  @override
  String onbPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get onbGetStarted => 'Get Started';

  @override
  String get onbNext => 'Next';

  @override
  String get exploreDistancesUpdated => 'Distances updated from your location';

  @override
  String exploreServicesOff(String place) {
    return 'Location services are off. Showing distances from $place.';
  }

  @override
  String exploreLocationUnavailable(String place) {
    return 'Location unavailable. Showing distances from $place.';
  }

  @override
  String get exploreShowMyLocation => 'Show my location';

  @override
  String nUpcomingEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upcoming events',
      one: '1 upcoming event',
      zero: 'No upcoming events',
    );
    return '$_temp0';
  }

  @override
  String openNamed(String name) {
    return 'Open $name';
  }

  @override
  String get exploreNearest => 'Nearest Location';

  @override
  String get exploreNoPlaces => 'No places match your search';

  @override
  String get exploreSearchHint => 'Search Your Location...';

  @override
  String explorePlaceSemantics(String title, String address, String distance) {
    return '$title, $address, $distance away';
  }

  @override
  String get favSortRecent => 'Recently saved';

  @override
  String get favSortSoonest => 'Date: soonest';

  @override
  String get favSortName => 'Name: A to Z';

  @override
  String favRemoved(String title) {
    return 'Removed $title';
  }

  @override
  String get undo => 'Undo';

  @override
  String get sort => 'Sort';

  @override
  String get favShowGrid => 'Show as grid';

  @override
  String get favShowList => 'Show as list';

  @override
  String get favEmptyTitle => 'No favorites yet';

  @override
  String get favEmptyBody => 'Tap the bookmark on any event to save it here.';

  @override
  String get exploreEvents => 'Explore events';

  @override
  String nResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get searchFullHint => 'Search events, venues, places';

  @override
  String get clear => 'Clear';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get recentCleared => 'Recent searches cleared';

  @override
  String get clearAll => 'Clear all';

  @override
  String removedTerm(String term) {
    return 'Removed \"$term\"';
  }

  @override
  String get trendingSearches => 'Trending searches';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchFiltersHiding =>
      'Your filters may be hiding matches. Clear them or try one of these:';

  @override
  String get searchCheckSpelling => 'Check the spelling or try one of these:';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get notifRemoved => 'Notification removed';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get notifEmptyTitle => 'All caught up';

  @override
  String get notifEmptyBody => 'New reminders and updates will appear here.';

  @override
  String get earlier => 'Earlier';

  @override
  String get seedFriendsTitle => '2 friends are going';

  @override
  String seedFriendsBody(String title) {
    return 'Sarah and Liam saved $title.';
  }

  @override
  String get seedSoonTitle => 'Coming up soon';

  @override
  String seedSoonBody(String title) {
    return '$title is one of the next events near you.';
  }

  @override
  String seedReviewTitle(String title) {
    return 'How was $title?';
  }

  @override
  String get seedReviewBody =>
      'Attendees are sharing reviews. Tap to read them.';

  @override
  String get seedNewTitle => 'New in Music near you';

  @override
  String seedNewBody(String title) {
    return '$title was just announced.';
  }

  @override
  String get seedPriceTitle => 'Early Bird price available';

  @override
  String seedPriceBody(String title) {
    return 'Save 20% on $title while Early Bird lasts.';
  }

  @override
  String get detailsTitle => 'Events Details';

  @override
  String plusParticipants(String count) {
    return '+$count Participants';
  }

  @override
  String get detailsAbout => 'About Event';

  @override
  String get detailsLocation => 'Location';

  @override
  String get detailsOrganizer => 'Organizer';

  @override
  String get detailsLineup => 'Lineup & Schedule';

  @override
  String get detailsPolicy => 'Ticket Policy';

  @override
  String get detailsSimilar => 'Similar events';

  @override
  String get shareEvent => 'Share event';

  @override
  String get soldOut => 'Sold Out';

  @override
  String get waitlistJoined =>
      'You\'re on the waitlist. We\'ll tell you when a spot opens.';

  @override
  String get waitlistLeft => 'You left the waitlist.';

  @override
  String get onWaitlist => 'On waitlist';

  @override
  String get joinWaitlist => 'Join waitlist';

  @override
  String get verifiedOrganizer => 'Verified organizer';

  @override
  String organizerFollowers(String followers) {
    return 'Organizer - $followers followers';
  }

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String openMapFor(String venue) {
    return 'Open map for $venue. Long press for directions.';
  }

  @override
  String get seeMore => 'See more....';

  @override
  String get seeLess => 'See less';

  @override
  String get getTicket => 'Get a Ticket';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileUnavailable => 'Profile unavailable.';

  @override
  String get profileLoginToEdit => 'Log in to edit your profile.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get couldNotSave => 'Could not save. Please try again.';

  @override
  String get avatarColor => 'Avatar color';

  @override
  String avatarColorN(String n) {
    return 'Avatar color $n';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldCity => 'City';

  @override
  String get fieldCityHint => 'Where you go out';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldBioHint => 'A line about you';

  @override
  String get saving => 'Saving...';

  @override
  String get guest => 'Guest';

  @override
  String get profileGuestPrompt => 'Log in to buy tickets and sync favorites';

  @override
  String get statTickets => 'Tickets';

  @override
  String get statSaved => 'Saved';

  @override
  String get statReviews => 'Reviews';

  @override
  String get loginOrSignup => 'Log in or sign up';

  @override
  String get myTickets => 'My Tickets';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get inviteFriendsTitle => 'Invite Friends';

  @override
  String get inviteShareText =>
      'I find events on Eventra - Discover. Book. Feel the moment. https://eventra.app';

  @override
  String get interestsTitleShort => 'Interests';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutQ => 'Log out?';

  @override
  String get logOutBody =>
      'Your tickets and favorites stay on this device for when you are back.';

  @override
  String get cancel => 'Cancel';

  @override
  String get setReminders => 'Event reminders';

  @override
  String get setRemindersSub =>
      '24 hours and 2 hours before events you have tickets for';

  @override
  String get setOrders => 'Order updates';

  @override
  String get setOrdersSub => 'Booking confirmations and refunds in your inbox';

  @override
  String get setRecs => 'Recommendations';

  @override
  String get setRecsSub => 'New events and price drops you might like';

  @override
  String get setPersonalized => 'Personalized feed';

  @override
  String get setPersonalizedSub => 'Use your interests to rank events';

  @override
  String get setClearCache => 'Clear cache';

  @override
  String get setClearCacheSub => 'Cached images and recent searches';

  @override
  String get setCacheCleared => 'Cache cleared';

  @override
  String get setAbout => 'About Eventra';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountQ => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your profile, tickets, reviews and notifications are removed from this device. Tickets are not refunded. This cannot be undone.';

  @override
  String get deleteConfirmWord => 'DELETE';

  @override
  String typeToConfirm(String word) {
    return 'Type $word';
  }

  @override
  String get delete => 'Delete';

  @override
  String get setAppearance => 'Appearance';

  @override
  String get setLanguage => 'Language';

  @override
  String get setNotifications => 'Notifications';

  @override
  String get setPrivacy => 'Privacy';

  @override
  String get setStorage => 'Storage';

  @override
  String get setAboutSection => 'About';

  @override
  String get setAccount => 'Account';

  @override
  String get sortReviews => 'Sort reviews';

  @override
  String get revNewest => 'Newest';

  @override
  String get revHighest => 'Highest rated';

  @override
  String get revLowest => 'Lowest rated';

  @override
  String get revLoadFailed => 'Reviews could not load.';

  @override
  String get revNoneHere => 'No reviews here';

  @override
  String get revTryAnotherStar => 'Try another star filter.';

  @override
  String nReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String revYou(String name) {
    return '$name (you)';
  }

  @override
  String get revOptions => 'Review options';

  @override
  String get edit => 'Edit';

  @override
  String get seeAllLower => 'See all';

  @override
  String get revNoneYet => 'No reviews yet.';

  @override
  String get revWrite => 'Write a review';

  @override
  String get revEditYours => 'Edit your review';

  @override
  String get revSignedOut =>
      'Log in with a ticket for this event to leave a review.';

  @override
  String get revOnlyAttendees =>
      'Only attendees with a ticket can review this event.';

  @override
  String get revAfterEnd => 'You can review this event after it ends.';

  @override
  String get revDeleteQ => 'Delete your review?';

  @override
  String get cannotUndo => 'This cannot be undone.';

  @override
  String get revDeleted => 'Review deleted';

  @override
  String get revThanks => 'Thanks for your review!';

  @override
  String get revUpdated => 'Review updated';

  @override
  String get revRateEvent => 'Rate this event';

  @override
  String nStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get revHint => 'What did you like? What could be better?';

  @override
  String revMinChars(String n) {
    return 'At least $n characters';
  }

  @override
  String get revPost => 'Post review';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get revEdited => 'edited';

  @override
  String get revLoginToWrite => 'Log in to write a review.';

  @override
  String get tkBadQuantity => 'Bad quantity.';

  @override
  String get tkUnknownTier => 'Unknown ticket type.';

  @override
  String tkTierMax(String max, String tier) {
    return 'You can buy up to $max $tier tickets.';
  }

  @override
  String get tkChooseFirst => 'Choose a ticket first.';

  @override
  String tkOrderMax(String max) {
    return 'You can buy up to $max tickets per order.';
  }

  @override
  String tkNotEnough(String tier) {
    return 'Not enough $tier tickets left. Update your selection.';
  }

  @override
  String get tkSelectionLost => 'Your selection was lost.';

  @override
  String get tkHoldEnded =>
      'Your 10-minute hold ended and the tickets were released.';

  @override
  String get tkChoosePay => 'Choose how to pay.';

  @override
  String get tkPaymentFailed => 'The payment failed.';

  @override
  String get tkSoldOutPaying =>
      'Those tickets sold out while you were paying. You have not been charged.';

  @override
  String get tkOrderNotFound => 'Order not found.';

  @override
  String get tkTicketUsed => 'A ticket in this order was already used.';

  @override
  String get tkRefundFailed => 'The refund could not be processed. Try again.';

  @override
  String get cardEnterNumber => 'Enter your card number.';

  @override
  String cardIncomplete(String brand) {
    return 'That $brand number is incomplete.';
  }

  @override
  String get cardInvalid => 'That card number is not valid.';

  @override
  String get cardUseMmYy => 'Use MM/YY.';

  @override
  String get cardExpired => 'This card expired.';

  @override
  String get cardCheckYear => 'Check the expiry year.';

  @override
  String cardCvcDigits(String n) {
    return '$n digits.';
  }

  @override
  String get cardGeneric => 'Card';

  @override
  String get payAuthCancelled =>
      'Card authentication was cancelled. You were not charged.';

  @override
  String get payDeclined => 'Your card was declined. Try another card.';

  @override
  String get payTimeout =>
      'The payment timed out. You were not charged; try again.';

  @override
  String get promoEmpty => 'Enter a promo code.';

  @override
  String get promoUnknown => 'That code does not exist.';

  @override
  String get promoNotYet => 'This code is not active yet.';

  @override
  String get promoExpired => 'This code has expired.';

  @override
  String get promoExhausted => 'This code has been fully redeemed.';

  @override
  String get promoUsed => 'You have already used this code.';

  @override
  String get promoNotApplicable =>
      'This code does not apply to the selected tickets.';

  @override
  String get promoMinSubtotal => 'Add more tickets to use this code.';

  @override
  String get promoL10 => '10% off';

  @override
  String get promoL5 => '\$5 off your first order';

  @override
  String get promoL20 => '20% off VIP tickets';

  @override
  String get promoL25 => '25% off summer events';

  @override
  String get promoL50 => '50% flash sale';

  @override
  String get refundSummary =>
      'Full refund when you cancel more than 48 hours before the event starts. No refunds within 48 hours of the start time.';

  @override
  String get refundStarted => 'This event has already started.';

  @override
  String get refundFreeAnyTime =>
      'Free reservation: cancel any time before the event.';

  @override
  String get refundFullUntil =>
      'Full refund available until 48 hours before the event.';

  @override
  String get refundClosed => 'Refunds close 48 hours before the event starts.';

  @override
  String get remChannel => 'Event reminders';

  @override
  String get remChannelDesc => 'Reminders 24 hours and 2 hours before events';

  @override
  String remTitleTomorrow(String title) {
    return '$title starts tomorrow';
  }

  @override
  String remTitleSoon(String title) {
    return '$title starts in 2 hours';
  }

  @override
  String remBody(String venue) {
    return '$venue. Your ticket is ready in Eventra.';
  }

  @override
  String get stValid => 'Valid';

  @override
  String get stUsed => 'Used';

  @override
  String get stExpired => 'Expired';

  @override
  String get stCancelled => 'Cancelled';

  @override
  String get ntBookingConfirmed => 'Booking confirmed';

  @override
  String ntBookingBody(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets for $title. Your QR code is ready.',
      one: '1 ticket for $title. Your QR code is ready.',
    );
    return '$_temp0';
  }

  @override
  String get ntRefundIssued => 'Refund issued';

  @override
  String ntRefundBody(String amount, String title) {
    return '$amount for $title is on its way to your card.';
  }

  @override
  String get bsOrderNotFound => 'Order not found';

  @override
  String get bsInMyTickets => 'Your tickets are in My Tickets.';

  @override
  String get bsLoadFailed => 'We could not load your order.';

  @override
  String get bsYoureIn => 'You\'re in!';

  @override
  String bsFreeReserved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free spots reserved',
      one: '1 free spot reserved',
    );
    return '$_temp0';
  }

  @override
  String bsPaid(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets · $amount paid',
      one: '1 ticket · $amount paid',
    );
    return '$_temp0';
  }

  @override
  String get bsRemindBoth => 'We\'ll remind you 24 hours and 2 hours before.';

  @override
  String get bsRemind2h => 'We\'ll remind you 2 hours before.';

  @override
  String get bsViewTickets => 'View Tickets';

  @override
  String get bsViewTicket => 'View Ticket';

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get done => 'Done';

  @override
  String get coCheckout => 'Checkout';

  @override
  String get coLoadFailed => 'We could not load your checkout.';

  @override
  String get coNotFound => 'Checkout not found';

  @override
  String get coSelectionGone =>
      'This selection is no longer available. Pick your tickets again.';

  @override
  String get coAlreadyBooked => 'Already booked';

  @override
  String get coInWallet => 'These tickets are in your wallet.';

  @override
  String get coLeaveQ => 'Leave checkout?';

  @override
  String get coLeaveBody =>
      'Your tickets are held for you. Leaving releases them for other fans.';

  @override
  String get coStay => 'Stay';

  @override
  String get coRelease => 'Release tickets';

  @override
  String get coPriceDetails => 'Price details';

  @override
  String get coAttendee => 'Attendee details';

  @override
  String get coEnterHolder => 'Enter the name on the tickets.';

  @override
  String get coEmailForTickets => 'Email for your tickets';

  @override
  String get coValidEmail => 'Enter a valid email.';

  @override
  String get coPromo => 'Promo code';

  @override
  String coPromoSaves(String label, String amount) {
    return '$label · saves $amount';
  }

  @override
  String get coRemovePromo => 'Remove promo code';

  @override
  String get coEnterCode => 'Enter code';

  @override
  String get coApply => 'Apply';

  @override
  String get coPayment => 'Payment method';

  @override
  String get coDemoMode => 'Demo mode';

  @override
  String get coAddCard => 'Add a new card';

  @override
  String get coUseAnother => 'Use another card';

  @override
  String get coConfirmFree => 'Confirm free reservation';

  @override
  String coPay(String amount) {
    return 'Pay $amount';
  }

  @override
  String coExpires(String date) {
    return 'Expires $date';
  }

  @override
  String coNewCardExpires(String date) {
    return 'New card · expires $date';
  }

  @override
  String coCardEnding(String brand, String last4) {
    return '$brand ending $last4';
  }

  @override
  String get coHoldExpired =>
      'Your hold expired and the tickets were released.';

  @override
  String coHeldFor(String time) {
    return 'Tickets held for $time';
  }

  @override
  String get coChooseAgain => 'Choose again';

  @override
  String get co3dsTitle => 'Confirm with your bank';

  @override
  String co3dsBody(String amount, String card) {
    return 'Approve a payment of $amount to Eventra with $card. This is a simulated 3-D Secure check.';
  }

  @override
  String get coApprove => 'Approve';

  @override
  String get coPaymentConfirmed => 'Payment confirmed';

  @override
  String get coProcessing => 'Processing payment…';

  @override
  String get coIssuing => 'Issuing your tickets';

  @override
  String get coKeepOpen => 'Please keep the app open';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabPast => 'Past';

  @override
  String get tabCancelled => 'Cancelled';

  @override
  String get mtLoadFailed => 'We could not open your tickets.';

  @override
  String get mtNoUpcoming => 'No upcoming tickets';

  @override
  String get mtNoUpcomingBody =>
      'Find something you love and your tickets will live here, ready to scan even offline.';

  @override
  String get mtNoPast => 'No past events yet';

  @override
  String get mtNoPastBody => 'Events you attend will be kept here.';

  @override
  String get mtNoCancelled => 'Nothing cancelled';

  @override
  String get mtNoCancelledBody => 'Refunded tickets show up here.';

  @override
  String tabWithCount(String label, String count) {
    return '$label ($count)';
  }

  @override
  String get tdRefundQ => 'Request a refund?';

  @override
  String get tdCancelResQ => 'Cancel reservation?';

  @override
  String tdRefundBody(int count, String amount, String card) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'All $count tickets in this order will be cancelled and $amount goes back to your $card.',
      one:
          'The ticket in this order will be cancelled and $amount goes back to your $card.',
    );
    return '$_temp0';
  }

  @override
  String tdReleaseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your spots will be released for other fans.',
      one: 'Your spot will be released for other fans.',
    );
    return '$_temp0';
  }

  @override
  String get tdKeep => 'Keep tickets';

  @override
  String get tdRefund => 'Refund';

  @override
  String get tdCancelRes => 'Cancel reservation';

  @override
  String tdRefunded(String amount) {
    return 'Refunded $amount. Your tickets were cancelled.';
  }

  @override
  String get tdResCancelled => 'Reservation cancelled.';

  @override
  String get tdYourTicket => 'Your Ticket';

  @override
  String get tdLoadFailed => 'We could not open this ticket.';

  @override
  String get tdNotFound => 'Ticket not found';

  @override
  String get tdOtherAccount => 'It may belong to another account.';

  @override
  String get tdAddCal => 'Add to\nCalendar';

  @override
  String get tdDirections => 'Directions';

  @override
  String get tdInvite => 'Invite\nfriends';

  @override
  String get tdDetails => 'Event\ndetails';

  @override
  String get tdOrder => 'Order';

  @override
  String get tdRefundedChip => 'Refunded';

  @override
  String get tdPaid => 'Paid';

  @override
  String get tdBooked => 'Booked';

  @override
  String tdPromo(String code) {
    return 'Promo $code';
  }

  @override
  String get feesAndTax => 'Fees and tax';

  @override
  String get tdTotalPaid => 'Total paid';

  @override
  String get tdPaidWith => 'Paid with';

  @override
  String get tdRefundPolicy => 'Refund policy';

  @override
  String get tdProcessing => 'Processing…';

  @override
  String tdRequestRefund(String amount) {
    return 'Request refund · $amount';
  }

  @override
  String get fDate => 'Date';

  @override
  String get fTime => 'Time';

  @override
  String get fVenue => 'Venue';

  @override
  String get fTicket => 'Ticket';

  @override
  String tdSeqOf(String seq, String count) {
    return '$seq of $count';
  }

  @override
  String get tdWasCancelled => 'This ticket was cancelled';

  @override
  String get tdEnded => 'This event has ended';

  @override
  String get fHolder => 'Holder';

  @override
  String get fTier => 'Tier';

  @override
  String get tdShowCode =>
      'Show this code at the entrance. It changes every 30 seconds, so screenshots will not work.';

  @override
  String get tpLoadFailed => 'We could not load the tickets for this event.';

  @override
  String get tpStarted => 'This event has started; tickets are no longer sold.';

  @override
  String tpCapReached(String max) {
    return 'You reached the $max-ticket limit for one order.';
  }

  @override
  String tpUpTo(String max) {
    return 'Up to $max tickets per order. Seats are held for 10 minutes once you continue.';
  }

  @override
  String get soldOutLower => 'Sold out';

  @override
  String tpAllGone(String count) {
    return 'All $count tickets are gone';
  }

  @override
  String tpLeftOf(String left, String total) {
    return '$left of $total left';
  }

  @override
  String tpOnlyLeft(String left) {
    return 'Only $left left';
  }

  @override
  String tpMaxPer(String max) {
    return 'Max $max per order';
  }

  @override
  String get tpChooseToSee => 'Choose your tickets to see the total.';

  @override
  String nTickets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tickets',
      one: '1 ticket',
    );
    return '$_temp0';
  }

  @override
  String get total => 'Total';

  @override
  String get tpHolding => 'Holding your seats…';

  @override
  String get tpContinue => 'Continue to checkout';

  @override
  String get cfAddCard => 'Add a card';

  @override
  String get cfNumber => 'Card number';

  @override
  String get cfName => 'Name on card';

  @override
  String get cfEnterName => 'Enter the name on the card.';

  @override
  String get cfDemo =>
      'Demo mode, no real charge. Test cards: 4242 4242 4242 4242 approves, 4000 0000 0000 0002 is declined, 4000 0000 0000 3220 asks for 3-D Secure. We keep only the brand and last four digits.';

  @override
  String get cfUse => 'Use this card';

  @override
  String tvCalDesc(String link) {
    return 'Your Eventra ticket is in the app. $link';
  }

  @override
  String get tvCalAdded => 'Added to your calendar';

  @override
  String get tvCalFailed => 'Could not open your calendar.';

  @override
  String tvInviteText(String title, String date, String venue, String link) {
    return 'I\'m going to $title on $date at $venue. Join me! $link';
  }

  @override
  String tvMapsFailed(String address) {
    return 'Could not open maps. $address';
  }

  @override
  String get tvQrLabel => 'Ticket QR code. Refreshes every 30 seconds.';

  @override
  String tvRefreshIn(String seconds) {
    return 'Code refreshes in ${seconds}s';
  }

  @override
  String get tvQrFailed =>
      'The secure code could not be created on this device.';

  @override
  String tvTierSeq(String tier, String seq, String count) {
    return '$tier · Ticket $seq of $count';
  }

  @override
  String get removeOne => 'Remove one';

  @override
  String get addOne => 'Add one';

  @override
  String subtotalN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Subtotal ($count tickets)',
      one: 'Subtotal (1 ticket)',
    );
    return '$_temp0';
  }

  @override
  String get serviceFees => 'Service fees';

  @override
  String get tax => 'Tax';

  @override
  String get valProfileName => 'Enter your name (2+ characters)';

  @override
  String valUnderN(String n) {
    return 'Keep it under $n characters';
  }

  @override
  String get revValRating => 'Pick a rating from 1 to 5 stars.';

  @override
  String revValShort(String n) {
    return 'Write at least $n characters.';
  }

  @override
  String revValLong(String n) {
    return 'Keep it under $n characters.';
  }

  @override
  String get revDupEdit =>
      'You already reviewed this event. Edit your review instead.';

  @override
  String get revDup => 'You already reviewed this event.';

  @override
  String get revNotFound => 'Review not found.';
}
