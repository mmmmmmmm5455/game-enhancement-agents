#!/bin/bash
# =============================================================================
# Game Enhancement Orchestration Script
# Executes Phase A → B → C → D → E → F → G → H:
#   A: Game Test Team scan (A1 test execution, A5 UX eval, A7 content review)
#   B: Art Style Reviewer (CSS/HTML audit + screenshot analysis)
#   C: Video Research Synthesizer (video fetch + whisper + cross-reference)
#   D: Game Enhancement PRD Writer (consolidate A+B+C → PRD)
#   E: Audio Director (Web Audio API drones + environmental sounds)
#   F: QA Lead (regression verification + quality gates)
#   G: Creative Director (cross-phase aesthetic signoff)
#   H: Game Designer (narrative hooks + dreamcore fragments)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_DIR/output"
SCHEMAS_DIR="$PROJECT_DIR/schemas"
PROMPTS_DIR="$PROJECT_DIR/prompts"

# Ensure output directory exists BEFORE any logging
mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/orchestrate_$(date +%Y%m%d_%H%M%S).log"

# Game project paths (adjust if needed)
GAME_DIR="C:/Users/qwqwh/.claude/projects/multi-agent-plan/output"
GAME_HTML="$GAME_DIR/index.html"
GAME_CSS_DIR="$GAME_DIR/css"

# Video script extractor paths (verified 2026-04-30)
EXTRACT_SCRIPT="C:/Users/qwqwh/.claude/projects/video-script-extractor/extract-video-script.sh"
ENV_SH="C:/Users/qwqwh/.claude/video-scripts/.env.sh"

# Source environment (BBDown, yt-dlp, whisper PATH)
if [ -f "$ENV_SH" ]; then
    source "$ENV_SH"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# Utility functions
# =============================================================================

log() {
    local level="$1"; shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE"
}

log_info()  { log "INFO" "$@"; }
log_warn()  { log "${YELLOW}WARN${NC}" "$@"; }
log_error() { log "${RED}ERROR${NC}" "$@"; }
log_ok()    { log "${GREEN}OK${NC}" "$@"; }

check_prerequisite() {
    local tool="$1"
    if ! command -v "$tool" &>/dev/null; then
        log_error "Missing prerequisite: $tool"
        return 1
    fi
}

validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        log_error "Invalid JSON: $file"
        return 1
    fi
    log_ok "JSON valid: $file"
}

# =============================================================================
# Pre-flight checks
# =============================================================================

run_preflight() {
    log_info "=== PRE-FLIGHT CHECKS ==="

    mkdir -p "$OUTPUT_DIR"

    # Check required tools
    check_prerequisite "jq" || exit 1
    check_prerequisite "grep" || exit 1

    # Check input schemas exist
    local schemas=(
        "art_reviewer_input.json"
        "art_reviewer_output.json"
        "video_synth_input.json"
        "video_synth_output.json"
        "enhancement_prd_input.json"
        "enhancement_prd_output.json"
        "audio_director_input.json"
        "audio_director_output.json"
        "qa_lead_input.json"
        "qa_lead_output.json"
        "creative_director_input.json"
        "creative_director_output.json"
        "game_designer_input.json"
        "game_designer_output.json"
    )
    for schema in "${schemas[@]}"; do
        if [ ! -f "$SCHEMAS_DIR/$schema" ]; then
            log_error "Schema missing: $SCHEMAS_DIR/$schema"
            exit 1
        fi
    done

    # Check prompts exist
    local prompts=(
        "art_style_reviewer.md"
        "video_research_synth.md"
        "enhancement_prd_writer.md"
        "audio_director.md"
        "qa_lead.md"
        "creative_director.md"
        "game_designer.md"
    )
    for prompt in "${prompts[@]}"; do
        if [ ! -f "$PROMPTS_DIR/$prompt" ]; then
            log_error "Prompt missing: $PROMPTS_DIR/$prompt"
            exit 1
        fi
    done

    # Check game directory exists
    if [ ! -d "$GAME_DIR" ]; then
        log_warn "Game directory not found: $GAME_DIR"
        log_warn "Set GAME_DIR environment variable to override"
    fi

    # Check extract-video-script.sh (CRITICAL — Phase C needs this)
    if [ -f "$EXTRACT_SCRIPT" ]; then
        log_ok "extract-video-script.sh found: $EXTRACT_SCRIPT"
    else
        log_error "MISSING: $EXTRACT_SCRIPT — Phase C will fail"
        exit 1
    fi

    # Check optional tools (warn only)
    check_prerequisite "whisper" || log_warn "whisper not in PATH — video transcription will fail"
    check_prerequisite "yt-dlp" || log_warn "yt-dlp not in PATH — YouTube search will fail"
    check_prerequisite "BBDown" || log_warn "BBDown not in PATH — Bilibili search will fail"

    log_ok "Pre-flight checks complete"
}

