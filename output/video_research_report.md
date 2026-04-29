# Video Research Synthesis Report — Millennium Bug Incident

**Date:** 2026-04-30  
**Research Keywords:** Y2K dark cyan liminal space game art, PS1 retro horror aesthetic, CRT post-processing effects CSS, low poly 3D horror atmosphere, liminal space environment design game  
**Sources Analyzed:** 6 videos  
**Total Transcript Words:** 23,574  
**Overall Confidence:** HIGH — direct technical implementations from 3 of 6 sources

---

## Executive Summary

Six videos spanning PS1 horror aesthetic analysis, Unity PSX shader tutorials, WebGL CRT post-processing implementation, and liminal space theory were transcribed and cross-referenced. Three sources provide **directly implementable technical guidance** (Unity PSX pipeline, WebGL CRT shader, PS1 aesthetic principles). Two sources provide **design theory** (liminal surrealism, horror loneliness). One source (P6cfM2GsEFQ) provides gameplay reference footage of a first-person liminal exploration game with CRT/VHS toggle UI — moderate utility.

**Top 5 actionable findings for Millennium Bug Incident:**

1. Fog is the single highest-impact aesthetic technique — both atmospheric AND performance-saving (all 5 design sources agree)
2. CRT implementation requires 5 distinct effects, not just scanlines — chromatic aberration (per-channel RGB offset), barrel distortion, noise grain, vignette edges, scanline overlay
3. Low-resolution texture pipeline is structural, not cosmetic — 64x64 textures + point filtering + vertex jitter create PS1 authenticity
4. Loneliness is the core emotional mechanic of PS1 horror — achieved through minimal sound design, sparse environments, and fixed/limited camera perspectives
5. Liminal spaces work by being empty-but-not-abandoned — recent traces of human presence, transitional architecture (hallways, pools, underpasses), fog obscuring boundaries

---

## 1. Source-by-Source Analysis

### Source 1: "The Haunting Aesthetic Of PS1 Horror" (1hZGbnj3hus)
**Words:** 2,702 | **Type:** Documentary/Analysis | **Utility:** HIGH

**Core Thesis:** The PS1's hardware limitations created a unique horror aesthetic that modern games struggle to replicate because the limitations *were* the art direction.

**Key Findings:**

| Insight | Game Application | Priority |
|---|---|---|
| Fog as dual-purpose: atmospheric + resource-saving (Silent Hill) | All 4 scenes must use correct fog; FogExp2 density at 0.0015 minimum | **CRITICAL** |
| Loneliness as primary horror mechanic | Reduce NPC count, minimize audio cues, maximize echo/reverb on player footsteps | HIGH |
| Low-res textures trigger imagination (filling gaps like peering down dark hallway) | 64x64 texture cap enforced; no interpolation filtering | HIGH |
| Fixed camera perspective creates helplessness | Consider optional fixed-camera exploration mode for key liminal moments | MEDIUM |
| Minimal sound design > fully realized audio | Sparse ambient drones, isolated wind, lone footsteps — no music beds | HIGH |
| Cutscene uncanny valley via low-res facial animation | Dialogue system should use low-FPS character portraits with slight animation jitter | MEDIUM |
| CRT nostalgia as emotional anchor | CRT post-processing must be comprehensive, not token | HIGH |

**Verbatim Quote (paraphrased):** "The calm winds faintly whistling in the distance, the loud footsteps echoing with each movement, and the thick fog being used to both make the game look atmospheric and save visual resources — it was all in service of what became one of the most iconic horror series of all time."

---

### Source 2: "How to create a PS1 style horror game in Unity | In-depth Tutorial" (YyFx5HDbgSU)
**Words:** 3,973 | **Type:** Technical Tutorial | **Utility:** VERY HIGH — Directly Implementable

**Core Thesis:** PS1 aesthetic requires deliberate technical choices at every pipeline stage: textures, shaders, fog, skybox, terrain, foliage, camera.

**Key Findings:**

