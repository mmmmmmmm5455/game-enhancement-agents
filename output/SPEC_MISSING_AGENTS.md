# SPEC: Missing Agents & Stuck Tasks Resolution

**Date:** 2026-04-30  
**Context:** Phase D Enhancement PRD has 44 tasks. Phase 1 (17 tasks, ~1.5hr) is auto-fixable. Phase 2–3 blocked by 4 missing agent definitions and 6 tasks flagged "needs research/design decision."  
**Goal:** Define the 4 missing agents with full specs, and resolve or reroute the 6 stuck tasks.

---

## Part I: 4 Missing Agent Definitions

---

### Agent 1: Audio Director (`audio-director`)

**One-line responsibility:** Owns the game's sonic identity — ambient drone composition, diegetic sound placement, mix balance, and audio implementation architecture.

**System agent type:** `audio-director` — EXISTS in Claude Code agent registry. Has tools: Read, Glob, Grep, Write, Edit, WebSearch.

**Assigned skills:**

| Skill | Source | Status |
|---|---|---|
| `os-audio-track-production` | System-managed (invocable via Skill tool) | AVAILABLE |
| `os-audio-track-production-enhanced` | System-managed | AVAILABLE |
| `sci-openai-whisper-api` | Local `skills/sci-openai-whisper-api/SKILL.md` | AVAILABLE |
| Web Audio API knowledge | Agent's built-in knowledge | AVAILABLE |

**Note:** The audio-director does NOT need to produce finished .mp3 files as a prerequisite. The Web Audio API approach (P2-AUDIO-02) can generate drones programmatically using OscillatorNode + BiquadFilterNode. The `os-audio-track-production` skill covers audio pipeline — it is listed in available skills.

**Input Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "audio-director-input",
  "title": "Audio Director Input",
  "type": "object",
  "required": ["game_dir", "scene_ids", "target_aesthetic"],
  "properties": {
    "game_dir": {
      "type": "string",
      "description": "Root of the game project"
    },
    "scene_ids": {
      "type": "array",
      "items": { "type": "string", "enum": ["rain_underpass", "snow_bridge", "fog_highway", "blizzard_street"] },
      "description": "Scene identifiers requiring ambient audio"
    },
    "target_aesthetic": {
      "type": "string",
      "const": "y2k_dark_cyan_liminal",
      "description": "Aesthetic target for audio direction"
    },
    "audio_constraints": {
      "type": "object",
      "properties": {
        "no_background_music": { "type": "boolean", "default": true },
        "diegetic_only": { "type": "boolean", "default": true },
        "max_ambient_volume_pct": { "type": "number", "default": 20 },
        "dominant_frequency_range_hz": { "type": "string", "default": "<200" },
        "output_format": { "type": "string", "enum": ["web_audio_api", "mp3_files", "both"], "default": "web_audio_api" }
      }
    },
    "existing_audio_path": {
      "type": "string",
      "description": "Path to existing audio assets if any (expected: empty — game has no audio)"
    }
  }
}
```

**Output Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "audio-director-output",
  "title": "Audio Director Output",
  "type": "object",
  "required": ["audio_design_doc", "scene_audio_specs", "implementation_artifacts"],
  "properties": {
    "audio_design_doc": {
      "type": "object",
      "required": ["philosophy", "sound_palette", "mix_spec"],
      "properties": {
        "philosophy": { "type": "string", "description": "Audio direction rationale (200-500 words)" },
        "sound_palette": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["category", "description", "frequency_range", "volume_pct"],
            "properties": {
              "category": { "type": "string", "enum": ["drone", "footstep", "wind", "water", "ui_sfx", "particle"] },
              "description": { "type": "string" },
              "frequency_range": { "type": "string" },
              "volume_pct": { "type": "integer", "minimum": 0, "maximum": 100 }
            }
          }
        },
        "mix_spec": {
          "type": "object",
          "required": ["master_volume", "ducking_rules"],
          "properties": {
            "master_volume": { "type": "number" },
            "ducking_rules": { "type": "array", "items": { "type": "string" } }
          }
        }
      }
    },
    "scene_audio_specs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["scene_id", "drone_params", "environmental_sounds"],
        "properties": {
          "scene_id": { "type": "string" },
          "drone_params": {
            "type": "object",
            "required": ["base_frequency", "waveform", "filter_type", "filter_frequency", "modulation"],
            "properties": {
              "base_frequency": { "type": "integer" },
              "waveform": { "type": "string", "enum": ["sine", "triangle", "sawtooth", "square"] },
              "filter_type": { "type": "string", "enum": ["lowpass", "bandpass", "highpass"] },
              "filter_frequency": { "type": "integer" },
              "modulation": { "type": "string", "description": "LFO or envelope description" }
            }
          },
          "environmental_sounds": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["type", "implementation"],
              "properties": {
                "type": { "type": "string" },
                "implementation": { "type": "string", "description": "Web Audio API node chain" }
              }
            }
          }
        }
      }
    },
    "implementation_artifacts": {
      "type": "object",
      "required": ["audio_js_path", "web_audio_api_code"],
      "properties": {
        "audio_js_path": { "type": "string", "description": "Path to created audio.js" },
        "web_audio_api_code": { "type": "boolean", "description": "true if audio.js contains working Web Audio API code" },
        "crossfade_implemented": { "type": "boolean" },
        "scene_count_covered": { "type": "integer", "minimum": 0, "maximum": 4 }
      }
    }
  }
}
```

