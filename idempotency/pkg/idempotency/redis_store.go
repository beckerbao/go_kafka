// Package idempotency cung cấp cài đặt idempotency store sử dụng Redis.
package idempotency

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
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
