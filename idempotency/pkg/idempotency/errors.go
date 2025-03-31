// Package idempotency định nghĩa các lỗi chung cho module.
package idempotency

import "errors"

var (
    // ErrAlreadyProcessed trả về khi message đã được xử lý.
    ErrAlreadyProcessed = errors.New("message already processed")
)
