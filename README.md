# org-mode reveal.js Presentation Template

A starter template for creating browser-based slide presentations using [reveal.js], authored in Emacs [org-mode] with the [ox-reveal] exporter. It solves the problem of having to rediscover all the reveal.js org-mode incantations every time you start a new presentation.

## Prerequisites

- [Emacs] installed with org-mode and ox-reveal configured — see [this config][emacs-config] for reference
- [Node.js] installed (for PDF generation via Puppeteer)

## Usage

1. Copy `slides/010-slides.org` and edit it to your liking
2. Run `make publish` to generate HTML, PDF, and ZIP outputs and move them to `docs/`
3. Push to `trunk` — GitHub Actions deploys `public/` to [GitHub Pages] automatically

### Make targets

| Target | Description |
|---|---|
| `generate-html` | Export `.org` slide files to reveal.js HTML |
| `fix-reveal-notes` | Patch reveal.js speaker notes compatibility |
| `generate-pdf` | Export `.org` lecture files to PDF via LaTeX |
| `generate-print-pdf` | Export slide HTML to PDF via Puppeteer |
| `publish` | Run all of the above and move outputs to `docs/` |
| `clean` | Remove generated files from `docs/` |
| `verify-slides` | Screenshot slide PDFs into `tmp/` for visual review |

## Slide features demonstrated

The template in `slides/010-slides.org` covers the most common patterns:

- Simple bullet slides
- Splitting one logical slide across multiple screens
- Nested (vertical) slides
- Color, image, and GIF backgrounds
- Fragmented (step-by-step) bullet animations
- Syntax-highlighted code blocks with line-number stepping
- Speaker notes
- Two-column layouts

[reveal.js]: https://revealjs.com
[org-mode]: https://orgmode.org
[ox-reveal]: https://github.com/yjwen/org-reveal
[Emacs]: https://www.gnu.org/software/emacs
[emacs-config]: https://github.com/rolandtritsch/emacs.d/blob/trunk/roland/21-org-mode.org#reveal
[Node.js]: https://nodejs.org
[GitHub Pages]: https://pages.github.com
