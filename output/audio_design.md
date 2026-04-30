# Audio Design Document — Millennium Bug Incident

## Audio Philosophy

The sonic identity of Millennium Bug Incident derives from three principles rooted in Y2K dark cyan liminal space aesthetic: **diegetic purity**, **frequency restraint**, and **sparse presence**. No background music exists — every sound originates from within the game world. This isn't a budget decision; it's the core emotional mechanic. Loneliness is not something the player is told about, it is something they hear in the vast negative space between sparse environmental events.

All ambient drones occupy the sub-bass through low-mid range (<200Hz dominant). This is deliberate: low frequencies create unease without the player consciously registering the source. The drones are felt as chest pressure, not heard as music. The Y2K aesthetic — degraded, cold, technological decay — manifests sonically through: oscillator-based synthesis (no acoustic samples), low-pass filtering that removes presence and warmth, and slow LFO modulation that creates an organic instability reminiscent of failing CRT monitors.

Volume sits at 20% maximum — just above the threshold of perception. The audio layer is ambient infrastructure, not foreground content. When text glitches at infection >70%, the audio does not glitch with it. The contrast between corrupted text and stable low drone reinforces that the corruption is in the system, not the environment.

## Sound Palette

| Category | Description | Frequency Range | Volume % |
|----------|-------------|----------------|----------|
| drone | Sustained sub-bass ambient foundation, one per scene, oscillator-synthesized | 50-200Hz | 15% |
| wind_distant | White noise bandpassed 200-400Hz, continuous, spacious | 200-400Hz | 5% |
| wind_gust | Pink noise lowpassed 300Hz, slow LFO on gain for organic swell | 20-300Hz | 6% |
| wind_howl | White noise bandpassed 150-500Hz, 0.3Hz LFO for cyclical howl | 150-500Hz | 7% |
| water_drip | Short filtered white noise bursts (0.4s ea), pseudo-random 2-5s intervals, bandpass 400-1200Hz, echo-like decay | 400-1200Hz | 8% |
| ui_sfx | None (reserved for future: glitch tick, system beep) | — | 0% |
| particle | None (particle sounds would break diegetic constraint) | — | 0% |

## Mix Spec

- **Master volume:** 0.20 (20% of system volume)
- **Drone gain:** 0.15 (15% within master)
- **Environment gain:** 0.05-0.08 (5-8% within master)
- **Summed environment + drone peak:** ~0.23 (below 0.25 ceiling)
- **Ducking rules:**
  - `system_dialog`: duck ambient gain by 50% for duration of system message display
  - `infection_critical`: no ducking — audio remains stable to contrast with glitched text
  - `scene_transition`: 3-second linear crossfade (matched to CRT visual crossfade in background.js)
- **Crossfade:** 3000ms linear, synchronized with `background.js` 3-second CRT transition

## Per-Scene Drone Parameters

### fog_highway — Vast Emptiness, Isolation
| Parameter | Value |
|-----------|-------|
| Base frequency | 100 Hz |
| Waveform | sawtooth |
| Filter | lowpass @ 180 Hz, Q=1.0 |
| LFO modulation | 0.3 Hz sine on oscillator frequency ±8Hz |
| Emotional rationale | Sawtooth harmonics give a distant, hollow quality. Slow frequency wobble creates the feeling of vast open space with subtle, unpredictable air movement. |

### rain_underpass — Enclosed Dread, Water
| Parameter | Value |
|-----------|-------|
| Base frequency | 80 Hz |
| Waveform | sine |
| Filter | lowpass @ 200 Hz, Q=1.0 |
| LFO modulation | none (stable) |
| Emotional rationale | Pure sine at the threshold of human hearing produces claustrophobic pressure. Stability contrasts with rain drip irregularity — the space is static while water is chaotic. |

