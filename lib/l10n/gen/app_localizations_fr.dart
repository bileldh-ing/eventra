// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Eventra';

  @override
  String get appTagline => 'Découvrez. Réservez. Vivez l\'instant.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navTickets => 'Billets';

  @override
  String get navProfile => 'Profil';

  @override
  String get priceFree => 'Gratuit';

  @override
  String distanceKm(String value) {
    return '$value km';
  }

  @override
  String distanceKmAway(String value) {
    return 'à $value km';
  }

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get errNetwork =>
      'Impossible de joindre Eventra. Vérifiez votre connexion.';

  @override
  String get errEventGone => 'Cet événement n\'est plus disponible.';

  @override
  String get errStorage => 'Le stockage local est indisponible.';

  @override
  String get errUnknown => 'Une erreur s\'est produite.';

  @override
  String get errorTitle => 'Une erreur s\'est produite';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get mapEventLocation => 'Lieu de l\'événement';

  @override
  String get mapAttribution => '© les contributeurs d\'OpenStreetMap';

  @override
  String get yourLocation => 'Votre position';

  @override
  String get catCinema => 'Cinéma';

  @override
  String get catSports => 'Sport';

  @override
  String get catSocial => 'Social';

  @override
  String get catMusic => 'Musique';

  @override
  String get catArt => 'Art';

  @override
  String get catTech => 'Tech';

  @override
  String get catFood => 'Gastronomie';

  @override
  String get catComedy => 'Humour';

  @override
  String get intOutdoors => 'Plein air';

  @override
  String get intNightlife => 'Vie nocturne';

  @override
  String get intCharity => 'Solidarité';

  @override
  String get intBusiness => 'Business';

  @override
  String get sortRecommended => 'Recommandés';

  @override
  String get sortSoonest => 'Les plus proches dans le temps';

  @override
  String get sortNearest => 'Les plus proches';

  @override
  String get sortPriceLow => 'Prix croissant';

  @override
  String get sortPopular => 'Les plus populaires';

  @override
  String get dateAny => 'N\'importe quand';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateTomorrow => 'Demain';

  @override
  String get dateThisWeekend => 'Ce week-end';

  @override
  String get dateNext7 => '7 prochains jours';

  @override
  String get datePick => 'Choisir des dates';

  @override
  String get rowRecommendedForYou => 'Recommandés pour vous';

  @override
  String rowBecauseYouLike(String interest) {
    return 'Parce que vous aimez : $interest';
  }

  @override
  String reasonBecauseYouLike(String interest) {
    return 'Parce que vous aimez : $interest';
  }

  @override
  String get reasonNearYou => 'Près de vous';

  @override
  String get reasonTrending => 'Tendance';

  @override
  String get reasonStartsSoon => 'Commence bientôt';

  @override
  String get reasonThisWeek => 'Cette semaine';

  @override
  String get reasonLikeSaves => 'Comme vos favoris';

  @override
  String get homeUpcoming => 'Événements à venir';

  @override
  String categoryEvents(String category) {
    return 'Événements : $category';
  }

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get noEventsMatch => 'Aucun événement ne correspond';

  @override
  String get loosenFilters =>
      'Assouplissez vos filtres pour voir plus d\'événements.';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get pickDateRange => 'Choisissez une période';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get filtersCategories => 'Catégories';

  @override
  String get filtersAll => 'Toutes';

  @override
  String get filtersDate => 'Date';

  @override
  String filtersPriceRange(String min, String max) {
    return 'Prix : $min - $max';
  }

  @override
  String get filtersDistanceAny => 'Distance : toutes';

  @override
  String filtersDistanceWithin(String km) {
    return 'Distance : moins de $km km';
  }

  @override
  String get filtersAny => 'Toutes';

  @override
  String filtersKm(String km) {
    return '$km km';
  }

  @override
  String filtersFrom(String origin) {
    return 'Depuis $origin';
  }

  @override
  String get filtersFreeOnly => 'Gratuits uniquement';

  @override
  String get filtersHasTickets => 'Billets encore disponibles';

  @override
  String get filtersSortBy => 'Trier par';

  @override
  String filtersShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afficher $count résultats',
      one: 'Afficher 1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Tout voir';

  @override
  String get tryAnotherCategory =>
      'Essayez une autre catégorie ou réinitialisez vos filtres.';

  @override
  String get showAllEvents => 'Voir tous les événements';

  @override
  String reasonNearYouKm(String km) {
    return 'Près de vous · $km km';
  }

  @override
  String get homeTrendingWeek => 'Tendances de la semaine';

  @override
  String nGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
      zero: 'Personne pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get homeFreeEvents => 'Événements gratuits';

  @override
  String get openProfile => 'Ouvrir le profil';

  @override
  String get notificationsUnread => 'Notifications non lues';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get homeHeroTitle => 'Découvrez des\névénements près de vous';

  @override
  String get searchEvents => 'Rechercher des événements';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get favUpdateFailed =>
      'Impossible de mettre à jour les favoris. Réessayez.';

  @override
  String get favRemove => 'Retirer des favoris';

  @override
  String get favSave => 'Ajouter aux favoris';

  @override
  String get openEvent => 'Ouvrir l\'événement';

  @override
  String nParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get friendGoing => 'Ami - y va';

  @override
  String get going => 'Y va';

  @override
  String morePeopleGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count autres personnes y vont',
      one: '+1 autre personne y va',
    );
    return '$_temp0';
  }

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get closePreview => 'Fermer l\'aperçu';

  @override
  String get saved => 'Enregistré';

  @override
  String get save => 'Enregistrer';

  @override
  String get share => 'Partager';

  @override
  String get viewEvent => 'Voir l\'événement';

  @override
  String cardDateDistance(String date, String km) {
    return '$date  ·  à $km km';
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
    return '$title - $date à $venue, $address. $price. $link';
  }

  @override
  String get shareFreeEntry => 'Entrée libre';

  @override
  String shareTicketsFrom(String price) {
    return 'Billets à partir de $price';
  }

  @override
  String shareInviteText(String title, String date, String link) {
    return 'Rejoins-moi à $title le $date ! $link';
  }

  @override
  String shareInviteSubject(String title) {
    return 'Viens avec moi à $title';
  }

  @override
  String get authWeakPassword => 'Choisissez un mot de passe plus sûr.';

  @override
  String get authEmailTaken =>
      'Un compte existe déjà avec cet e-mail. Connectez-vous plutôt.';

  @override
  String get authCodeExpired => 'Ce code a expiré. Demandez-en un nouveau.';

  @override
  String get authCodeWrong =>
      'Ce code est incorrect. Vérifiez-le et réessayez.';

  @override
  String authBadCredentials(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'E-mail ou mot de passe incorrect. $left tentatives restantes.',
      one: 'E-mail ou mot de passe incorrect. 1 tentative restante.',
    );
    return '$_temp0';
  }

  @override
  String get authUnverified =>
      'Confirmez votre e-mail avec le code envoyé pour terminer l\'inscription.';

  @override
  String get authCodeInvalid =>
      'Ce code n\'est pas valide. Demandez-en un nouveau.';

  @override
  String get authUserNotFound => 'Aucun compte ne correspond à cet e-mail.';

  @override
  String authLockedOut(String seconds) {
    return 'Trop de tentatives. Réessayez dans $seconds s.';
  }

  @override
  String get valEnterEmail => 'Saisissez votre e-mail';

  @override
  String get valValidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get valEnterName => 'Saisissez votre nom';

  @override
  String get valNameShort => 'Le nom est trop court';

  @override
  String get valPhone => 'Saisissez un numéro de téléphone valide';

  @override
  String get valEnterPassword => 'Saisissez votre mot de passe';

  @override
  String get valPasswordLength => 'Utilisez au moins 8 caractères';

  @override
  String get valPasswordMix =>
      'Ajoutez des chiffres, des symboles ou des majuscules';

  @override
  String get pwWeak => 'Faible';

  @override
  String get pwFair => 'Moyen';

  @override
  String get pwGood => 'Bon';

  @override
  String get pwStrong => 'Fort';

  @override
  String get authEnterCode => 'Saisissez le code à 6 chiffres.';

  @override
  String get authPasswordUpdated =>
      'Mot de passe mis à jour. Connectez-vous avec le nouveau.';

  @override
  String get authSetNewPassword => 'Définir un nouveau mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String authResetCodeSent(String email) {
    return 'Saisissez le code envoyé à $email et choisissez un nouveau mot de passe.';
  }

  @override
  String get authResetIntro =>
      'Saisissez l\'e-mail de votre compte et nous vous enverrons un code de réinitialisation.';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldNewPassword => 'Nouveau mot de passe';

  @override
  String get pleaseWait => 'Veuillez patienter...';

  @override
  String get authUpdatePassword => 'Mettre à jour le mot de passe';

  @override
  String get authSendResetCode => 'Envoyer le code';

  @override
  String get authDemoNotice =>
      'Mode démo : aucun code n\'est envoyé par e-mail ; rien ne quitte cet appareil.';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authLoginToBook =>
      'Connectez-vous pour réserver des billets et synchroniser vos favoris.';

  @override
  String get authLoginContinue =>
      'Connectez-vous pour reprendre là où vous en étiez.';

  @override
  String get authNewHere => 'Nouveau ici ?';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String authTryAgainIn(String seconds) {
    return 'Réessayez dans $seconds s';
  }

  @override
  String get authLoggingIn => 'Connexion...';

  @override
  String get authLogIn => 'Se connecter';

  @override
  String get authOr => 'ou';

  @override
  String get authTryDemo => 'Essayer le compte démo';

  @override
  String get authContinueGuest => 'Continuer en tant qu\'invité';

  @override
  String authNewCodeSent(String email) {
    return 'Nous avons envoyé un nouveau code à $email';
  }

  @override
  String get authCheckEmail => 'Vérifiez vos e-mails';

  @override
  String authOtpSubtitle(String email) {
    return 'Saisissez le code à 6 chiffres envoyé à $email.';
  }

  @override
  String get authVerifying => 'Vérification...';

  @override
  String get authVerify => 'Vérifier';

  @override
  String get authDidntGetIt => 'Pas reçu ?';

  @override
  String authResendIn(String seconds) {
    return 'Renvoyer dans 0:$seconds';
  }

  @override
  String get authResendCode => 'Renvoyer le code';

  @override
  String get authCodesExpire => 'Les codes expirent au bout de 10 minutes.';

  @override
  String get authCreateAccountTitle => 'Créer un compte';

  @override
  String get authJoinSubtitle =>
      'Rejoignez Eventra pour réserver des billets et suivre des organisateurs.';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get fieldFullName => 'Nom complet';

  @override
  String get fieldPhoneOptional => 'Téléphone (facultatif)';

  @override
  String get fieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get valPasswordsMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authAgreeTerms =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité';

  @override
  String get authCreatingAccount => 'Création du compte...';

  @override
  String get authCreateAccount => 'Créer le compte';

  @override
  String get back => 'Retour';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get pwStrengthLabel => 'Robustesse du mot de passe';

  @override
  String pwStrengthValue(String level) {
    return 'Robustesse du mot de passe : $level';
  }

  @override
  String authDebugCode(String code) {
    return 'Version de débogage : le code démo est $code';
  }

  @override
  String get interestsTitle => 'Qu\'est-ce qui vous plaît ?';

  @override
  String interestsSubtitle(String min) {
    return 'Choisissez-en au moins $min pour personnaliser votre fil. Vous pourrez les modifier plus tard dans Profil.';
  }

  @override
  String interestsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String interestsChooseMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count à choisir',
      one: 'Encore 1 à choisir',
    );
    return '$_temp0';
  }

  @override
  String get actionContinue => 'Continuer';

  @override
  String locNearestArea(String city) {
    return 'Zone la plus proche : $city';
  }

  @override
  String get locOff =>
      'La localisation est désactivée : choisissez votre ville ci-dessous.';

  @override
  String get locWhere => 'Où êtes-vous ?';

  @override
  String get locWhy =>
      'Nous l\'utilisons pour afficher les événements proches et calculer les distances.';

  @override
  String get locUseCurrent => 'Utiliser ma position actuelle';

  @override
  String get locSkip => 'Passer pour l\'instant';

  @override
  String get onb1Title => 'Découvrez les événements près de chez vous';

  @override
  String get onb1Body =>
      'Concerts, matchs, conférences et marchés gourmands autour de vous, choisis selon vos goûts.';

  @override
  String get onb2Title => 'Réservez en quelques secondes';

  @override
  String get onb2Body =>
      'Choisissez vos billets, appliquez un code promo et payez en quelques gestes.';

  @override
  String get onb3Title => 'Entrez d\'un geste';

  @override
  String get onb3Body => 'Votre billet QR est dans l\'appli, prêt à l\'entrée.';

  @override
  String get onbSkip => 'Passer';

  @override
  String onbPageOf(int page, int total) {
    return 'Page $page sur $total';
  }

  @override
  String get onbGetStarted => 'Commencer';

  @override
  String get onbNext => 'Suivant';

  @override
  String get exploreDistancesUpdated =>
      'Distances mises à jour depuis votre position';

  @override
  String exploreServicesOff(String place) {
    return 'Les services de localisation sont désactivés. Distances calculées depuis $place.';
  }

  @override
  String exploreLocationUnavailable(String place) {
    return 'Position indisponible. Distances calculées depuis $place.';
  }

  @override
  String get exploreShowMyLocation => 'Afficher ma position';

  @override
  String nUpcomingEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements à venir',
      one: '1 événement à venir',
      zero: 'Aucun événement à venir',
    );
    return '$_temp0';
  }

  @override
  String openNamed(String name) {
    return 'Ouvrir $name';
  }

  @override
  String get exploreNearest => 'Lieux les plus proches';

  @override
  String get exploreNoPlaces => 'Aucun lieu ne correspond à votre recherche';

  @override
  String get exploreSearchHint => 'Rechercher un lieu...';

  @override
  String explorePlaceSemantics(String title, String address, String distance) {
    return '$title, $address, à $distance';
  }

  @override
  String get favSortRecent => 'Ajoutés récemment';

  @override
  String get favSortSoonest => 'Date : la plus proche';

  @override
  String get favSortName => 'Nom : de A à Z';

  @override
  String favRemoved(String title) {
    return '$title retiré';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get sort => 'Trier';

  @override
  String get favShowGrid => 'Afficher en grille';

  @override
  String get favShowList => 'Afficher en liste';

  @override
  String get favEmptyTitle => 'Aucun favori pour l\'instant';

  @override
  String get favEmptyBody =>
      'Touchez le signet d\'un événement pour l\'enregistrer ici.';

  @override
  String get exploreEvents => 'Explorer les événements';

  @override
  String nResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get searchFullHint => 'Rechercher des événements, salles, lieux';

  @override
  String get clear => 'Effacer';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get recentCleared => 'Recherches récentes effacées';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String removedTerm(String term) {
    return '« $term » supprimé';
  }

  @override
  String get trendingSearches => 'Recherches tendance';

  @override
  String noResultsFor(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchFiltersHiding =>
      'Vos filtres masquent peut-être des résultats. Effacez-les ou essayez l\'une de ces suggestions :';

  @override
  String get searchCheckSpelling =>
      'Vérifiez l\'orthographe ou essayez l\'une de ces suggestions :';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get notifRemoved => 'Notification supprimée';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get notifEmptyTitle => 'Vous êtes à jour';

  @override
  String get notifEmptyBody =>
      'Les nouveaux rappels et mises à jour apparaîtront ici.';

  @override
  String get earlier => 'Plus tôt';

  @override
  String get seedFriendsTitle => '2 amis y vont';

  @override
  String seedFriendsBody(String title) {
    return 'Sarah et Liam ont enregistré $title.';
  }

  @override
  String get seedSoonTitle => 'Bientôt';

  @override
  String seedSoonBody(String title) {
    return '$title fait partie des prochains événements près de chez vous.';
  }

  @override
  String seedReviewTitle(String title) {
    return 'Comment était $title ?';
  }

  @override
  String get seedReviewBody =>
      'Les participants partagent leurs avis. Touchez pour les lire.';

  @override
  String get seedNewTitle => 'Nouveau en musique près de chez vous';

  @override
  String seedNewBody(String title) {
    return '$title vient d\'être annoncé.';
  }

  @override
  String get seedPriceTitle => 'Tarif Early Bird disponible';

  @override
  String seedPriceBody(String title) {
    return 'Économisez 20 % sur $title tant que l\'offre Early Bird dure.';
  }

  @override
  String get detailsTitle => 'Détails de l\'événement';

  @override
  String plusParticipants(String count) {
    return '+$count participants';
  }

  @override
  String get detailsAbout => 'À propos';

  @override
  String get detailsLocation => 'Lieu';

  @override
  String get detailsOrganizer => 'Organisateur';

  @override
  String get detailsLineup => 'Programme';

  @override
  String get detailsPolicy => 'Conditions des billets';

  @override
  String get detailsSimilar => 'Événements similaires';

  @override
  String get shareEvent => 'Partager l\'événement';

  @override
  String get soldOut => 'Complet';

  @override
  String get waitlistJoined =>
      'Vous êtes sur liste d\'attente. Nous vous préviendrons si une place se libère.';

  @override
  String get waitlistLeft => 'Vous avez quitté la liste d\'attente.';

  @override
  String get onWaitlist => 'Sur liste d\'attente';

  @override
  String get joinWaitlist => 'Rejoindre la liste d\'attente';

  @override
  String get verifiedOrganizer => 'Organisateur vérifié';

  @override
  String organizerFollowers(String followers) {
    return 'Organisateur - $followers abonnés';
  }

  @override
  String get following => 'Abonné';

  @override
  String get follow => 'Suivre';

  @override
  String openMapFor(String venue) {
    return 'Ouvrir la carte de $venue. Appui long pour l\'itinéraire.';
  }

  @override
  String get seeMore => 'Voir plus...';

  @override
  String get seeLess => 'Voir moins';

  @override
  String get getTicket => 'Obtenir un billet';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profileUnavailable => 'Profil indisponible.';

  @override
  String get profileLoginToEdit => 'Connectez-vous pour modifier votre profil.';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get couldNotSave => 'Enregistrement impossible. Veuillez réessayer.';

  @override
  String get avatarColor => 'Couleur de l\'avatar';

  @override
  String avatarColorN(String n) {
    return 'Couleur de l\'avatar $n';
  }

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldCity => 'Ville';

  @override
  String get fieldCityHint => 'Où vous sortez';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldBioHint => 'Une phrase sur vous';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get guest => 'Invité';

  @override
  String get profileGuestPrompt =>
      'Connectez-vous pour acheter des billets et synchroniser vos favoris';

  @override
  String get statTickets => 'Billets';

  @override
  String get statSaved => 'Enregistrés';

  @override
  String get statReviews => 'Avis';

  @override
  String get loginOrSignup => 'Se connecter ou s\'inscrire';

  @override
  String get myTickets => 'Mes billets';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get inviteFriendsTitle => 'Inviter des amis';

  @override
  String get inviteShareText =>
      'Je trouve mes sorties sur Eventra - Découvrez. Réservez. Vivez l\'instant. https://eventra.app';

  @override
  String get interestsTitleShort => 'Centres d\'intérêt';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutQ => 'Se déconnecter ?';

  @override
  String get logOutBody =>
      'Vos billets et favoris restent sur cet appareil pour votre retour.';

  @override
  String get cancel => 'Annuler';

  @override
  String get setReminders => 'Rappels d\'événements';

  @override
  String get setRemindersSub =>
      '24 h et 2 h avant les événements pour lesquels vous avez des billets';

  @override
  String get setOrders => 'Suivi des commandes';

  @override
  String get setOrdersSub =>
      'Confirmations de réservation et remboursements dans votre boîte';

  @override
  String get setRecs => 'Recommandations';

  @override
  String get setRecsSub =>
      'Nouveaux événements et baisses de prix susceptibles de vous plaire';

  @override
  String get setPersonalized => 'Fil personnalisé';

  @override
  String get setPersonalizedSub =>
      'Utiliser vos centres d\'intérêt pour classer les événements';

  @override
  String get setClearCache => 'Vider le cache';

  @override
  String get setClearCacheSub => 'Images en cache et recherches récentes';

  @override
  String get setCacheCleared => 'Cache vidé';

  @override
  String get setAbout => 'À propos d\'Eventra';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountQ => 'Supprimer votre compte ?';

  @override
  String get deleteAccountBody =>
      'Votre profil, vos billets, avis et notifications seront supprimés de cet appareil. Les billets ne sont pas remboursés. Cette action est irréversible.';

  @override
  String get deleteConfirmWord => 'SUPPRIMER';

  @override
  String typeToConfirm(String word) {
    return 'Tapez $word';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get setAppearance => 'Apparence';

  @override
  String get setLanguage => 'Langue';

  @override
  String get setNotifications => 'Notifications';

  @override
  String get setPrivacy => 'Confidentialité';

  @override
  String get setStorage => 'Stockage';

  @override
  String get setAboutSection => 'À propos';

  @override
  String get setAccount => 'Compte';

  @override
  String get sortReviews => 'Trier les avis';

  @override
  String get revNewest => 'Plus récents';

  @override
  String get revHighest => 'Mieux notés';

  @override
  String get revLowest => 'Moins bien notés';

  @override
  String get revLoadFailed => 'Impossible de charger les avis.';

  @override
  String get revNoneHere => 'Aucun avis ici';

  @override
  String get revTryAnotherStar => 'Essayez un autre filtre d\'étoiles.';

  @override
  String nReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
      zero: 'Aucun avis',
    );
    return '$_temp0';
  }

  @override
  String revYou(String name) {
    return '$name (vous)';
  }

  @override
  String get revOptions => 'Options de l\'avis';

  @override
  String get edit => 'Modifier';

  @override
  String get seeAllLower => 'Tout voir';

  @override
  String get revNoneYet => 'Aucun avis pour l\'instant.';

  @override
  String get revWrite => 'Écrire un avis';

  @override
  String get revEditYours => 'Modifier votre avis';

  @override
  String get revSignedOut =>
      'Connectez-vous avec un billet pour cet événement afin de laisser un avis.';

  @override
  String get revOnlyAttendees =>
      'Seuls les participants munis d\'un billet peuvent évaluer cet événement.';

  @override
  String get revAfterEnd =>
      'Vous pourrez évaluer cet événement une fois terminé.';

  @override
  String get revDeleteQ => 'Supprimer votre avis ?';

  @override
  String get cannotUndo => 'Cette action est irréversible.';

  @override
  String get revDeleted => 'Avis supprimé';

  @override
  String get revThanks => 'Merci pour votre avis !';

  @override
  String get revUpdated => 'Avis mis à jour';

  @override
  String get revRateEvent => 'Évaluer cet événement';

  @override
  String nStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get revHint =>
      'Qu\'avez-vous aimé ? Qu\'est-ce qui pourrait être mieux ?';

  @override
  String revMinChars(String n) {
    return 'Au moins $n caractères';
  }

  @override
  String get revPost => 'Publier l\'avis';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get revEdited => 'modifié';

  @override
  String get revLoginToWrite => 'Connectez-vous pour écrire un avis.';

  @override
  String get tkBadQuantity => 'Quantité invalide.';

  @override
  String get tkUnknownTier => 'Type de billet inconnu.';

  @override
  String tkTierMax(String max, String tier) {
    return 'Vous pouvez acheter jusqu\'à $max billets $tier.';
  }

  @override
  String get tkChooseFirst => 'Choisissez d\'abord un billet.';

  @override
  String tkOrderMax(String max) {
    return 'Vous pouvez acheter jusqu\'à $max billets par commande.';
  }

  @override
  String tkNotEnough(String tier) {
    return 'Il ne reste pas assez de billets $tier. Modifiez votre sélection.';
  }

  @override
  String get tkSelectionLost => 'Votre sélection a été perdue.';

  @override
  String get tkHoldEnded =>
      'Votre réservation de 10 minutes a expiré et les billets ont été libérés.';

  @override
  String get tkChoosePay => 'Choisissez un moyen de paiement.';

  @override
  String get tkPaymentFailed => 'Le paiement a échoué.';

  @override
  String get tkSoldOutPaying =>
      'Ces billets ont été vendus pendant votre paiement. Vous n\'avez pas été débité.';

  @override
  String get tkOrderNotFound => 'Commande introuvable.';

  @override
  String get tkTicketUsed => 'Un billet de cette commande a déjà été utilisé.';

  @override
  String get tkRefundFailed =>
      'Le remboursement n\'a pas pu être effectué. Réessayez.';

  @override
  String get cardEnterNumber => 'Saisissez le numéro de carte.';

  @override
  String cardIncomplete(String brand) {
    return 'Ce numéro $brand est incomplet.';
  }

  @override
  String get cardInvalid => 'Ce numéro de carte n\'est pas valide.';

  @override
  String get cardUseMmYy => 'Utilisez le format MM/AA.';

  @override
  String get cardExpired => 'Cette carte a expiré.';

  @override
  String get cardCheckYear => 'Vérifiez l\'année d\'expiration.';

  @override
  String cardCvcDigits(String n) {
    return '$n chiffres.';
  }

  @override
  String get cardGeneric => 'Carte';

  @override
  String get payAuthCancelled =>
      'L\'authentification de la carte a été annulée. Vous n\'avez pas été débité.';

  @override
  String get payDeclined =>
      'Votre carte a été refusée. Essayez une autre carte.';

  @override
  String get payTimeout =>
      'Le paiement a expiré. Vous n\'avez pas été débité ; réessayez.';

  @override
  String get promoEmpty => 'Saisissez un code promo.';

  @override
  String get promoUnknown => 'Ce code n\'existe pas.';

  @override
  String get promoNotYet => 'Ce code n\'est pas encore actif.';

  @override
  String get promoExpired => 'Ce code a expiré.';

  @override
  String get promoExhausted => 'Ce code a atteint sa limite d\'utilisation.';

  @override
  String get promoUsed => 'Vous avez déjà utilisé ce code.';

  @override
  String get promoNotApplicable =>
      'Ce code ne s\'applique pas aux billets sélectionnés.';

  @override
  String get promoMinSubtotal => 'Ajoutez des billets pour utiliser ce code.';

  @override
  String get promoL10 => '-10 %';

  @override
  String get promoL5 => '5 \$ de réduction sur votre première commande';

  @override
  String get promoL20 => '-20 % sur les billets VIP';

  @override
  String get promoL25 => '-25 % sur les événements d\'été';

  @override
  String get promoL50 => 'Vente flash -50 %';

  @override
  String get refundSummary =>
      'Remboursement intégral en cas d\'annulation plus de 48 heures avant le début. Aucun remboursement dans les 48 heures précédant l\'événement.';

  @override
  String get refundStarted => 'Cet événement a déjà commencé.';

  @override
  String get refundFreeAnyTime =>
      'Réservation gratuite : annulable à tout moment avant l\'événement.';

  @override
  String get refundFullUntil =>
      'Remboursement intégral possible jusqu\'à 48 heures avant l\'événement.';

  @override
  String get refundClosed =>
      'Les remboursements ferment 48 heures avant le début de l\'événement.';

  @override
  String get remChannel => 'Rappels d\'événements';

  @override
  String get remChannelDesc => 'Rappels 24 h et 2 h avant les événements';

  @override
  String remTitleTomorrow(String title) {
    return '$title commence demain';
  }

  @override
  String remTitleSoon(String title) {
    return '$title commence dans 2 heures';
  }

  @override
  String remBody(String venue) {
    return '$venue. Votre billet vous attend dans Eventra.';
  }

  @override
  String get stValid => 'Valide';

  @override
  String get stUsed => 'Utilisé';

  @override
  String get stExpired => 'Expiré';

  @override
  String get stCancelled => 'Annulé';

  @override
  String get ntBookingConfirmed => 'Réservation confirmée';

  @override
  String ntBookingBody(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count billets pour $title. Votre code QR est prêt.',
      one: '1 billet pour $title. Votre code QR est prêt.',
    );
    return '$_temp0';
  }

  @override
  String get ntRefundIssued => 'Remboursement effectué';

  @override
  String ntRefundBody(String amount, String title) {
    return '$amount pour $title est en route vers votre carte.';
  }

  @override
  String get bsOrderNotFound => 'Commande introuvable';

  @override
  String get bsInMyTickets => 'Vos billets sont dans Mes billets.';

  @override
  String get bsLoadFailed => 'Impossible de charger votre commande.';

  @override
  String get bsYoureIn => 'C\'est réservé !';

  @override
  String bsFreeReserved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places gratuites réservées',
      one: '1 place gratuite réservée',
    );
    return '$_temp0';
  }

  @override
  String bsPaid(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count billets · $amount payés',
      one: '1 billet · $amount payé',
    );
    return '$_temp0';
  }

  @override
  String get bsRemindBoth => 'Nous vous le rappellerons 24 h et 2 h avant.';

  @override
  String get bsRemind2h => 'Nous vous le rappellerons 2 h avant.';

  @override
  String get bsViewTickets => 'Voir les billets';

  @override
  String get bsViewTicket => 'Voir le billet';

  @override
  String get addToCalendar => 'Ajouter au calendrier';

  @override
  String get done => 'Terminé';

  @override
  String get coCheckout => 'Paiement';

  @override
  String get coLoadFailed => 'Impossible de charger le paiement.';

  @override
  String get coNotFound => 'Paiement introuvable';

  @override
  String get coSelectionGone =>
      'Cette sélection n\'est plus disponible. Choisissez à nouveau vos billets.';

  @override
  String get coAlreadyBooked => 'Déjà réservé';

  @override
  String get coInWallet => 'Ces billets sont dans votre portefeuille.';

  @override
  String get coLeaveQ => 'Quitter le paiement ?';

  @override
  String get coLeaveBody =>
      'Vos billets sont réservés pour vous. En partant, vous les libérez pour d\'autres fans.';

  @override
  String get coStay => 'Rester';

  @override
  String get coRelease => 'Libérer les billets';

  @override
  String get coPriceDetails => 'Détail du prix';

  @override
  String get coAttendee => 'Informations du participant';

  @override
  String get coEnterHolder => 'Saisissez le nom figurant sur les billets.';

  @override
  String get coEmailForTickets => 'E-mail pour recevoir vos billets';

  @override
  String get coValidEmail => 'Saisissez un e-mail valide.';

  @override
  String get coPromo => 'Code promo';

  @override
  String coPromoSaves(String label, String amount) {
    return '$label · économie de $amount';
  }

  @override
  String get coRemovePromo => 'Retirer le code promo';

  @override
  String get coEnterCode => 'Saisir le code';

  @override
  String get coApply => 'Appliquer';

  @override
  String get coPayment => 'Moyen de paiement';

  @override
  String get coDemoMode => 'Mode démo';

  @override
  String get coAddCard => 'Ajouter une carte';

  @override
  String get coUseAnother => 'Utiliser une autre carte';

  @override
  String get coConfirmFree => 'Confirmer la réservation gratuite';

  @override
  String coPay(String amount) {
    return 'Payer $amount';
  }

  @override
  String coExpires(String date) {
    return 'Expire le $date';
  }

  @override
  String coNewCardExpires(String date) {
    return 'Nouvelle carte · expire le $date';
  }

  @override
  String coCardEnding(String brand, String last4) {
    return '$brand se terminant par $last4';
  }

  @override
  String get coHoldExpired =>
      'Votre réservation a expiré et les billets ont été libérés.';

  @override
  String coHeldFor(String time) {
    return 'Billets réservés pendant $time';
  }

  @override
  String get coChooseAgain => 'Choisir à nouveau';

  @override
  String get co3dsTitle => 'Confirmez auprès de votre banque';

  @override
  String co3dsBody(String amount, String card) {
    return 'Approuvez un paiement de $amount à Eventra avec $card. Il s\'agit d\'une vérification 3-D Secure simulée.';
  }

  @override
  String get coApprove => 'Approuver';

  @override
  String get coPaymentConfirmed => 'Paiement confirmé';

  @override
  String get coProcessing => 'Paiement en cours…';

  @override
  String get coIssuing => 'Émission de vos billets';

  @override
  String get coKeepOpen => 'Veuillez garder l\'appli ouverte';

  @override
  String get tabUpcoming => 'À venir';

  @override
  String get tabPast => 'Passés';

  @override
  String get tabCancelled => 'Annulés';

  @override
  String get mtLoadFailed => 'Impossible d\'ouvrir vos billets.';

  @override
  String get mtNoUpcoming => 'Aucun billet à venir';

  @override
  String get mtNoUpcomingBody =>
      'Trouvez une sortie qui vous plaît : vos billets seront ici, prêts à être scannés même hors ligne.';

  @override
  String get mtNoPast => 'Aucun événement passé';

  @override
  String get mtNoPastBody =>
      'Les événements auxquels vous assistez seront conservés ici.';

  @override
  String get mtNoCancelled => 'Aucune annulation';

  @override
  String get mtNoCancelledBody => 'Les billets remboursés apparaissent ici.';

  @override
  String tabWithCount(String label, String count) {
    return '$label ($count)';
  }

  @override
  String get tdRefundQ => 'Demander un remboursement ?';

  @override
  String get tdCancelResQ => 'Annuler la réservation ?';

  @override
  String tdRefundBody(int count, String amount, String card) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Les $count billets de cette commande seront annulés et $amount sera remboursé sur votre $card.',
      one:
          'Le billet de cette commande sera annulé et $amount sera remboursé sur votre $card.',
    );
    return '$_temp0';
  }

  @override
  String tdReleaseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vos places seront libérées pour d\'autres fans.',
      one: 'Votre place sera libérée pour d\'autres fans.',
    );
    return '$_temp0';
  }

  @override
  String get tdKeep => 'Garder les billets';

  @override
  String get tdRefund => 'Rembourser';

  @override
  String get tdCancelRes => 'Annuler la réservation';

  @override
  String tdRefunded(String amount) {
    return '$amount remboursé. Vos billets ont été annulés.';
  }

  @override
  String get tdResCancelled => 'Réservation annulée.';

  @override
  String get tdYourTicket => 'Votre billet';

  @override
  String get tdLoadFailed => 'Impossible d\'ouvrir ce billet.';

  @override
  String get tdNotFound => 'Billet introuvable';

  @override
  String get tdOtherAccount => 'Il appartient peut-être à un autre compte.';

  @override
  String get tdAddCal => 'Ajouter au\ncalendrier';

  @override
  String get tdDirections => 'Itinéraire';

  @override
  String get tdInvite => 'Inviter\ndes amis';

  @override
  String get tdDetails => 'Détails de\nl\'événement';

  @override
  String get tdOrder => 'Commande';

  @override
  String get tdRefundedChip => 'Remboursé';

  @override
  String get tdPaid => 'Payé';

  @override
  String get tdBooked => 'Réservé le';

  @override
  String tdPromo(String code) {
    return 'Promo $code';
  }

  @override
  String get feesAndTax => 'Frais et taxes';

  @override
  String get tdTotalPaid => 'Total payé';

  @override
  String get tdPaidWith => 'Payé avec';

  @override
  String get tdRefundPolicy => 'Politique de remboursement';

  @override
  String get tdProcessing => 'Traitement…';

  @override
  String tdRequestRefund(String amount) {
    return 'Demander le remboursement · $amount';
  }

  @override
  String get fDate => 'Date';

  @override
  String get fTime => 'Heure';

  @override
  String get fVenue => 'Lieu';

  @override
  String get fTicket => 'Billet';

  @override
  String tdSeqOf(String seq, String count) {
    return '$seq sur $count';
  }

  @override
  String get tdWasCancelled => 'Ce billet a été annulé';

  @override
  String get tdEnded => 'Cet événement est terminé';

  @override
  String get fHolder => 'Titulaire';

  @override
  String get fTier => 'Catégorie';

  @override
  String get tdShowCode =>
      'Présentez ce code à l\'entrée. Il change toutes les 30 secondes : les captures d\'écran ne fonctionnent pas.';

  @override
  String get tpLoadFailed =>
      'Impossible de charger les billets de cet événement.';

  @override
  String get tpStarted =>
      'Cet événement a commencé ; les billets ne sont plus en vente.';

  @override
  String tpCapReached(String max) {
    return 'Vous avez atteint la limite de $max billets par commande.';
  }

  @override
  String tpUpTo(String max) {
    return 'Jusqu\'à $max billets par commande. Les places sont réservées 10 minutes une fois que vous continuez.';
  }

  @override
  String get soldOutLower => 'Épuisé';

  @override
  String tpAllGone(String count) {
    return 'Les $count billets sont partis';
  }

  @override
  String tpLeftOf(String left, String total) {
    return '$left sur $total restants';
  }

  @override
  String tpOnlyLeft(String left) {
    return 'Plus que $left';
  }

  @override
  String tpMaxPer(String max) {
    return '$max max. par commande';
  }

  @override
  String get tpChooseToSee => 'Choisissez vos billets pour voir le total.';

  @override
  String nTickets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count billets',
      one: '1 billet',
    );
    return '$_temp0';
  }

  @override
  String get total => 'Total';

  @override
  String get tpHolding => 'Réservation de vos places…';

  @override
  String get tpContinue => 'Passer au paiement';

  @override
  String get cfAddCard => 'Ajouter une carte';

  @override
  String get cfNumber => 'Numéro de carte';

  @override
  String get cfName => 'Nom sur la carte';

  @override
  String get cfEnterName => 'Saisissez le nom figurant sur la carte.';

  @override
  String get cfDemo =>
      'Mode démo, aucun débit réel. Cartes de test : 4242 4242 4242 4242 est acceptée, 4000 0000 0000 0002 est refusée, 4000 0000 0000 3220 demande 3-D Secure. Nous ne conservons que la marque et les quatre derniers chiffres.';

  @override
  String get cfUse => 'Utiliser cette carte';

  @override
  String tvCalDesc(String link) {
    return 'Votre billet Eventra est dans l\'appli. $link';
  }

  @override
  String get tvCalAdded => 'Ajouté à votre calendrier';

  @override
  String get tvCalFailed => 'Impossible d\'ouvrir votre calendrier.';

  @override
  String tvInviteText(String title, String date, String venue, String link) {
    return 'Je vais à $title le $date à $venue. Rejoins-moi ! $link';
  }

  @override
  String tvMapsFailed(String address) {
    return 'Impossible d\'ouvrir les cartes. $address';
  }

  @override
  String get tvQrLabel =>
      'Code QR du billet. Actualisé toutes les 30 secondes.';

  @override
  String tvRefreshIn(String seconds) {
    return 'Nouveau code dans $seconds s';
  }

  @override
  String get tvQrFailed =>
      'Le code sécurisé n\'a pas pu être créé sur cet appareil.';

  @override
  String tvTierSeq(String tier, String seq, String count) {
    return '$tier · Billet $seq sur $count';
  }

  @override
  String get removeOne => 'Retirer un';

  @override
  String get addOne => 'Ajouter un';

  @override
  String subtotalN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sous-total ($count billets)',
      one: 'Sous-total (1 billet)',
    );
    return '$_temp0';
  }

  @override
  String get serviceFees => 'Frais de service';

  @override
  String get tax => 'Taxes';

  @override
  String get valProfileName => 'Saisissez votre nom (2 caractères min.)';

  @override
  String valUnderN(String n) {
    return 'Moins de $n caractères';
  }

  @override
  String get revValRating => 'Choisissez une note de 1 à 5 étoiles.';

  @override
  String revValShort(String n) {
    return 'Écrivez au moins $n caractères.';
  }

  @override
  String revValLong(String n) {
    return 'Moins de $n caractères.';
  }

  @override
  String get revDupEdit =>
      'Vous avez déjà évalué cet événement. Modifiez plutôt votre avis.';

  @override
  String get revDup => 'Vous avez déjà évalué cet événement.';

  @override
  String get revNotFound => 'Avis introuvable.';

  @override
  String get profOrganizerMode => 'Mode organisateur';

  @override
  String get profOrganizerModeBody =>
      'Publiez des événements, suivez les ventes et contrôlez les entrées';

  @override
  String get profOrganizerDashboard => 'Tableau de bord organisateur';

  @override
  String get orgDashboardTitle => 'Tableau de bord';

  @override
  String get orgCreateEvent => 'Créer un événement';

  @override
  String get orgRevenue => 'Revenus';

  @override
  String get orgTicketsSold => 'Billets vendus';

  @override
  String get orgCheckInRate => 'Taux d\'entrée';

  @override
  String orgOfCapacity(String sold, String capacity) {
    return '$sold sur $capacity';
  }

  @override
  String orgCheckedInOf(String checkedIn, String total) {
    return '$checkedIn sur $total entrés';
  }

  @override
  String get orgSalesOverTime => 'Ventes, 14 derniers jours';

  @override
  String orgTicketsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count billets',
      one: '1 billet',
      zero: 'Aucun billet',
    );
    return '$_temp0';
  }

  @override
  String get orgByTier => 'Ventes par catégorie';

  @override
  String get orgDrafts => 'Brouillons';

  @override
  String get orgDraftUntitled => 'Événement sans titre';

  @override
  String orgDraftSavedAt(String when) {
    return 'Enregistré le $when';
  }

  @override
  String get orgDraftDeleted => 'Brouillon supprimé';

  @override
  String get orgDelete => 'Supprimer';

  @override
  String get orgUpcoming => 'Événements à venir';

  @override
  String get orgNoEvents => 'Aucun événement à venir. Créez le premier.';

  @override
  String get orgStatusLive => 'En cours';

  @override
  String get orgStatusOnSale => 'En vente';

  @override
  String get orgStatusSoldOut => 'Complet';

  @override
  String get orgCheckIn => 'Contrôle';

  @override
  String get orgEdit => 'Modifier';

  @override
  String get orgScanTab => 'Scanner';

  @override
  String get orgGuestsTab => 'Liste des invités';

  @override
  String get orgScanHint => 'Visez le QR code du billet du participant.';

  @override
  String get orgCameraUnavailable =>
      'La caméra est indisponible. Saisissez le code à la main.';

  @override
  String get orgEnterCode => 'Saisir le code';

  @override
  String get orgEnterCodeBody =>
      'Collez le contenu du QR code ou saisissez l\'identifiant du billet.';

  @override
  String get orgCodeHint => 'ETK1… ou identifiant du billet';

  @override
  String get orgVerify => 'Vérifier';

  @override
  String get orgSearchGuests => 'Rechercher par nom, catégorie ou billet';

  @override
  String get orgNoGuests => 'Aucun invité';

  @override
  String get orgNoGuestsBody =>
      'Les billets vendus pour cet événement apparaîtront ici.';

  @override
  String get orgNoMatches => 'Aucun invité ne correspond à votre recherche.';

  @override
  String get orgCheckInAction => 'Faire entrer';

  @override
  String orgPendingSync(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à synchroniser',
      one: '1 à synchroniser',
    );
    return '$_temp0';
  }

  @override
  String get orgSynced => 'Toutes les entrées sont synchronisées.';

  @override
  String orgSyncOffline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hors ligne : $count entrées seront synchronisées plus tard.',
      one: 'Hors ligne : 1 entrée sera synchronisée plus tard.',
    );
    return '$_temp0';
  }

  @override
  String get resValid => 'Billet valide. Bienvenue !';

  @override
  String get resAlready => 'Déjà entré';

  @override
  String resAlreadyBody(String time) {
    return 'Ce billet a été utilisé à $time.';
  }

  @override
  String get resWrongEvent => 'Mauvais événement';

  @override
  String get resWrongEventBody => 'Ce billet est pour un autre événement.';

  @override
  String get resExpired => 'Code expiré';

  @override
  String get resExpiredBody =>
      'Les codes changent toutes les 30 secondes. Demandez au participant de rouvrir son billet.';

  @override
  String get resForged => 'Billet invalide';

  @override
  String get resForgedBody =>
      'Ce code n\'est pas un billet Eventra authentique.';

  @override
  String get resCancelled => 'Annulé';

  @override
  String get resCancelledBody => 'Ce billet a été remboursé ou annulé.';

  @override
  String get resNextScan => 'Scanner le suivant';

  @override
  String get wizNewTitle => 'Nouvel événement';

  @override
  String get wizEditTitle => 'Modifier l\'événement';

  @override
  String get wizSaveDraft => 'Enregistrer';

  @override
  String get wizDraftSaved => 'Brouillon enregistré';

  @override
  String wizStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get wizStepBasics => 'L\'essentiel';

  @override
  String get wizStepSchedule => 'Date et heure';

  @override
  String get wizStepVenue => 'Lieu';

  @override
  String get wizStepTiers => 'Billets et tarifs';

  @override
  String get wizStepCover => 'Photo de couverture';

  @override
  String get wizStepReview => 'Vérifier et publier';

  @override
  String get wizNext => 'Continuer';

  @override
  String get wizPublish => 'Publier l\'événement';

  @override
  String get wizSaveChanges => 'Enregistrer les modifications';

  @override
  String get wizPublished => 'Votre événement est en ligne.';

  @override
  String get wizUpdated => 'Événement mis à jour.';

  @override
  String get wizPublishFailed =>
      'Impossible de publier l\'événement. Réessayez.';

  @override
  String get wizTitle => 'Titre de l\'événement';

  @override
  String get wizCategory => 'Catégorie';

  @override
  String get wizDescription => 'Description';

  @override
  String get wizStarts => 'Début';

  @override
  String get wizEnds => 'Fin';

  @override
  String get wizPick => 'Choisir';

  @override
  String wizDuration(int hours, int minutes) {
    return 'Durée : $hours h $minutes min';
  }

  @override
  String get wizVenueName => 'Nom du lieu';

  @override
  String get wizAddress => 'Adresse';

  @override
  String get wizPinHint => 'Touchez la carte pour placer l\'entrée.';

  @override
  String get wizPinHere => 'Ma position';

  @override
  String wizTierN(int n) {
    return 'Catégorie $n';
  }

  @override
  String get wizTierName => 'Nom de la catégorie';

  @override
  String get wizTierNameHint => 'Entrée générale';

  @override
  String get wizTierPrice => 'Prix';

  @override
  String get wizTierCapacity => 'Quantité';

  @override
  String get wizFreeTier =>
      'Un prix de 0 rend cette catégorie gratuite (sur inscription).';

  @override
  String get wizAddTier => 'Ajouter une catégorie';

  @override
  String wizCapacityTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places au total',
      one: '1 place au total',
      zero: 'Aucune place pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String wizCoverN(int n) {
    return 'Photo de couverture $n';
  }

  @override
  String get wizCoverCredit => 'Photos : Unsplash (licence Unsplash).';

  @override
  String get wizDefaultPolicy =>
      'Remboursement intégral jusqu\'à 48 heures avant l\'événement. Aucun remboursement dans les 48 heures précédant le début.';

  @override
  String wizErrTitle(int min, int max) {
    return 'Entre $min et $max caractères.';
  }

  @override
  String get wizErrCategory => 'Choisissez une catégorie.';

  @override
  String wizErrDescription(int n) {
    return 'Décrivez l\'événement en au moins $n caractères.';
  }

  @override
  String get wizErrStart => 'Choisissez le début de l\'événement.';

  @override
  String get wizErrStartPast => 'Le début doit être dans le futur.';

  @override
  String get wizErrEnd => 'Choisissez la fin de l\'événement.';

  @override
  String get wizErrEndBefore => 'La fin doit être après le début.';

  @override
  String get wizErrTooLong => 'Un événement dure au plus 7 jours.';

  @override
  String get wizErrVenue => 'Saisissez le nom du lieu.';

  @override
  String get wizErrAddress => 'Saisissez l\'adresse.';

  @override
  String get wizErrPin => 'Placez le repère sur la carte.';

  @override
  String wizErrTiers(int n) {
    return 'Ajoutez entre 1 et $n catégories.';
  }

  @override
  String get wizErrTierName => 'Nommez la catégorie (2 à 30 caractères).';

  @override
  String get wizErrTierDuplicate =>
      'Chaque catégorie doit avoir un nom différent.';

  @override
  String get wizErrTierPrice => 'Saisissez un prix entre 0 et 10 000.';

  @override
  String get wizErrTierCapacity => 'Saisissez une quantité entre 1 et 100 000.';

  @override
  String get wizErrTierBelowSold =>
      'La quantité ne peut pas être inférieure aux billets déjà vendus.';

  @override
  String wizErrTierBelowSoldN(int n) {
    return 'Au moins $n (déjà vendus).';
  }

  @override
  String get wizErrCover => 'Choisissez une photo de couverture.';

  @override
  String orgPctOfCapacity(String pct, String capacity) {
    return '$pct des $capacity places';
  }

  @override
  String a11yRating(String rating, String count) {
    return 'Noté $rating sur 5 d\'après $count avis';
  }

  @override
  String a11yEventPhoto(String title) {
    return 'Photo de $title';
  }

  @override
  String a11ySalesChart(String days, String total, String peak) {
    return 'Billets vendus sur les $days derniers jours : $total au total, meilleur jour $peak';
  }
}
