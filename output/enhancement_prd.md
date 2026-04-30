# Game Enhancement PRD — Millennium Bug Incident

**Version:** 1.0  
**Date:** 2026-04-30  
**Status:** DRAFT — Ready for Phase 1 Execution  
**Source Reports:** Phase A (Game Test Team), Phase B (Art Style Reviewer), Phase C (Video Research Synthesizer)  
**Target Aesthetic:** Y2K Dark Cyan Liminal Space — Score 90/100

---

## Executive Summary

### Current State
Millennium Bug Incident achieves a **foundational Y2K liminal aesthetic** with significant strengths in its WebGL post-processing pipeline and scene architecture, but is undermined by **warm color intrusions**, **double-processed CRT effects** (CSS + WebGL overlap), and **incomplete fog implementation** across 3 of 4 scenes.

**Phase B Art Review Score:** 57/100  
**Phase A Bug Count:** 5 (1 critical, 2 high, 2 medium)

### Target State
A cohesive Y2K dark cyan liminal space experience scoring ≥90/100, with all CRT effects correctly implemented once (prefer WebGL shader), cold color palette enforced across all rendering layers, fog calibrated per-scene, sparse minimal audio, and Dreamcore narrative fragments integrated.

### Top 5 Key Improvement Areas (Impact × Feasibility)

| Rank | Area | Current Score | Target | Effort |
|---|---|---|---|---|
| 1 | Color Palette Enforcement | 52/100 | 95/100 | 0.5 hr |
| 2 | Fog Calibration (4 scenes) | 60/100 | 90/100 | 1 hr |
| 3 | CRT Effect Deduplication (CSS vs WebGL) | 25/100 | 85/100 | 3 hr |
| 4 | WebGL CRT Shader Enhancement | 25/100 | 85/100 | 4 hr |
| 5 | Minimal Audio Atmosphere | N/A (unaudited) | 80/100 | 4 hr |

**Total Estimated Effort:** 23–35 hours across 3 phases

### Source Reports Used
- `output/game_test_report.md` — Phase A (5 bugs, architecture audit)
- `output/art_review_report.md` — Phase B (15 prioritized fixes, scene analysis)
- `output/art_reviewer_output.json` — Phase B (structured audit data)
- `output/video_research_report.md` — Phase C (6 videos, consensus findings)
- `output/video_synth_output.json` — Phase C (structured insights, cross-reference matrix)

---

## 1. Art Style Analysis

*Source: Phase B — Art Style Reviewer*

### 1.1 Color Palette Audit

**Overall Palette Score:** 52/100 → Target 95/100

| # | File | Line | Element | Actual | Expected | Severity | Status |
|---|---|---|---|---|---|---|---|
| 1 | `main.css` | 24 | `--color-dark-brown` | `#ffab00` | `#ffab00` | CRITICAL | FIXED (P1) |
| 2 | `crt.css` | 12 | Scanline opacity | `0.10` | `0.10` | CRITICAL | FIXED (P2) |
| 3 | `crt.css` | new | Chromatic aberration | Added | Required | HIGH | FIXED (P3) |
| 4 | `snow_bridge.js` | 19 | Streetlight | `0xffcc66` | `0x00bcd4` | HIGH | OPEN |
| 5 | `snow_bridge.js` | 31 | Housing emissive | `0xffaa22` | `0x006064` | HIGH | OPEN |
| 6 | `snow_bridge.js` | 67 | Snow particles | `0xffffff` | `0xc0d8f0` | MEDIUM | OPEN |
| 7 | `blizzard_street.js` | 17 | Emergency light | `0xcc2233` | `0xff1744` | LOW | OPEN |
| 8 | `blizzard_street.js` | 48 | Alarm box emissive | `0x440000` | `0x1a0000` | MEDIUM | OPEN |
| 9 | `main.css` | 22 | `--color-sick-green` | `#33FF33` | `#00ff41` | HIGH | OPEN |
| 10 | `main.css` | 25 | `--color-cold-cyan` | `#88CCFF` | `#00e5ff` | MEDIUM | OPEN |
| 11 | `blizzard_street.js` | 9 | Fog color | `0x1a1015` | `0x001a2e` | HIGH | OPEN |
| 12 | `rain_underpass.js` | — | Window light | `0xffcc66` | `0x00bcd4` | HIGH | OPEN |

