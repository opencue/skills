---
name: agvc
description: "Use when the user asks to work on the AGV3 robot or says \"agvc\", \"AGV bringup\", \"AGV TF\", \"map to odom\", \"AGV localization\", or \"AGV mapping\". Provides guarded AGV lifecycle operations plus read-only lidar, camera, CAN, odometry, TF, and navigation diagnostics."
tags: [agv, ros2, robotics, navigation, safety]
compatibility: "Requires the AGV3 checkout and agvc; agv-mcp additionally requires Python 3."
user-invocable: true
metadata: {"author": "recodeee", "version": "2.0.0"}
---

# AGVC

Operate the AGV3 ROS 2 stack through its safety-aware project interface.

## Choose the interface

- Prefer **agv-mcp** for typed agent calls, structured results, status/doctor checks, TF lookup, topic inspection, logs, and controlled stage operations.
- Use **`agvc` CLI** for a human-reproducible command, terminal debugging, or if the MCP is unavailable. For the machine-readable agent API use `agvc agent <operation>`.
- Use generic **ros-mcp / ros-skill** only for read-only ROS inspection not exposed by AGV tooling. Never use them to bypass AGV safety gates.

## Safe workflow

1. Start read-only: `agv_status`, then `agv_doctor`. Status is stage-aware: treat an item marked `expected_absent` differently from a fault.
2. Run `agv_validate_graph` when a stage is unhealthy. Report missing graph elements, duplicate nodes/publishers, and TF ownership conflicts rather than hiding them with another publisher.
3. Bring up only the required stage. Use only the stages returned by the tool/CLI; do not invent stage names.
4. For a supported state change, call the prepare tool first. Show its exact operation and impact to the operator. Only after their explicit confirmation in the current conversation, call execute with the returned short-lived, single-use token. Never manufacture, reuse, or persist a token.
5. After execution, verify with read-only status/topic/TF evidence and use the audit result/identifier when diagnosing a failure.

## Structured diagnostics

- Preserve the status classification (`ok`, `degraded`, `expected_absent`, or `error`) and stage in reports.
- Duplicate nodes or publishers are evidence, not noise. Preserve counts and topic/node names. For TF, identify the expected owner and flag multiple writers.
- `agv_tf_lookup` returns translation, quaternion/RPY rotation, transform age/freshness, and any available ownership metadata. Check freshness and finite values before trusting it.
- `agv_topic_echo` returns parsed messages, not display YAML. Inspect the structured fields; do not parse a JSON-escaped terminal blob.
- Prefer one `agv_validate_graph` contract result over a collection of ad-hoc shell probes.

## Robot selection and audit

Robot selection is runtime configuration, not repository configuration. `AGVC_ROBOT`,
`AGVC_HOST`, `AGVC_IP`, and `AGVC_CONTAINER` may select a target. Never write
credentials or a site-specific address into the skill or MCP registry. Before a
mutation, include the resolved robot identity from prepare/status in the confirmation.

Prepare/execute operations write an audit record. Treat token and audit paths as
local runtime state, keep them out of git, and do not print token contents in prose or
logs. Audit success records authorization and outcome; it does not replace post-change
ROS verification.

## TF ownership

Treat TF as a single-writer graph:

- wheel odometry/EKF owns the odometry chain selected by project configuration;
- mapping or localization owns `map -> odom`;
- robot-state/static publishers own body and sensor links.

`map -> base_link` being absent during perception-only bringup is not by itself a YAML frame-name fault. First verify that a mapping or localization owner is running and that `odom -> base_link` exists. Do not enable a second TF publisher to hide a missing owner.

## Motion safety — hard rules

- Motor arming, `/cmd_vel`, navigation/action goals, arbitrary mutating services, and arbitrary parameter changes are **not exposed**, even with a confirmation token.
- Never bypass or weaken arm interlocks, deadman behavior, command timeouts, E-stop handling, or the `agvc`/agv-mcp confirmation gates.
- Never substitute raw `ros2 topic pub`, ros-mcp, ros-skill, SSH, or Docker commands to evade a rejected operation.
- A bare `confirmed: true`, an old token, or agent self-approval is not authorization. If operator confirmation is absent, stop after prepare and continue with read-only diagnostics only.

## Example

<example>
User: Check why `map -> base_link` is absent after perception bringup.

Action: Call `agv_status` and `agv_tf_lookup` first. Explain that perception
does not own `map -> odom`; do not enable another TF publisher or start a new
stage without confirmation.
</example>
