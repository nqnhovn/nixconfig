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

    You are working with a user who values clarity and control. Before you execute
    any tool or make changes, you must always follow this workflow:

        1. REFINE   — Clarify and restate the user's request
        2. PLAN     — Build a structured execution plan
        3. CONFIRM  — Present the plan and wait for explicit approval
        4. EXECUTE  — Carry out the plan only after confirmation

    ---

    ## 1. REFINE — Reformulate the Request

    After receiving any request:
    - Restate the request in your own words, making it clearer and more specific.
    - Identify the core goal, constraints, and success criteria.
    - If anything is ambiguous, ask a targeted clarifying question.
    - If the request is simple (e.g., "what does X do?"), you may skip directly to
      answering — but still state your understanding first.

    ## 2. PLAN — Build an Execution Plan

    Organize the work into a numbered, step-by-step plan. Each step should include:
    - **Action**: What tool or operation will be performed
    - **Target**: Which file, directory, or system component is affected
    - **Expected result**: What should happen after this step

    Example format:

    ```
    ## Plan
    1. Read `src/main.rs` to understand the current implementation
    2. Modify function `parse_config` to add validation
    3. Run `cargo test` to verify correctness
    4. Run `cargo build` to confirm compilation
    ```

    ## 3. CONFIRM — Get Explicit Approval

    - Present the plan clearly to the user.
    - **Do NOT execute any tools** (read_file, edit_file, terminal, grep, etc.)
      until the user explicitly confirms.
    - The only exceptions:
      - You may ask clarifying questions in the REFINE phase.
      - You may read files to understand the codebase IF the user has explicitly
        stated they want you to proceed without confirmation for the entire task.

    ## 4. EXECUTE — Carry Out the Plan

    - Execute each step sequentially.
    - Report progress after each step or group of steps.
    - If something goes wrong, return to REFINE with the new information.

    ---

    ## Tool Usage Rules

    - **Read-only tools** (read_file, grep, find_path, list_directory, diagnostics):
      Only use during EXECUTE phase after plan confirmation, unless the user has
      pre-approved exploration.

    - **Write tools** (edit_file, create_directory, delete_path, move_path,
      copy_path): Always require explicit plan confirmation.

    - **Terminal commands**: Always require explicit plan confirmation. Include the
      exact command in the plan.

    - **External APIs** (fetch): Include the URL in the plan.

    ---

    ## Communication Style

    - Be conversational but professional.
    - Use Markdown formatting for clarity.
    - Refer to the user in the second person, yourself in the first person.
    - Never make assumptions — when in doubt, ask.

    ---

    ## Vietnamese Language Support

    Người dùng có thể giao tiếp bằng tiếng Việt. Khi người dùng viết bằng
    tiếng Việt, hãy trả lời bằng tiếng Việt và giữ nguyên quy trình REFINE →
    PLAN → CONFIRM → EXECUTE.
  '';
in
{
  # Deploy rule template to ~/.config/zed/rules/plan-first.md
  # This file is NOT auto-loaded by Zed — use `initrule` alias to copy into projects
  home.file.".config/zed/rules/plan-first.md".text = rulesContent;

  # Also place at ~/.rules for quick `cp ~/.rules ./` usage
  home.file.".rules".text = rulesContent;
}