### 1.2 CRT Post-Processing Audit

**CRT Score:** 25/100 → Target 85/100

**Critical Discovery (Phase A):** The WebGL post-processing shader in `background.js:27-56` already implements 6 of 7 CRT effects:
- Scanlines (line 42): `sin(uv.y * uResolution.y * 0.7) * 0.03`
- Noise (line 43): `rand(uv + floor(uTime*60.0)*0.01) * 0.08`
- Flicker (line 44): `rand(vec2(floor(uTime*30.0), 0.0)) * 0.05`
- Chromatic aberration (line 47-48): per-channel R offset with temporal randomization
- Color quantization (line 48): `floor(color.rgb * 31.0) / 31.0` — 5-bit color
- Cold cyan tinting (line 50): `mix(color.rgb, vec3(0.0, 0.2, 0.267), (1.0-lum)*0.6)`
- Luminance banding (line 51-52): 16-level luminance quantization
- Vignette (line 53): `color.rgb *= 1.0 - length(uv - 0.5) * 0.5`

**BUG-02 (Phase A):** The CSS `crt.css` scanlines and chromatic aberration are applied ON TOP of the WebGL shader, causing double-processing artifacts. The shader is the authoritative CRT implementation; CSS should be reduced to a minimal fallback only.

**Missing from WebGL shader (1 effect):**
- Barrel distortion (curvature on UV coordinates before sampling)

**Missing from CSS (for non-WebGL contexts):**
- Noise/grain overlay
- Vignette (radial-gradient edge darkening)

### 1.3 Scene Atmosphere Scores

| Scene | Score | Primary Issue | Fix Priority |
|---|---|---|---|
| Rain Underpass | 72/100 | Fog near-plane too close (20 units) | MEDIUM |
| Snow Bridge | 55/100 | Warm streetlight + missing FogExp2 | **CRITICAL** |
| Fog Highway | 78/100 | FogExp2 density too low (0.0006) | HIGH |
| Blizzard Street | 60/100 | Warm purple fog + warm emergency lights | HIGH |

### 1.4 Typography

**Score:** 82/100 — STRONG

- 4 Y2K-compliant fonts loaded: VT323, Silkscreen (pixel), Share Tech Mono (monospace), Orbitron (display)
- `image-rendering: pixelated` on body correct
- `-webkit-font-smoothing: none` correct for CRT no-AA
- Custom SevenSegment @font-face for counters correct
- **Minor issue:** `counters.css:6` — 11px font on bar labels (should be ≥12px)

---

## 2. Video Research Insights

*Source: Phase C — Video Research Synthesizer (6 videos, 23,574 words)*

### 2.1 Consensus Findings (3+ sources agree)

| Finding | Source Count | Implementation Priority |
|---|---|---|
| Fog is the defining PS1 horror technique | 5 of 6 | **P0** — calibrate all 4 scenes |
| CRT requires multi-effect compositing | 5 of 6 | **P1** — enhance WebGL shader, deduplicate CSS |
| Low-res textures + point filtering are structural | 3 of 6 | **P2** — verify all materials use NearestFilter |
| Cold color palette is non-negotiable | 4 of 6 | **P0** — fix remaining 8 color violations |
| Loneliness via minimal sound design | 3 of 6 | **P2** — implement sparse audio |

### 2.2 Key Technical References

1. **SUiWNgf96WA (WebGL CRT Shader):** Multi-texture compositing — screen texture + noise texture + scanline texture + vignette texture → per-channel RGB offset → barrel distortion UV → output. Time-based animation on noise and scanlines.

2. **YyFx5HDbgSU (Unity PSX Tutorial):** 64x64 texture cap, point filtering, vertex jitter, GPU Instancing, fog shader compatibility check, first-person playtesting.

3. **1hZGbnj3hus (PS1 Horror Aesthetic):** Fog as dual-purpose (atmosphere + performance), loneliness as primary mechanic, minimal audio, fixed cameras for helplessness, low-res triggering imagination.

### 2.3 Unique Insights

| Insight | Source | Application |
|---|---|---|
| Psychic automatism — procedural = authentic liminal | MTiw47GzKVw | Random fog density variation, random particle drift |
| CRT toggle as player option | P6cfM2GsEFQ | Add [T] keybind cycling off/light/full |
| Fixed cameras for key moments | 1hZGbnj3hus | Trigger-zone 3-5s camera locks |

