"""Collision-resistant evidence file writer.

Mirrors the filename scheme already used by every PowerShell gate script
in this project since Phase 2C.4:
    "<UTC timestamp with milliseconds>_<4 random hex chars>"
so that concurrent or rapid-fire test runs never overwrite each other's
evidence, and evidence directories from this tool and from the
PowerShell gates can be told apart by their `.json`/`.md` pair and
report-type prefix alone.
"""

from __future__ import annotations

import datetime
import json
import os
import secrets
import tempfile
from pathlib import Path
from typing import Any, Dict, Tuple


def generate_report_basename(prefix: str) -> str:
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime(
        "%Y%m%d_%H%M%S_%f"
    )[:-3]  # milliseconds, not microseconds
    suffix = secrets.token_hex(2)  # 4 hex chars
    return f"{prefix}_{timestamp}_{suffix}"


def write_evidence(
    report_dir: str, prefix: str, data: Dict[str, Any], markdown_body: str
) -> Tuple[Path, Path]:
    """Writes a <basename>.json and <basename>.md pair into report_dir.

    Returns (json_path, md_path). Raises if report_dir cannot be created
    or written to - evidence-writing failures are never silently
    swallowed.
    """
    out_dir = Path(report_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    basename = generate_report_basename(prefix)
    json_path = out_dir / f"{basename}.json"
    md_path = out_dir / f"{basename}.md"

    # Fail closed on an actual filename collision rather than silently
    # overwriting - this should be astronomically unlikely given the
    # millisecond timestamp + random suffix, but a collision here means
    # something is wrong (e.g. a clock/RNG problem), not something to
    # paper over.
    if json_path.exists() or md_path.exists():
        raise FileExistsError(
            f"Evidence filename collision detected for basename "
            f"'{basename}' in {out_dir} - refusing to overwrite."
        )

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write("\n")

    with open(md_path, "w", encoding="utf-8") as f:
        f.write(markdown_body)
        if not markdown_body.endswith("\n"):
            f.write("\n")

    return json_path, md_path


def atomic_write_json(path: "Path | str", data: Dict[str, Any]) -> Path:
    """Writes `data` as JSON to `path` via write-to-temp-file-then-
    replace, so a process interrupted mid-write (e.g. killed by an
    external watchdog) never leaves a truncated or half-written file at
    `path` - readers either see the previous complete version or the
    new complete version, never a mix (Gate A serial-transport-
    hardening phase: incremental handshake/probe evidence is rewritten
    after every stage, so this matters a great deal here).

    `os.replace()` is atomic on both POSIX and Windows when the source
    and destination are on the same volume, which they always are here
    (same report directory).
    """
    out_path = Path(path)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    fd, tmp_name = tempfile.mkstemp(
        dir=str(out_path.parent), prefix=out_path.name + ".", suffix=".tmp"
    )
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, sort_keys=True)
            f.write("\n")
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp_name, str(out_path))
    except BaseException:
        try:
            os.remove(tmp_name)
        except OSError:
            pass
        raise
    return out_path
