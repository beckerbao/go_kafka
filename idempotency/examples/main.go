package main

import (
	"fmt"
	"log"

	"idempotency/pkg/idempotency"

	"github.com/redis/go-redis/v9"
)

func main() {
    // Thiết lập kết nối Redis
    client := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
    })

    store := idempotency.NewRedisStore(client)

    uniqueID := "message-123"// Unique identifier for the message Kafka message
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