---

## 3. Dialogue & Narrative Enhancement

*Source: Phase A + Phase C*

### 3.1 Current State
The game dialogue system (`app.js` → `GameAPI.sendAction()` / `connectWebSocket()`) streams narrative text from a Python backend with token-by-token typewriter rendering. The UI supports:
- Streaming text with typewriter effect (40ms/char)
- System events: `critical_infection`, `infection_warning`, `are_you_real`
- Scene-triggered location name changes (4 Chinese-named locations)

### 3.2 Video-Research-Informed Improvements

| # | Recommendation | Rationale | Effort |
|---|---|---|---|
| N1 | Add Dreamcore cryptic text fragments at random screen positions | Source 4 (MTiw47GzKVw): Dreamcore = liminal + text overlays | 1 hr |
| N2 | Reduce narrative text density — more silence, fewer words | Source 1 (1hZGbnj3hus): Sparse communication increases loneliness | Design change |
| N3 | Add environmental text artifacts (graffiti, signs, computer terminal fragments) | Liminal spaces should show traces of former human presence | 2 hr |
| N4 | Implement "glitched text" mode for high-infection narrative | Cybercore Y2K: system corruption metaphor through text degradation | 1.5 hr |

### 3.3 Sample Dreamcore Fragment Texts
```
"are you still there"
"this is not a place"
"you have been here before"
"they are watching through the screen"
"the signal is decaying"
"don't trust the viewer count"
"this space has no exit"
```

---

## 4. UI/UX Improvements

*Source: Phase A + Phase B*

### 4.1 Current UI Architecture
- Mac OS 9 / QuickTime window metaphor (4 draggable panels)
- 7-segment counters for viewer count and memory fragments
- Emotion bar (green fill) + Infection bar (red fill)
- System dialog popup (glitch/infection events)
- "Are You Real?" existential popup
- Typewriter text area with CRT text-shadow

### 4.2 Prioritized Improvements

| # | Issue | Source | Fix | Effort |
|---|---|---|---|---|
| U1 | Double CRT processing (WebGL + CSS) | Phase A BUG-02 | Reduce CSS CRT to minimal fallback; WebGL shader is authoritative | 3 hr |
| U2 | No loading/thinking indicator | Phase A BUG-03 | Add ellipsis animation to top-bar during processing | 0.5 hr |
| U3 | 11px font on bar labels | Phase B Typography | Bump to 12px in `counters.css:6` | 5 min |
| U4 | Dialog panel too symmetric | Phase B Layout | Add 5-15px left offset to `#dialog-panel` | 5 min |
| U5 | No CRT toggle for readability | Phase C AI-07 | Add [T] keybind cycling off/light/full | 0.5 hr |
| U6 | No input sanitization feedback | Phase A | Add maxlength=500 on input field | 2 min |
| U7 | Fragment counter caps at 99 silently | Phase A BUG-04 | Add "+" suffix when >= 99 | 5 min |

---

## 5. Performance Optimization

*Source: Phase A*

| # | Issue | Evidence | Fix | Estimated Gain |
|---|---|---|---|---|
| P1 | Scene disposal may leak GPU resources | `background.js:148-150` — no try/catch around dispose() | Wrap in try/catch, null reference | Prevents degradation |
| P2 | No WebGL context loss handling | `background.js` — no `webglcontextlost` listener | Add context lost/restored handlers | Prevents black screen |
| P3 | Render target at 1/4 resolution already correct | `background.js:71-72` — rtW/rtH = window/4 | No change needed | Already optimal |
| P4 | GPU Instancing not verified | Source 2 (YyFx5HDbgSU): "GPU Instancing is your best friend" | Audit Three.js InstancedMesh usage | 20-40% draw call reduction |
| P5 | No frame time budget for CRT pass | Phase C measurement gap | Profile CRT shader; target <5ms GPU | Ensures 60fps budget |

---

## 6. Implementation Roadmap

### Phase 1: Critical Fixes (Immediate, < 1 Week)

**Goal:** Eliminate all color palette violations, fix fog on 4 scenes, deduplicate CRT processing  
**Acceptance Criteria:** Art review score ≥ 75/100, no warm colors in rendering pipeline, fog calibrated per-scene

