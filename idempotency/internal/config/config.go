// Package config chứa các cấu hình nội bộ cho module idempotency.
package config

// Config là cấu hình nội bộ cho module.
type Config struct {
    RedisAddr string
    TTL       int // TTL tính bằng giây.
}