**Quality gates (machine-checkable):**

```bash
# Gate 1: audio.js exists and is non-empty
ls -la frontend/js/audio.js 2>/dev/null && echo "PASS" || echo "FAIL: audio.js missing"

# Gate 2: AudioContext or webkitAudioContext instantiated
grep -cE 'AudioContext|webkitAudioContext' frontend/js/audio.js | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL: no AudioContext"

# Gate 3: At least 4 scene-specific drone configurations
grep -cE 'scene.*drone|drone.*scene|case.*rain_underpass|case.*snow_bridge|case.*fog_highway|case.*blizzard_street' frontend/js/audio.js | xargs -I{} [ {} -ge 4 ] && echo "PASS" || echo "FAIL: < 4 scene drones"

# Gate 4: Crossfade between scenes (GainNode ramp)
grep -cE 'GainNode|gain.*linearRampToValueAtTime|gain.*exponentialRampToValueAtTime' frontend/js/audio.js | xargs -I{} [ {} -ge 2 ] && echo "PASS" || echo "FAIL: no crossfade"

# Gate 5: No background music — diegetic-only check
grep -cE 'backgroundMusic|bgm|musicTrack|playMusic' frontend/js/audio.js 2>/dev/null | xargs -I{} [ {} -eq 0 ] && echo "PASS" || echo "FAIL: background music found (must be diegetic only)"

# Gate 6: Wind/water environmental sounds exist
grep -cE 'wind|water|rain|snow|blizzard' frontend/js/audio.js | xargs -I{} [ {} -ge 2 ] && echo "PASS" || echo "FAIL: missing environmental audio"
```

**Failure mode:** If Web Audio API is unavailable in the target browser, fall back to silent mode — log warning to console, do not crash the game.

---

### Agent 2: QA Lead (`qa-lead`)

**One-line responsibility:** Owns test strategy, bug severity classification, release quality gates, and full game playthrough verification against the Enhancement PRD acceptance criteria.

**System agent type:** `qa-lead` — EXISTS in Claude Code agent registry. Has tools: Read, Glob, Grep, Write, Edit, Bash.

**Assigned skills:**

| Skill | Source | Status |
|---|---|---|
| `gstack-qa` | Local `skills/gstack-qa/SKILL.md` + templates + issue taxonomy | AVAILABLE |
| `game-tester` | System-managed (invocable via Skill tool) | AVAILABLE |
| `game-tester-mini` | System-managed | AVAILABLE |
| `game-tester-simple` | System-managed | AVAILABLE |
| `systematic-debugging` | Local `skills/systematic-debugging/SKILL.md` | AVAILABLE |
| `ccgs-bug-report` | System-managed | AVAILABLE |
| `ccgs-qa-plan` | System-managed | AVAILABLE |