# =============================================================================
# Phase A: Game Test Team Scan
# =============================================================================

run_phase_a() {
    log_info "=== PHASE A: Game Test Team Scan ==="

    local output="$OUTPUT_DIR/game_test_report_$(date +%Y%m%d_%H%M%S).md"

    # This phase is executed by the existing Game Test Team (A1/A5/A7 agents)
    # The orchestration script triggers it via Claude Code skill invocation.
    # If the game-tester skills are available, they produce the report directly.

    log_info "Triggering Game Test Team (A1: test execution, A5: UX eval, A7: content review)"

    # Check if game test reports already exist from a recent run
    local existing_test_report
    existing_test_report=$(ls -t "$OUTPUT_DIR"/game_test_report_*.md 2>/dev/null | head -1 || true)

    if [ -n "$existing_test_report" ]; then
        log_info "Found existing test report: $existing_test_report"
        log_info "To re-run, delete the existing report or pass --force-phase-a"
        echo "$existing_test_report"
    else
        # Placeholder: the actual invocation depends on how game-tester skills are wired
        log_info "No existing test report found. Run the following in a Claude Code window:"
        log_info "  /game-tester --game-dir \"$GAME_DIR\" --output \"$output\""
        log_info "Then re-run this orchestration script."
        echo "$output"
    fi
}

# =============================================================================
# Phase B: Art Style Reviewer
# =============================================================================

run_phase_b() {
    log_info "=== PHASE B: Art Style Reviewer ==="

    # Gather CSS files
    local css_files_json="[]"
    if [ -d "$GAME_CSS_DIR" ]; then
        local css_files
        css_files=$(find "$GAME_CSS_DIR" -name "*.css" -type f 2>/dev/null || true)
        if [ -n "$css_files" ]; then
            css_files_json=$(echo "$css_files" | jq -R -s 'split("\n") | map(select(length > 0))')
        fi
    fi
    log_info "CSS files found: $css_files_json"

    # Take screenshots with Playwright (requires page-agent or playwright)
    log_info "Capturing screenshots..."
    local screenshot_dir="$OUTPUT_DIR/screenshots"
    mkdir -p "$screenshot_dir"

    # Build input JSON
    local input_json="$OUTPUT_DIR/art_reviewer_input.json"
    jq -n \
        --arg game_dir "$GAME_DIR" \
        --arg title_ss "$screenshot_dir/title.png" \
        --arg gameplay_ss "$screenshot_dir/gameplay.png" \
        --arg dialogue_ss "$screenshot_dir/dialogue.png" \
        --arg menu_ss "$screenshot_dir/menu.png" \
        --arg html_file "$GAME_HTML" \
        --argjson css_files "$css_files_json" \
        --arg target "y2k_dark_cyan" \
        '{
            game_dir: $game_dir,
            screenshot_paths: [$title_ss, $gameplay_ss, $dialogue_ss, $menu_ss],
            target_style: $target,
            css_files: $css_files,
            html_file: $html_file,
            scene_configs: []
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "Art Reviewer input written to: $input_json"

    # Invoke the Art Style Reviewer agent
    log_info "Invoking Art Style Reviewer agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/art_style_reviewer.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/art_reviewer_output.json"
    log_info "  Report expected at: $OUTPUT_DIR/art_review_report.md"

    echo "$input_json"
}

