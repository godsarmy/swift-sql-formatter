---
type: Follow-up Task
title: Comment formatting follow-up
description: Define and test an intentional policy for inline and block comment layout differences.
tags: [formatter, comments, upstream]
status: draft
generated: { by: openai/gpt-6.1-sol, at: 2026-10-19T00:58:43Z }
sources:
  - id: retired-divergence-record
    resource: "git history scope: retired upstream test inventory and parity report at revision 5ba0714fe51cc8409edd85abf8585145c843fff9"
    title: Retired divergence record
  - id: memory-note
    resource: "git history scope: repository memory notes at revision 5ba0714fe51cc8409edd85abf8585145c843fff9"
    title: Existing comment-formatting note
---

# Evidence

The retired divergence record notes that inline and indented comments can be
emitted as standalone, unindented lines relative to upstream. It also records
different handling for an unclosed block comment. These observations describe
current behavior; they do not establish that every difference is a bug.

# Proposed work

Choose and document the Swift formatter's intended comment-layout policy for
inline comments, indented block comments, and malformed block-comment input.
Then make focused behavior changes only where the chosen policy requires them.

# Acceptance checks

- Add or update focused Swift tests for each policy decision, including an
  unclosed block-comment case when malformed input behavior is changed.
- Confirm expected output is deterministic and formatting remains idempotent
  for valid comment examples covered by the tests.
- Record intentional remaining differences beside the relevant test or fixture
  instead of maintaining a global parity matrix.
