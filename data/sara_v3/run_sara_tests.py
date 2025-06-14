#!/usr/bin/env python3
import subprocess
import re
import sys
from pathlib import Path

# —— Configuration —— #
ROOT       = Path(__file__).resolve().parent
INIT_PL    = ROOT / "statutes" / "prolog" / "init.pl"
CASES_DIR  = ROOT / "cases"
TRAIN_FILE = ROOT / "splits" / "train"

def extract_query(case_path: Path) -> str:
    """
    Pull the multi-line ':- ….' directive from the % Test section,
    strip the ':-' and trailing '.', collapse to one line.
    """
    content = case_path.read_text()
    m = re.search(r'%\s*Test\s*\n\s*(:-.*?\.)', content, re.DOTALL)
    if not m:
        return ""
    directive = m.group(1)
    # remove leading ':-' and trailing '.'
    body = directive.lstrip(":-").rstrip(".")
    # collapse whitespace/newlines into single spaces
    return " ".join(body.split())

def main():
    # Load list of case IDs
    if not TRAIN_FILE.exists():
        print(f"Train split not found: {TRAIN_FILE}", file=sys.stderr)
        sys.exit(1)
    case_ids = [l.strip() for l in TRAIN_FILE.read_text().splitlines() if l.strip()]

    total = len(case_ids)
    passed = 0

    for cid in case_ids:
        case_file = CASES_DIR / f"{cid}.pl"
        if not case_file.exists():
            print(f"{cid}: MISSING .pl file")
            continue

        query = extract_query(case_file)
        if not query:
            print(f"{cid}: NO TEST QUERY FOUND")
            continue

        # Build and run the SWI-Prolog command
        cmd = [
            "swipl", "-q",
            "-s", str(INIT_PL),
            "-s", str(case_file),
            "-g", query,
            "-t", "halt"
        ]
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        out = proc.stdout.strip()
        err = proc.stderr.strip()

        # Determine PASS/FAIL
        if proc.returncode == 0 or "true." in out:
            result = "PASS"
            passed += 1
        elif "false." in out:
            result = "FAIL"
        else:
            result = f"ERROR (exit {proc.returncode})"
        
        # Print per-case diagnostics
        print("="*40)
        print(f"{cid}: running → {query}")
        if err:
            print("--- STDERR ---")
            print(err)
        print("--- STDOUT ---")
        print(out)
        print(f"Result: {result}\n")

    # Summary
    accuracy = passed / total if total else 0
    print("="*40)
    print(f"Total cases: {total}")
    print(f"Passed:      {passed}")
    print(f"Accuracy:    {accuracy:.2%}")
    sys.exit(0 if passed == total else 1)

if __name__ == "__main__":
    main()