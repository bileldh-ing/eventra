import 'package:eventra/features/reviews/domain/review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewRules.validate', () {
    test('rating must be 1 to 5', () {
      expect(
        ReviewRules.validate(0, 'Great night out!')?.code,
        ReviewError.invalidRating,
      );
      expect(
        ReviewRules.validate(6, 'Great night out!')?.code,
        ReviewError.invalidRating,
      );
      for (var r = 1; r <= 5; r++) {
        expect(ReviewRules.validate(r, 'Great night out!'), isNull);
      }
    });

    test('text is 10 to 500 characters after trimming', () {
      expect(
        ReviewRules.validate(4, '   short   ')?.code,
        ReviewError.tooShort,
      );
      expect(ReviewRules.validate(4, 'x' * 9)?.code, ReviewError.tooShort);
      expect(ReviewRules.validate(4, 'x' * 10), isNull);
      expect(ReviewRules.validate(4, 'x' * 500), isNull);
      expect(ReviewRules.validate(4, 'x' * 501)?.code, ReviewError.tooLong);
      expect(ReviewRules.validate(4, '  ${'x' * 500}  '), isNull);
    });
  });

  group('ReviewRules.eligibility', () {
    ReviewEligibility e({
      bool signedIn = true,
      bool ticket = true,
      bool ended = true,
      bool reviewed = false,
    }) => ReviewRules.eligibility(
      signedIn: signedIn,
      hasValidTicket: ticket,
      eventEnded: ended,
      alreadyReviewed: reviewed,
    );

    test('only signed-in ticket holders of ended events may review', () {
      expect(e(), ReviewEligibility.eligible);
      expect(e(signedIn: false), ReviewEligibility.signedOut);
      expect(e(ticket: false), ReviewEligibility.noTicket);
      expect(e(ended: false), ReviewEligibility.notEnded);
      expect(e(reviewed: true), ReviewEligibility.reviewed);
      expect(e(ticket: false, ended: false), ReviewEligibility.noTicket);
    });
  });

  group('RatingSummary', () {
    test('average, count, histogram and shares', () {
      final s = RatingSummary.of(const [5, 5, 4, 3, 1, 9, 0]);
      expect(s.count, 5);
      expect(s.histogram, [1, 0, 1, 1, 2]);
      expect(s.average, closeTo(3.6, 1e-9));
      expect(s.share(5), closeTo(0.4, 1e-9));
      expect(s.share(2), 0);
    });

    test('empty summary is all zeros', () {
      expect(RatingSummary.empty.average, 0);
      expect(RatingSummary.empty.share(3), 0);
      expect(RatingSummary.of(const []).count, 0);
    });
  });
}
