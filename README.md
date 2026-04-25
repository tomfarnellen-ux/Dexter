# Conveya — basic landing site

Static HTML/CSS/JS landing page based on the Conveya pitch deck.

- `index.html` — single-page structure
- `styles.css` — typography (Fraunces / Inter), warm-paper palette, dark sections
- `script.js` — animated stats, indicative quote calculator (UK SDLT bands incl. FTB carve-out), client-side contact form validation

To preview locally:

```sh
python3 -m http.server 8080
# then open http://localhost:8080
```

The repo's `.github/workflows/pages.yml` deploys the site to GitHub Pages
on every push to the development branch. Enable Pages in the repo settings
(Source: GitHub Actions) the first time.
