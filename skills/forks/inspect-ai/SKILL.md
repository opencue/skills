---
name: inspect-ai
description: >-
  Use only while working in the a2ui project. Useful when working with the Inspect AI evaluation framework (e.g.,
  in the eval/ directory). Provides instructions on how to access Inspect AI documentation.
metadata:
  internal: true
category: forks
---

> Upstream: [NagyVikt/a2ui](https://github.com/NagyVikt/a2ui/blob/b4f91c26fcf62abc0720c21a65840220941d0a3f/.agents/skills/inspect-ai/SKILL.md). Run project-specific commands only in a checkout of that upstream project.

# Inspect AI Framework Guidelines

When you are tasked with creating, modifying, or debugging evaluation scripts (especially within the `eval/` directory) that utilize the **Inspect AI** framework, you should consult the official documentation to ensure you are using the correct APIs, solvers, scorers, and best practices.

### Documentation Source

To learn how to use Inspect AI, read the official LLM-optimized documentation guide by fetching the following URL using your `read_url_content` tool:

`https://inspect.aisi.org.uk/llms.txt`

Always reference this document when you need clarification on how Inspect AI handles task execution, scoring objects, parallelism, or tool calling architectures.