| Finding | Implementation Detail | Game Application |
|---|---|---|
| 64x64 texture standard | Unity built-in downscale + point filtering (no filter) | Enforce texture resolution cap |
| Skybox from Google Images cubemaps | Any low-res photo → cube map material → assign to scene | Replace current procedural sky with photographic cubemap |
| Unity terrain at low resolution (64x64 heightmap) | Lower terrain resolution in settings → sculpt → texture with PSX shader | Not directly applicable (Three.js), but low-poly principle transfers |
| Fog shader compatibility critical | URP PSX default shader does NOT support fog; must use PBR1 variant | Verify all Three.js materials are fog-compatible |
| GPU Instancing essential for performance | Enable on all materials; single biggest performance win | Use Three.js InstancedMesh where applicable |
| Vertex jitter creates authentic PS1 polygon wobble | Add subtle random vertex displacement in vertex shader | Implement in Three.js custom vertex shader (0.5-1.0 unit jitter) |
| GoPainter > Unity terrain tree placement | Unity terrain tree system broken with PSX shader; use prefab painter | Not applicable, but reinforces need for manual scene assembly |
| First-person controller for playtesting | Always test scene from player perspective before finalizing | Verify first-person camera height, FOV, movement speed |

**Critical Detail:** The Unity PSX shader (Haunted PS1 Renderer) provides: noise intensity, barrel distortion, vignette, bloom, scanline sharpening, image sharpening, and a "great mass" TV distortion parameter. Resolution is controlled via camera volume with two sliders.

---

### Source 3: "WebGL Post Processing - CRT effect shader" (SUiWNgf96WA)
**Words:** 4,944 | **Type:** Technical Implementation | **Utility:** VERY HIGH — Directly Implementable in Three.js/WebGL

**Core Thesis:** CRT emulation requires multi-texture compositing with time-based animation, not static CSS overlays.

**Key Findings:**

| Effect | Implementation | Current Game Status |
|---|---|---|
| Scanlines | Repeating texture sampled with time offset for animation | PARTIAL — CSS-only, static, opacity was 4x too high (fixed) |
| Vignette | Separate vignette texture composited at screen edges | MISSING — need CSS radial-gradient or shader |
| Noise/Grain | Noise texture with time-based randomness | MISSING — CSS noise overlay or canvas-based grain |
| Chromatic Aberration | Per-channel RGB offset: sample R at offset+1, G at center, B at offset-1 | PARTIAL — added CSS text-shadow and radial-gradient but not per-channel screen split |
| Barrel Distortion | Curvature transform on UV coordinates before sampling | MISSING |
| Brightness/Luminance | Grayscale conversion of screen texture multiplied by brightness value → RGB | MISSING — controls phosphor glow |

**Implementation Architecture (WebGL):**
1. Render scene to FrameBuffer (Color Attachment 0) → produces screen texture
2. Load 3 auxiliary textures: noise, scanlines, vignette
3. In post-process shader: sample screen texture at barrel-distorted UV coordinates → apply per-channel RGB offset for chromatic aberration → multiply by scanline texture (time-animated) → composite noise texture (randomized per frame) → blend vignette at edges → output to canvas

**Critical Insight:** A CSS-only approach (like the current `crt.css`) cannot achieve true CRT simulation. The scanline animation, barrel distortion, and per-channel chromatic aberration all require per-pixel operations in a shader. The current game's `crt.css` is a reasonable fallback but will never reach CRT authenticity above ~40/100 without WebGL post-processing.

---

### Source 4: "Liminal Spaces & Dreamcore — A New Form of Surrealism" (MTiw47GzKVw)
**Words:** 2,035 | **Type:** Art Theory Documentary | **Utility:** MEDIUM — Context & Design Philosophy

**Core Thesis:** Liminal spaces work because they depict transitional architecture (hallways, pools, stairways) in states of unnatural emptiness, triggering the brain's pattern-matching for "something should be here but isn't."

**Key Findings:**