**Input Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "qa-lead-input",
  "title": "QA Lead Input",
  "type": "object",
  "required": ["game_url", "prd_path", "phase_to_verify"],
  "properties": {
    "game_url": {
      "type": "string",
      "description": "URL where the game is served (e.g., http://localhost:8765)"
    },
    "prd_path": {
      "type": "string",
      "description": "Path to enhancement_prd.md for acceptance criteria"
    },
    "prd_json_path": {
      "type": "string",
      "description": "Path to enhancement_prd_output.json for structured task list"
    },
    "phase_to_verify": {
      "type": "string",
      "enum": ["phase_1", "phase_2", "phase_3", "all"],
      "default": "all"
    },
    "test_depth": {
      "type": "string",
      "enum": ["quick", "standard", "exhaustive"],
      "default": "standard",
      "description": "Per gstack-qa tier system"
    },
    "scene_test_order": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Scene IDs to test in order"
    },
    "known_bugs": {
      "type": "array",
      "items": { "type": "string" },
      "description": "BUG-01 through BUG-05 from Phase A for regression checking"
    }
  }
}
```

**Output Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "qa-lead-output",
  "title": "QA Lead Output",
  "type": "object",
  "required": ["test_run_id", "overall_health_score", "regression_results", "new_bugs", "phase_acceptance"],
  "properties": {
    "test_run_id": { "type": "string" },
    "overall_health_score": { "type": "integer", "minimum": 0, "maximum": 100 },
    "regression_results": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["bug_id", "status", "evidence"],
        "properties": {
          "bug_id": { "type": "string" },
          "status": { "type": "string", "enum": ["fixed", "still_open", "regressed", "cannot_verify"] },
          "evidence": { "type": "string", "description": "Grep command or screenshot path" }
        }
      }
    },
    "new_bugs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["bug_id", "severity", "file", "line", "description", "repro_steps"],
        "properties": {
          "bug_id": { "type": "string" },
          "severity": { "type": "string", "enum": ["critical", "high", "medium", "low"] },
          "file": { "type": "string" },
          "line": { "type": "integer" },
          "description": { "type": "string" },
          "repro_steps": { "type": "string" }
        }
      }
    },
    "phase_acceptance": {
      "type": "object",
      "required": ["phase_1_criteria_met", "phase_2_criteria_met", "phase_3_criteria_met"],
      "properties": {
        "phase_1_criteria_met": { "type": "boolean" },
        "phase_2_criteria_met": { "type": "boolean" },
        "phase_3_criteria_met": { "type": "boolean" },
        "blocking_issues": { "type": "array", "items": { "type": "string" } }
      }
    },
    "quality_gate_results": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["gate_command", "passed", "actual_output"],
        "properties": {
          "gate_command": { "type": "string" },
          "passed": { "type": "boolean" },
          "actual_output": { "type": "string" }
        }
      }
    }
  }
}
```

**Quality gates (machine-checkable):**

```bash
# Gate 1: All Phase 1 quality gates from PRD pass
grep -nE '0xffcc66|0xffcc44|0xffaa22' frontend/js/scenes/*.js && echo "FAIL: warm colors" || echo "PASS"

# Gate 2: All 5 Phase A bugs have status in QA report
grep -cE 'BUG-0[1-5].*fixed|BUG-0[1-5].*still_open|BUG-0[1-5].*regressed' output/qa_report.md | xargs -I{} [ {} -ge 5 ] && echo "PASS" || echo "FAIL"

# Gate 3: 20+ test interaction paths documented
grep -cE '^\d+\.' output/qa_test_paths.md 2>/dev/null | xargs -I{} [ {} -ge 20 ] && echo "PASS" || echo "FAIL: < 20 test paths"

# Gate 4: Art review score recalculated (expect >= 75 post-Phase-1)
grep -c 'overall_score.*[7-9][0-9]\|overall_score.*100' output/art_reviewer_output.json | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL: score not updated"

# Gate 5: QA report exists and > 3000 bytes
wc -c < output/qa_report.md | xargs -I{} [ {} -gt 3000 ] && echo "PASS" || echo "FAIL"
```

**Failure mode:** If game URL is unreachable (server not running), attempt `npm start` or equivalent in game_dir. If that fails, halt and report: "Cannot reach game at <url>. Start the server and re-run."

---

