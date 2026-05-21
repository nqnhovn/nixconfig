# 🧠 Zed AI Agent System — Kiến Trúc Đa Tác Nhân

**Version:** 2.0 · **Date:** 2026-05-20

---

## Tổng quan

Hệ thống AI Agent được thiết kế cho **Solo Coder** làm việc với phương pháp **Agile Scrum**, vận hành qua **Zed Editor Agent Panel**. Một **Orchestrator** (Meta-Agent) tự động nhận diện giai đoạn dự án và điều phối 5 Agent chuyên biệt.

## Kiến trúc

```
┌──────────────────────────────────────────────────────────┐
│                   Zed Agent Panel                         │
│                                                           │
│   👤 Solo Coder — giao tiếp tự nhiên                      │
│   🧠 Orchestrator (default rule)                          │
│                                                           │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│   │PlanAgent │  │ DevAgent  │  │ DocAgent  │              │
│   │PO + SM   │  │Code+Git  │  │ Tài liệu  │              │
│   └──────────┘  └──────────┘  └──────────┘              │
│                                                           │
│   ┌──────────┐  ┌──────────┐                              │
│   │TechAgent │  │CicdAgent │                              │
│   │Nghiên cứu│  │CI/CD+VPS │                              │
│   └──────────┘  └──────────┘                              │
└──────────────────────────────────────────────────────────┘
```

## 5 Agent

| #   | Agent         | Vai trò Scrum        | Trách nhiệm                                                   |
| --- | ------------- | -------------------- | ------------------------------------------------------------- |
| 1   | **PlanAgent** | PO + SM              | Product Backlog, Sprint Planning, Daily Scrum, Review, Retro  |
| 2   | **DevAgent**  | Developer            | Viết code, git branch, commit, PR, review                     |
| 3   | **DocAgent**  | Technical Writer     | Tài liệu kỹ thuật, API doc, README, Changelog                 |
| 4   | **TechAgent** | Architect/Researcher | Nghiên cứu công nghệ mới, đề xuất cải tiến, so sánh giải pháp |
| 5   | **CicdAgent** | DevOps               | CI/CD pipeline, deploy lên GitHub + VPS, monitoring           |

## Orchestrator — Cơ chế tự động

Orchestrator phân tích yêu cầu người dùng → xác định giai đoạn dự án → chọn Agent phù hợp:

| Giai đoạn          | Từ khóa                                                   | Agent             |
| ------------------ | --------------------------------------------------------- | ----------------- |
| 0. Khởi tạo        | "dự án mới", "bắt đầu", "khởi tạo", "vision"              | PlanAgent (PO)    |
| 1. Sprint Planning | "sprint planning", "sprint goal", "chọn story"            | PlanAgent (PO+SM) |
| 2. The Sprint      | "làm task", "code", "sửa", "fix bug", "implement"         | DevAgent          |
| 3. Daily Scrum     | "daily", "standup", "tiến độ", "blocker"                  | PlanAgent (SM)    |
| 4. Sprint Review   | "review", "demo", "kết quả sprint"                        | PlanAgent (PO+SM) |
| 5. Retrospective   | "retro", "bài học", "cải tiến"                            | PlanAgent (SM)    |
| 6. Tài liệu        | "tài liệu", "document", "readme", "api doc"               | DocAgent          |
| 7. Nghiên cứu      | "công nghệ", "so sánh", "có cách nào tốt hơn", "xu hướng" | TechAgent         |
| 8. Deploy          | "deploy", "release", "CI/CD", "push lên VPS", "pipeline"  | CicdAgent         |

## Cấu trúc file

```
~/.config/nixos/docs/zed-agents/
├── orchestrator.md       ← Orchestrator rule (Meta-Agent)
├── plan-agent.md         ← PlanAgent (PO + SM)
├── dev-agent.md          ← DevAgent (Developer)
├── doc-agent.md          ← DocAgent (Technical Writer)
├── tech-agent.md         ← TechAgent (Researcher)
└── cicd-agent.md         ← CicdAgent (DevOps)
```

Deploy bởi: `home/rules.nix` → `~/.config/zed/rules/`

## Cài đặt

```bash
home-manager switch --flake .#lg
```

Sau đó mở Zed → Agent Panel → Rules → `plan-first.md` đã được set làm default rule.

## Tài liệu liên quan

- [aichat-setup.md](./aichat-setup.md) — Hệ thống aichat CLI (RAG + Agent)
- [zed-agents/orchestrator.md](./zed-agents/orchestrator.md) — Orchestrator rule
- [plan/README.md](./zed-agents/plan/README.md) — Bộ biểu mẫu Scrum template
