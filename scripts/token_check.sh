#!/usr/bin/env bash
# ============================================================
#  token_check.sh — Analyze token usage in project files
#  Usage: tokencheck  OR  bash token_check.sh [project_root]
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

estimate_tokens() {
  local file="$1"
  local words
  words=$(wc -w < "$file" 2>/dev/null || echo 0)
  echo $((words * 4 / 3))
}

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   Token Usage Analyzer                   ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo -e "  Project: ${BOLD}$PROJECT_ROOT${NC}"
echo ""

# ── CLAUDE.md analysis ───────────────────────────────────────
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  TOKENS=$(estimate_tokens "$CLAUDE_MD")
  STATUS="${GREEN}✓ Good${NC}"
  [ "$TOKENS" -gt 600 ]  && STATUS="${YELLOW}⚠ Getting large${NC}"
  [ "$TOKENS" -gt 1500 ] && STATUS="${RED}✗ Too large — trim it!${NC}"
  echo -e "  ${BOLD}CLAUDE.md:${NC} ~$TOKENS tokens — $STATUS"
  echo -e "  ${CYAN}Target: < 600 tokens${NC}"
  
  if [ "$TOKENS" -gt 1500 ]; then
    echo ""
    echo -e "  ${YELLOW}Suggestions to trim CLAUDE.md:${NC}"
    echo "  • Move detailed docs to separate files (docs/*.md)"
    echo "  • Replace inline rules with file references"
    echo "  • Remove completed sprint tasks"
    echo "  • Trim example code snippets"
  fi
else
  echo -e "  ${RED}✗ No CLAUDE.md found${NC}"
  echo "  Run: newfeature to initialize from template"
fi

# ── Subdirectory CLAUDE.md files ─────────────────────────────
echo ""
echo -e "  ${BOLD}Subdirectory CLAUDE.md files:${NC}"
TOTAL_SUB=0
while IFS= read -r -d '' file; do
  rel="${file#$PROJECT_ROOT/}"
  t=$(estimate_tokens "$file")
  TOTAL_SUB=$((TOTAL_SUB + t))
  STATUS="${GREEN}✓${NC}"
  [ "$t" -gt 400 ] && STATUS="${YELLOW}⚠${NC}"
  echo -e "    $STATUS $rel (~$t tokens)"
done < <(find "$PROJECT_ROOT" -name "CLAUDE.md" -not -path "$PROJECT_ROOT/CLAUDE.md" -not -path "*/node_modules/*" -print0 2>/dev/null)
[ "$TOTAL_SUB" -eq 0 ] && echo "    (none found)"

# ── Docs folder ───────────────────────────────────────────────
echo ""
echo -e "  ${BOLD}Referenced docs (loaded on demand):${NC}"
DOCS_TOTAL=0
while IFS= read -r -d '' file; do
  t=$(estimate_tokens "$file")
  DOCS_TOTAL=$((DOCS_TOTAL + t))
  rel="${file#$PROJECT_ROOT/}"
  echo -e "    ${CYAN}↳${NC} $rel (~$t tokens)"
done < <(find "$PROJECT_ROOT/docs" -name "*.md" -print0 2>/dev/null)
[ "$DOCS_TOTAL" -eq 0 ] && echo "    (no docs/ folder found)"

# ── Knowledge graph ───────────────────────────────────────────
echo ""
echo -e "  ${BOLD}Graphify status:${NC}"
GRAPH="$PROJECT_ROOT/graphify-out/GRAPH_REPORT.md"
if [ -f "$GRAPH" ]; then
  GRAPH_SIZE=$(estimate_tokens "$GRAPH")
  GRAPH_AGE=$(( ($(date +%s) - $(stat -c %Y "$GRAPH" 2>/dev/null || stat -f %m "$GRAPH" 2>/dev/null || echo 0)) / 86400 ))
  echo -e "    ${GREEN}✓${NC} Graph exists: ~$GRAPH_SIZE tokens (${GRAPH_AGE}d old)"
  echo -e "    ${CYAN}↳ Each query reads graph (~1.7k) instead of raw files${NC}"
else
  echo -e "    ${YELLOW}⚠${NC} No graph found"
  FILES=$(find "$PROJECT_ROOT" -name "*.ts" -o -name "*.js" -o -name "*.py" 2>/dev/null | grep -v node_modules | wc -l)
  if [ "$FILES" -gt 20 ]; then
    echo -e "    ${RED}  → $FILES source files detected. Graphify could save 20-70x tokens.${NC}"
    echo "    Run: graphify ."
  fi
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}  Summary:${NC}"
MAIN=$(estimate_tokens "$CLAUDE_MD" 2>/dev/null || echo 0)
TOTAL=$((MAIN + TOTAL_SUB))
echo -e "  Fixed context loaded every session: ~${BOLD}$TOTAL tokens${NC}"
[ "$TOTAL" -gt 2000 ] && echo -e "  ${RED}  Action needed: reduce to under 800 tokens${NC}"
[ "$TOTAL" -le 2000 ] && [ "$TOTAL" -gt 800 ] && echo -e "  ${YELLOW}  Could be leaner — aim for < 800 total${NC}"
[ "$TOTAL" -le 800 ]  && echo -e "  ${GREEN}  Looking good!${NC}"
echo ""