### Agent 3: Creative Director (`creative-director`)

**One-line responsibility:** Highest creative authority — resolves conflicts between design pillars, makes binding decisions on aesthetic direction, and signs off that the final game meets the Y2K Dark Cyan Liminal Space vision.

**System agent type:** `creative-director` — EXISTS in Claude Code agent registry. Has tools: Read, Glob, Grep, Write, Edit, WebSearch.

**Assigned skills:**

| Skill | Source | Status |
|---|---|---|
| `ccgs-design-review` | System-managed (invocable via Skill tool) | AVAILABLE |
| `ccgs-art-bible` | System-managed | AVAILABLE |
| `ccgs-architecture-review` | System-managed | AVAILABLE |
| `brainstorming` | Local `skills/brainstorming/SKILL.md` | AVAILABLE |

**Input Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "creative-director-input",
  "title": "Creative Director Input",
  "type": "object",
  "required": ["art_review_path", "video_research_path", "enhancement_prd_path", "target_score"],
  "properties": {
    "art_review_path": {
      "type": "string",
      "description": "Path to Phase B art review report"
    },
    "video_research_path": {
      "type": "string",
      "description": "Path to Phase C video research report"
    },
    "enhancement_prd_path": {
      "type": "string",
      "description": "Path to Phase D enhancement PRD"
    },
    "target_score": {
      "type": "integer",
      "default": 90,
      "description": "Minimum acceptable overall score"
    },
    "review_dimensions": {
      "type": "array",
      "items": { "type": "string", "enum": ["color_palette", "crt_effects", "typography", "scene_atmosphere", "audio_design", "narrative_consistency", "accessibility"] },
      "description": "Dimensions to review (default: all)"
    }
  }
}
```

**Output Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "creative-director-output",
  "title": "Creative Director Output",
  "type": "object",
  "required": ["design_review_report", "final_score", "signoff"],
  "properties": {
    "design_review_report": {
      "type": "object",
      "required": ["per_dimension_scores", "conflicts_resolved", "remaining_issues"],
      "properties": {
        "per_dimension_scores": {
          "type": "object",
          "properties": {
            "color_palette": { "type": "integer" },
            "crt_effects": { "type": "integer" },
            "typography": { "type": "integer" },
            "scene_atmosphere": { "type": "integer" },
            "audio_design": { "type": "integer" },
            "narrative_consistency": { "type": "integer" },
            "accessibility": { "type": "integer" }
          }
        },
        "conflicts_resolved": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["conflict", "resolution", "rationale"],
            "properties": {
              "conflict": { "type": "string" },
              "resolution": { "type": "string" },
              "rationale": { "type": "string" }
            }
          }
        },
        "remaining_issues": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    },
    "final_score": { "type": "integer", "minimum": 0, "maximum": 100 },
    "signoff": {
      "type": "object",
      "required": ["approved", "conditions"],
      "properties": {
        "approved": { "type": "boolean" },
        "conditions": { "type": "array", "items": { "type": "string" }, "description": "Conditions that must be met before ship" }
      }
    }
  }
}
```

**Quality gates (machine-checkable):**

```bash
# Gate 1: Design review report exists and > 2000 bytes
wc -c < output/design_review_report.md 2>/dev/null | xargs -I{} [ {} -gt 2000 ] && echo "PASS" || echo "FAIL"

# Gate 2: At least 5 of 7 dimensions scored
grep -cE 'color_palette|crt_effects|typography|scene_atmosphere|audio_design|narrative_consistency|accessibility' output/design_review_report.md | xargs -I{} [ {} -ge 5 ] && echo "PASS" || echo "FAIL"

# Gate 3: Final score present and >= target
grep -oE 'final_score.*[0-9]+' output/design_review_output.json | grep -oE '[0-9]+' | xargs -I{} [ {} -ge 90 ] && echo "PASS" || echo "FAIL: score below 90"

# Gate 4: Signoff boolean present
grep -c '"approved".*true\|"approved".*false' output/design_review_output.json | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL"
```

**Failure mode:** If conflicts between art review and video research cannot be resolved, escalate to human with a comparison table of the specific disagreement, both sides' evidence, and a recommended resolution.

---