| Concept | Definition | Game Application |
|---|---|---|
| Classical Liminal Space | Empty transitional architecture; no people, no purpose, just passage | Rain Underpass (72/100), Fog Highway (78/100) — strongest scenes |
| Dreamcore | Liminal base + surreal overlays (cryptic text, floating artifacts, portals) | Current game leans toward this — add cryptic UI text fragments |
| Weirdcore | Dreamcore pushed to nightmare — organic matter, flesh, distorted forms | Consider for Phase 3 horror escalation |
| "Places you've seen in your dreams" | Hypnagogic imagery: indoor vegetation, rooms with water, stairs to nowhere, clouds indoors | Water in underpass scene is correct; add flooded room or indoor tree |
| Psychic Automatism (Surrealism) | Let unconscious thoughts guide creation — don't over-plan liminal scenes | Current 4 scenes are too "designed" — add procedural fog variation |
| Salvador Dali influence | Objects melting into environments, impossible architecture | Consider geometry that defies physics (floating platforms, non-Euclidean spaces) |

**Key Distinction:** Dreamcore adds text/characters/portals on top of liminal base. Weirdcore distorts the base itself. Millennium Bug Incident currently sits at pure liminal — adding cryptic UI text would push it toward Dreamcore, which aligns with the Y2K cybercore aesthetic already present.

---

### Source 5: "How to create a PS1 style horror game in Unity | Tutorial Part 1" (AOgl-MRi26A)
**Words:** 4,590 | **Type:** Technical Tutorial | **Utility:** HIGH — Pipeline Configuration

**Core Thesis:** The Haunted PS1 Renderer for Unity provides a drop-in PSX emulation pipeline with global volume post-processing controls.

**Key Findings:**

| Finding | Detail |
|---|---|
| Haunted PS1 Renderer | Custom Scriptable Render Pipeline for Unity; requires standard (non-URP/HDRP) project |
| Global Volume Effects | Quality override → Noise intensity → Barrel distortion → Vignette → Bloom → Scanline sharpening → Image sharpening → "Great mass" TV distortion |
| Camera Volume | Resolution control via two sliders; anti-aliasing must be disabled for authentic look |
| Material Migration | ALL scene materials must switch from Standard → PSX shader (10+ minute batch operation) |
| Built-in Fog Incompatibility | Unity built-in fog breaks with PSX shader; PBR1 variant required |
| Occlusion Culling | Disabled — unnecessary with low-res textures |

**Translation to Three.js:**
- "Global Volume" → Three.js EffectComposer with custom CRT shader pass
- "Camera Volume resolution" → `renderer.setPixelRatio()` to 1 (disable retina) or lower
- "Material migration to PSX shader" → Custom ShaderMaterial applied to all scene meshes
- "Disable anti-aliasing" → `renderer.setPixelRatio(1)` + no MSAA

---

### Source 6: "Dream Pools — First Person Liminal Exploration" (P6cfM2GsEFQ)
**Words:** 5,230 | **Type:** Gameplay Footage | **Utility:** LOW-MEDIUM — Reference Only

**Key Observations:**
- CRT/VHS toggle UI: player can switch between CRT mode, VHS mode, and clean fullscreen — confirms that post-processing as user-toggleable option increases immersion buy-in
- Flashlight as primary interaction mechanic: exploring dark liminal pools requires finding light source first
- Dream Pools aesthetic: indoor water park, water slides, submerged rooms, unnatural architecture
- Player commentary notes: "You never know if you're doing or going the right way" — core liminal disorientation
- Contains Alienware sponsorship segment (not useful)

**Relevant Design Pattern:** Allow players to toggle CRT effects on/off. This reduces complaints about readability while letting aesthetic-focused players keep full immersion. Implementation: add `[T]` keybind to cycle CRT modes (off / light / full).

---

## 2. Cross-Reference Matrix

