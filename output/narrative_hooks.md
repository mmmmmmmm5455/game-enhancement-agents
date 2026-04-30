# Game Design Document — Millennium Bug Incident

**Designer:** Game Designer Agent
**Date:** 2026-04-30
**Version:** 1.0
**Scope:** Environmental narrative hooks, revisit triggers, dreamcore fragments, glitched text mode

---

## 1. Design Philosophy

**Sparse is scarier.** Every communication reduces isolation. Environmental changes should be missable on first glance — the player who notices is rewarded with unease, not explanation. **Liminal spaces are transitional** — underpasses, bridges, highways, streets are places between destinations, not destinations themselves. The player is perpetually passing through, never arriving. **The player is being watched** — the viewer counter is the only persistent companion. It never explains itself. **Infection is corruption** — as infection rises, the world degrades: visually (glitched text), sonically (stable — contrast principle), and spatially (environmental changes intensify).

---

## 2. Environmental Narrative Hooks (10 total)

### rain_underpass — 雨中地下道 (Enclosed Dread)

| # | Hook Type | Description | Trigger Condition | File |
|---|-----------|-------------|-------------------|------|
| H1 | object_state_change | Graffiti text "你還在嗎" appears on the underpass wall, rendered as a CanvasTexture decal. Was not present on first visit. | `app.visitedScenes.has('rain_underpass') && data.visitCount >= 2` | `frontend/js/scenes/rain_underpass.js` |
| H2 | audio_cue | Water drip interval shifts from regular (2-5s) to irregular (8-15s) with occasional double-drip. The space is changing. | `app.visitedScenes.has('rain_underpass') && data.infection_level > 35` | `frontend/js/audio.js` (rain_underpass env preset) |
| H3 | lighting_change | Fluorescent light above flickers once (1-frame off), then stabilizes. Only on revisit. Player questions if they imagined it. | `app.visitedScenes.has('rain_underpass') && data.visitCount >= 3` | `frontend/js/scenes/rain_underpass.js` |

### snow_bridge — 雪中天橋 (Cold Exposure)

| # | Hook Type | Description | Trigger Condition | File |
|---|-----------|-------------|-------------------|------|
| H4 | object_state_change | Footprints in the snow leading away from the bridge. Were not there on first visit. A single set, walking east. | `app.visitedScenes.has('snow_bridge') && data.visitCount >= 2` | `frontend/js/scenes/snow_bridge.js` |
| H5 | object_state_change | Distant housing block: one additional window is now lit. On first visit, only 3 windows were lit. Now there are 4. | `app.visitedScenes.has('snow_bridge') && data.infection_level > 40` | `frontend/js/scenes/snow_bridge.js` |
| H6 | audio_cue | Wind drone gains a dissonant second layer — a 73Hz sine LFO modulating the snow_bridge drone gain. The exposure feels deeper. | `data.memory_fragments >= 3 && app.visitedScenes.has('snow_bridge')` | `frontend/js/audio.js` |

### fog_highway — 霧中公路 (Vast Emptiness)

| # | Hook Type | Description | Trigger Condition | File |
|---|-----------|-------------|-------------------|------|
| H7 | object_state_change | An abandoned car wreck materializes at the edge of fog draw distance. Low-poly, dark silhouette. Was not there on previous visit. | `app.visitedScenes.has('fog_highway') && data.visitCount >= 2` | `frontend/js/scenes/fog_highway.js` |
| H8 | lighting_change | Fog density permanently increases by 40% (base × 1.4). The highway is being consumed. | `app.visitedScenes.has('fog_highway') && data.infection_level > 60` | `frontend/js/background.js` (fogDensityBase) |

### blizzard_street — 暴雪街道 (Urban Abandonment)

| # | Hook Type | Description | Trigger Condition | File |
|---|-----------|-------------|-------------------|------|
| H9 | lighting_change | One streetlight has burned out on revisit. The pool of light it cast is now darkness. The street is dimmer. | `app.visitedScenes.has('blizzard_street') && data.visitCount >= 2` | `frontend/js/scenes/blizzard_street.js` |
| H10 | object_state_change | Emergency light on a distant building starts blinking. Was previously off. Irregular blink pattern (1-3s random intervals). | `app.visitedScenes.has('blizzard_street') && data.infection_level > 50` | `frontend/js/scenes/blizzard_street.js` |

---

## 3. Revisit Triggers (5 total)

### TRIGGER-01: The Watcher Multiplies (Threshold)
- **Type:** threshold
- **Condition:** `app.visitedScenes.size >= 3 && data.visit_counts.total() >= 5`
- **Effect:** Viewer counter permanently increments by +1. System message: "Viewer #2 connected." No further explanation.
- **Implementation:** `app.js:applyGameResponse()` — check `visitedScenes.size` after scene_trigger, if >=3 and viewer hasn't been bumped yet, set `viewerCount = 2`.