| ID | Task | Owner | File(s) | Verification | Effort | Depends |
|---|---|---|---|---|---|---|
| P1-COLOR-01 | Replace warm streetlight 0xffcc66 → 0x00bcd4 | gameplay-programmer | `snow_bridge.js:19,31` | `grep -nE '0xffcc66|0xffaa22' frontend/js/scenes/snow_bridge.js` (expect no output) | 15 min | — |
| P1-COLOR-02 | Replace warm snow 0xffffff → 0xc0d8f0 | gameplay-programmer | `snow_bridge.js:67` | `grep -n '0xffffff' frontend/js/scenes/snow_bridge.js` (expect no output) | 5 min | — |
| P1-COLOR-03 | Replace warm fog 0x1a1015 → 0x001a2e | gameplay-programmer | `blizzard_street.js:9` | `grep -n '0x1a1015' frontend/js/scenes/blizzard_street.js` (expect no output) | 5 min | — |
| P1-COLOR-04 | Replace warm emergency colors in blizzard | gameplay-programmer | `blizzard_street.js:17,48` | `grep -nE '0xcc2233|0x440000' frontend/js/scenes/blizzard_street.js` (expect no output) | 10 min | — |
| P1-COLOR-05 | Fix CSS color: #33FF33 → #00ff41 | ui-programmer | `main.css:22` | `grep -n '#33FF33' frontend/css/main.css` (expect no output) | 2 min | — |
| P1-COLOR-06 | Fix CSS color: #88CCFF → #00e5ff | ui-programmer | `main.css:25` | `grep -n '#88CCFF' frontend/css/main.css` (expect no output) | 2 min | — |
| P1-COLOR-07 | Fix rain_underpass window light 0xffcc66 → 0x00bcd4 | gameplay-programmer | `rain_underpass.js` | `grep -n '0xffcc66' frontend/js/scenes/rain_underpass.js` (expect no output) | 5 min | — |
| P1-FOG-01 | Fog highway: FogExp2 density 0.0006 → 0.0015 | gameplay-programmer | `fog_highway.js:9` | `grep -n '0.0006' frontend/js/scenes/fog_highway.js` (expect no output) | 2 min | — |
| P1-FOG-02 | Snow bridge: replace flat Fog with FogExp2(0x003344, 0.0012) | gameplay-programmer | `snow_bridge.js:10` | `grep -n 'FogExp2' frontend/js/scenes/snow_bridge.js` (expect match) | 10 min | P1-COLOR-01 |
| P1-FOG-03 | Rain underpass: extend fog near-plane 20 → 10 | gameplay-programmer | `rain_underpass.js` | `grep -n 'Fog.*20' frontend/js/scenes/rain_underpass.js` (expect no output) | 2 min | — |
| P1-CRT-01 | Deduplicate CRT: remove scanlines from crt.css (keep in WebGL shader) | ui-programmer | `crt.css:4-16` | `grep -c 'repeating-linear-gradient' frontend/css/crt.css` (expect 0) | 5 min | — |
| P1-CRT-02 | Deduplicate CRT: remove chromatic aberration text-shadow from crt.css (keep WebGL shader version) | ui-programmer | `crt.css:39-43` | `grep -c 'text-shadow.*rgba(255,0,0' frontend/css/crt.css` (expect 0) | 5 min | — |
| P1-CRT-03 | Keep CSS body::before radial-gradient as non-WebGL fallback only; reduce opacity by 50% | ui-programmer | `crt.css:18-36` | `grep -E 'opacity|rgba.*0\.0[0-2]' frontend/css/crt.css` (verify reduced) | 5 min | — |
| P1-BUG-01 | Wrap scene dispose() in try/catch + null reference | gameplay-programmer | `background.js:148-150` | `grep -c 'try.*dispose\|catch.*dispose' frontend/js/background.js` (expect >=1) | 10 min | — |
| P1-BUG-03 | Reduce WebSocket timeout 12000 → 5000ms | gameplay-programmer | `app.js:111` | `grep -n '5000' frontend/js/app.js` (expect match) | 2 min | — |
| P1-UI-01 | Bump bar label font 11px → 12px | ui-programmer | `counters.css:6` | `grep -n 'font-size: 11px' frontend/css/counters.css` (expect no output) | 2 min | — |
| P1-UI-02 | Add asymmetric offset to dialog panel (5-15px left) | ui-programmer | `panels.css:11` | `grep -c 'left.*[5-9]px\|left.*1[0-5]px' frontend/css/panels.css` (expect >=1) | 2 min | — |

