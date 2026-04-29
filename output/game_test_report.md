# Game Test Team Report — Millennium Bug Incident

**Date:** 2026-04-30
**Phase:** A — Initial Game Scan
**Audit Scope:** All 8 frontend source files (4 CSS, 4 scenes, 4 core JS)
**Bugs Found:** 5
**Critical:** 1 | **High:** 2 | **Medium:** 2

---

## 1. Architecture Summary

| Layer | Files | Status |
|---|---|---|
| Entry | `index.html` | OK — loads 4 fonts, 4 CSS, 4 scene JS, Three.js r128 CDN |
| Core JS | `app.js`, `api.js`, `renderer.js`, `background.js` | OK — IIFE pattern, no global leaks beyond intentional exports |
| Scenes | `fog_highway.js`, `rain_underpass.js`, `snow_bridge.js`, `blizzard_street.js` | OK — each exports `createScene_<name>()` returning `{scene, camera, animate, dispose}` |
| CSS | `main.css`, `crt.css`, `counters.css`, `panels.css` | PARTIAL — 4 of 5 CRT effects missing in CSS (but some exist in WebGL shader) |

## 2. Functionality Audit

### 2.1 Game Initialization
- `DOMContentLoaded` → `initGame()` → `GameAPI.newSession()` → `applyGameResponse()` → `BackgroundManager.start()`
- Fallback: hardcoded Chinese error message if API unreachable
- **ISSUE A1 (Medium):** No retry mechanism on `newSession()` failure. Player sees static error with no recovery path.

### 2.2 Input Handling
- `#input-field` + `#send-button` → `handleSend()` 
- WebSocket-first with 12-second timeout fallback to POST
- Typewriter effect cancelled before new streaming starts
- Processing lock prevents double-send
- **ISSUE A2 (Low):** Input field disabled during processing but no visual spinner/indicator showing "thinking" state

### 2.3 State Updates
- `emotion_value` → emotion bar width (%)
- `infection_level` → infection bar width (%)
- `memory_fragments` → 7-segment counter (0-99, zero-padded)
- `viewer_count` → 7-segment counter with glitch animation
- `scene_trigger` → `BackgroundManager.switchScene()` + location display update
- `system_event` → system dialog popup (critical_infection, infection_warning, are_you_real)

### 2.4 Scene Transitions
- 3-second crossfade via `uTransition` uniform
- Previous scene rendered to `prevRT` before disposal
- CRT noise transition during crossfade
- **No issues found** — robust implementation

## 3. Bug Register

### BUG-01 (Critical) — Scene Disposal Memory Leak Risk
**File:** `background.js:148-150`
```js
if (currentSceneObj && currentSceneObj.dispose) {
  currentSceneObj.dispose();
}
```
**Problem:** `dispose()` is called but scene reference is not nulled before reassignment. If `dispose()` throws, `currentSceneObj` holds stale reference.
**Risk:** Memory accumulation on rapid scene switches.
**Suggested fix:** Wrap in try/catch, null reference after disposal.
**Status:** OPEN

### BUG-02 (High) — Post-Processing Shader Overlap with CSS CRT
**File:** `background.js:47-53` vs `crt.css`
**Problem:** The WebGL post-processing fragment shader already implements scanlines (line 42), noise (line 43), chromatic aberration (lines 47-48), color quantization (line 48), cold cyan tinting (line 50), banding (lines 51-52), and vignette (line 53). The CSS `crt.css` adds a SECOND layer of scanlines and chromatic aberration on top, causing double-processing.
**Risk:** Visual artifacts — scanlines applied twice (WebGL shader + CSS pseudo-element), chromatic aberration doubled.
**Suggested fix:** Either remove CSS CRT effects and enhance WebGL shader, OR keep CSS as fallback and disable when WebGL is active.
**Status:** OPEN

### BUG-03 (High) — WebSocket Timeout Too Generous
**File:** `app.js:111-113`
```js
setTimeout(function () {
  if (!wsDone) runFallback();
}, 12000);
```
**Problem:** 12-second WebSocket timeout before POST fallback. Player waits 12 seconds with no feedback if WebSocket silently fails.
**Risk:** Poor UX — player thinks game is broken and refreshes.
**Suggested fix:** Reduce to 5000ms, add "reconnecting..." indicator.
**Status:** OPEN

### BUG-04 (Medium) — Seven-Segment Counter Overflow
**File:** `renderer.js:68`
```js
if (fragEl) fragEl.textContent = String(Math.min(99, Math.max(0, fragments | 0))).padStart(2, '0');
```
**Problem:** Memory fragments capped at 99 with no overflow indicator. If game design intends >99 fragments, counter silently stops incrementing.
**Risk:** Minor — 99 may be the intended cap. But no visual indication that cap was reached.
**Suggested fix:** Add "+" suffix when value exceeds 99, or expand to 3 digits.
**Status:** OPEN

### BUG-05 (Medium) — No Scene Load Failure Handling
**File:** `background.js:152-158`
```js
var createFn = window['createScene_' + sceneName];
if (typeof createFn === 'function') {
  currentSceneObj = createFn();
```
**Problem:** If `createScene_<name>` is not a function (scene file failed to load), `currentSceneObj` stays null, but code continues. Next `animLoop()` frame will skip rendering silently — black screen with no error.
**Risk:** Silent failure — player sees black screen with no explanation.
**Suggested fix:** Fallback to default scene (fog_highway), log error to console.
**Status:** OPEN

## 4. Code Quality Notes

**Strengths:**
- `background.js` post-processing shader is surprisingly complete: scanlines, noise, chromatic aberration (temporal RGB offset), color quantization to 31 levels, cold cyan tinting, luminance banding, and vignette — all time-animated via `uTime`
- Vertex wobble injection via `onBeforeCompile` is elegant and non-invasive
- Scene render-to-texture at 1/4 resolution (NearestFilter) is correct PS1 approach
- `renderer.setPixelRatio(1)` and `antialias: false` are correct
- Unicode-safe typewriter with `Array.from(text)` avoids surrogate pair corruption

**Weaknesses:**
- All UI strings hardcoded in Chinese — acceptable for zh-TW game but no i18n support
- No loading states or progress indicators
- `BASE = ''` in api.js relies on same-origin deployment
- No input length limit on player input before sending to server

## 5. Test Coverage Gaps

| Area | Status |
|---|---|
| Cross-browser testing | NOT DONE — single environment |
| Mobile/tablet responsive | NOT DONE — likely broken (fixed pixel layout) |
| Network disconnect recovery | NOT DONE — WebSocket reconnection not implemented |
| Rapid scene switching | NOT DONE — memory leak risk (BUG-01) |
| Server error state persistence | NOT DONE — error messages never cleared |

---

*Generated by Game Test Team Agent (Phase A), 2026-04-30.*
*Files audited: index.html, main.css, crt.css, counters.css, panels.css, app.js, api.js, renderer.js, background.js, fog_highway.js, rain_underpass.js, snow_bridge.js, blizzard_street.js*
