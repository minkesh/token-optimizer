#!/usr/bin/env bash
# ============================================================
#  token_stats.sh — Show token usage stats and habits report
#  Usage: tokenstats
# ============================================================

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   Token Health Dashboard                     ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# ── File count ────────────────────────────────────────────────
TOTAL_FILES=$(find "$PROJECT_ROOT" \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l)

# Naive cost estimate (without graph)
NAIVE_COST=$((TOTAL_FILES * 500)) # ~500 tokens per file average

echo -e "  ${BOLD}Codebase:${NC} $TOTAL_FILES source files"
echo -e "  ${BOLD}Naive session cost:${NC} ~$NAIVE_COST tokens (Claude reads all files)"

# With graph
GRAPH="$PROJECT_ROOT/graphify-out/GRAPH_REPORT.md"
if [ -f "$GRAPH" ]; then
  GRAPH_TOKENS=$(wc -w < "$GRAPH" 2>/dev/null)
  GRAPH_TOKENS=$((GRAPH_TOKENS * 4 / 3))
  SAVINGS=$(( (NAIVE_COST - GRAPH_TOKENS) * 100 / (NAIVE_COST + 1) ))
  echo -e "  ${BOLD}With Graphify:${NC} ~$GRAPH_TOKENS tokens per query (${GREEN}${SAVINGS}% saved${NC})"
else
  echo -e "  ${YELLOW}  No graph — install Graphify to reduce this to ~1,700 tokens${NC}"
fi

# ── CLAUDE.md health ─────────────────────────────────────────
echo ""
echo -e "  ${BOLD}CLAUDE.md health:${NC}"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  TOKENS=$(( $(wc -w < "$CLAUDE_MD") * 4 / 3 ))
  PER_10=$(( TOKENS * 10 ))
  echo -e "  Per session (10 msgs): ~$PER_10 tokens just from CLAUDE.md"
  [ "$TOKENS" -lt 600 ]  && echo -e "  ${GREEN}✓ Lean ($TOKENS tokens)${NC}"
  [ "$TOKENS" -ge 600 ] && [ "$TOKENS" -lt 1500 ] && echo -e "  ${YELLOW}⚠ Medium ($TOKENS tokens) — consider trimming${NC}"
  [ "$TOKENS" -ge 1500 ] && echo -e "  ${RED}✗ Heavy ($TOKENS tokens) — trim urgently${NC}"
fi

# ── Good habits checklist ─────────────────────────────────────
echo ""
echo -e "  ${BOLD}Session habits checklist:${NC}"
habits=(
  "Start with /model sonnet for daily tasks"
  "Use /clear between unrelated tasks"
  "Use /compact when context feels heavy"
  "Batch multiple questions into one message"
  "Request diffs instead of full file rewrites"
  "Keep CLAUDE.md under 600 tokens"
  "Use CLI tools (gh, npm) instead of MCP where possible"
  "Run graphrebuild after big refactors"
)
for habit in "${habits[@]}"; do
  echo -e "    ${CYAN}□${NC} $habit"
done

echo ""
echo -e "  ${BOLD}Quick commands:${NC}"
echo -e "    ${CYAN}newfeature${NC}    — Start optimized session with prompt"
echo -e "    ${CYAN}tokencheck${NC}    — Audit CLAUDE.md & docs token usage"
echo -e "    ${CYAN}graphrebuild${NC}  — Rebuild Graphify knowledge graph"
echo ""