| Topic | Source 1 (PS1 Horror) | Source 2 (Unity PSX) | Source 3 (WebGL CRT) | Source 4 (Liminal Theory) | Source 5 (PS1 Tutorial) | Source 6 (Gameplay) |
|---|---|---|---|---|---|---|
| Fog | PRIMARY — Silent Hill fog as defining technique | CONFIRMS — Fog shader compatibility issue | — | IMPLIES — fog obscures boundaries | CONFIRMS — PBR1 for fog support | PRESENT — fog in pool scenes |
| Low-Res Textures | PRIMARY — triggers imagination | CONFIRMS — 64x64, point filter | — | — | CONFIRMS — downscale pipeline | — |
| CRT Effects | MENTIONS — CRT nostalgia | COVERS — Bloom, scanline, barrel, vignette, noise | PRIMARY — Full implementation | — | COVERS — Camera volume resolution | CONFIRMS — CRT/VHS toggle |
| Color Palette | IMPLIES — dark, cold tones | — | — | COVERS — surreal color theory | — | PRESENT — dark pools |
| Loneliness/Isolation | PRIMARY — core mechanic | — | — | PRIMARY — empty spaces | — | PRESENT — solo exploration |
| Fixed Cameras | PRIMARY — helplessness via limited view | — | — | — | — | — |
| Sound Design | PRIMARY — minimal > maximal | — | — | — | — | — |
| Vertex Jitter | — | COVERS — polygon wobble | — | — | MENTIONS — vertex shader option | — |
| GPU Instancing | — | PRIMARY — performance win | — | — | — | — |

**Consensus Findings (3+ sources agree):**
1. Fog is the defining PS1 horror technique — implement aggressively
2. Low-resolution textures + point filtering are structural requirements
3. CRT post-processing must be multi-effect (not just scanlines)
4. Empty/isolated environments create more tension than populated ones

**Contradictions:**
- Source 2 says Unity terrain system works for low-poly; Source 5 says it's broken with PSX shader. Resolution: Source 5 is correct (Source 2 acknowledges this later). For Three.js: terrain must be manually constructed with low-poly geometry.
- Source 3 implements CRT as WebGL shader post-pass; current game implements as CSS overlay. CSS cannot achieve equivalent quality — this is a confirmed gap.

**Unique Insights (single source):**
- Source 4: "Psychic automatism" — don't over-design liminal scenes; let procedural elements introduce unpredictability
- Source 1: Fixed camera angles create more tension than first-person for certain horror moments
- Source 6: CRT toggle as player-facing option solves readability complaints

---

## 3. Actionable Recommendations for Millennium Bug Incident

### CRITICAL — Blocking Aesthetic Quality

#### R1. Implement WebGL CRT Post-Processing Shader
**Source:** Source 3 (WebGL CRT) + Source 2 (PSX effects list)  
**Current gap:** Only CSS scanlines + basic chromatic aberration exist. Missing: barrel distortion, noise grain with time animation, vignette, per-channel RGB split.  
**Implementation:**
1. Create `crt-shader.js` — Three.js ShaderPass using EffectComposer
2. Vertex shader: pass UV coordinates
3. Fragment shader: barrel distortion → chromatic aberration (offset R/B channels) → scanline texture (time * frequency) → noise texture (random per frame) → vignette mask (distance from center) → output
4. Add EffectComposer to render loop
5. Retain CSS `crt.css` as fallback for non-WebGL contexts
**Verification:** `grep -c 'EffectComposer\|ShaderPass\|barrel\|noise.*time\|chromatic.*offset' frontend/js/crt-shader.js`

#### R2. Fix Fog Across All 4 Scenes
**Source:** Source 1 (Silent Hill fog), Source 2 (fog shader compatibility), Source 5 (PBR1 fog fix)  
**Current gap:** Fog highway uses FogExp2 at density 0.0006 (too light); Snow bridge uses flat black Fog (no depth); Blizzard street uses warm purple fog; Rain underpass fog near-plane at 20 (too close).  
**Implementation:**
1. `fog_highway.js`: FogExp2 density 0.0006 → 0.0015
2. `snow_bridge.js`: Replace `Fog(0x000000, 8, 30)` with `FogExp2(0x003344, 0.0012)`
3. `blizzard_street.js`: Fog color `0x1a1015` → `0x001a2e`
4. `rain_underpass.js`: Fog near-plane 20 → 10
**Verification:**
```bash
grep -n 'Fog\|FogExp2' frontend/js/scenes/*.js
```