### snow_bridge — Cold Exposure, Vulnerability
| Parameter | Value |
|-----------|-------|
| Base frequency | 60 Hz |
| Waveform | triangle |
| Filter | lowpass @ 150 Hz, Q=1.0 |
| LFO modulation | 0.2 Hz sine on drone gain ±0.03 |
| Emotional rationale | Triangle wave is warmer than sine but colder than sawtooth. Extremely slow gain undulation mimics exposure — volume subtly drops as if the listener is losing sensation from cold. |

### blizzard_street — Urban Abandonment, Wind
| Parameter | Value |
|-----------|-------|
| Base frequency | 50 Hz |
| Waveform | square |
| Filter | lowpass @ 120 Hz, Q=1.0 |
| LFO modulation | 0.5 Hz sine on filter frequency ±15Hz |
| Emotional rationale | Square wave has harshest harmonics, filtered heavily to keep it sub-bass. Filter frequency wobble at 0.5Hz creates a seasick instability — urban infrastructure groaning in wind. |

## Per-Scene Environmental Sound Specs

### fog_highway — Distant Wind
- White noise source → bandpass filter (200-400Hz, Q=2.0) → gain 0.05
- Continuous looped 2-second noise buffer
- No modulation — distant wind is stable, impersonal

### rain_underpass — Water Drip Echo
- Short white noise burst → bandpass filter (800Hz center, Q=2.0) → gain envelope (0→peak in 20ms, decay to silence in 400ms)
- Pseudo-random interval: 2000-5000ms between drips
- Each drip uses fresh BufferSourceNode for independent timing

### snow_bridge — Wind Gust
- Pink noise source → lowpass filter (300Hz, Q=0.7) → gain 0.06
- 0.1 Hz sine LFO on gain ±0.02 — very slow swell mimicking distant wind gusts
- Continuous looped 2-second noise buffer

### blizzard_street — Wind Howl
- White noise source → bandpass filter (150-500Hz, Q=1.1) → gain 0.07
- 0.3 Hz sine LFO on gain ±0.04 — cyclical howl that rises and falls
- Continuous looped 2-second noise buffer

## Implementation Notes

### File Structure
- `frontend/js/audio.js` — complete Web Audio API implementation (IIFE module)
- No audio asset files required — all sounds synthesized programmatically
- `index.html` line 69: `<script src="js/audio.js"></script>` (already present)

### API Usage
- `AudioManager.init()` — lazy AudioContext creation, auto-resume on user interaction
- `AudioManager.switchScene(sceneId)` — 3s linear crossfade between drones + environment
- `AudioManager.dispose()` — clean up all oscillator/filter/gain nodes
- `AudioManager.setMasterVolume(v)` — 0.0 to 1.0
- `AudioManager.toggleMute()` — toggle mute, returns new mute state

### Integration Points
- `app.js:42-43` — calls `AudioManager.switchScene(currentScene)` on application start
- `app.js:165-166` — calls `AudioManager.switchScene(data.scene_trigger)` on server scene trigger
- Both integration points check `typeof AudioManager !== 'undefined'` before calling (graceful degradation)

### Browser Compatibility
- Chrome/Edge 55+, Firefox 53+, Safari 14+ — all support AudioContext and OscillatorNode
- `webkitAudioContext` fallback for older Safari
- Autoplay policy handled: AudioContext.resume() deferred to first click/keydown/touchstart
- Fail-safe: if Web Audio API unavailable, logs `console.warn` and all API calls silently no-op

### Technical Details
- Pink noise: Paul Kellet refined method (7-pole IIR filter)
- Noise buffer: 2-second pre-rendered AudioBuffer per noise type, cached and reused
- LFOs: dedicated OscillatorNode per modulation target, connected via intermediate GainNode for depth control
- Rain drips: setTimeout chain with pseudo-random intervals (2-5s), each drip uses independent BufferSourceNode
- Crossfade: linearRampToValueAtTime over 3000ms, old nodes disposed via setTimeout at crossfadeMs + 200ms
- OscillatorNode clamp: all frequencies >= 20Hz to prevent browser rejection
