// Package idempotency cung cấp API để kiểm tra và đánh dấu các message đã được xử lý.
package idempotency

// IdempotencyChecker định nghĩa interface cho idempotency store.
type IdempotencyChecker interface {
    // CheckAndMark kiểm tra uniqueID, nếu chưa được xử lý thì đánh dấu và trả về true.
    CheckAndMark(uniqueID string, ttlSeconds int) (bool, error)
}
