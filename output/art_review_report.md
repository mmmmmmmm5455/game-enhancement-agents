# Art Style Review Report — Millennium Bug Incident

**Date:** 2026-04-30  
**Target Aesthetic:** Y2K Dark Cyan Liminal Space  
**Overall Score:** 57/100  
**Status:** Needs significant work — 15 prioritized fixes identified

---

## Executive Summary

The game achieves a passable Y2K foundation — correct font families, CRT scanlines, cool-dark color intentions, and four distinct liminal 3D scenes with fog and particle systems. However, **warm color intrusions break the cold palette**, **75% of required CRT post-processing effects are missing**, and **the scanline overlay is 3-8x too opaque**, producing a heavy banding effect rather than subtle phosphor texture.

**Score breakdown:**
| Dimension | Score | Status |
|---|---|---|
| Color Palette Compliance | 52/100 | Critical issues — warm brown, pure green |
| Color Warmth | 45/100 | Dominant warm — snow_bridge streetlights |
| CRT Authenticity | 25/100 | 1 of 5 effects present |
| Typography | 82/100 | Strong — correct fonts, minor size issues |
| Layout | 65/100 | Acceptable — Mac OS 9 metaphor, too symmetric |
| Scene Atmosphere | 68/100 | Good fog work, warm lighting breaks scenes |
| **Overall** | **57/100** | |

---

## 1. Color Audit

### Palette Score: 52/100

The 12-color CSS palette is structurally correct but has 3 problematic colors:

| File | Line | Selector | Actual | Expected | Severity |
|---|---|---|---|---|---|
| `css/main.css` | 24 | `--color-dark-brown` | `#8B4513` | `#ffab00` | **CRITICAL** |
| `css/main.css` | 22 | `--color-sick-green` | `#33FF33` | `#00ff41` | HIGH |
| `css/main.css` | 25 | `--color-cold-cyan` | `#88CCFF` | `#00e5ff` | MEDIUM |
| `css/main.css` | 27 | `--color-taillight-red` | `#8B0000` | `#ff1744` | MEDIUM |
| `css/main.css` | 28 | `--color-text-primary` | `#C0C0C0` | `#b0bec5` | LOW |
| `css/counters.css` | 14 | `#fragment-counter` | `#8B4513` | `#ffab00` | **CRITICAL** |

**Verification:**
```bash
grep -n '#8B4513' frontend/css/*.css
```

### 3D Scene Color Violations

| File | Line | Element | Actual | Expected | Severity |
|---|---|---|---|---|---|
| `js/scenes/snow_bridge.js` | 19 | Streetlight | `0xffcc66` | `0x00bcd4` | **HIGH** |
| `js/scenes/snow_bridge.js` | 31 | Housing emissive | `0xffaa22` | `0x006064` | **HIGH** |
| `js/scenes/snow_bridge.js` | 67 | Snow particles | `0xffffff` | `0xc0d8f0` | MEDIUM |
| `js/scenes/blizzard_street.js` | 17 | Emergency light | `0xcc2233` | `0xff1744` | LOW |
| `js/scenes/blizzard_street.js` | 48 | Alarm box emissive | `0x440000` | `0x1a0000` | MEDIUM |

### Warmth Check: 45/100 — DOMINANT WARM

The snow_bridge scene is the primary offender. Its single streetlight at 0xffcc66 (~5500K) shifts the entire scene toward warm yellow. Y2K dark-cyan requires **cool illumination only** (<5000K color temperature).

