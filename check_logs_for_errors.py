#!/usr/bin/env python3

import argparse
from pathlib import Path

CONTEXT_LINES = 5
LOGS_DIR = Path(__file__).resolve().parent / "logs"

known_errors = [
    "Error setting jorammq0-eth0 up",
    "(10ms delay) *** Error:",
    "transferring",
    "label: {error_logger,error_msg}"
]

def log(message: str, args) -> None:
    if args.log == "true":
        print(message)

def main():
    parser = argparse.ArgumentParser(
        description="Search log files for lines containing 'err' (case-insensitive)."
    )
    parser.add_argument(
        "--timestamp",
        required=True,
        help="Timestamp prefix to match files under logs/, e.g. 20260519142106_0",
    )
    parser.add_argument(
        "--log",
        required=False,
        help="Print found errors to console",
    )
    args = parser.parse_args()

    matches = sorted(LOGS_DIR.glob(f"{args.timestamp}*"))
    if not matches:
        log(f"No files found under logs/ matching: {args.timestamp}*", args)
        return

    error_count = 0
    for path in matches:
        if not path.is_file():
            continue

        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()

        for i, line in enumerate(lines):
            if "error" not in line.lower() or any(known_error in line for known_error in known_errors):
                continue

            error_count += 1
            log(f"=== Error found in {path.name} line {i + 1} ===", args)
            start = max(0, i - CONTEXT_LINES)
            end = min(len(lines), i + CONTEXT_LINES + 1)
            for ctx_line in lines[start:end]:
                log(ctx_line, args)
            log("=== End of error context ===\n\n", args)

    print(f"Total errors found: {error_count}")
    if error_count == 0:
        exit(0)
    else:
        exit(1)


if __name__ == "__main__":
    main()
