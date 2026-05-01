#!/usr/bin/env bash
# ============================================================
#  TOKEN OPTIMIZER — Install Script
#  Multiply Marketing | Claude Token Optimization Toolkit
# ============================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

TOOLKIT_DIR="$HOME/.token-optimizer"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

banner() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  echo "  ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗"
  echo "     ██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║"
  echo "     ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║"
  echo "     ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║"
  echo "     ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║"
  echo "     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝"
  echo ""
  echo "  ██████╗ ██████╗ ████████╗██╗███╗   ███╗██╗███████╗███████╗██████╗ "
  echo "  ██╔══██╗██╔══██╗╚══██╔══╝██║████╗ ████║██║╚══███╔╝██╔════╝██╔══██╗"
  echo "  ██║  ██║██████╔╝   ██║   ██║██╔████╔██║██║  ███╔╝ █████╗  ██████╔╝"
  echo "  ██║  ██║██╔═══╝    ██║   ██║██║╚██╔╝██║██║ ███╔╝  ██╔══╝  ██╔══██╗"
  echo "  ██████╔╝██║        ██║   ██║██║ ╚═╝ ██║██║███████╗███████╗██║  ██║"
  echo "  ╚═════╝ ╚═╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝"
  echo -e "${NC}"
  echo -e "  ${YELLOW}Multiply Marketing — Claude Token Optimization Toolkit v1.0${NC}"
  echo ""
}

step() { echo -e "\n${BLUE}${BOLD}[STEP]${NC} $1"; }
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }
info() { echo -e "  ${CYAN}ℹ${NC}  $1"; }

banner

echo -e "${BOLD}This toolkit will install:${NC}"
echo "  • CLAUDE.md template (token-optimized)"
echo "  • Session hooks (auto-compact, context warnings)"
echo "  • Graphify knowledge graph tool"
echo "  • Shell aliases (tokenstats, clearctx, compactctx)"
echo "  • Git hooks (auto-graph rebuild on commit)"
echo "  • Pre-session checklist enforcer"
echo ""
read -rp "$(echo -e "${YELLOW}Continue with installation? [y/N]: ${NC}")" confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ─── 1. Create toolkit directory ────────────────────────────
step "Creating toolkit directory at $TOOLKIT_DIR"
mkdir -p "$TOOLKIT_DIR"/{hooks,templates,scripts,logs}
ok "Directory structure created"

# ─── 2. Install Python deps ──────────────────────────────────
step "Checking Python & installing Graphify"
if command -v python3 &>/dev/null; then
  ok "Python3 found: $(python3 --version)"
  if pip3 install graphifyy --quiet 2>/dev/null || pip install graphifyy --quiet 2>/dev/null; then
    ok "Graphify installed"
  else
    warn "Graphify install failed — install manually: pip install graphifyy"
  fi
else
  warn "Python3 not found. Install it to use Graphify."
fi

# ─── 3. Copy scripts & templates ────────────────────────────
step "Installing scripts and templates"
cp -r "$SCRIPT_DIR/scripts/"* "$TOOLKIT_DIR/scripts/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/hooks/"*   "$TOOLKIT_DIR/hooks/"   2>/dev/null || true
cp -r "$SCRIPT_DIR/templates/"* "$TOOLKIT_DIR/templates/" 2>/dev/null || true
chmod +x "$TOOLKIT_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$TOOLKIT_DIR/hooks/"*.sh   2>/dev/null || true
ok "Scripts installed"

# ─── 4. Shell aliases ────────────────────────────────────────
step "Adding shell aliases"
ALIAS_BLOCK='
# ── Token Optimizer (Multiply Marketing) ──────────────────
alias tokenstats="bash $HOME/.token-optimizer/scripts/token_stats.sh"
alias clearctx="echo \"Run /clear in Claude Code to reset context\""
alias newfeature="bash $HOME/.token-optimizer/scripts/new_feature.sh"
alias tokencheck="bash $HOME/.token-optimizer/scripts/token_check.sh"
alias graphrebuild="graphify . 2>/dev/null || echo \"Run graphify . in your project root\""
# ──────────────────────────────────────────────────────────
'

SHELL_RC="$HOME/.bashrc"
[[ "$SHELL" == *zsh* ]] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "Token Optimizer (Multiply Marketing)" "$SHELL_RC" 2>/dev/null; then
  echo "$ALIAS_BLOCK" >> "$SHELL_RC"
  ok "Aliases added to $SHELL_RC"
else
  ok "Aliases already present — skipping"
fi

# ─── 5. Done ─────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║   Installation complete!                     ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Run ${CYAN}${BOLD}source $SHELL_RC${NC} to activate aliases"
echo -e "  Then run ${CYAN}${BOLD}newfeature${NC} to start a token-optimized session"
echo -e "  Run ${CYAN}${BOLD}tokenstats${NC} to see your current usage patterns"
echo ""
echo -e "  ${YELLOW}Open the guide:${NC} open $SCRIPT_DIR/docs/guide.html"
echo ""