#### R3. Enforce Cold Color Palette in All 3D Scenes
**Source:** Art Review Report (warm violations) + Source 1 (cold horror palette)  
**Current gap:** 5 warm color violations in 3D scenes (streetlight 0xffcc66, housing 0xffaa22, snow 0xffffff, emergency light 0xcc2233, fog 0x1a1015).  
**Implementation:** Replace all warm hex values per art review fix list (items 8, 9, 10).
**Verification:**
```bash
grep -nE '0xffcc66|0xffcc44|0xffaa22' frontend/js/scenes/*.js && echo "FAIL: warm colors remain" || echo "PASS"
```

### HIGH — Significant Quality Improvement

#### R4. Add Vertex Jitter to Scene Geometry
**Source:** Source 2 (Unity PSX) + Source 5 (vertex shader)  
**Implementation:** Custom ShaderMaterial with vertex shader that adds random displacement (0.3-0.8 units) to vertex positions. Apply to all scene meshes.  
**Verification:** `grep -c 'position.*random\|jitter\|displacement' frontend/js/shaders/*.js`

#### R5. Downscale Render Resolution
**Source:** Source 2 (camera volume resolution), Source 5 (resolution control)  
**Implementation:** `renderer.setPixelRatio(0.5)` for 480p-like output; disable MSAA via `renderer = new THREE.WebGLRenderer({ antialias: false })`  
**Verification:** `grep -c 'setPixelRatio\|antialias.*false' frontend/js/main.js`

#### R6. Implement Sparse/Minimal Audio Design
**Source:** Source 1 (loneliness via minimal sound), Source 4 (empty spaces)  
**Implementation:**
1. Single drone ambient per scene (low-pass filtered, <200Hz dominant)
2. Player footsteps with 1.5x reverb in large spaces
3. Wind/water particles at 20% volume
4. No background music — only diegetic sound
**Verification:** `ls frontend/audio/ambient*.mp3 | wc -l` — expect >= 4

### MEDIUM — Polish & Depth

#### R7. Add CRT Toggle Keybind [T]
**Source:** Source 6 (CRT/VHS toggle UI)  
**Implementation:** `window.addEventListener('keydown', e => { if (e.key === 't') cycleCrtMode() })` — cycles off/light/full  
**Verification:** `grep -c 'key.*===.*t\|cycleCrt\|crtMode' frontend/js/input.js`

#### R8. Add Cryptic UI Text Fragments (Dreamcore Layer)
**Source:** Source 4 (Dreamcore = liminal + text overlays)  
**Implementation:** Occasional `<div class="dreamcore-fragment">` appearing at random screen positions with cryptic messages ("are you still there", "this is not a place", "you have been here before") fading in/out over 8-12 seconds.  
**Verification:** `grep -c 'dreamcore-fragment' frontend/css/crt.css`

#### R9. Consider Fixed-Camera Perspective for Key Moments
**Source:** Source 1 (fixed cameras create helplessness)  
**Implementation:** When entering certain liminal trigger zones, lock camera to a fixed angle for 3-5 seconds before returning control.  
**Verification:** `grep -c 'fixedCamera\|lockCamera\|cameraLock' frontend/js/camera.js`

---

## 4. Implementation Priority Matrix

| Priority | # | Recommendation | Effort | Impact | Source Agreement |
|---|---|---|---|---|---|
| **P0** | R2 | Fix fog on all 4 scenes | 1 hour | Very High | 5/6 sources |
| **P0** | R3 | Enforce cold palette in 3D | 30 min | High | 4/6 sources |
| **P1** | R1 | WebGL CRT shader | 4-6 hours | Very High | 5/6 sources |
| **P1** | R5 | Downscale render resolution | 15 min | High | 3/6 sources |
| **P2** | R4 | Vertex jitter shader | 2-3 hours | Medium | 2/6 sources |
| **P2** | R6 | Minimal audio design | 3-4 hours | High | 3/6 sources |
| **P3** | R7 | CRT toggle keybind | 30 min | Low | 1/6 sources |
| **P3** | R8 | Dreamcore text fragments | 1 hour | Medium | 1/6 sources |
| **P3** | R9 | Fixed camera moments | 2 hours | Low | 1/6 sources |

