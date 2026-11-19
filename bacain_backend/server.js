// server.js - titik masuk API Bacain
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('./db');
const authRoutes = require('./routes/auth');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  console.error('JWT_SECRET belum diisi / terlalu pendek (min. 32 karakter). Cek file .env');
  process.exit(1);
}

const app = express();
app.use(cors()); // dev: izinkan semua origin (Flutter web memakai port acak)
app.use(express.json({ limit: '10kb' }));

app.get('/api/health', (_req, res) => res.json({ ok: true }));
app.use('/api/auth', authRoutes);

app.use((_req, res) => res.status(404).json({ message: 'Endpoint tidak ditemukan' }));

const port = Number(process.env.PORT || 3000);

pool
  .query('SELECT 1')
  .then(() => {
    app.listen(port, () =>
      console.log(`API Bacain berjalan di http://localhost:${port}`)
    );
  })
  .catch((err) => {
    console.error('Gagal terhubung ke MySQL:', err.message);
    process.exit(1);
  });