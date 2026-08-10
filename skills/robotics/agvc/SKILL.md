---
name: agvc
description: "Use when working on the AGV3 robot or when the user says \"agvc\", \"AGV bringup\", \"AGV TF\", \"map to odom\", \"AGV localization\", \"AGV mapping\", or asks to diagnose its lidar, cameras, CAN, odometry, or navigation."
tags: [agv, ros2, robotics, navigation, safety]
compatibility: "Requires the AGV3 checkout and agvc; agv-mcp additionally requires Python 3."
user-invocable: true
metadata: {"author": "recodeee", "version": "1.0.0"}
---

# AGVC

Operate the AGV3 ROS 2 stack through its safety-aware project interface.

## Choose the interface

- Prefer **agv-mcp** for typed agent calls, structured results, status/doctor checks, TF lookup, topic inspection, logs, and controlled stage operations.
- Use **`agvc` CLI** for a human-reproducible command, terminal debugging, or if the MCP is unavailable. Prefer `--json` whenever the command supports it.
- Use generic **ros-mcp / ros-skill** only for read-only ROS inspection not exposed by AGV tooling. Never use them to bypass AGV safety gates.

## Safe workflow

1. Start read-only: `agv_status`, then `agv_doctor`; inspect rates, TF, nodes, parameters, and logs before changing anything.
2. Bring up only the required stage. Use the project's supported staged bringup (`base` → `sensors` → `perception` → mapping/localization/navigation as applicable); do not invent stage names.
3. State the intended mutation and obtain explicit operator confirmation before **every** state-changing operation, including bringup, stop, deploy, parameter changes, map save, localization, goals, and motion.
4. After an approved change, verify with read-only status/topic/TF evidence.

## TF ownership

Treat TF as a single-writer graph:

- wheel odometry/EKF owns the odometry chain selected by project configuration;
- mapping or localization owns `map -> odom`;
- robot-state/static publishers own body and sensor links.

`map -> base_link` being absent during perception-only bringup is not by itself a YAML frame-name fault. First verify that a mapping or localization owner is running and that `odom -> base_link` exists. Do not enable a second TF publisher to hide a missing owner.

## Motion safety — hard rules

- Never arm motors, publish `/cmd_vel`, send a navigation/action goal, call a mutating service, or set a parameter without explicit confirmation in the current conversation.
- Never bypass or weaken arm interlocks, deadman behavior, command timeouts, E-stop handling, or the `agvc`/agv-mcp confirmation gates.
- Never substitute raw `ros2 topic pub`, ros-mcp, ros-skill, SSH, or Docker commands to evade a rejected operation.
- If confirmation is absent, return the planned command/tool call and continue with read-only diagnostics only.
