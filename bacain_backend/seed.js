// seed.js - membuat akun demo "senkuu" (password: 123456) dengan hash bcrypt.
// Jalankan: npm run seed
require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('./db');

(async () => {
  try {
    const hash = await bcrypt.hash('123456', 10);
    await pool.execute(
      `INSERT INTO users
         (username, email, password_hash, avatar_url, bio,
          favorite_count, read_count, comment_count)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash)`,
      [
        'senkuu',
        'senkuu@baca.in',
        hash,
        'assets/Yaemiko.png',
        'Penikmat manhwa aksi & fantasi. Baca sambil ngopi ☕',
        128,
        3420,
        57,
      ]
    );
    console.log('Akun demo siap: senkuu / 123456');
  } catch (err) {
    console.error('Seed gagal:', err.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();