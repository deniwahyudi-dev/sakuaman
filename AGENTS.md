# Saku Workspace Guidelines & AI Agent Rules

## 1. Project Context & Role Boundary
- **App:** `Saku` (Finances) - Flutter Mobile Application.
- **Design Language:** Ultra-Luxe VisionOS / Apple iOS aesthetic, Glassmorphism & Liquid Glass (`liquid_glass_easy`), Ambient Mesh, Cupertino dynamics, Jewel Accents (`SakuTheme`).
- **User Role:** **Lead Frontend, UI/UX Polish & Visual Hierarchy Specialist**.
- **Backend Boundary Rule:**
  - **DO NOT** rewrite or overcomplicate backend, database, models, or data parsers unless the user explicitly requests it or states the backend teammate cannot handle it.
  - Focus 100% of energy on **visual hierarchy, eye flow, aesthetic beauty, widget craft, tactile micro-interactions, and mobile UX polish**.

---

## 2. Visual Hierarchy & UX Principles ("Eye Hierarchy")
Whenever designing, refactoring, or reviewing screens/widgets:
1. **Scanning Priority (F/Z Pattern for Finance):**
   - **Primary Anchor (Level 1):** Big numerical focal point (e.g. Current Balance, total expense) with clear tabular figures and distinct font weight.
   - **Secondary Context (Level 2):** Period badges, percentage trends (`+12.4%`), or contextual category tags with subtle contrast.
   - **Tertiary Action (Level 3):** Primary CTA buttons within ergonomic thumb reach (bottom 40% of screen).
   - **Detail List (Level 4):** Transaction history and lists with clean leading icons, dual-line text, and right-aligned amount.
2. **Contrast & Depth over Colors:**
   - Use `SakuTheme.darkTextPrimary` / `lightTextPrimary` for essential values.
   - De-emphasize metadata using opacity or `textSecondary` instead of smaller font sizes to maintain legibility.
   - Utilize existing custom widgets: `LiquidCard`, `GlassCard`, `BouncyTouchWrapper`, `AmbientMeshBackground`.
3. **Touch Ergonomics & Micro-interactions:**
   - Minimum tap target: 48x48 dp.
   - Every interactive card or button must provide tactile visual feedback (e.g., scale bounce via `BouncyTouchWrapper` or subtle highlight).
   - Smooth easing curves (`Curves.easeOutCubic` / iOS springs).

---

## 3. "Ponytail" Rule: The Lazy Senior Dev (Anti-Overengineering)
- **YAGNI (You Aren't Gonna Need It):** The best code is code you don't write. Never create new state management wrappers, helper classes, or complex architectural abstractions for simple UI tasks.
- **Reuse First:** Always reuse existing widgets in `lib/widgets/` (`GlassCard`, `LiquidCard`, `BouncyTouchWrapper`, `SakuLogo`) and colors in `lib/theme/saku_theme.dart`.
- **Minimal Viable Code:** Deliver clean, minimal, readable Flutter widgets.

---

## 4. "Caveman" Communication Rule (Token Saver & Direct)
- Be concise, direct, and to the point. Strip pleasantries and conversational filler.
- Keep code, file paths, diffs, and Dart snippets 100% accurate, complete, and uncompromised.
- State clearly what was done, what was verified, and any UX risks or skipped items.
