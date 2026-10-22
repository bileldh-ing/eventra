import 'package:drift/drift.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';

/// Profile details and account deletion over raw SQL.
class ProfileRepository {
  ProfileRepository(this.db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _clock;

  Future<UserProfile> load(String userId, {required String name}) async {
    final row = await db
        .customSelect(
          'SELECT bio, city, avatar_color FROM profiles WHERE user_id = ?',
          variables: [Variable.withString(userId)],
        )
        .getSingleOrNull();
    if (row == null) return UserProfile(name: name);
    return UserProfile(
      name: name,
      bio: row.read<String>('bio'),
      city: row.read<String>('city'),
      avatarColor: row.read<int>('avatar_color'),
    );
  }

  /// Saves the profile and renames the account in one transaction.
  Future<UserProfile> save(String userId, UserProfile p) async {
    final clean = p.copyWith(
      name: p.name.trim(),
      bio: p.bio.trim(),
      city: p.city.trim(),
    );
    await db.transaction(() async {
      await db.customUpdate(
        'UPDATE users SET name = ? WHERE id = ?',
        variables: [
          Variable.withString(clean.name),
          Variable.withString(userId),
        ],
      );
      await db.customInsert(
        'INSERT INTO profiles (user_id, bio, city, avatar_color, updated_at) '
        'VALUES (?, ?, ?, ?, ?) ON CONFLICT(user_id) DO UPDATE SET '
        'bio = excluded.bio, city = excluded.city, '
        'avatar_color = excluded.avatar_color, '
        'updated_at = excluded.updated_at',
        variables: [
          Variable.withString(userId),
          Variable.withString(clean.bio),
          Variable.withString(clean.city),
          Variable.withInt(clean.avatarColor),
          Variable.withInt(_clock().millisecondsSinceEpoch),
        ],
      );
    });
    return clean;
  }

  /// Number of reviews written by [userId].
  Future<int> reviewCount(String userId) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM reviews WHERE user_id = ?',
          variables: [Variable.withString(userId)],
        )
        .getSingle();
    return row.read<int>('c');
  }

  /// Permanently removes the account and everything tied to it.
  Future<void> deleteAccount(String userId) async {
    final id = Variable.withString(userId);
    await db.transaction(() async {
      Future<void> run(String sql) => db.customStatement(sql, [userId]);
      // Give seats in open checkout holds back before dropping the holds.
      await db.customStatement(
        'UPDATE tier_stock SET held = held - '
        '(SELECT COALESCE(SUM(i.quantity), 0) '
        'FROM ticket_hold_items i JOIN ticket_holds h ON h.id = i.hold_id '
        "WHERE h.user_id = ?1 AND h.status = 'active' "
        'AND h.event_id = tier_stock.event_id '
        'AND i.tier_id = tier_stock.tier_id)',
        [userId],
      );
      await run(
        'DELETE FROM order_items WHERE order_id IN '
        '(SELECT id FROM orders WHERE user_id = ?)',
      );
      await run(
        'DELETE FROM ticket_hold_items WHERE hold_id IN '
        '(SELECT id FROM ticket_holds WHERE user_id = ?)',
      );
      for (final sql in const [
        'DELETE FROM tickets WHERE user_id = ?',
        'DELETE FROM orders WHERE user_id = ?',
        'DELETE FROM ticket_holds WHERE user_id = ?',
        'DELETE FROM promo_redemptions WHERE user_id = ?',
        'DELETE FROM reviews WHERE user_id = ?',
        'DELETE FROM notifications WHERE scope = ?',
        'DELETE FROM profiles WHERE user_id = ?',
      ]) {
        await run(sql);
      }
      await db.customUpdate(
        'DELETE FROM users WHERE id = ?',
        variables: [id],
        updateKind: UpdateKind.delete,
      );
    });
  }
}
