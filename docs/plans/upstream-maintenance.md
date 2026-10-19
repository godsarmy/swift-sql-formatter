---
type: Maintenance Plan
title: Upstream maintenance
description: A repeatable plan for selecting, auditing, and integrating an upstream sql-formatter release.
tags: [upstream, maintenance, releases]
status: stable
generated: { by: openai/gpt-6.1-sol, at: 2026-10-19T00:58:43Z }
sources:
  - id: upstream-guide
    resource: https://github.com/godsarmy/swift-sql-formatter/blob/5ba0714fe51cc8409edd85abf8585145c843fff9/UPSTREAM.md
    title: Retired upstream maintenance guide
  - id: retired-parity-scope
    resource: "git history scope: completed upstream parity plan and reports at revision 5ba0714fe51cc8409edd85abf8585145c843fff9"
    title: Retired parity planning and reporting scope
---

# Purpose

This port follows `sql-formatter` deliberately rather than claiming identical
output for every SQL input. Select one upstream release at a time, compare
against its exact commit, and make retained differences explicit in the
affected tests or fixtures.

# Update procedure

1. Choose a release tag and resolve its immutable upstream commit.
2. Compare that commit with the previously reviewed baseline, concentrating on
   upstream implementation and test changes that affect formatter behavior.
3. Create an audit of relevant behavior changes. Port applicable inputs,
   options, and expected output into focused Swift coverage, then implement the
   Swift equivalent.
4. For affected cases, compare output with that exact upstream release. Keep a
   documented Swift expectation when a difference is intentional or follows a
   typed Swift API boundary; do not silently relabel a difference as parity.
5. Run the validation appropriate to the change. Include build and test checks;
   run the benchmark utility when performance-sensitive behavior changes.
6. Update user-facing documentation only for intentional public behavior or
   workflow changes.

# Baseline record

The last retired audit reviewed upstream `sql-formatter` v15.9.0 at
`63dc9f835cef4738ef107bf2306b20fd7e7a4d20`, compared with
`a9849494212c0a61fb6b0c1461db84e93ab2ac96`. These revisions are historical
anchors for the next audit, not a completeness claim.

Upstream tracking is manual; no scheduled synchronization is implied.
