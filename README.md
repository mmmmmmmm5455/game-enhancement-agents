# game-enhancement-agents

Automated 3-agent pipeline for analyzing and enhancing browser-based games toward the Y2K Dark Cyan Liminal Space aesthetic.

## Pipeline

```
Phase A: Game Test Team (external input)
    ↓
Phase B: Art Style Reviewer → art_review_report.md + art_reviewer_output.json
    ↓
Phase C: Video Research Synthesizer → video_research_report.md + video_synth_output.json
    ↓
Phase D: Enhancement PRD Writer → enhancement_prd.md + enhancement_prd_output.json
```

## Agents

| Agent | Role | Input | Output |
|-------|------|-------|--------|
| `art_style_reviewer` | Evaluates CSS/HTML/3D scenes against Y2K dark-cyan palette, CRT authenticity, typography | `schemas/art_reviewer_input.json` | `schemas/art_reviewer_output.json` |
| `video_research_synth` | Fetches 10-20 videos from Bilibili/YouTube via extract-video-script, transcribes with local whisper, synthesizes research report | `schemas/video_synth_input.json` | `schemas/video_synth_output.json` |
| `enhancement_prd_writer` | Merges Phase A (Game Test Team) + B + C outputs into executable 3-phase enhancement roadmap | `schemas/enhancement_prd_input.json` | `schemas/enhancement_prd_output.json` |

## Dependencies

- **extract-video-script** (for Phase C): `C:/Users/qwqwh/.claude/projects/video-script-extractor/extract-video-script.sh`
  - Requires: BBDown, yt-dlp, whisper, ffmpeg, jq
- **Game Test Team** (for Phase A): `C:/Users/qwqwh/.claude/projects/multi-agent-plan/output/test_team/`
- **ccgs-art-bible** skill (for Phase B): Y2K color palette and CRT standards reference

## Usage

```bash
# Full pipeline (Phases B + C in parallel, then Phase D)
bash orchestrate_enhancement.sh --game-dir <path> --mode full

# Single phase
bash orchestrate_enhancement.sh --game-dir <path> --mode art_review
bash orchestrate_enhancement.sh --game-dir <path> --mode video_research
bash orchestrate_enhancement.sh --game-dir <path> --mode prd_write
```

## Output

All output lands in `output/`:
- `art_review_report.md` + `art_reviewer_output.json`
- `video_research_report.md` + `video_synth_output.json`
- `enhancement_prd.md` + `enhancement_prd_output.json`
