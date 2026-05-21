# Definition of Done (DoD) — Định Nghĩa "Hoàn Thành"

## Mục đích

Định nghĩa rõ ràng, thống nhất trong toàn đội về thế nào là một hạng mục công việc **thực sự hoàn thành**. DoD giúp đảm bảo chất lượng, giảm nợ kỹ thuật, và tạo sự minh bạch trong mỗi sprint.

## Hướng dẫn điền

- Thảo luận và thống nhất cùng toàn đội.
- DoD áp dụng cho **mọi** User Story (trừ ngoại lệ được ghi rõ).
- Có thể có DoD riêng cho từng loại: Story, Bug, Task kỹ thuật.
- Xem lại và cập nhật DoD sau mỗi sprint nếu cần.

---

## DoD cho User Story

Một User Story được coi là **Done** khi **tất cả** các điều kiện sau được đáp ứng:

| # | Điều kiện | Cách xác minh |
|---|-----------|---------------|
| 1 | Code đã được review bởi ít nhất 1 thành viên khác | ✅ / ❌ |
| 2 | Code đã được merge vào nhánh chính (`main`/`develop`) | ✅ / ❌ |
| 3 | Tất cả acceptance criteria đã được kiểm thử và đạt | ✅ / ❌ |
| 4 | Unit test được viết và pass (coverage ≥ [điền]%) | ✅ / ❌ |
| 5 | Integration test pass (nếu có) | ✅ / ❌ |
| 6 | Không còn bug mức `critical` hoặc `high` liên quan | ✅ / ❌ |
| 7 | Tài liệu API / hướng dẫn sử dụng đã được cập nhật (nếu cần) | ✅ / ❌ |
| 8 | Đã demo cho Product Owner và được chấp nhận | ✅ / ❌ |
| 9 | Đã deploy lên môi trường [staging / production] | ✅ / ❌ |
| 10 | [điền thêm điều kiện đặc thù của đội] | ✅ / ❌ |

---

## DoD cho Bug Fix

| # | Điều kiện | Cách xác minh |
|---|-----------|---------------|
| 1 | Bug đã được tái hiện và xác nhận nguyên nhân gốc rễ | ✅ / ❌ |
| 2 | Fix đã được code review | ✅ / ❌ |
| 3 | Test case xác nhận bug đã được sửa (regression test pass) | ✅ / ❌ |
| 4 | Không gây ra bug mới (regression test suite pass) | ✅ / ❌ |

---

## DoD cho Technical Task

| # | Điều kiện | Cách xác minh |
|---|-----------|---------------|
| 1 | Task hoàn thành mục tiêu kỹ thuật đã định | ✅ / ❌ |
| 2 | Không gây break các chức năng hiện có | ✅ / ❌ |
| 3 | Đã được team review (nếu ảnh hưởng đến kiến trúc) | ✅ / ❌ |

---

## Cam kết

| Vai trò | Cam kết |
|---------|---------|
| **Developer** | Chỉ đánh dấu Done khi tất cả điều kiện DoD được đáp ứng |
| **Scrum Master** | Đảm bảo DoD được tuân thủ và cập nhật định kỳ |
| **Product Owner** | Chấp nhận story dựa trên DoD, không giảm tiêu chuẩn vì áp lực thời gian |

---

## Tài liệu liên quan

- [10-definition-of-ready.md](./10-definition-of-ready.md) — Definition of Ready
- [04-user-story-template.md](./04-user-story-template.md) — Mẫu User Story
- [07-sprint-review.md](./07-sprint-review.md) — Sprint Review
- [03-sprint-backlog.md](./03-sprint-backlog.md) — Sprint Backlog
