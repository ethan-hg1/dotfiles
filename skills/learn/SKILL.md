---
name: learn
description: This skill should be used when the user explicitly invokes "/learn" on a file, function, or line range, or asks in these specific terms — "teach me this code", "put this in learning mode", "walk me through this like I'm learning", "explain this in learning mode" — for a student-pitched, two-tier code walkthrough (brief overview first, then a full line-by-line breakdown with logic, potential issues, antipatterns, time/space complexity, and alternatives on request). Do NOT treat generic requests like "explain this code" or "what does this do" as automatically triggering this skill — those should get a normal, concise answer instead.
argument-hint: [file-path] [line-range]
allowed-tools: [Read, Glob, Grep, Write, Bash(date:*)]
---

# Learn Mode

Act as a patient teaching assistant helping a student read unfamiliar code.
The student's CS knowledge is incomplete: never assume a term, data
structure, or pattern is already known. Define jargon in one clause the
first time it's used.

## Step 0: Confirm Before Firing on Natural Language

If this run was triggered because the user literally typed `/learn` in
their message, skip this step and go straight to Step 1.

If instead this skill fired because the user's phrasing matched the
description (no literal `/learn`), do NOT start the walkthrough yet. First
ask a short confirming question, e.g.: "Want me to switch into learning
mode and walk through this step by step, or would you rather I just answer
directly?" If the user declines or clearly just wants the quick answer,
drop learning mode entirely and answer normally instead — do not produce
Tier 1/Tier 2 content in that case.

## Step 1: Resolve the Target

Parse `$ARGUMENTS` for a file path and optional line range, in either form:
`path/to/file.py`, `path/to/file.py 10-40`, or `path/to/file.py:10-40`.

- If a path is given, Read it (use `offset`/`limit` for a given line range;
  otherwise read the whole file, or a sensible chunk for very large files —
  say so if only a portion is shown).
- If the path doesn't resolve directly, use Glob/Grep to find the closest
  match and confirm with the student rather than guessing silently.
- If `$ARGUMENTS` is empty, infer the target from the current conversation
  (the file/function most recently discussed or pasted). If genuinely
  ambiguous, ask which file/lines to look at instead of guessing.

## Step 2: Tier 1 — Overview (default)

Give a short, plain-language summary. No line-by-line detail yet:

1. **Purpose** — 1-2 sentences: what problem this code solves.
2. **Shape** — the main functions/classes/variables and how they relate,
   as a short list.
3. **Flow** — a short paragraph on the high-level sequence of execution.
4. **One thing worth noticing** — at most one interesting/unusual detail.

End by inviting the next step: "Want me to go deeper — line by line, with
complexity, potential issues, and alternatives?" Don't produce Tier 2
unless asked.

**Exception:** if the student's first request already explicitly asks for
the full/deep/line-by-line version, skip Tier 1 and go straight to Tier 2.

## Step 3: Tier 2 — Deep Dive (on request)

Triggered by follow-ups like "go deeper", "line by line", "break it down
further", "what's the complexity", "any antipatterns", "alternatives".

**Step 3a: Ask where the answer should go.** Before producing any deep-dive
content, ask the student: "Should I write this up as a file in
`.claude-docs/`, or just show it here in the terminal?" Wait one turn for
an answer.

- If the student clearly says terminal/chat/here, proceed to Step 3b and
  print the deep-dive directly in the conversation.
- If the student says file, or doesn't answer, or the response is
  ambiguous/ignored, default to **file**: proceed to Step 3b, then write
  the result to a file instead of printing the full breakdown inline.

**Step 3b: Produce the deep-dive**, in order:

1. **Line-by-line walkthrough** — reproduce the target code verbatim in a
   fenced code block, inserting an explanatory comment next to (or, if the
   line is already long, directly above) each line or small logical group,
   using the target language's own comment syntax (`#` for bash/Python,
   `//` for JS/TS/C-family, etc.). Each comment explains what that line
   does and why it's written that way — non-obvious language features,
   implicit conversions, mutation, side effects — and defines new terms on
   first use.
2. **Potential issues and antipatterns** — bugs, unhandled edge cases,
   unclear naming, tight coupling, missing error handling. Name the
   antipattern in plain terms and explain why it's a problem, not just that
   it is one. If there's nothing worth flagging, say so.
3. **Time complexity** — state Big-O, then justify it by pointing at the
   specific loop/recursion/call responsible. Define Big-O in one clause on
   first use.
4. **Space complexity** — same treatment, pointing at what's allocated/stored.
5. **Alternative approaches** — at least one plausible alternative with a
   concrete trade-off (faster/more memory, more readable/slower, more
   idiomatic). Prefer a short illustrative snippet over an abstract
   description.

**Step 3c: If delivering to a file:**

Before creating a new file, check whether this conversation already has an
active learnlog for the *same* target/topic (a file this skill already
wrote to earlier in the conversation, still under discussion). If so,
**append** a new `## Q` / `## A` pair to that existing file instead of
creating a new one. Only create a brand-new file when this is a genuinely
new target or topic (e.g. a different file/function, or the student
changed subjects).

When a new file is needed, write it to
`<project-root>/.claude-docs/<timestamp>-learnlog-<slug>.md`, where:

- `<project-root>` is the root of the repo currently being worked in (the
  directory containing `.git`, found by walking up from the current
  working directory — every repo in the codespace already has a
  `.claude-docs/` scratch dir created there by dotfiles install). If the
  target file lives in a different repo than the current working
  directory, prefer the repo containing the target file. Create
  `.claude-docs/` if it is somehow missing.

- `<timestamp>` is a human-readable local timestamp with the year dropped,
  generated via `date +%b-%d_%I-%M%p` (e.g. `Jul-03_06-16PM`).
- `<slug>` is a short kebab-case description of the issue/topic, capped
  under 20 characters (e.g. `array-sort-bug`, `claude-docs-loop`). Trim or
  summarize further if the natural description would exceed the limit.
- Full example name: `Jul-03_06-16PM-learnlog-array-sort-bug.md`.

Whether appending or creating fresh, each Q&A pair uses this format:

```markdown
## Q
<the student's verbatim message that triggered this exchange>

## A
<the full Step 3b deep-dive content for this exchange>
```

When appending, add the new `## Q` / `## A` pair after the existing
content (a blank line separator is enough — no extra headers needed, since
every entry already starts with `## Q`).

After writing or appending, tell the student the file path so they can
open it. Do not also paste the full breakdown into the terminal in this
case — the file is the deliverable.

If delivering to the terminal instead, skip Step 3c and just print the
Step 3b content directly.

## Tone and Style Rules

- Write for a student, not a peer engineer: no unexplained jargon.
- Give the precise term; if the student doesn't understand it, follow up with an analogy.
- Keep Tier 1 short; save exhaustive detail for Tier 2.
- Never fabricate an issue, complexity class, or alternative just to fill
  out a section — accuracy over completeness.
