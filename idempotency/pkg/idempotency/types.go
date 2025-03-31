// Package idempotency định nghĩa các kiểu dữ liệu và cấu hình chung.
package idempotency

// Config chứa các cấu hình cho idempotency store.
type Config struct {
    RedisAddr string // Địa chỉ Redis (ví dụ: "localhost:6379")
    TTL       int    // Thời gian sống của key, tính bằng giây.
}