The fragment counter using `--color-dark-brown` (#8B4513) introduces a warm earth tone into the otherwise cool UI — this is the most visible warm leak to the player.

**Verification:**
```bash
grep -nE '0xffcc66|0xffcc44|0xffaa22|#8B4513' frontend/js/scenes/*.js frontend/css/*.css
```

---

## 2. CRT Post-Processing Audit

### Score: 25/100 — 4 of 5 effects MISSING

| Effect | Present | Details |
|---|---|---|
| Scanlines | YES | `crt.css` body::after, repeating-linear-gradient, but opacity 0.4 is **3-8x too high** (spec: 0.05-0.15) |
| Bloom/Glow | **MISSING** | No text-shadow on accents, no filter:blur on bright elements |
| Chromatic Aberration | **MISSING** | No RGB channel separation at edges |
| Noise/Grain | **MISSING** | blizzard_street has 3D grain particles but no CSS overlay |
| Vignette/Curvature | **MISSING** | No radial-gradient edge darkening |

The scanline implementation is technically correct but visually broken due to opacity. At 0.4, every 2nd and 4th pixel row is 40% darkened — creating a visible horizontal banding pattern rather than the subtle phosphor texture intended.

**Verification:**
```bash
grep -nE 'filter|bloom|chromatic|noise|vignette|radial-gradient' frontend/css/crt.css
```

---

## 3. Typography Audit

### Score: 82/100 — STRONG

**Strengths:**
- 4 Y2K-compliant fonts: VT323, Silkscreen (pixel), Share Tech Mono (monospace), Orbitron (display)
- `image-rendering: pixelated` on body (line 61)
- `-webkit-font-smoothing: none` (line 62) — correct CRT no-AA
- Custom SevenSegment @font-face for counters
- Monospace fallback in font stack

**Minor issues:**
- `counters.css:6` — emotion/infection bar labels at 11px (should be >= 12px)

**Verification:**
```bash
grep -n 'font-size: 11px' frontend/css/counters.css
```

---

## 4. Scene-by-Scene Atmosphere Analysis

### Rain Underpass — 72/100 (Best Liminal Quality)
- Fog (20-80 range) creates depth tunnel effect
- 600 rain particles with additive blending
- PS1 flat-shaded cracked concrete floor
- Single warm window light (0xffcc66) provides isolation contrast
- **Issue:** Fog near-plane too close (20 units), limiting depth perception

### Snow Bridge — 55/100 (Warm Palette Violation)
- 70% dead black requirement is atmospheric
- Streetlight flicker effect adds unease
- **Issue:** Streetlight is warm yellow — breaks cold palette entirely
- **Issue:** Snow at pure white (0xffffff) instead of cold cyan
- **Issue:** Flat black Fog, no volumetric depth

### Fog Highway — 78/100 (Best Technical Implementation)
- FogExp2 creates continuous exponential depth falloff — correct approach
- Dashed center lines at 30% opacity fade into fog
- Light poles with distance-based opacity (0.05-0.30 range)
- 300 fog particles with additive blending
- Highway light at 0xaaccff is cold cyan — palette-compliant
- **Issue:** FogExp2 density 0.0006 too light, distant objects (overpass at -45) still visible

### Blizzard Street — 60/100 (Innovative but Warm)
- Dual particle system: snow (500) + film grain (200) — creative 3D approach
- Building silhouettes fading into fog reinforce liminal quality
- Emergency light flicker creates tension
- **Issue:** Fog color 0x1a1015 has warm purple tint
- **Issue:** Dark red emergency palette conflicts with Y2K dark-cyan
- **Note:** Film grain via 3D points is clever but should be CSS overlay for consistency

---

## 5. Prioritized Fix List

### CRITICAL (Fix Immediately — Phase 1)

| # | Fix | File | Verification |
|---|---|---|---|
| 1 | `#8B4513` -> `#ffab00` (brown to cold amber) | `main.css:24` | `grep -n '#8B4513' frontend/css/*.css && echo FAIL \|\| echo PASS` |
| 2 | Scanline opacity 0.4 -> 0.10 | `crt.css:12` | `grep -n 'opacity: 0.4' frontend/css/crt.css && echo FAIL \|\| echo PASS` |

### HIGH (Fix Soon — Phase 1-2)

| # | Fix | File | Verification |
|---|---|---|---|
| 3 | Add chromatic aberration | `crt.css` (new) | `grep -n 'chromatic' frontend/css/crt.css \|\| echo 'FAIL: missing'` |
| 4 | Add bloom/glow on accents | `main.css` (new) | grep check |
| 5 | Add noise/grain CSS overlay | `crt.css` (new) | grep check |
| 6 | Add screen vignette | `crt.css` (new) | grep check |
| 7 | `#33FF33` -> `#00ff41` (green fix) | `main.css:22` | grep check |
| 8 | Snow white -> pale cyan (0xc0d8f0) | `snow_bridge.js:67` | grep check |
| 9 | Warm streetlight -> cold cyan | `snow_bridge.js:19,31` | grep check |

### MEDIUM (Phase 2-3)

| # | Fix | File | Verification |
|---|---|---|---|
| 10 | Fog purple -> cold cyan | `blizzard_street.js:9` | grep check |
| 11 | 11px -> 12px font bump | `counters.css:6` | grep check |
| 12 | FogExp2 density 0.0006 -> 0.0012 | `fog_highway.js:9` | grep check |
| 13 | Add FogExp2 to snow_bridge | `snow_bridge.js:10` | grep check |
| 14 | Asymmetric dialog offset | `panels.css:11` | grep check |
| 15 | `#88CCFF` -> `#00e5ff` (cyan saturation) | `main.css:25` | grep check |

---

## 6. Screenshot Capture Status

**Not captured.** Playwright, Selenium, and Node.js are not installed on this system. Manual screenshots needed:

1. Navigate to `http://localhost:8765`
2. Capture initial scene (fog_highway default)
3. In console: trigger `BackgroundManager.switchScene('rain_underpass')` — capture
4. Trigger `BackgroundManager.switchScene('snow_bridge')` — capture
5. Trigger `BackgroundManager.switchScene('blizzard_street')` — capture

To automate in the future:
```bash
npm install playwright
npx playwright install chromium
```

---

## 7. Summary

**What's working:**
- Typography foundation (fonts, pixel rendering, no anti-aliasing) — 82/100
- Scene fog architecture (3 of 4 scenes use fog, FogExp2 on highway) — structural win
- Y2K panel metaphor (Mac OS 9 / QuickTime windows) — period-correct
- Flat shading + low-poly geometry on all scenes — PS1 aesthetic

**What's broken:**
- Warm color intrusions (brown, warm yellow streetlight, warm red fog) — the #1 problem
- 4 of 5 CRT post-processing effects missing — bloom, aberration, noise, vignette
- Scanline opacity renders the one working effect unusable
- snow_bridge scene is fundamentally warm — needs complete relighting

**Goal:** Reach 85/100 by Phase 2 completion (fix all CRITICAL + HIGH items).

---

*Generated by Art Style Reviewer Agent, 2026-04-30.*  
*Source code: all CSS/JS files in frontend/ directory of the Millennium Bug Incident game.*