### TRIGGER-02: Frozen Echo (Cross-Scene)
- **Type:** cross_scene
- **Condition:** `app.visitedScenes.has('rain_underpass') && app.visitedScenes.has('snow_bridge') && currentScene === 'rain_underpass'`
- **Effect:** Water drips in rain_underpass now have a frozen quality — the drip interval doubles (5-10s), and each drip is followed by a faint ice-crack sound (80Hz tiny burst). The rain is freezing.
- **Implementation:** `audio.js:createRainDrips()` — check `visitedScenes` set for cross-scene condition, modify interval range and add secondary noise burst.

### TRIGGER-03: The Fog Remembers (Infection-Gated)
- **Type:** infection_gated
- **Condition:** `data.infection_level > 55 && app.visitedScenes.has('fog_highway') && data.visitCount >= 2`
- **Effect:** Fog density permanently increases by 50% and fog color shifts slightly green (sick tint). The highway is sick. Reverts only if infection drops below 55.
- **Implementation:** `background.js:switchScene()` — set `fogDensityBase *= 1.5` and adjust fog color slightly toward green-cyan on fog_highway scene when infection condition met.

### TRIGGER-04: The Signal Decays (Fragment-Gated)
- **Type:** fragment_gated
- **Condition:** `data.memory_fragments >= 5`
- **Effect:** Glass-shatter particle effect triggers briefly on next scene transition. All subsequent scene transitions have a 20% chance of a 1-frame glitch flash (white frame). The world is fragmenting.
- **Implementation:** `background.js:switchScene()` — add fragment count check, create white flash overlay div with setTimeout removal. In `app.js:applyGameResponse()`, roll 20% chance on each scene_trigger with fragments >=5.

### TRIGGER-05: Blizzard Claims the Street (Threshold + Infection)
- **Type:** threshold
- **Condition:** `app.visitedScenes.has('blizzard_street') && data.visitCount >= 3 && data.infection_level > 40`
- **Effect:** Snow particle count increases by 50%, particle speed doubles, and visibility drops. The blizzard intensifies each time the player returns. A new piece of debris (overturned trash can, low-poly) appears near the streetlight.
- **Implementation:** `frontend/js/scenes/blizzard_street.js` — check visit count at scene creation, multiply particle count/speed, add debris mesh at predefined position.

---

## 4. Dreamcore Fragment System

### Fragments (10 total)

| # | Text | Trigger Condition |
|---|------|-------------------|
| F1 | "are you still there" | `infection_level >= 20`, random timer 45-120s after scene entry |
| F2 | "this is not a place" | `infection_level >= 30`, random timer 60-150s after previous fragment |
| F3 | "you have been here before" | Triggered on any scene revisit (visitCount >= 2), appears within 30s |
| F4 | "they are watching through the screen" | `viewer_count >= 2`, random timer 90-180s |
| F5 | "the signal is decaying" | `infection_level >= 50`, random timer 30-90s |
| F6 | "don't trust the viewer count" | `viewer_count >= 1 && infection_level >= 40`, random timer 60-120s |
| F7 | "this space has no exit" | `fragments_collected >= 5 && visitedScenes.size >= 3`, random timer 120-240s |
| F8 | "your body is not here" | `infection_level >= 65`, appears immediately on reaching threshold |
| F9 | "they rebuilt it wrong" | `visitedScenes.size >= 4` (all scenes visited), random timer 60-150s |
| F10 | "wake up" | `infection_level >= 90`, appears immediately, only once |

### Display Behavior
- **Position:** Random 10-30% from top of viewport, 5-15% from left of viewport
- **Animation:** `fadeIn 2s → hold 8s → fadeOut 2s` (CSS transition on opacity)
- **Duration:** 12000ms total
- **Font:** VT323, 20px, `var(--color-cold-cyan)` with cyan glow text-shadow
- **Z-index:** 55 (below system dialog at 60, above scene at 50)

### Frequency Control
- **Min interval:** 45000ms (45 seconds between fragments)
- **Max interval:** 240000ms (4 minutes between fragments)
- **Infection scaling:** true — at infection >70, min interval drops to 30000ms
- **Fragment non-repeat:** Each fragment appears at most once per session (Set-based tracking)

---

## 5. Glitched Text Mode

### Specification

| Parameter | Value |
|-----------|-------|
| Activation threshold | infection_level ≥ 70 |
| Corruption rate at threshold (70) | 5% of characters corrupted |
| Corruption rate at max (95) | 30% of characters corrupted |
| Rate interpolation | Linear: `rate = 0.05 + (infection - 70) / 25 * 0.25` |
| Corruption method | `unicode_combining` — zalgo combining marks at low intensity (1-3 marks per corrupted char, from U+0300-U+036F range) |
| Per-message randomization | Each message independently selects which characters to corrupt |
| Non-corrupted characters | Letters preserved with original spacing (no unicode issues for Chinese characters — apply only to ASCII a-z ranges) |