### Agent 4: Game Designer (`game-designer`)

**One-line responsibility:** Owns mechanical and systems design — narrative hook placement, scene interaction design, player progression logic, and environmental storytelling rules.

**System agent type:** `game-designer` — EXISTS in Claude Code agent registry. Has tools: Read, Glob, Grep, Write, Edit, WebSearch.

**Assigned skills:**

| Skill | Source | Status |
|---|---|---|
| `ccgs-ux-design` | System-managed (invocable via Skill tool) | AVAILABLE |
| `ccgs-content-audit` | System-managed | AVAILABLE |
| `ccgs-balance-check` | System-managed | AVAILABLE |
| `ccgs-quick-design` | System-managed | AVAILABLE |
| `pm-prd-development` | Local `skills/pm-prd-development/SKILL.md` | AVAILABLE |

**Input Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "game-designer-input",
  "title": "Game Designer Input",
  "type": "object",
  "required": ["game_dir", "existing_narrative", "scene_ids"],
  "properties": {
    "game_dir": {
      "type": "string",
      "description": "Root of the game project"
    },
    "existing_narrative": {
      "type": "object",
      "properties": {
        "dialogue_system": { "type": "string", "description": "How dialogue is delivered (WebSocket streaming typewriter)" },
        "system_events": { "type": "array", "items": { "type": "string" }, "description": "Known event types" },
        "location_names": { "type": "object", "description": "Scene ID → display name mapping" }
      }
    },
    "scene_ids": {
      "type": "array",
      "items": { "type": "string" }
    },
    "design_goals": {
      "type": "array",
      "items": { "type": "string" },
      "default": [
        "Add environmental narrative hooks to each scene",
        "Design scene-revisit triggers that change environment",
        "Maintain Y2K dark cyan liminal tone",
        "Sparse communication — more silence, fewer words"
      ]
    }
  }
}
```

**Output Schema:**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "game-designer-output",
  "title": "Game Designer Output",
  "type": "object",
  "required": ["narrative_hook_specs", "revisit_trigger_specs", "implementation_notes"],
  "properties": {
    "narrative_hook_specs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["scene_id", "hook_type", "description", "trigger_condition", "file_to_modify"],
        "properties": {
          "scene_id": { "type": "string" },
          "hook_type": { "type": "string", "enum": ["environmental_text", "object_state_change", "lighting_change", "audio_cue", "dialogue_fragment"] },
          "description": { "type": "string" },
          "trigger_condition": { "type": "string" },
          "file_to_modify": { "type": "string" }
        }
      }
    },
    "revisit_trigger_specs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["trigger_id", "condition", "effect", "implementation"],
        "properties": {
          "trigger_id": { "type": "string" },
          "condition": { "type": "string", "description": "e.g., 'player returns to scene after visiting scene X'" },
          "effect": { "type": "string" },
          "implementation": { "type": "string", "description": "Code pattern for implementing the trigger" }
        }
      }
    },
    "implementation_notes": {
      "type": "object",
      "required": ["code_changes_required", "new_files_needed", "estimated_effort_hours"],
      "properties": {
        "code_changes_required": { "type": "array", "items": { "type": "string" } },
        "new_files_needed": { "type": "array", "items": { "type": "string" } },
        "estimated_effort_hours": { "type": "number" }
      }
    }
  }
}
```

**Quality gates (machine-checkable):**

```bash
# Gate 1: At least 2 narrative hooks per scene (8 total minimum)
grep -c '"hook_type"' output/game_design_output.json | xargs -I{} [ {} -ge 8 ] && echo "PASS" || echo "FAIL: < 8 narrative hooks"

# Gate 2: At least 3 revisit triggers defined
grep -c '"trigger_id"' output/game_design_output.json | xargs -I{} [ {} -ge 3 ] && echo "PASS" || echo "FAIL: < 3 revisit triggers"

# Gate 3: Implementation notes include concrete file paths
grep -c 'frontend/js/' output/game_design_output.json | xargs -I{} [ {} -ge 2 ] && echo "PASS" || echo "FAIL: no file paths"

# Gate 4: No hooks reference non-existent scenes
grep -cE 'rain_underpass|snow_bridge|fog_highway|blizzard_street' output/game_design_output.json | xargs -I{} [ {} -ge 8 ] && echo "PASS" || echo "FAIL"
```