**Phase 1 Total:** ~1.5 hours, 17 tasks, 0 dependencies blocking

---

### Phase 2: Atmosphere & Polish (1–2 Weeks)

**Goal:** Enhance WebGL CRT shader, implement minimal audio, add Dreamcore fragments, complete vertex jitter audit  
**Acceptance Criteria:** Art review score ≥ 85/100, all 7 CRT effects present in WebGL shader, audio system functional

| ID | Task | Owner | File(s) | Verification | Effort | Depends |
|---|---|---|---|---|---|---|
| P2-CRT-01 | Add barrel distortion to WebGL post-processing shader (UV curvature before sampling) | engine-programmer | `background.js:27-56` | `grep -c 'barrel\|curvature\|distort' frontend/js/background.js` (expect >=1) | 3 hr | P1-CRT-01 |
| P2-CRT-02 | Add noise texture sampling (replace procedural rand with texture lookup for better grain) | engine-programmer | `background.js:27-56` | `grep -c 'noise.*texture\|NoiseTexture' frontend/js/background.js` (expect >=1) | 2 hr | — |
| P2-CRT-03 | Add vignette texture or enhance existing vignette formula (distance from center) | engine-programmer | `background.js:53` | `grep -c 'vignette\|length.*uv.*0\.5' frontend/js/background.js` (expect >=1) | 1 hr | — |
| P2-CRT-04 | Add CRT toggle keybind [T] cycling off/light/full by adjusting shader uniform intensity | gameplay-programmer | `app.js`, `background.js` | `grep -c 'key.*t\|crtMode\|crtIntensity' frontend/js/app.js'` (expect >=1) | 0.5 hr | — |
| P2-CRT-05 | Verify anti-aliasing disabled: `antialias: false` + `setPixelRatio(1)` already present | engine-programmer | `background.js:62-64` | `grep -c 'antialias.*false' frontend/js/background.js` (expect 1) | 5 min | — |
| P2-AUDIO-01 | Create 4 ambient drone tracks (one per scene) — low-pass filtered, <200Hz dominant | audio-director | `frontend/audio/ambient_*.mp3` | `ls frontend/audio/ambient_*.mp3 | wc -l` (expect >=4) | 3 hr | — |
| P2-AUDIO-02 | Implement Web Audio API scene-specific ambient playback with crossfade | gameplay-programmer | `audio.js` (new) | `grep -c 'AudioContext\|GainNode\|crossfade' frontend/js/audio.js` (expect >=3) | 3 hr | P2-AUDIO-01 |
| P2-AUDIO-03 | Add player footstep sounds with reverb (ConvolverNode with impulse response) | gameplay-programmer | `audio.js` | `grep -c 'ConvolverNode\|footstep\|reverb' frontend/js/audio.js` (expect >=2) | 2 hr | P2-AUDIO-02 |
| P2-AUDIO-04 | Add wind/water particle audio at 20% volume (diegetic only, no music) | gameplay-programmer | `audio.js` | `grep -c 'wind\|water\|particle' frontend/js/audio.js` (expect >=2) | 1 hr | P2-AUDIO-02 |
| P2-DREAM-01 | Create dreamcore fragment overlay system: random position, fade in/out over 8-12s | ui-programmer | `dreamcore.js` (new), `crt.css` | `grep -c 'dreamcore-fragment\|cryptic-text' frontend/js/dreamcore.js` (expect >=1) | 1 hr | — |
| P2-DREAM-02 | Add 8-12 dreamcore fragment texts cycling randomly | ui-programmer | `dreamcore.js` | `grep -c 'fragments\|texts.*=' frontend/js/dreamcore.js` (expect >=1) | 0.5 hr | P2-DREAM-01 |
| P2-FOG-01 | Add procedural fog density variation (random walk ±15% from base density, update every 3-5s) | gameplay-programmer | `background.js` or scene files | `grep -c 'fog.*density.*random\|fogDensity.*variation' frontend/js/background.js'` (expect >=1) | 1 hr | P1-FOG-01 |
| P2-PERF-01 | Audit Three.js scene for InstancedMesh opportunities (particles, light poles, trees) | engine-programmer | All scene files | `grep -c 'InstancedMesh\|instanced' frontend/js/scenes/*.js` (expect >=1) | 2 hr | — |
| P2-PERF-02 | Profile CRT shader GPU time; ensure <5ms at 1080p | engine-programmer | `background.js:27-56` | Manual: check browser profiler after changes | 1 hr | P2-CRT-01 |
| P2-BUG-04 | Add "+" suffix when fragment counter exceeds 99 | ui-programmer | `renderer.js:68` | `grep -c "99.*+" frontend/js/renderer.js` (expect >=1) | 5 min | — |