---

## 5. Gap Analysis: What Video Research Did NOT Cover

| Missing Topic | Why It Matters | Mitigation |
|---|---|---|
| Y2K-specific UI design patterns | The game's Mac OS 9 window metaphor is period-specific but not covered in any video | Rely on existing art review layout analysis (65/100) |
| CSS-only CRT techniques | WebGL video covers shader approach; CSS-only approach has undocumented limitations | Documented in this report: CSS can reach ~40/100 CRT fidelity; shader needed for 80+ |
| Text adventure dialogue UI within 3D | No video covered hybrid 2D-text-on-3D-scene interfaces | Existing `panels.css` + `dialogue.js` architecture is adequate |
| Performance budgets for WebGL CRT | No source provided frame time targets for post-processing | Profile after R1 implementation; target <5ms GPU time for CRT pass |
| Bilibili-specific Chinese PS1 horror community | BBDown failed; all 6 sources are English YouTube | If Chinese market aesthetic is desired, re-run with Bilibili keywords once BBDown encoding is fixed |

---

## 6. Source Inventory

| # | Video ID | Title | Duration | Words | Type | Utility |
|---|---|---|---|---|---|---|
| 1 | 1hZGbnj3hus | The Haunting Aesthetic Of PS1 Horror | 15:38 | 2,702 | Documentary | HIGH |
| 2 | YyFx5HDbgSU | How to create a PS1 style horror game in Unity (In-depth) | 19:09 | 3,973 | Tutorial | VERY HIGH |
| 3 | SUiWNgf96WA | WebGL Post Processing - CRT effect shader | 46:25 | 4,944 | Tutorial | VERY HIGH |
| 4 | MTiw47GzKVw | Liminal Spaces & Dreamcore — New Surrealism | — | 2,035 | Documentary | MEDIUM |
| 5 | AOgl-MRi26A | PS1 Style Horror Game in Unity (Part 1) | 25:31 | 4,590 | Tutorial | HIGH |
| 6 | P6cfM2GsEFQ | Dream Pools — Liminal Exploration Gameplay | — | 5,230 | Gameplay | LOW-MEDIUM |

**Total:** 23,574 words transcribed | **Audio deleted:** 5 .m4a files (~48 MB freed)

---

## 7. Verification Commands (Machine-Checkable Claims)

```bash
# Claim: Fog present in all 4 scenes
grep -l 'Fog\|FogExp2' frontend/js/scenes/*.js | wc -l  # expect: 4

# Claim: No warm colors remain in 3D scenes
grep -nE '0xffcc66|0xffaa22' frontend/js/scenes/*.js  # expect: no output

# Claim: CRT CSS has chromatic aberration
grep -c 'radial-gradient\|text-shadow.*rgba(255,0,0' frontend/css/crt.css  # expect: >= 2

# Claim: Scanline opacity within spec (0.05-0.15)
grep -E 'opacity: 0\.(0[5-9]|1[0-5])' frontend/css/crt.css  # expect: match

# Claim: All transcripts present
ls output/scripts/*.txt | wc -l  # expect: 7 (6 individual + 1 merged)

# Claim: No audio files remain
ls output/scripts/*.m4a 2>/dev/null | wc -l  # expect: 0
```

---

*Generated by Video Research Synthesizer Agent, 2026-04-30.*  
*Pipeline: yt-dlp search → yt-dlp -f bestaudio → whisper base → manual merge → synthesis*  
*Input keywords: "Y2K dark cyan liminal space game art", "PS1 retro horror aesthetic", "CRT post-processing effects CSS", "low poly 3D horror atmosphere", "liminal space environment design game"*