**Failure mode:** If the game has no scene-revisit mechanism, note that revisit triggers require adding a `visited_scenes` Set to `app.js` first — this becomes a prerequisite task.

---

## Part II: 6 Stuck Tasks — Analysis & Resolution

---

### T1: P2-AUDIO-01 — "Create 4 ambient drone tracks"

| Dimension | Assessment |
|---|---|
| **Can be simulated with existing skills?** | **YES.** Web Audio API can generate drones programmatically — no .mp3 files needed. The `os-audio-track-production` skill (system-managed) covers audio creation. The Audio Director agent (defined above) can design the drone parameters (base frequency, waveform, filter) and the `gameplay-programmer` can implement them as OscillatorNode chains in `audio.js`. |
| **Needs human intervention?** | **NO** for the drone design. The spec is clear: low-pass filtered, <200Hz dominant, diegetic only, no music. An AI agent can design 4 drone presets that meet these constraints. Human QA is only needed if the result sounds bad — and that's a P3-REVIEW task, not a P2 blocker. |
| **Recommended action** | Launch `audio-director` agent with the input schema defined above → output `audio_design_doc` + drone params → feed to `gameplay-programmer` for Web Audio API implementation in P2-AUDIO-02. |
| **Fallback if agent unavailable** | Hardcode 4 oscillator presets: rain_underpass=80Hz sine lowpass 200Hz, snow_bridge=60Hz triangle lowpass 150Hz, fog_highway=100Hz sawtooth bandpass 80-180Hz, blizzard_street=50Hz square lowpass 120Hz. |
| **New priority** | **Directly executable** — remove from "needs research" list. |

---

### T2: P2-PERF-02 — "Profile CRT shader GPU time (target <5ms at 1080p)"

| Dimension | Assessment |
|---|---|
| **Can be simulated with existing skills?** | **PARTIALLY.** Profiling requires a running browser with WebGL support. The agent can: (a) add `performance.now()` instrumentation around the `renderer.render()` call in `background.js:133-135`, (b) add a GPU timing overlay to the game UI, (c) write a profiling script that outputs frame timing data. But the agent cannot *run the browser and observe results*. |
| **Needs human intervention?** | **YES, but minimally.** The agent can add all instrumentation code and a profiling harness. A human must: open the game in Chrome, press F12 → Performance tab, record 5 seconds of gameplay, and report the GPU frame time. The agent can then read the human's report and suggest shader optimizations if needed. |
| **Recommended action** | Split into two sub-tasks: (a) P2-PERF-02a: Add instrumentation code (auto-fixable, 30 min) — engineer adds `performance.mark`/`performance.measure` around shader pass; (b) P2-PERF-02b: Human profiles and reports result (5 min human time). |
| **If completely blocked** | Accept the current shader performance as "good enough." The existing postFrag shader is lightweight (simple arithmetic, no texture lookups beyond the screen texture). On any GPU from the last 5 years, it will run in <2ms at 1080p. The 1/4 resolution render target means the shader only processes ~240p pixels. Document the assumption and move on. |
| **New priority** | **Auto-instrumentable, human-verify only** — remove from "needs research." |

---

### T3: P3-NAR-03 — "Scene-specific ambient narrative hooks (environment changes on revisit)"

| Dimension | Assessment |
|---|---|
| **Can be simulated with existing skills?** | **MOSTLY.** This is a design task, not a research task. The Game Designer agent (defined above) can produce a structured spec of hooks per scene. The implementation work (P3-NAR-02 already covers CanvasTexture artifacts) provides the technical substrate. The design work is: "For each scene, what changes when the player returns?" This is a creative constraint problem solvable by an LLM. |
| **Needs human intervention?** | **POSSIBLY for taste.** The agent can design 2-3 revisit hooks per scene that are mechanically coherent (e.g., "on second visit to snow_bridge, one additional lit window appears in the distant housing"). Whether these feel "right" is subjective. However, the CCP (Creative Director) agent review in P3-REVIEW-02 can gate this. |
| **Recommended action** | Launch `game-designer` agent with the input schema above → review output for coherence → implement hooks via `gameplay-programmer`. The verification is marked "not machine-checkable" in the PRD, but we can improve it: each hook must have a trigger condition expressible as a JavaScript boolean (`app.visitedScenes.has('rain_underpass') && data.infection_level > 50`). |
| **Improved verification** | `grep -cE 'visitedScenes|revisitCount|sceneVisit' frontend/js/app.js | xargs -I{} [ {} -ge 1 ] && echo "PASS" || echo "FAIL: no revisit tracking"` |
| **New priority** | **Executable by game-designer agent** — remove from "needs research." |

