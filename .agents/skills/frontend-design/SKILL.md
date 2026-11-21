---
name: frontend-design
description: Design distinctive, production-grade user interfaces with intentional visual hierarchy, custom color palettes, and polished microinteractions. Use when styling, improving, or designing UI screens and widgets.
---

# Frontend Design & Craft

Avoid generic "AI slop" (cliché gradient buttons, washed-out purple/cyan soup, uniform card grids, standard boilerplate). Treat every UI as crafted by a boutique design lead.

## 1. Intentional Palette & Contrast
- Never use random hex colors. Pick a deliberate color system aligned with the theme (`SakuTheme`).
- **Hierarchy of visual weight:**
  - Background (Atmosphere): Dark obsidian / deep slate or pristine pearl ceramic.
  - Cards & Surfaces: Specular border contrast, frosted glass / blur (`BackdropFilter`), subtle elevation.
  - Accents: High-impact punch colors (`cyberCyan`, `neonGreen`, `crimsonRed`, `electricBlue`) reserved strictly for status, CTA, or key financial trends. Never paint everything with accents.

## 2. Typographic Scale & Rhythm
- High contrast in font weight (`FontWeight.w800` vs `FontWeight.w400`) rather than drastic font size jumps.
- Tabular figures (`FontFeature.tabularFigures()`) for all currency and financial digits to avoid jitter during updates.
- Microcopy: Clear, human, functional (e.g., "Add Expense", "Top-up balance", not generic "Submit" or "Click here").

## 3. Visual Restraint & Polish
- One dominant visual anchor per screen (Hero Card or Balance Chart). Everything else plays a supporting role.
- Spacing rhythm: Consistent 4/8-point grid (4, 8, 12, 16, 20, 24, 32).
- Micro-interactions: Tactile feedback on press (`BouncyTouchWrapper`), subtle icon transitions, zero clunky layout shifts.
