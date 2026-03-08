#!/usr/bin/env python3
"""Rank Dart files likely due for refactoring.

Defaults to scanning flutter_app/lib and flutter_app/test.
Length scoring is applied only for files larger than 400 lines.
"""

from __future__ import annotations

import argparse
import pathlib
import re
from dataclasses import dataclass


DEFAULT_ROOTS = ("flutter_app/lib", "flutter_app/test")
LENGTH_THRESHOLD = 400


@dataclass(frozen=True)
class FileScore:
    path: pathlib.Path
    lines: int
    todo_count: int
    fixme_count: int
    function_count: int
    long_function_count: int
    complexity_points: int
    score: int


def discover_dart_files(roots: list[pathlib.Path]) -> list[pathlib.Path]:
    files: list[pathlib.Path] = []
    for root in roots:
        if not root.exists():
            continue
        files.extend(p for p in root.rglob("*.dart") if p.is_file())
    return sorted(set(files))


def estimate_functions(lines: list[str]) -> list[tuple[int, int]]:
    """Return list of (start_line, end_line) for top-level-ish function blocks."""
    decl = re.compile(r"^\s*(?:[\w<>\[\],? ]+\s+)+\w+\s*\([^;]*\)\s*\{")
    blocks: list[tuple[int, int]] = []
    i = 0
    n = len(lines)
    while i < n:
        if not decl.search(lines[i]):
            i += 1
            continue
        start = i
        depth = lines[i].count("{") - lines[i].count("}")
        i += 1
        while i < n and depth > 0:
            depth += lines[i].count("{") - lines[i].count("}")
            i += 1
        end = min(i, n) - 1
        if end >= start:
            blocks.append((start + 1, end + 1))
    return blocks


def compute_score(path: pathlib.Path, root: pathlib.Path) -> FileScore:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    line_count = len(lines)
    lower = text.lower()
    todo_count = lower.count("todo")
    fixme_count = lower.count("fixme")

    function_blocks = estimate_functions(lines)
    long_function_count = sum(1 for start, end in function_blocks if (end - start + 1) >= 60)

    complexity_tokens = re.findall(
        r"\b(if|else\s+if|for|while|switch|case|catch|&&|\|\||\?)\b", text
    )
    complexity_points = len(complexity_tokens)

    score = 0
    if line_count > LENGTH_THRESHOLD:
        score += (line_count - LENGTH_THRESHOLD) // 25 + 1
    score += todo_count * 2
    score += fixme_count * 3
    score += long_function_count * 2
    score += complexity_points // 80

    return FileScore(
        path=path.relative_to(root),
        lines=line_count,
        todo_count=todo_count,
        fixme_count=fixme_count,
        function_count=len(function_blocks),
        long_function_count=long_function_count,
        complexity_points=complexity_points,
        score=score,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        default=".",
        help="Repository root (default: current directory).",
    )
    parser.add_argument(
        "--paths",
        nargs="*",
        default=list(DEFAULT_ROOTS),
        help="Relative directories to scan for .dart files.",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=25,
        help="Maximum rows to print (default: 25).",
    )
    parser.add_argument(
        "--min-score",
        type=int,
        default=1,
        help="Minimum score to include in output (default: 1).",
    )
    parser.add_argument(
        "--include-small",
        action="store_true",
        help="Include files with <= 400 lines (default: false).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = pathlib.Path(args.root).resolve()
    scan_roots = [root / p for p in args.paths]
    files = discover_dart_files(scan_roots)
    if not files:
        print("No Dart files found.")
        return 0

    scored = [compute_score(path, root) for path in files]
    ranked = sorted(scored, key=lambda r: (r.score, r.lines), reverse=True)
    filtered = [row for row in ranked if row.score >= args.min_score]
    if not args.include_small:
        filtered = [row for row in filtered if row.lines > LENGTH_THRESHOLD]

    print("Dart refactor candidates")
    print(f"Scanned files: {len(files)}")
    print(f"Length score threshold: > {LENGTH_THRESHOLD} lines")
    print(f"Including <= {LENGTH_THRESHOLD} lines: {bool(args.include_small)}")
    print("")
    if not filtered:
        print("No files met the minimum score.")
        return 0

    print(
        "score  lines  long_fn  todo  fixme  complexity  path\n"
        "-----  -----  -------  ----  -----  ----------  ----"
    )
    for row in filtered[: args.top]:
        print(
            f"{row.score:>5}  {row.lines:>5}  {row.long_function_count:>7}  "
            f"{row.todo_count:>4}  {row.fixme_count:>5}  {row.complexity_points:>10}  "
            f"{row.path.as_posix()}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
