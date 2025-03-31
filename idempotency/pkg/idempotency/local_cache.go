// Package idempotency cung cấp cài đặt local cache cho idempotency (tùy chọn).
package idempotency

import (
    "sync"
    "time"
)

type LocalCache struct {
    cache map[string]time.Time
    mu    sync.RWMutex
}

// NewLocalCache tạo mới một LocalCache.
func NewLocalCache() *LocalCache {
    return &LocalCache{
        cache: make(map[string]time.Time),
    }
}

// CheckAndMark kiểm tra và đánh dấu message trong cache.
// TTL được áp dụng để tự động xoá các key cũ.
func (lc *LocalCache) CheckAndMark(uniqueID string, ttlSeconds int) (bool, error) {
    lc.mu.Lock()
    defer lc.mu.Unlock()

    now := time.Now()
    if exp, exists := lc.cache[uniqueID]; exists {
        // Nếu key tồn tại và chưa hết TTL, trả về false
        if now.Before(exp) {
            return false, nil
        }
    }
    // Đánh dấu key với TTL mới
    lc.cache[uniqueID] = now.Add(time.Duration(ttlSeconds) * time.Second)
    return true, nil
}
