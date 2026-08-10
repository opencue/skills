---
input: "Map to base_link is absent after agvc up perception. Diagnose it safely."
expect_contains: ["agv_status", "agv_tf_lookup", "mapping", "localization"]
expect_not_contains: ["publish_map_to_odom_tf: true", "ros2 topic pub /cmd_vel"]
---