# =============================================================================
# Phase C: Video Research Synthesizer
# =============================================================================

run_phase_c() {
    log_info "=== PHASE C: Video Research Synthesizer ==="

    # Build keywords based on research topic + art review findings
    local keywords_json
    keywords_json=$(jq -n '[
        "Y2K dark cyan aesthetic game design",
        "liminal space atmosphere 3D rendering",
        "阈限空间 游戏美学 暗青色",
        "CRT shader effect Three.js WebGL",
        "low poly horror atmosphere lighting",
        "retro UI monospace typography game",
        "Y2K 千禧年 美学 游戏 UI 设计",
        "fog volumetric lighting Three.js",
        "chromatic aberration post-processing WebGL",
        "ps1 style graphics modern game"
    ]')

    # Build input JSON
    local input_json="$OUTPUT_DIR/video_synth_input.json"
    jq -n \
        --arg topic "Y2K dark cyan liminal space game art" \
        --argjson keywords "$keywords_json" \
        --argjson sources '["youtube", "bilibili"]' \
        --argjson max 15 \
        --arg format "markdown" \
        --arg model "base" \
        --arg lang "zh" \
        '{
            research_topic: $topic,
            keyword_list: $keywords,
            sources: $sources,
            max_videos: $max,
            output_format: $format,
            model_size: $model,
            language: $lang,
            keep_video_files: false,
            game_context: {
                art_review_report_path: "",
                game_test_report_path: "",
                identified_weaknesses: []
            }
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "Video Synth input written to: $input_json"

    # Invoke the Video Research Synthesizer agent
    log_info "Invoking Video Research Synthesizer agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/video_research_synth.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/video_synth_output.json"
    log_info "  Report expected at: $OUTPUT_DIR/video_research_report.md"

    echo "$input_json"
}

# =============================================================================
# Phase D: Game Enhancement PRD Writer
# =============================================================================

run_phase_d() {
    log_info "=== PHASE D: Game Enhancement PRD Writer ==="

    local art_review_json="$OUTPUT_DIR/art_reviewer_output.json"
    local art_review_report="$OUTPUT_DIR/art_review_report.md"
    local video_synth_json="$OUTPUT_DIR/video_synth_output.json"
    local video_research_report="$OUTPUT_DIR/video_research_report.md"
    local game_test_report
    game_test_report=$(ls -t "$OUTPUT_DIR"/game_test_report_*.md 2>/dev/null | head -1 || echo "")

    # Verify inputs exist
    local missing=false
    [ -f "$art_review_json" ] || { log_error "Missing: $art_review_json"; missing=true; }
    [ -f "$art_review_report" ] || { log_error "Missing: $art_review_report"; missing=true; }
    [ -f "$video_synth_json" ] || { log_error "Missing: $video_synth_json"; missing=true; }
    [ -f "$video_research_report" ] || { log_error "Missing: $video_research_report"; missing=true; }
    if [ "$missing" = true ]; then
        log_error "Phase D cannot run — missing Phase B and/or Phase C outputs"
        log_error "Complete Phase B and Phase C first, then re-run with --phase-d"
        return 1
    fi

    # Build input JSON
    local input_json="$OUTPUT_DIR/enhancement_prd_input.json"
    jq -n \
        --arg art_json "$art_review_json" \
        --arg art_report "$art_review_report" \
        --arg vid_json "$video_synth_json" \
        --arg vid_report "$video_research_report" \
        --arg test_report "${game_test_report:-}" \
        --arg bible "" \
        --arg templates "" \
        '{
            art_review_report_path: $art_report,
            art_review_json_path: $art_json,
            video_research_report_path: $vid_report,
            video_synth_json_path: $vid_json,
            game_test_report_path: $test_report,
            ccgs_art_bible_path: $bible,
            prd_templates_dir: $templates
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "PRD Writer input written to: $input_json"

    # Invoke the Enhancement PRD Writer agent
    log_info "Invoking Game Enhancement PRD Writer agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/enhancement_prd_writer.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/enhancement_prd_output.json"
    log_info "  PRD expected at: $OUTPUT_DIR/enhancement_prd.md"

    echo "$input_json"
}

