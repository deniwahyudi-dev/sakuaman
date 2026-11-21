---
name: mobile-ux-hierarchy
description: Guidelines and heuristics for visual eye hierarchy, ergonomic touch zones, microinteractions, and fintech UX polish. Use when refining screen layouts, typography balance, card elevation, or thumb ergonomics.
---

# Mobile UX & Visual Eye Hierarchy Guide

Tailored for Fintech & Modern VisionOS/Glassmorphic Mobile UI.

## 1. The 3-Second Eye Scan Rule (Fintech Layouts)
When a user opens any screen, their eyes scan in this sequence:
1. **The Hero Number / Status (0.5s):** Total Balance / Total Spent. Must have strongest typographic weight and size.
2. **Context & Trend (1.0s):** "+3.2% this week" or "Remaining limit: Rp 2.500.000". Small badge or subtle color contrast adjacent to the hero number.
3. **Primary Actionable CTAs (1.5s):** Fast Actions (e.g. "Add Transaction", "Transfer", "Scan"). Must be grouped together and immediately recognizable.
4. **Recent Activity Feed (3.0s):** Grouped by date (Today, Yesterday) with clear category icons and amounts.

## 2. Visual Hierarchy Techniques
- **Contrast over Size:** Instead of making secondary text tiny (causing eye strain), keep it readable (13-14sp) but use muted opacity (`SakuTheme.darkTextSecondary` or `lightTextSecondary`).
- **Surface Layering (Depth):**
  - Layer 0: Ambient mesh background (subtle glow).
  - Layer 1: Frosted cards / `LiquidCard` with specular border.
  - Layer 2: Floating pills, badges, and interactive buttons with higher elevation or active color pop.
- **Whitespace as a Divider:** Prefer 12-16dp spacing and subtle container background tint over harsh dividing lines.

## 3. Ergonomics & Touch Feedback
- **Thumb Zone:** Critical actions must sit in the lower 40-50% of the screen. Upper area is for glanceable information.
- **Minimum Tap Size:** 48x48dp interactive area even if visual icon is 24dp.
- **Haptic & Visual Spring:** Wrap clickable cards with `BouncyTouchWrapper` or `CupertinoButton` to give physical feedback.