### Implementation

```javascript
// In renderer.js, add before typewriterEffect():
function corruptText(text, infectionLevel) {
  if (infectionLevel < 70) return text;
  var rate = 0.05 + (Math.min(95, infectionLevel) - 70) / 25 * 0.25;
  var marks = [
    '̀', '́', '̂', '̃', '̈',
    '̣', '̤', '̥', '̦', '̴'
  ];
  var result = '';
  for (var i = 0; i < text.length; i++) {
    var ch = text[i];
    result += ch;
    // Only corrupt ASCII letters (preserve CJK and punctuation)
    if (/[a-zA-Z]/.test(ch) && Math.random() < rate) {
      var count = 1 + Math.floor(Math.random() * 3);
      for (var j = 0; j < count; j++) {
        result += marks[Math.floor(Math.random() * marks.length)];
      }
    }
  }
  return result;
}
```

**Integration point:** `renderer.js:typewriterEffect()` — call `corruptText(rawText, infectionLevel)` before character-by-character rendering. The corrupted text produces the zalgo effect in the DOM via combining Unicode marks.

---

## 6. Prerequisites

Before any narrative hooks can execute, `app.js` must track visit state:

```javascript
// Add to app.js near startApplication():
app.visitedScenes = new Set();
app.visitCounts = {};  // { sceneId: count }

// Add to applyGameResponse(), after scene_trigger detected:
if (data.scene_trigger && data.scene_trigger !== currentScene) {
  app.visitedScenes.add(data.scene_trigger);
  app.visitCounts[data.scene_trigger] = (app.visitCounts[data.scene_trigger] || 0) + 1;
}
```

This is a prerequisite task that every narrative hook depends on.

---

## 7. Implementation Notes

### Code Changes Required
1. `frontend/js/app.js` — Add `visitedScenes` Set and `visitCounts` object (prerequisite, ~8 lines)
2. `frontend/js/app.js` — Populate visitedScenes in `applyGameResponse()` on scene_trigger (~5 lines)
3. `frontend/js/app.js` — Wire revisit trigger checks after scene state update (~15 lines)
4. `frontend/js/renderer.js` — Add `corruptText()` function and integrate into `typewriterEffect()` (~25 lines)
5. `frontend/js/renderer.js` — Add fragment non-repeat Set tracking in `updateStatusBars()` (~5 lines)
6. `frontend/js/background.js` — Add infection-gated fog density multiplier in `switchScene()` (~10 lines)
7. `frontend/js/background.js` — Add fragment-gated transition flash effect (~15 lines)
8. `frontend/js/audio.js` — Add cross-scene trigger check in `createRainDrips()` (~10 lines)
9. `frontend/js/audio.js` — Add dissonant drone layer function for snow_bridge (~20 lines)
10. `frontend/js/scenes/rain_underpass.js` — Add graffiti CanvasTexture decal creation function (~30 lines)
11. `frontend/js/scenes/rain_underpass.js` — Add fluorescent flicker logic (~10 lines)
12. `frontend/js/scenes/snow_bridge.js` — Add footprint geometry generation function (~25 lines)
13. `frontend/js/scenes/snow_bridge.js` — Add dynamic lit window toggle (~15 lines)
14. `frontend/js/scenes/fog_highway.js` — Add car wreck mesh creation function (~30 lines)
15. `frontend/js/scenes/blizzard_street.js` — Add streetlight state toggle (~10 lines)
16. `frontend/js/scenes/blizzard_street.js` — Add emergency light blinking with random intervals (~20 lines)
17. `frontend/js/scenes/blizzard_street.js` — Add blizzard intensity scaling per TRIGGER-05 (~15 lines)
18. `frontend/js/dreamcore.js` — Add trigger condition checks before fragment display (~15 lines)

### New Files Needed
None — all changes are modifications to existing files.

### Estimated Effort
- **Hours:** 5.5 (330 minutes)
- **Breakdown:** Narrative hooks (2.5 hr) + Revisit triggers (1.0 hr) + Dreamcore conditions (0.5 hr) + Glitched text (0.5 hr) + Integration testing (1.0 hr)

### Hook Implementability
All hooks are implementable in <50 lines of JavaScript each:
- H1 (graffiti decal): ~30 lines
- H2 (audio drip interval): ~10 lines (config change)
- H3 (fluorescent flicker): ~10 lines (one-frame toggle)
- H4 (footprints): ~25 lines (geometry generation)
- H5 (lit window): ~15 lines (visibility toggle)
- H6 (dissonant drone): ~20 lines (additional OscillatorNode)
- H7 (car wreck): ~30 lines (low-poly mesh)
- H8 (fog density): ~15 lines (config change)
- H9 (streetlight): ~10 lines (intensity toggle)
- H10 (emergency light): ~20 lines (blinking interval)
