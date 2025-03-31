# Idempotency Module

Module này cung cấp một giải pháp idempotency để xử lý duplicate messages với độ trễ thấp, sử dụng Redis và (tuỳ chọn) local cache.

## Cấu trúc
- pkg/idempotency: Các file public API của module.
- internal/config: Các cấu hình nội bộ.
- examples: Ví dụ minh họa sử dụng module.
