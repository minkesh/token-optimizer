# Token Optimizer — Multiply Marketing
## Claude Token Optimization Toolkit v1.0

> Cut Claude API costs by 70–90% with enforced habits, Graphify integration, and one-command team setup.

---

## What's Included

| File | Purpose |
|---|---|
| `install.sh` | One-command installer |
| `templates/CLAUDE.md` | Token-optimized project template |
| `hooks/session-start.sh` | Auto-injects minimal context per task type |
| `hooks/post-commit` | Auto-rebuilds Graphify graph on commit |
| `scripts/token_check.sh` | Audits CLAUDE.md & docs token usage |
| `scripts/token_stats.sh` | Dashboard: codebase health & habit reminders |
| `scripts/new_feature.sh` | Generates session prompt, picks model, checks graph |
| `docs/guide.html` | Interactive team guide (open in browser) |

## Quick Start

```bash
git clone <this-repo> ~/.token-optimizer-src
cd ~/.token-optimizer-src
bash install.sh
source ~/.zshrc
```

## Aliases Installed

```bash
newfeature     # Start an optimized Claude session
tokencheck     # Audit your project's token usage
tokenstats     # Full token health dashboard
graphrebuild   # Rebuild Graphify knowledge graph
```

## Impact Summary

| Technique | Savings |
|---|---|
| Graphify (50+ file projects) | 71x tokens per query |
| Lean CLAUDE.md (<600 tokens) | 62% per session |
| Model selection (Haiku/Sonnet/Opus) | Up to 70% cost reduction |
| Batching + diff output | 30–50% per session |
| CLI over MCP | 10–100x per tool call |

## Team Onboarding

1. Share the `docs/guide.html` file — open in any browser
2. Each developer runs `bash install.sh`
3. Copy `templates/CLAUDE.md` into every project
4. Run `graphify .` in project root (one-time per project)

---

Built with ❤️ by Multiply Marketing for teams shipping AI-powered products.