# =============================================================================
# Phase E: Audio Director
# =============================================================================

run_phase_e() {
    log_info "=== PHASE E: Audio Director ==="

    # Build input JSON
    local input_json="$OUTPUT_DIR/audio_director_input.json"
    jq -n \
        --arg game_dir "$GAME_DIR" \
        --argjson scene_ids '["fog_highway","rain_underpass","snow_bridge","blizzard_street"]' \
        --arg target "y2k_dark_cyan_liminal" \
        '{
            game_dir: $game_dir,
            scene_ids: $scene_ids,
            target_aesthetic: $target,
            audio_constraints: {
                no_background_music: true,
                diegetic_only: true,
                max_ambient_volume_pct: 20,
                dominant_frequency_range_hz: "<200",
                output_format: "web_audio_api",
                crossfade_duration_ms: 3000
            }
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "Audio Director input written to: $input_json"

    log_info "Invoking Audio Director agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/audio_director.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/audio_director_output.json"
    log_info "  Design doc expected at: $OUTPUT_DIR/audio_design.md"
    log_info "  Implementation expected at: $GAME_DIR/js/audio.js"

    echo "$input_json"
}

# =============================================================================
# Phase F: QA Lead
# =============================================================================

run_phase_f() {
    log_info "=== PHASE F: QA Lead ==="

    local prd_path="$OUTPUT_DIR/enhancement_prd.md"
    local prd_json_path="$OUTPUT_DIR/enhancement_prd_output.json"

    if [ ! -f "$prd_path" ]; then
        log_error "PRD not found: $prd_path — Phase D must complete first"
        return 1
    fi

    local phase_to_verify="${1:-phase_1}"

    # Build input JSON
    local input_json="$OUTPUT_DIR/qa_lead_input.json"
    jq -n \
        --arg game_url "http://localhost:8765" \
        --arg prd_path "$prd_path" \
        --arg prd_json_path "$prd_json_path" \
        --arg phase "$phase_to_verify" \
        --arg test_depth "standard" \
        '{
            game_url: $game_url,
            prd_path: $prd_path,
            prd_json_path: $prd_json_path,
            phase_to_verify: $phase,
            test_depth: $test_depth,
            scene_test_order: ["fog_highway","rain_underpass","snow_bridge","blizzard_street"],
            known_bugs: [
                {bug_id: "BUG-01", description: "Scene dispose() not wrapped in try/catch", severity: "critical"},
                {bug_id: "BUG-02", description: "CRT CSS/WebGL double-processing", severity: "high"},
                {bug_id: "BUG-03", description: "WebSocket timeout too generous", severity: "high"},
                {bug_id: "BUG-04", description: "Fragment counter caps at 99", severity: "medium"},
                {bug_id: "BUG-05", description: "No scene load failure handling", severity: "medium"}
            ]
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "QA Lead input written to: $input_json"

    log_info "Invoking QA Lead agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/qa_lead.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/qa_lead_output.json"
    log_info "  Report expected at: $OUTPUT_DIR/qa_test_report.md"

    echo "$input_json"
}

# =============================================================================
# Phase G: Creative Director
# =============================================================================

