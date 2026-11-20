// Vercel serverless function that returns the TMDB credentials from
// environment variables. The key is never committed to the repository.
module.exports = function handler(req, res) {
  const payload = {};

  if (process.env.TMDB_API_KEY) {
    payload.TMDB_API_KEY = process.env.TMDB_API_KEY;
  }

  if (process.env.TMDB_ACCESS_TOKEN) {
    payload.TMDB_ACCESS_TOKEN = process.env.TMDB_ACCESS_TOKEN;
  }

  res.setHeader('Content-Type', 'application/json');
  // Never let the browser cache credentials.
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).send(JSON.stringify(payload));
};
