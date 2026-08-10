---
input: "Perception is running, map to base_link is absent, and /odom might have two publishers. Diagnose this."
expect_contains: ["agv_status", "agv_validate_graph", "expected_absent", "duplicate"]
---
