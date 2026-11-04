"""Local, bounded build-log summaries and lossless command-output capture."""
from __future__ import annotations

import argparse
from collections import OrderedDict
import hashlib
import io
from pathlib import Path
import re
import subprocess
import sys

ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
ERROR = re.compile(
    r"^\s*(?:ERROR|FATAL(?:\s+ERROR)?)(?:\s*[:\[]|\s+-)|"
    r"\bfatal error:|:\s*error(?:\s+[A-Z]+\d+)?\s*:|"
    r"^\s*Traceback \(most recent call last\)|^\s*(?:FAILED\b|FAIL:)|"
    r"^\s*(?:\w+\.)*[A-Z]\w*(?:Error|Exception):|"
    r"^\s*\S*(?:_ERROR|_FAILED)\b|\*\*\*.*(?:Error|Stop\.)|"
    r"^\s*(?:Build|Compilation|Synthesis|Implementation)\s+(?:has\s+)?failed\b",
    re.I,
)
WARNING = re.compile(r"^\s*(?:CRITICAL\s+WARNING|WARNING)(?:\s*[:\[]|\s+-)|:\s*warning\b", re.I)
KEY = re.compile(
    r"\b(?:WNS|TNS|WHS|THS)\b|\b(?:LUTs?|Slice Registers|DSPs?|Block RAM|BRAM)\s*\||"
    r"\b(?:passed|failed|errors?|warnings?)\s*[:=]\s*\d+|"
    r"\b\d+\s+(?:passed|failed|errors?|warnings?)\b|"
    r"\b(?:TEST_\w+_OK|TEST_ELF(?:_SIZE)?|Total elapsed|Elapsed time)\b|"
    r"\b(?:completed successfully|build succeeded|build failed|design Complete!|write_bitstream Complete!)",
    re.I,
)
TIMESTAMP = re.compile(r"^\s*(?:\d{4}-\d\d-\d\d[ T])?\d\d:\d\d:\d\d(?:[.,]\d+)?\s*")


def open_log(path: Path):
    raw = path.open("rb")
    prefix = raw.read(512)
    raw.seek(0)
    if prefix.startswith((b"\xff\xfe", b"\xfe\xff")):
        encoding = "utf-16"
    elif prefix.startswith(b"\xef\xbb\xbf"):
        encoding = "utf-8-sig"
    elif prefix and prefix.count(b"\x00") > len(prefix) // 4:
        encoding = "utf-16-be" if prefix[:1] == b"\x00" else "utf-16-le"
    else:
        encoding = "utf-8"
    return io.TextIOWrapper(raw, encoding=encoding, errors="replace")


def analyze(path: Path):
    groups = {"Errors": OrderedDict(), "Warnings": OrderedDict(), "Key lines": OrderedDict()}
    totals = {key: 0 for key in groups}
    overflow = {key: 0 for key in groups}
    line_count = char_count = 0
    pending = None
    with open_log(path) as stream:
        for number, raw in enumerate(stream, 1):
            line_count = number
            char_count += len(raw)
            line = ANSI.sub("", raw).strip()
            if not line:
                continue
            category = "Errors" if ERROR.search(line) else "Warnings" if WARNING.search(line) else "Key lines" if KEY.search(line) else None
            if category is None:
                if pending is not None:
                    previous_category, previous_key, remaining = pending
                    if re.match(r"^(?:INFO\s*[:\[]|\s*$)", line, re.I):
                        pending = None
                    else:
                        record = groups[previous_category][previous_key]
                        fragment = line[:350]
                        if fragment not in record[2] and len(record[2]) < 900:
                            record[2] += f"\n    L{number}: " + fragment
                        pending = (previous_category, previous_key, remaining - 1) if remaining > 1 else None
                continue
            totals[category] += 1
            # Preserve IDs, paths and line numbers; only ignore leading timestamps.
            key = hashlib.sha256(TIMESTAMP.sub("", line).encode("utf-8")).digest()
            retained = groups[category]
            if key in retained:
                retained[key][1] += 1
            elif len(retained) < 200:
                retained[key] = [number, 1, line[:500]]
            else:
                overflow[category] += 1
            pending = (category, key, 2) if category in ("Errors", "Warnings") and key in retained else None
    return {"path": str(path.resolve()), "lines": line_count, "characters": char_count,
            "groups": groups, "totals": totals, "overflow": overflow}


def render(data, exit_code=None, max_chars=6000):
    totals = data["totals"]
    if exit_code is None:
        status = "Process exit unknown; log markers are not proof of success."
    elif exit_code != 0:
        status = f"FAILED: process exit {exit_code}."
    elif totals["Errors"]:
        status = "Process exit 0, but error markers need review."
    else:
        status = "Process exit 0; verify expected build artifacts."
    lines = [status, f"Full log: {data['path']}",
             f"Input: {data['lines']} lines, {data['characters']} decoded characters.",
             f"Markers: {totals['Errors']} error, {totals['Warnings']} warning, {totals['Key lines']} key-line occurrences."]
    for category, groups in data["groups"].items():
        if not groups:
            continue
        lines.append(f"{category} ({len(groups)} retained unique groups):")
        for number, count, text in groups.values():
            repeat = f" [x{count}]" if count > 1 else ""
            lines.append(f"  L{number}{repeat}: {text}")
        if data["overflow"][category]:
            lines.append(f"  {data['overflow'][category]} further unmatched occurrences retained only in full log.")
    if not any(totals.values()):
        lines.append("No recognized markers. Inspect a targeted log range for this tool's output format.")
    footer = "\nSummary is selective; original log is unchanged. Inspect referenced lines when needed."
    body = "\n".join(lines)
    if len(body) + len(footer) > max_chars:
        footer = "\n[Summary truncated to output limit; inspect full log for omitted details.]"
        body = body[:max_chars - len(footer)]
    return body + footer


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="mode", required=True)
    summary = commands.add_parser("summarize", help="Read an existing log without changing it")
    summary.add_argument("log", type=Path)
    summary.add_argument("--exit-code", type=int)
    run = commands.add_parser("run", help="Capture a command and preserve its exit code")
    run.add_argument("--log", type=Path, required=True)
    run.add_argument("--cwd", type=Path)
    run.add_argument("command", nargs=argparse.REMAINDER)
    for command in (summary, run):
        command.add_argument("--max-chars", type=int, default=6000)
    args = parser.parse_args(argv)
    if not 1024 <= args.max_chars <= 64000:
        parser.error("--max-chars must be between 1024 and 64000")
    exit_code = getattr(args, "exit_code", None)
    try:
        if args.mode == "run":
            command = args.command[1:] if args.command[:1] == ["--"] else args.command
            if not command:
                parser.error("run requires -- <executable> <arguments...>")
            args.log.parent.mkdir(parents=True, exist_ok=True)
            with args.log.open("xb") as log:
                try:
                    exit_code = subprocess.run(command, cwd=args.cwd, stdout=log,
                                               stderr=subprocess.STDOUT, check=False).returncode
                except OSError as error:
                    log.write(f"ERROR: Could not launch command: {error}\n".encode("utf-8"))
                    exit_code = 127
        output = render(analyze(args.log), exit_code, args.max_chars)
        # Old Windows consoles may lack glyphs present in source logs.
        if hasattr(sys.stdout, "reconfigure"):
            sys.stdout.reconfigure(errors="backslashreplace")
        print(output)
        return exit_code if args.mode == "run" else 0
    except (OSError, UnicodeError) as error:
        print(f"Log filter error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