run_phase_g() {
    log_info "=== PHASE G: Creative Director ==="

    local art_review_json="$OUTPUT_DIR/art_reviewer_output.json"
    local art_review_report="$OUTPUT_DIR/art_review_report.md"
    local video_synth_json="$OUTPUT_DIR/video_synth_output.json"
    local video_research_report="$OUTPUT_DIR/video_research_report.md"
    local prd_path="$OUTPUT_DIR/enhancement_prd.md"
    local prd_json_path="$OUTPUT_DIR/enhancement_prd_output.json"
    local game_test_report
    game_test_report=$(ls -t "$OUTPUT_DIR"/game_test_report_*.md 2>/dev/null | head -1 || echo "")
    local audio_design_doc="$OUTPUT_DIR/audio_design.md"

    # Verify required inputs exist
    local missing=false
    [ -f "$art_review_json" ] || { log_warn "Missing: $art_review_json"; }
    [ -f "$video_synth_json" ] || { log_warn "Missing: $video_synth_json"; }
    [ -f "$prd_path" ] || { log_error "Missing: $prd_path"; missing=true; }
    if [ "$missing" = true ]; then
        log_error "Phase G cannot run — missing required Phase D output"
        return 1
    fi

    # Build input JSON
    local input_json="$OUTPUT_DIR/creative_director_input.json"
    jq -n \
        --arg art_json "$art_review_json" \
        --arg art_report "$art_review_report" \
        --arg vid_json "$video_synth_json" \
        --arg vid_report "$video_research_report" \
        --arg prd_path "$prd_path" \
        --arg prd_json "$prd_json_path" \
        --arg test_report "${game_test_report:-}" \
        --arg audio_doc "$audio_design_doc" \
        --argjson target 90 \
        '{
            art_review_path: $art_report,
            art_review_json_path: $art_json,
            video_research_path: $vid_report,
            video_research_json_path: $vid_json,
            enhancement_prd_path: $prd_path,
            enhancement_prd_json_path: $prd_json,
            game_test_report_path: $test_report,
            audio_design_doc_path: $audio_doc,
            target_score: $target,
            review_dimensions: [
                "color_palette",
                "crt_effects",
                "typography",
                "scene_atmosphere",
                "audio_design",
                "narrative_consistency",
                "accessibility"
            ]
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "Creative Director input written to: $input_json"

    log_info "Invoking Creative Director agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/creative_director.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/creative_director_output.json"
    log_info "  Report expected at: $OUTPUT_DIR/creative_review_report.md"

    echo "$input_json"
}

# =============================================================================
# Phase H: Game Designer
# =============================================================================