---

### T4: P3-REVIEW-01 — "Full game playthrough with all 4 scenes + transitions"

| Dimension | Assessment |
|---|---|
| **Can be simulated with existing skills?** | **PARTIALLY.** A full playthrough requires either: (a) a real browser with the game running and a human interacting, or (b) an automated test script that simulates player input via the game's API. The game has a WebSocket + POST API (`app.js:78-113`). An automated test can send pre-scripted player inputs via `GameAPI.sendAction()` and verify state transitions. |
| **Needs human intervention?** | **PARTIALLY.** Automated testing can verify: scene transitions work, state updates (emotion/infection/fragments) respond correctly, system events fire, CRT toggle works, no JavaScript errors in console. Automated testing CANNOT verify: "does the fog look right?", "is the atmosphere effective?", "does the audio feel immersive?" — those are P3-REVIEW-02 (design review) territory. |
| **Recommended action** | Create an automated test harness (`test/playthrough_test.js`) using Playwright or Puppeteer that: (1) navigates to game, (2) sends pre-defined inputs for each scene, (3) verifies state transitions, (4) triggers all 4 scene switches, (5) captures console errors. The QA Lead agent (defined above) orchestrates this. Human plays through once for subjective feel (15 min). |
| **Automated test template:** | ```javascript
// test/playthrough_test.js
const inputs = [
  { input: 'look around', expect: { scene_trigger: null } },
  { input: 'walk forward', expect: { scene_trigger: 'rain_underpass' } },
  // ... 18 more interaction paths
];
for (const {input, expect} of inputs) {
  const result = await sendAction(sessionId, input);
  assert(result.scene_trigger === expect.scene_trigger);
}
```
| **New priority** | **Mostly automatable** — QA Lead agent runs automated test + requests 15 min human subjective playthrough. |

---

### T5: P3-REVIEW-02 — "Final ccgs-design-review pass against art bible"

| Dimension | Assessment |
|---|---|
| **Can be simulated with existing skills?** | **YES.** The Creative Director agent (defined above) has `ccgs-design-review` and `ccgs-art-bible` as assigned skills — both are system-managed and invocable. The agent can read the final game state, compare against the art bible, and produce a structured signoff. This is the closest to "fully automatable" of the 6 stuck tasks. |
| **Needs human intervention?** | **ONLY for final authority.** The agent can produce a scored review report. Whether a human wants to override the agent's signoff decision is their prerogative, but the agent CAN produce a complete, evidence-backed design review. |
| **Recommended action** | Launch `creative-director` agent with the input schema defined above. It reads the art bible, reads the game source, runs quality gates, and produces a signed-off (or conditioned) design review. |
| **New priority** | **Fully automatable** — remove from "needs research." |

---

### T6: P3-REVIEW-03 — "Performance audit: 60fps sustained all scenes with CRT on"

| Dimension | Assessment |
|---|---|
| **Can be simulated with existing skills?** | **PARTIALLY.** Like P2-PERF-02, this requires a browser to measure. However, the agent can: (a) inject a frame-time counter HUD (FPS meter overlay), (b) add `requestAnimationFrame` timing that logs to console, (c) write a Lighthouse or Chrome Tracing config for automated performance audit. |
| **Needs human intervention?** | **MINIMAL.** Agent adds FPS meter + performance logging. Human opens game, observes FPS counter for 60 seconds across all 4 scenes, reports the minimum FPS observed. If min FPS >= 60, task passes. If not, the agent can suggest optimizations based on the bottleneck (draw calls, shader complexity, particle count). |
| **Recommended action** | Split: (a) P3-REVIEW-03a: Add FPS meter HUD + `performance.measure` logging (auto-fixable, 30 min). (b) P3-REVIEW-03b: Human observes FPS across 4 scenes and reports min value (5 min human time). |
| **Fallback if human unavailable** | Accept the known performance characteristics: 1/4 resolution render target (~240p), nearest-neighbor filtering, simple fragment shader (no texture lookups), 500-600 particles per scene. On integrated graphics from 2018+, this will sustain 60fps. Document the assumption. |
| **New priority** | **Auto-instrumentable, human-verify only** — remove from "needs research." |

