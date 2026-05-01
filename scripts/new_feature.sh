#!/usr/bin/env bash
# ============================================================
#  new_feature.sh — Start a clean, token-optimized session
#  Usage: newfeature
# ============================================================

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   New Session — Token Optimizer          ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── 1. Get task description ──────────────────────────────────
read -rp "$(echo -e "${YELLOW}What are you working on? (1-2 sentences): ${NC}")" TASK_DESC
echo ""

# ── 2. Infer model recommendation ───────────────────────────
MODEL="sonnet"
echo "$TASK_DESC" | grep -iE "architect|refactor|complex|design|strategy|debug" > /dev/null 2>&1 && MODEL="opus"
echo "$TASK_DESC" | grep -iE "rename|format|typo|comment|docstring|quick" > /dev/null 2>&1 && MODEL="haiku"

echo -e "  ${GREEN}✓${NC} Recommended model: ${BOLD}$MODEL${NC}"
case "$MODEL" in
  opus)   echo -e "  ${CYAN}ℹ${NC}  Complex task detected — Opus is worth the cost" ;;
  haiku)  echo -e "  ${CYAN}ℹ${NC}  Simple task — Haiku will be faster and cheaper" ;;
  sonnet) echo -e "  ${CYAN}ℹ${NC}  Standard task — Sonnet is the best value here" ;;
esac

# ── 3. Check if CLAUDE.md exists ────────────────────────────
echo ""
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo -e "  ${YELLOW}⚠${NC}  No CLAUDE.md found. Creating from template..."
  cp "$HOME/.token-optimizer/templates/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
  echo -e "  ${GREEN}✓${NC} Created CLAUDE.md — please fill in project details"
fi

# ── 4. Check graph freshness ─────────────────────────────────
GRAPH="$PROJECT_ROOT/graphify-out/GRAPH_REPORT.md"
if [ ! -f "$GRAPH" ]; then
  FILES=$(find "$PROJECT_ROOT" -name "*.ts" -o -name "*.js" -o -name "*.py" 2>/dev/null | grep -v node_modules | wc -l)
  if [ "$FILES" -gt 20 ]; then
    echo -e "  ${YELLOW}⚠${NC}  $FILES source files, no knowledge graph."
    read -rp "$(echo -e "  Build Graphify knowledge graph now? (recommended) [y/N]: ")" build_graph
    if [[ "$build_graph" =~ ^[Yy]$ ]]; then
      echo -e "  Building graph..."
      graphify . && echo -e "  ${GREEN}✓${NC} Graph built!" || echo -e "  ${YELLOW}  Skipped (install graphify with: pip install graphifyy)${NC}"
    fi
  fi
fi

# ── 5. Generate the session prompt ───────────────────────────
echo ""
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
CHANGED=$(git diff --name-only HEAD 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/, $//')

SESSION_PROMPT="Task: $TASK_DESC

Branch: $BRANCH
$([ -n "$CHANGED" ] && echo "Recently changed files: $CHANGED")

Rules for this session:
- Use /model $MODEL
- Output diffs only, not full files
- Batch all related questions in one message
- No preamble or summaries unless asked
$([ -f "$GRAPH" ] && echo "- Knowledge graph available at graphify-out/GRAPH_REPORT.md — consult it before grepping")"

echo -e "  ${CYAN}${BOLD}Your session starter prompt:${NC}"
echo ""
echo -e "${YELLOW}────────────────────────────────────────────────${NC}"
echo "$SESSION_PROMPT"
echo -e "${YELLOW}────────────────────────────────────────────────${NC}"
echo ""

# ── 6. Copy to clipboard if possible ────────────────────────
if command -v pbcopy &>/dev/null; then
  echo "$SESSION_PROMPT" | pbcopy
  echo -e "  ${GREEN}✓${NC} Copied to clipboard — paste this into Claude Code"
elif command -v xclip &>/dev/null; then
  echo "$SESSION_PROMPT" | xclip -selection clipboard
  echo -e "  ${GREEN}✓${NC} Copied to clipboard — paste this into Claude Code"
else
  echo -e "  ${CYAN}ℹ${NC}  Copy the prompt above and paste it into Claude Code to start"
fi

echo ""
echo -e "  ${CYAN}Tip:${NC} Run ${BOLD}tokencheck${NC} mid-session to check context health"
echo ""