run_phase_h() {
    log_info "=== PHASE H: Game Designer ==="

    # Build existing_narrative from known game state
    local input_json="$OUTPUT_DIR/game_designer_input.json"
    jq -n \
        --arg game_dir "$GAME_DIR" \
        --argjson scene_ids '["rain_underpass","snow_bridge","fog_highway","blizzard_street"]' \
        '{
            game_dir: $game_dir,
            existing_narrative: {
                dialogue_system: "WebSocket streaming typewriter with POST fallback",
                system_events: [
                    "critical_infection",
                    "infection_warning",
                    "are_you_real",
                    "scene_entered",
                    "fragment_found",
                    "system_message"
                ],
                location_names: {
                    rain_underpass: "雨中地下道",
                    snow_bridge: "雪中天橋",
                    fog_highway: "霧中公路",
                    blizzard_street: "暴雪街道"
                }
            },
            scene_ids: $scene_ids,
            design_goals: [
                "Add environmental narrative hooks to each scene (2+ per scene)",
                "Design revisit triggers (3+ total) that change environment on return",
                "Integrate 8 dreamcore cryptic text fragments with trigger conditions",
                "Design glitched text mode for infection > 70%",
                "Maintain Y2K dark cyan liminal tone — sparse communication, more silence",
                "All hooks implementable in < 50 lines of JavaScript"
            ]
        }' > "$input_json"

    validate_json "$input_json" || exit 1
    log_info "Game Designer input written to: $input_json"

    log_info "Invoking Game Designer agent..."
    log_info "Paste this into a Claude Code window to execute:"
    log_info "  Read prompts/game_designer.md and execute with input: $input_json"
    log_info "  Output expected at: $OUTPUT_DIR/game_designer_output.json"
    log_info "  Spec expected at: $OUTPUT_DIR/narrative_hooks.md"

    echo "$input_json"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Game Enhancement Orchestration — Y2K Dark Cyan Aesthetic ║${NC}"
    echo -e "${CYAN}║                Phase A → B → C → D → E → F → G → H           ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    log_info "Starting orchestration at $(date)"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "Log file: $LOG_FILE"

    run_preflight

    local phase="${1:-all}"

    case "$phase" in
        --phase-a|a)
            run_phase_a
            ;;
        --phase-b|b)
            run_phase_b
            ;;
        --phase-c|c)
            run_phase_c
            ;;
        --phase-d|d)
            run_phase_d
            ;;
        --phase-e|e)
            run_phase_e
            ;;
        --phase-f|f)
            run_phase_f "${2:-phase_1}"
            ;;
        --phase-g|g)
            run_phase_g
            ;;
        --phase-h|h)
            run_phase_h
            ;;
        --force-phase-a)
            rm -f "$OUTPUT_DIR"/game_test_report_*.md
            run_phase_a
            ;;
        all|--all)
            log_info "Running all phases sequentially"

            # Phase A
            local test_report
            test_report=$(run_phase_a)
            log_ok "Phase A complete — report: $test_report"

            # Phase B
            local art_input
            art_input=$(run_phase_b)
            log_ok "Phase B input prepared — input: $art_input"
            log_warn "Phase B agent must be invoked manually in Claude Code (see above)"

            # Phase C
            local vid_input
            vid_input=$(run_phase_c)
            log_ok "Phase C input prepared — input: $vid_input"
            log_warn "Phase C agent must be invoked manually in Claude Code (see above)"

            # Phase D (only if B and C outputs exist)
            if run_phase_d; then
                log_ok "Phase D input prepared"
                log_warn "Phase D agent must be invoked manually in Claude Code (see above)"
            else
                log_error "Phase D skipped — missing Phase B/C outputs"
            fi

            # Phase E (Audio Director)
            local audio_input
            audio_input=$(run_phase_e)
            log_ok "Phase E input prepared — input: $audio_input"
            log_warn "Phase E agent must be invoked manually in Claude Code (see above)"

            # Phase F (QA Lead — runs Phase 1 verification by default)
            local qa_input
            qa_input=$(run_phase_f "phase_1")
            log_ok "Phase F input prepared — input: $qa_input"
            log_warn "Phase F agent must be invoked manually in Claude Code (see above)"

            # Phase G (Creative Director — requires D outputs, benefits from E/F)
            local cd_input
            cd_input=$(run_phase_g 2>/dev/null || echo "skipped (missing prerequisites)")
            log_ok "Phase G input prepared — input: $cd_input"
            log_warn "Phase G agent must be invoked manually in Claude Code (see above)"

            # Phase H (Game Designer)
            local gd_input
            gd_input=$(run_phase_h)
            log_ok "Phase H input prepared — input: $gd_input"
            log_warn "Phase H agent must be invoked manually in Claude Code (see above)"
            ;;
        *)
            echo "Usage: $0 [--phase-a|...|--phase-h|--force-phase-a|all]"
            echo ""
            echo "  all            Run all phases sequentially (default)"
            echo "  --phase-a      Phase A: Game Test Team scan"
            echo "  --phase-b      Phase B: Art Style Reviewer prep"
            echo "  --phase-c      Phase C: Video Research Synth prep"
            echo "  --phase-d      Phase D: Enhancement PRD Writer"
            echo "  --phase-e      Phase E: Audio Director (Web Audio API drones)"
            echo "  --phase-f      Phase F: QA Lead [phase_1|phase_2|phase_3|all]"
            echo "  --phase-g      Phase G: Creative Director (aesthetic signoff)"
            echo "  --phase-h      Phase H: Game Designer (narrative hooks)"
            echo "  --force-phase-a  Re-run Phase A even if existing report found"
            exit 1
            ;;
    esac

    echo ""
    log_info "=== ORCHESTRATION COMPLETE ==="
    log_info "Files in output directory:"
    ls -la "$OUTPUT_DIR"/*.json "$OUTPUT_DIR"/*.md 2>/dev/null || log_warn "No output files yet (agents still need manual invocation)"
    log_info "Full log: $LOG_FILE"
}

main "$@"
