# Preview verification and remaining review

Prepared 2026-10-27.

Completed checks:

- All referenced local preview images exist.
- Copied source PNG hashes match the supplied Downloads originals exactly.
- PNG signatures, dimensions, encoding and actual pixel alpha were read without modifying image pixels; see `asset-manifest.json` and `inspect_assets.py`. The poster is RGB/opaque. The supplied logo and proposed layers contain transparent and translucent pixels. Transparency does not by itself certify clean edges.
- Extracted preview JavaScript passes `node --check`.
- Hidden headless Chrome rendered `previews/desktop-review.png` at 1440 by 1550; the desktop screenshot was visually inspected. Three compositions, readable text and main preview controls render. The screenshot is a viewport capture; scroll farther in the HTML for the full launcher section.

Limits:

- The first sandboxed browser attempt produced no screenshot; an explicitly approved hidden-browser retry produced the saved capture.
- Browser interaction, mobile/200% text, screen-reader behavior, animation frame pacing and reduced-motion settings have not been independently automated or manually exercised. Their preview controls are present, but are not certified from a static screenshot.
- The arrow retains soft edge/halo detail and is proposed for review. The wallet/coin/arrow are reconstructed variants, not exact source extractions.
- Android adaptive resources, density exports, native launch transitions and actual phone appearance remain unimplemented and untested.
- No application tests/builds, dependency changes, source configuration edits, Git or phone actions occurred.

Await owner review of artwork fidelity, Welcome copy, animation direction and launcher treatment. Application integration remains a separate authorization gate.