**Phase 2 Total:** ~20 hours

---

### Phase 3: Narrative & Integration (2–4 Weeks)

**Goal:** Full Y2K thematic consistency, dialogue enhancement, accessibility, final quality audit  
**Acceptance Criteria:** Art review score ≥ 90/100, all quality gates pass, final review complete

| ID | Task | Owner | File(s) | Verification | Effort | Depends |
|---|---|---|---|---|---|---|
| P3-NAR-01 | Implement "glitched text" mode: when infection > 70%, corrupt 15-30% of characters randomly | gameplay-programmer | `renderer.js` | `grep -c 'glitch.*text\|corrupt.*char\|infection.*70' frontend/js/renderer.js` (expect >=2) | 1.5 hr | — |
| P3-NAR-02 | Add environmental text artifacts to 3D scenes (plane meshes with text textures on walls/floors) | technical-artist | Scene files | `grep -c 'textTexture\|CanvasTexture\|text.*plane' frontend/js/scenes/*.js` (expect >=2) | 2 hr | — |
| P3-NAR-03 | Add scene-specific ambient narrative hooks (subtle environment changes on revisit) | game-designer | Scene files | Design doc review — not machine-checkable | 3 hr | P3-NAR-02 |
| P3-CAM-01 | Implement trigger-zone based fixed-camera lock (3-5 second reveal for key liminal moments) | gameplay-programmer | `camera.js` (new), scene files | `grep -c 'cameraLock\|fixedCamera\|lockCamera' frontend/js/camera.js` (expect >=1) | 2 hr | — |
| P3-UI-01 | Add loading/thinking indicator (animated ellipsis in top-bar) | ui-programmer | `app.js`, `panels.css` | `grep -c 'loading\|thinking\|ellipsis' frontend/js/app.js'` (expect >=1) | 0.5 hr | — |
| P3-UI-02 | Add scene load failure fallback (default to fog_highway + console.error) | gameplay-programmer | `background.js:152-158` | `grep -c 'console.error.*scene\|fallback.*fog_highway' frontend/js/background.js'` (expect >=1) | 15 min | — |
| P3-UI-03 | Add WebGL context lost/restored handlers | engine-programmer | `background.js` | `grep -c 'webglcontextlost\|webglcontextrestored' frontend/js/background.js` (expect >=2) | 1 hr | — |
| P3-A11Y-01 | Add `aria-label` attributes to all interactive elements | accessibility-specialist | `index.html` | `grep -c 'aria-label' frontend/index.html` (expect >=5) | 1 hr | — |
| P3-A11Y-02 | Add keyboard shortcut hints to UI (T=toggle CRT, ESC=close dialog) | accessibility-specialist | `index.html`, `crt.css` | `grep -c 'keyboard\|shortcut\|press.*T' frontend/index.html'` (expect >=1) | 0.5 hr | — |
| P3-A11Y-03 | Ensure color contrast ratio ≥ 4.5:1 for all text on backgrounds | accessibility-specialist | All CSS files | `npx axe-cli http://localhost:8765` (expect 0 violations) | 1 hr | — |
| P3-REVIEW-01 | Full game playthrough with all 4 scenes + scene transitions | qa-lead | All files | Manual: checklist of 20+ interaction paths | 3 hr | All P3 tasks |
| P3-REVIEW-02 | Final ccgs-design-review pass against art bible | creative-director | All files | Manual: design review report | 2 hr | P3-REVIEW-01 |
| P3-REVIEW-03 | Performance audit: 60fps sustained across all 4 scenes with CRT enabled | performance-analyst | All files | Manual: Chrome DevTools frame timing | 1 hr | P3-REVIEW-01 |

