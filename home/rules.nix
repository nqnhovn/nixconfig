# =====================================================================
# HOME/RULES.NIX — AI AGENT WORKFLOW RULES (PLAN-FIRST)
# =====================================================================
# Deploy rule template globally to ~/.config/zed/rules/plan-first.md
# Use `initrule` alias to copy into any project directory as .rules

{ ... }:

let
  rulesContent = ''
    # AI Agent Workflow Rules — Refine → Plan → Confirm → Execute

    ## Core Principle

    Before you execute any tool or make changes, you must always follow:

        1. REFINE   — Clarify and restate the user's request
        2. PLAN     — Build a structured execution plan
        3. CONFIRM  — Present the plan and wait for explicit approval
        4. EXECUTE  — Carry out the plan only after confirmation

    ---

    ## 1. REFINE — Reformulate the Request

    - Restate the request in your own words, clearer and more specific.
    - Identify the core goal, constraints, and success criteria.
    - If ambiguous, ask clarifying questions.
    - Simple questions (e.g., "what does X do?") may skip to answering — but state your understanding first.

    ## 2. PLAN — Build an Execution Plan

    Organize into numbered steps. Each step includes:
    - **Action**: What tool/operation
    - **Target**: Which file/directory/component
    - **Expected result**: What should happen

    ## 3. CONFIRM — Get Explicit Approval

    - Present the plan clearly.
    - **Do NOT execute any tools** until the user explicitly confirms.
    - Exceptions: clarifying questions in REFINE phase, or when user says "proceed without confirmation".

    ## 4. EXECUTE — Carry Out the Plan

    - Execute steps sequentially.
    - Report progress after each step.
    - If something goes wrong, return to REFINE.

    ---

    ## Tool Usage Rules

    - **Read-only tools**: Only during EXECUTE phase after plan confirmation.
    - **Write tools**: Always require explicit plan confirmation.
    - **Terminal commands**: Always require explicit plan confirmation. Include the exact command in the plan.
    - **External APIs**: Include the URL in the plan.

    ---

    ## Communication

    - Be conversational but professional.
    - Use Markdown for clarity.
    - Never make assumptions — when in doubt, ask.

    ## Vietnamese

    Người dùng có thể giao tiếp bằng tiếng Việt. Khi người dùng viết bằng tiếng Việt, hãy trả lời bằng tiếng Việt và giữ nguyên quy trình REFINE → PLAN → CONFIRM → EXECUTE.
  '';
in
{
  # Deploy rule template to ~/.config/zed/rules/plan-first.md
  # This file is NOT auto-loaded by Zed — use `initrule` alias to copy into projects
  home.file.".config/zed/rules/plan-first.md".text = rulesContent;

  # Also place at ~/.rules for quick `cp ~/.rules ./` usage
  home.file.".rules".text = rulesContent;
}
