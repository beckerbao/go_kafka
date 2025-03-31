#!/bin/bash

# Tạo thư mục gốc cho module idempotency
MODULE_DIR="idempotency"
mkdir -p "${MODULE_DIR}"

# Tạo file go.mod và README.md ở thư mục gốc
cat <<EOF > "${MODULE_DIR}/go.mod"
module github.com/yourusername/idempotency

go 1.16
EOF

cat <<EOF > "${MODULE_DIR}/README.md"
# Idempotency Module

Module này cung cấp một giải pháp idempotency để xử lý duplicate messages với độ trễ thấp, sử dụng Redis và (tuỳ chọn) local cache.

## Cấu trúc
- pkg/idempotency: Các file public API của module.
- internal/config: Các cấu hình nội bộ.
- examples: Ví dụ minh họa sử dụng module.
EOF

# Tạo thư mục pkg/idempotency và tạo các file bên trong
PKG_DIR="${MODULE_DIR}/pkg/idempotency"
mkdir -p "${PKG_DIR}"

cat <<EOF > "${PKG_DIR}/idempotency.go"
// Package idempotency cung cấp API để kiểm tra và đánh dấu các message đã được xử lý.
package idempotency

// IdempotencyChecker định nghĩa interface cho idempotency store.
type IdempotencyChecker interface {
    // CheckAndMark kiểm tra uniqueID, nếu chưa được xử lý thì đánh dấu và trả về true.
    CheckAndMark(uniqueID string, ttlSeconds int) (bool, error)
}
EOF

cat <<EOF > "${PKG_DIR}/redis_store.go"
// Package idempotency cung cấp cài đặt idempotency store sử dụng Redis.
package idempotency

import (
    "context"
    "time"

    "github.com/go-redis/redis/v8"
)

type RedisStore struct {
    client *redis.Client
}

// NewRedisStore tạo mới một RedisStore.
func NewRedisStore(client *redis.Client) *RedisStore {
    return &RedisStore{client: client}
}

// CheckAndMark thực hiện atomic check-and-set sử dụng SET NX.
func (r *RedisStore) CheckAndMark(uniqueID string, ttlSeconds int) (bool, error) {
    ctx := context.Background()
    result, err := r.client.SetNX(ctx, uniqueID, "processed", time.Duration(ttlSeconds)*time.Second).Result()
    if err != nil {
        return false, err
    }
    return result, nil
}
EOF

cat <<EOF > "${PKG_DIR}/local_cache.go"
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
EOF

cat <<EOF > "${PKG_DIR}/errors.go"
// Package idempotency định nghĩa các lỗi chung cho module.
package idempotency

import "errors"

var (
    // ErrAlreadyProcessed trả về khi message đã được xử lý.
    ErrAlreadyProcessed = errors.New("message already processed")
)
EOF

cat <<EOF > "${PKG_DIR}/types.go"
// Package idempotency định nghĩa các kiểu dữ liệu và cấu hình chung.
package idempotency

// Config chứa các cấu hình cho idempotency store.
type Config struct {
    RedisAddr string // Địa chỉ Redis (ví dụ: "localhost:6379")
    TTL       int    // Thời gian sống của key, tính bằng giây.
}
EOF

# Tạo thư mục internal/config và file config.go
INTERNAL_CONFIG_DIR="${MODULE_DIR}/internal/config"
mkdir -p "${INTERNAL_CONFIG_DIR}"

cat <<EOF > "${INTERNAL_CONFIG_DIR}/config.go"
// Package config chứa các cấu hình nội bộ cho module idempotency.
package config

// Config là cấu hình nội bộ cho module.
type Config struct {
    RedisAddr string
    TTL       int // TTL tính bằng giây.
}
EOF

# Tạo thư mục examples và file main.go
EXAMPLES_DIR="${MODULE_DIR}/examples"
mkdir -p "${EXAMPLES_DIR}"

cat <<EOF > "${EXAMPLES_DIR}/main.go"
package main

import (
    "fmt"
    "log"

    "github.com/go-redis/redis/v8"
    "github.com/yourusername/idempotency/pkg/idempotency"
    "context"
)

func main() {
    // Thiết lập kết nối Redis
    client := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
    })

    store := idempotency.NewRedisStore(client)

    uniqueID := "message-123"
    ttlSeconds := 60

    processed, err := store.CheckAndMark(uniqueID, ttlSeconds)
    if err != nil {
        log.Fatalf("Error in CheckAndMark: %v", err)
    }

    if processed {
        fmt.Println("Message được đánh dấu và sẽ được xử lý.")
        // Gọi Business Logic xử lý message ở đây.
    } else {
        fmt.Println("Message đã được xử lý trước đó, bỏ qua.")
    }
}
EOF

echo "Module idempotency đã được tạo thành công với cấu trúc thư mục và file."
