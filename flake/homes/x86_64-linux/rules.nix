# =====================================================================
# HOME/RULES.NIX — AI AGENT WORKFLOW RULES (PLAN-FIRST) + 5 AGENTS
# =====================================================================
# Deploy rules globally to ~/.config/zed/rules/ for Zed Rules Library
# Cách dùng: Mở Agent Panel (Ctrl+Shift+A) → gõ @AgentName
#
# Source files: ~/.config/nixos/docs/zed-agents/*.md
# Deployed to:   ~/.config/zed/rules/*.md
#
# Architecture:
#   Orchestrator (default rule) → tự động chọn 1 trong 5 Agent:
#     PlanAgent (PO+SM), DevAgent (Code+Git), DocAgent (Docs),
#     TechAgent (Research), CicdAgent (CI/CD)

{ ... }:

let
  # ── Read agent rules from source files ────────────────────────
  orchestratorContent = builtins.readFile ../../../docs/zed-agents/orchestrator.md;
  planAgentContent    = builtins.readFile ../../../docs/zed-agents/plan-agent.md;
  devAgentContent     = builtins.readFile ../../../docs/zed-agents/dev-agent.md;
  docAgentContent     = builtins.readFile ../../../docs/zed-agents/doc-agent.md;
  techAgentContent    = builtins.readFile ../../../docs/zed-agents/tech-agent.md;
  cicdAgentContent    = builtins.readFile ../../../docs/zed-agents/cicd-agent.md;
in
{
  # ── Orchestrator (default rule) ──────────────────────────────
  home.file.".config/zed/rules/plan-first.md".text = orchestratorContent;
  home.file.".rules".text = orchestratorContent;

  # ── 5 Specialized Agents ─────────────────────────────────────
  home.file.".config/zed/rules/plan-agent.md".text  = planAgentContent;
  home.file.".config/zed/rules/dev-agent.md".text   = devAgentContent;
  home.file.".config/zed/rules/doc-agent.md".text   = docAgentContent;
  home.file.".config/zed/rules/tech-agent.md".text  = techAgentContent;
  home.file.".config/zed/rules/cicd-agent.md".text  = cicdAgentContent;
}
