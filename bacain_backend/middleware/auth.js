// middleware/auth.js - verifikasi token "Authorization: Bearer <token>"
const jwt = require('jsonwebtoken');

module.exports = function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Token tidak ditemukan' });
  }
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = payload.sub;
    next();
  } catch (_) {
    return res
      .status(401)
      .json({ message: 'Sesi berakhir, silakan masuk kembali' });
  }
};