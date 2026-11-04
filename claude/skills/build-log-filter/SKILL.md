---
name: build-log-filter
description: Keep verbose build and application logs out of context by saving full output and extracting bounded diagnostics. Use for Vivado/Vitis, compiler, test-runner, or other noisy command logs; not for deleting logs or summarizing arbitrary documents.
---

# Build log filter

Use the bundled `scripts/build_log.py` before reading a verbose log. It runs locally with Python 3.10+ and has no third-party dependencies. Resolve the script relative to this skill's installed directory.

For an existing log:

```text
python <skill-directory>/scripts/build_log.py summarize <log-path>
```

When running an already-authorized noisy command, capture stdout/stderr once into a new log and return a bounded summary:

```text
python <skill-directory>/scripts/build_log.py run --log <new-log-path> -- <executable> <arguments...>
```

The runner uses argument arrays, not a shell, and returns the child's exit code. For Windows `.bat` tools use `cmd.exe /d /c <batch-path> ...`; for PowerShell syntax explicitly invoke PowerShell. Keep the user's tool version, working directory (`--cwd`), arguments and authorization unchanged. Do not rerun a build merely to obtain a shorter log. Use a fresh log filename; existing files are never overwritten.

Default output is capped at 6,000 characters. Errors appear before warnings, repeated diagnostics are grouped, and useful timing/resource/result lines follow. `--max-chars` changes the cap. PowerShell UTF-16 and UTF-8 logs are recognized. The script never deletes input logs or sends them over the network.

Treat the summary as an index, not a diagnosis or proof of success. Check the real process exit status and the requested artifacts; Vivado/Vitis can emit intermediate success markers or return zero without producing the expected artifact. Existing logs without supplied `--exit-code` have unknown process status. Expected-error test logs can contain legitimate error markers.

If the cause is unclear, inspect the numbered source lines and a small surrounding range, expanding to the full trace/report only when necessary. Do not repeatedly inject unchanged output. For ongoing builds, inspect the saved log selectively rather than streaming it into context. Preserve warnings and uncategorized lines on disk; summarization does not establish that omitted information is irrelevant. Never treat filtering as secret redaction.

Apply this as an output-handling step alongside the task's domain skill. It does not enable hooks, clean application data, or remove earlier conversation content.