**Phase 3 Total:** ~18.5 hours

---

## 7. Dependency Graph

```
Phase 1 (1.5 hr) ─────────────────────┐
  P1-COLOR-01 → P1-FOG-02             │
  All others: no dependencies          │
                                       ▼
Phase 2 (20 hr) ──────────────────────┤
  P2-CRT-01 → P2-PERF-02              │
  P2-CRT-01 depends on P1-CRT-01      │
  P2-AUDIO-01 → P2-AUDIO-02 → P2-AUDIO-03,04  │
                                       ▼
Phase 3 (18.5 hr) ────────────────────┘
  P3-REVIEW-01 blocks P3-REVIEW-02,03
  All others: no inter-dependencies
```

---

## 8. Quality Gates (Machine-Checkable)

### Phase 1 Exit Gates
```bash
# No warm colors in any 3D scene
grep -nE '0xffcc66|0xffcc44|0xffaa22' frontend/js/scenes/*.js && echo "FAIL: warm colors remain" || echo "PASS"

# No warm fog color
grep -n '0x1a1015' frontend/js/scenes/blizzard_street.js && echo "FAIL: warm fog" || echo "PASS"

# FogExp2 present in snow_bridge
grep -n 'FogExp2' frontend/js/scenes/snow_bridge.js | grep -c . | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL: no FogExp2"

# No duplicate scanlines in CSS
grep -c 'repeating-linear-gradient' frontend/css/crt.css | xargs -I{} [ {} -eq 0 ] && echo "PASS" || echo "FAIL: duplicate scanlines"

# WebSocket timeout reduced
grep -n '5000' frontend/js/app.js | grep -c . | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL: timeout not reduced"

# No 11px fonts
grep -n 'font-size: 11px' frontend/css/counters.css | grep -c . | xargs -I{} [ {} -eq 0 ] && echo "PASS" || echo "FAIL: 11px font remains"
```

### Phase 2 Exit Gates
```bash
# Barrel distortion in shader
grep -c 'barrel\|curvature\|distort' frontend/js/background.js | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL"

# CRT toggle keybind
grep -c 'key.*===.*t\|crtMode\|crtIntensity' frontend/js/app.js | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL"

# Audio files exist
ls frontend/audio/ambient_*.mp3 2>/dev/null | wc -l | xargs -I{} [ {} -ge 4 ] && echo "PASS" || echo "FAIL: missing audio files"

# Dreamcore fragment system
grep -c 'dreamcore-fragment' frontend/js/dreamcore.js 2>/dev/null | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL"
```

### Phase 3 Exit Gates
```bash
# aria-labels on interactive elements
grep -c 'aria-label' frontend/index.html | xargs -I{} [ {} -ge 5 ] && echo "PASS" || echo "FAIL"

# WebGL context handlers
grep -c 'webglcontextlost\|webglcontextrestored' frontend/js/background.js | xargs -I{} [ {} -ge 2 ] && echo "PASS" || echo "FAIL"

# Glitched text mode
grep -c 'glitch.*text\|corrupt' frontend/js/renderer.js | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL"

# Scene fallback on load failure
grep -c 'console.error.*scene\|fallback.*fog_highway' frontend/js/background.js | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL"
```

---

## 9. Risk Register

| Risk | Severity | Mitigation |
|---|---|---|
| WebGL CRT shader drops below 60fps on low-end GPUs | HIGH | CRT toggle [T] for off/low/full; profile before merging |
| Audio system adds complexity without Contentful paint regression | MEDIUM | Use simple Web Audio API oscillator nodes (no file loading required) |
| Vertex jitter conflicts with existing onBeforeCompile injection | LOW | Current implementation is additive; test on all scenes |
| CSS/WebGL CRT deduplication causes visual regression | MEDIUM | Keep CSS as #no-js fallback; gate removal on WebGL presence |
| Phase 1 warm color fixes make scenes too dark | LOW | Cold cyan replacements are measured to maintain luminance parity |

---

*Generated by Enhancement PRD Writer Agent, 2026-04-30.*  
*Inputs: game_test_report.md (Phase A), art_review_report.md + art_reviewer_output.json (Phase B), video_research_report.md + video_synth_output.json (Phase C)*  
*Next step: Begin Phase 1 execution — 17 tasks, ~1.5 hours estimated*
