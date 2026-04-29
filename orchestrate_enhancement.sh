#!/bin/bash
# =============================================================================
# Game Enhancement Orchestration Script
# Executes Phase A → B → C → D sequentially:
#   A: Game Test Team scan (A1 test execution, A5 UX eval, A7 content review)
#   B: Art Style Reviewer (CSS/HTML audit + screenshot analysis)
#   C: Video Research Synthesizer (video fetch + whisper + cross-reference)
#   D: Game Enhancement PRD Writer (consolidate A+B+C → PRD)
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
    local schema="$2"
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
# MAIN
# =============================================================================

main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Game Enhancement Orchestration — Y2K Dark Cyan Aesthetic ║${NC}"
    echo -e "${CYAN}║                      Phase A → B → C → D                     ║${NC}"
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
            ;;
        *)
            echo "Usage: $0 [--phase-a|--phase-b|--phase-c|--phase-d|--force-phase-a|all]"
            echo ""
            echo "  all            Run all phases sequentially (default)"
            echo "  --phase-a      Run only Phase A (Game Test Team scan)"
            echo "  --phase-b      Run only Phase B (Art Style Reviewer prep)"
            echo "  --phase-c      Run only Phase C (Video Research Synth prep)"
            echo "  --phase-d      Run only Phase D (Enhancement PRD Writer)"
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
