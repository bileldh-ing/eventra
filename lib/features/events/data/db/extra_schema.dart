/// Tables for accounts, searches and ticketing. They are accessed through
/// hand-written SQL DAOs (no code generation) and created idempotently every
/// time the database opens, so existing installs pick them up without a
/// schema bump.
const kExtraSchema = <String>[
  // Local demo accounts. Passwords are stored only as salted PBKDF2 hashes.
  '''
  CREATE TABLE IF NOT EXISTS users (
    id TEXT NOT NULL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    phone TEXT,
    password_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    iterations INTEGER NOT NULL,
    verified INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL
  )''',
  // Ticketing (Phase 7). Money is integer cents, times are epoch millis.
  // Live stock per tier. `held` counts seats in active checkout holds; the
  // CHECK makes overselling impossible even if application code is wrong.
  '''
  CREATE TABLE IF NOT EXISTS tier_stock (
    event_id TEXT NOT NULL,
    tier_id TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    sold INTEGER NOT NULL,
    held INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (event_id, tier_id),
    CHECK (sold >= 0 AND held >= 0 AND sold + held <= capacity)
  )''',
  '''
  CREATE TABLE IF NOT EXISTS ticket_holds (
    id TEXT NOT NULL PRIMARY KEY,
    user_id TEXT NOT NULL,
    event_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL,
    status TEXT NOT NULL
  )''',
  '''
  CREATE TABLE IF NOT EXISTS ticket_hold_items (
    hold_id TEXT NOT NULL,
    tier_id TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (hold_id, tier_id)
  )''',
  '''
  CREATE TABLE IF NOT EXISTS orders (
    id TEXT NOT NULL PRIMARY KEY,
    user_id TEXT NOT NULL,
    idempotency_key TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL,
    event_id TEXT NOT NULL,
    event_json TEXT NOT NULL,
    subtotal_cents INTEGER NOT NULL,
    discount_cents INTEGER NOT NULL,
    fees_cents INTEGER NOT NULL,
    tax_cents INTEGER NOT NULL,
    total_cents INTEGER NOT NULL,
    refund_cents INTEGER NOT NULL DEFAULT 0,
    promo_code TEXT,
    payment_ref TEXT,
    card_brand TEXT,
    card_last4 TEXT,
    attendee_name TEXT NOT NULL,
    attendee_email TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    refunded_at INTEGER
  )''',
  'CREATE INDEX IF NOT EXISTS orders_user ON orders (user_id)',
  '''
  CREATE TABLE IF NOT EXISTS order_items (
    order_id TEXT NOT NULL,
    tier_id TEXT NOT NULL,
    tier_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_cents INTEGER NOT NULL,
    PRIMARY KEY (order_id, tier_id)
  )''',
  '''
  CREATE TABLE IF NOT EXISTS tickets (
    id TEXT NOT NULL PRIMARY KEY,
    order_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    event_id TEXT NOT NULL,
    tier_id TEXT NOT NULL,
    tier_name TEXT NOT NULL,
    holder_name TEXT NOT NULL,
    status TEXT NOT NULL,
    seq INTEGER NOT NULL
  )''',
  'CREATE INDEX IF NOT EXISTS tickets_user ON tickets (user_id)',
  '''
  CREATE TABLE IF NOT EXISTS promo_redemptions (
    order_id TEXT NOT NULL PRIMARY KEY,
    code TEXT NOT NULL,
    user_id TEXT NOT NULL,
    created_at INTEGER NOT NULL
  )''',
];
