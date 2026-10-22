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
];
