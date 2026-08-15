# Logging

`LocalFileLogService` provides scoped structured technical logging through package `logging`. Records are written to bounded, rotated files under application-managed `logs/` storage. User-facing errors remain separate from raw exception details.
