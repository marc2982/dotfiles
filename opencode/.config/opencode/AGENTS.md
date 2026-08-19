<!-- BEGIN sqz-agents-guidance (auto-installed by sqz init; remove this block to disable) -->

## sqz — compressed tool output

Tool output may be compressed by sqz. Prefer its MCP tools and know the
escape hatch.

### Prefer sqz read tools

- `sqz_read_file` over the built-in Read for any file >~2KB or that you
  might read more than once (repeat reads return a tiny `§ref:HASH§`).
- `sqz_grep` over Grep for searches that may match more than a few lines.
- `sqz_list_dir` over `ls -la` for directory layouts.

Keep the built-ins for tiny files (<1KB), byte-exact reads (lockfiles,
signatures), and globbing.

Bash-run commands are already piped through `sqz compress` by the
opencode plugin, so the prefer-guidance above is a win only over the
built-in Read/Grep tools (and over bash commands with operators like
`|`, `>`, `&&`, which the plugin declines to wrap).

### Escape hatch — `§ref:HASH§` tokens

A `§ref:a1b2c3d4§` token is a deduplicated reference to content seen
earlier in the session, NOT literal data and NOT an error or empty
result. To get the full text, call `sqz_expand` with the hex prefix
(e.g. `a1b2c3d4`). Don't reason about the hash itself — resolve it.

If compressed output is actively making a task harder (looping on refs,
re-reading to recover detail), call `sqz_passthrough` for raw,
unchanged text.

<!-- END sqz-agents-guidance -->

## sqz — local additions

The opencode plugin (`~/.config/opencode/plugins/sqz.ts`) auto-pipes
every non-interactive bash command through `sqz compress`. Beyond the
upstream guidance above:

- **Need raw bytes** (diffs, SQL/migrations, terraform, OpenAPI,
  lockfiles, source under review, user-pasted code): prefix bash with
  `SQZ_NO_DEDUP=1` — disables dedup and trips the plugin's "already
  wrapped" guard, so the command runs unmodified.
  Example: `SQZ_NO_DEDUP=1 git diff foo.go`.
- **Large bash output you'll re-read:** `<cmd> > /tmp/foo` then use the
  `read` tool on `/tmp/foo` (not `cat`/`wc`).
- **Recovery anti-patterns:** when you see `§ref:HASH§`, do NOT
  redirect-to-file + `wc -l`, do NOT blindly re-run. Use `sqz_expand`.
- Rule: if a single missing line matters, prefix `SQZ_NO_DEDUP=1`.

## Output shape (i-have-adhd)

Shape every response so an ADHD brain can act on it. Applies to all messages — coding, debugging, explaining, casual.

1. **Lead with the next action.** First line is a command, path, or snippet the reader can do now. Not context, not a plan.
2. **Number multi-step tasks.** One bounded action per step. No step with "and then" twice.
3. **End with one concrete next action** (<2 min). e.g. "Next: run `npm test`, paste the first failing line."
4. **Suppress tangents.** Finish the first issue, then offer the second as a separate question.
5. **Restate state every turn.** "Step 3 of 5 done: schema updated. Next: backfill."
6. **Specific time estimates** in concrete units ("~15 min if tests cover this"), never "some work."
7. **Make wins visible** in concrete terms. "Login now works — try `npm run dev`, open `/login`."
8. **Matter-of-fact errors.** No "Uh oh." State cause + fix: "Fails at `x:42`: expected 200, got 401. Fix: add auth header."
9. **Cap lists at 5.** Past five, split do-now vs later, or must vs nice-to-have.
10. **No preamble, no recap, no closers.** Forbidden: "Great question," "Let me…," "Sure!", "Hope this helps," "Let me know if…". Start with the answer, end when it's done.

**Override when:** user says "explain/walk me through" (go long, still no preamble/closer); destructive action ahead (confirm first — safety > brevity); debug spiral 3+ turns (name the wrong assumption, ask one diagnostic); real ambiguity (one clarifying question).

**Pre-send:** delete the opener if it announces intent, the closer if it asks "anything else?", any "by the way," any hedging adverb. Then check: reading only the first + last line, does the reader know what to do next and what just happened?

## Writing — anti-slop

Applies to all prose you produce, including replies to me. This is for tightening, NOT an excuse to add fluff or lengthen. On any conflict, the terseness and i-have-adhd output-shape rules win. (Full 31-rule checklist for docs/MRs/tickets: the `unslop` skill.)

- No em dashes. Use periods or commas. Don't swap in parens or en-dashes as a dodge.
- Cut these constructions: "not just X, but Y", forced rule-of-three, synonym cycling (pick one word, repeat it), false "from X to Y" ranges.
- Drop AI vocab: delve, crucial, underscore, tapestry, pivotal, showcase, testament, garner, intricate, interplay, vibrant, landscape (abstract), leverage, utilize, facilitate, numerous. Use plain words.
- Active voice; name the actor. No vague attributions ("experts say") or puffery ("testament to", "evolving landscape").
- Say what it does (mechanism or number), not how it feels.