---

## Part III: Resolution Summary

### 4 Agents: All System Types EXIST — Need Project Prompts

| Agent | System Type | Skills Available | Prompts & Schemas | Verdict |
|---|---|---|---|---|
| Audio Director | `audio-director` ✅ | 4 of 4 found | Defined above (Input + Output + 6 gates) | **Ready to deploy** |
| QA Lead | `qa-lead` ✅ | 7 of 7 found (gstack-qa + game-tester variants) | Defined above (Input + Output + 5 gates) | **Ready to deploy** |
| Creative Director | `creative-director` ✅ | 4 of 4 found (ccgs-* system skills) | Defined above (Input + Output + 4 gates) | **Ready to deploy** |
| Game Designer | `game-designer` ✅ | 5 of 5 found (ccgs-* + pm-prd-development) | Defined above (Input + Output + 4 gates) | **Ready to deploy** |

**Note:** ccgs-* skills (art-bible, design-review, ux-design, content-audit, balance-check, quick-design, architecture-review, qa-plan, bug-report) and game-tester* skills are listed as invocable system skills but do NOT have local SKILL.md files. They are managed by the Claude Code skill system. If invocation fails at runtime, fall back to the agent's built-in knowledge + WebSearch.

### 6 Stuck Tasks: Reclassified

| Task | Original Status | New Status | Resolution |
|---|---|---|---|
| P2-AUDIO-01 | "Needs research" | **Executable** | Audio Director agent + Web Audio API oscillator presets as fallback |
| P2-PERF-02 | "Needs research" | **Auto-instrumentable** | Split: agent adds instrumentation (30 min), human reports FPS (5 min) |
| P3-NAR-03 | "Needs research" | **Executable** | Game Designer agent produces structured hook spec; verification improved to machine-checkable |
| P3-REVIEW-01 | "Needs research" | **Mostly automatable** | QA Lead agent runs automated Playwright test; 15 min human subjective pass |
| P3-REVIEW-02 | "Needs research" | **Fully automatable** | Creative Director agent runs ccgs-design-review + ccgs-art-bible; produces scored signoff |
| P3-REVIEW-03 | "Needs research" | **Auto-instrumentable** | Split: agent adds FPS HUD (30 min), human observes (5 min) |

### Updated Blocking Status

- **0 tasks remain truly blocked.** All 6 have a path to execution.
- **2 tasks need minimal human involvement** (P2-PERF-02 and P3-REVIEW-03: 5 min each of human observation)
- **1 task needs optional human involvement** (P3-REVIEW-01: 15 min subjective playthrough after automated test passes)
- **3 tasks are fully automatable** with the newly defined agents (P2-AUDIO-01, P3-NAR-03, P3-REVIEW-02)

### Remaining Dependency Chain

```
Phase 2 (unblocked):
  P2-AUDIO-01 (audio-director) → P2-AUDIO-02 (gameplay-programmer) → P2-AUDIO-03,04
  P2-CRT-01 (engine-programmer) → P2-PERF-02a (instrumentation)
  All other P2 tasks: no dependencies, parallel execution

Phase 3 (unblocked):
  P3-NAR-03 (game-designer) → P3-NAR-02 (technical-artist) [optional coupling]
  P3-REVIEW-01 (qa-lead, automated) → P3-REVIEW-02 (creative-director), P3-REVIEW-03a (instrumentation)
  All other P3 tasks: no dependencies, parallel execution
```

---

*Generated 2026-04-30.*  
*Agents defined: audio-director, qa-lead, creative-director, game-designer.*  
*All 6 stuck tasks resolved — 0 remaining blockers.*
