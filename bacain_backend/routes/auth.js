// routes/auth.js - endpoint: POST /login, POST /register, GET /me
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const pool = require('../db');
const requireAuth = require('../middleware/auth');

const router = express.Router();

// Batasi percobaan login/daftar per IP untuk mencegah tebak-tebakan password.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.' },
});

// Hash palsu (dibuat saat start): dipakai agar waktu respons tetap mirip
// walau username/email tidak ada, sehingga akun yang ada tidak mudah ditebak.
const DUMMY_HASH = bcrypt.hashSync('dummy-password', 10);

function toUserJson(row) {
  return {
    id: row.id,
    username: row.username,
    email: row.email,
    avatarUrl: row.avatar_url,
    bio: row.bio,
    createdAt: row.created_at,
    favoriteCount: row.favorite_count,
    readCount: row.read_count,
    commentCount: row.comment_count,
  };
}

function signToken(userId, remember) {
  return jwt.sign({ sub: userId }, process.env.JWT_SECRET, {
    expiresIn: remember ? '30d' : '1d',
  });
}

// ---------------- LOGIN ----------------
router.post('/login', authLimiter, async (req, res) => {
  const identifier = String(req.body.identifier || '').trim();
  const password = String(req.body.password || '');
  const remember = req.body.remember === true;

  if (!identifier || !password) {
    return res
      .status(400)
      .json({ message: 'Email/username dan password wajib diisi' });
  }

  try {
    // Query berparameter (?) -> aman dari SQL injection.
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE username = ? OR email = ? LIMIT 1',
      [identifier, identifier]
    );
    const user = rows[0];
    const ok = await bcrypt.compare(
      password,
      user ? user.password_hash : DUMMY_HASH
    );

    if (!user || !ok) {
      // Pesan sama untuk "user tidak ada" & "password salah".
      return res
        .status(401)
        .json({ message: 'Email/username atau password salah' });
    }

    return res.json({
      token: signToken(user.id, remember),
      user: toUserJson(user),
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ message: 'Terjadi kesalahan pada server' });
  }
});

// ---------------- REGISTER ----------------
router.post('/register', authLimiter, async (req, res) => {
  const username = String(req.body.username || '').trim();
  const email = String(req.body.email || '').trim().toLowerCase();
  const password = String(req.body.password || '');

  if (!/^[A-Za-z0-9_]{3,30}$/.test(username)) {
    return res.status(400).json({
      message: 'Username 3-30 karakter, hanya huruf, angka, dan underscore',
    });
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 120) {
    return res.status(400).json({ message: 'Format email tidak valid' });
  }
  if (password.length < 8 || password.length > 72) {
    return res.status(400).json({ message: 'Password minimal 8 karakter' });
  }

  try {
    const hash = await bcrypt.hash(password, 10);
    const [result] = await pool.execute(
      'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
      [username, email, hash]
    );
    const [rows] = await pool.execute('SELECT * FROM users WHERE id = ?', [
      result.insertId,
    ]);
    return res.status(201).json({
      token: signToken(result.insertId, true),
      user: toUserJson(rows[0]),
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res
        .status(409)
        .json({ message: 'Username atau email sudah terdaftar' });
    }
    console.error('Register error:', err);
    return res.status(500).json({ message: 'Terjadi kesalahan pada server' });
  }
});

// ---------------- PROFIL SAYA ----------------
router.get('/me', requireAuth, async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM users WHERE id = ?', [
      req.userId,
    ]);
    if (!rows[0]) {
      return res.status(401).json({ message: 'Akun tidak ditemukan' });
    }
    return res.json({ user: toUserJson(rows[0]) });
  } catch (err) {
    console.error('Me error:', err);
    return res.status(500).json({ message: 'Terjadi kesalahan pada server' });
  }
});

module.exports = router;