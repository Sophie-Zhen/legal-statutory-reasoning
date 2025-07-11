#!/usr/bin/env python3
"""
Stage-2 runner: "Fact Extraction and Query Generation". The LLM is given
the English case narrative and question and must generate BOTH the
corresponding Prolog facts and the query.
"""

import csv
import re
import random
import subprocess
import sys
import tempfile
from pathlib import Path

from tqdm import tqdm
from llm.gemini_client import GeminiClient

# --- Project Paths ---
ROOT = Path(__file__).resolve().parent
SRC_DIR = ROOT.parents[1]
PROJ_ROOT = ROOT.parents[2]
DATA_DIR = PROJ_ROOT / "data" / "sara_v3"
STAT_DIR_PL = DATA_DIR / "statutes/prolog"
CASES_DIR = DATA_DIR / "cases"
PROLOG_SH = SRC_DIR / "sara_hybrid/integration/prolog/shell_run.py"
OUT_DIR = ROOT / "stage2_results" # Use a new directory for Stage 2 results
RAW_DIR = OUT_DIR / "raw_output"
RAW_DIR.mkdir(parents=True, exist_ok=True)
# ───────────────────────

# --- Helpers ---
def load_case_english(path: Path) -> dict[str, str]:
    """Extracts only the English text and question from a case file."""
    parts = {"text": [], "question": []}
    current_tag = None
    for line in path.read_text().splitlines():
        if line.lstrip().startswith("%"):
            current_tag = line.strip("% ").lower()
            continue
        if current_tag in parts:
            parts[current_tag].append(line)
    return {key: "\n".join(value) for key, value in parts.items()}

_HEAD_RE = re.compile(r"^\s*([a-z][a-z0-9_]*)\s*\(([^):-]*)")
def generate_predicate_glossary(statute_dir: Path) -> str:
    preds: set[str] = set()
    for pl in statute_dir.glob("*.pl"):
        if pl.name == "events.pl": continue
        for line in pl.read_text().splitlines():
            if line.lstrip().startswith("%"): continue
            m = _HEAD_RE.match(line)
            if not m: continue
            name, args = m.groups()
            arity = 0 if args.strip() == "" else args.count(",") + 1
            preds.add(f"{name}/{arity}")
    return ", ".join(sorted(preds))

def run_swipl(generated_code: str, timeout: int = 60) -> tuple[bool, str]:
    """
    Runs the full block of LLM-generated code (facts + query) against
    the SARA statutes.
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        tdir = Path(tmpdir)
        # The LLM generates both facts and query, so we only need one file.
        (tdir / "generated.pl").write_text(generated_code)
        
        # We modify the shell run to consult the generated file, which should
        # contain the query to be executed.
        cmd = ["python", str(PROLOG_SH), str(STAT_DIR_PL), str(tdir)]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
            return proc.returncode == 0, proc.stderr
        except subprocess.TimeoutExpired: return False, "SWI-Prolog TIMEOUT"
# ────────────────

def main() -> None:
    if not all(d.is_dir() for d in [STAT_DIR_PL, CASES_DIR]):
        sys.exit("❌ A required data directory was not found.")

    glossary = generate_predicate_glossary(STAT_DIR_PL)
    prompt_tpl_path = ROOT / "prompts/stage2_extract_and_query.txt"
    if not prompt_tpl_path.exists(): sys.exit(f"❌ Stage 2 Prompt template not found.")
    prompt_tpl = prompt_tpl_path.read_text()
    gemini = GeminiClient()

    all_cases  = sorted(CASES_DIR.glob("*.pl"))
    random.seed(42)
    case_files = random.sample(all_cases, 5) # Start with a small sample
    
    print(f"--- Running Stage 2: Fact Extraction & Query Generation ---")
    print(f"INFO: Processing {len(case_files)} cases for this test run.")

    results = []
    for cfile in tqdm(case_files, desc="Processing cases"):
        case = load_case_english(cfile)
        
        user_prompt = prompt_tpl.replace("{{GLOSSARY}}", glossary) \
                                .replace("{{CASE_TEXT}}", case["text"]) \
                                .replace("{{QUESTION}}", case["question"])

        generated_code = gemini.chat([{"role": "user", "content": user_prompt}]) or ""
        
        passed, stderr = False, ""
        if generated_code.strip():
            passed, stderr = run_swipl(generated_code)

        log_content = generated_code if generated_code.strip() else "# EMPTY"
        if stderr:
            log_content += f"\n\n% --- SWI-PROLOG STDERR ---\n% {stderr.replace('\n', '\n% ')}"
        (RAW_DIR / f"{cfile.stem}.pl").write_text(log_content)

        results.append({
            "case": cfile.stem,
            "pass": passed,
            "generated_code": generated_code.strip().replace("\n", " ")
        })

    if not results: sys.exit("❌ No cases were processed.")
        
    out_csv = OUT_DIR / "stage2_results.csv"
    with out_csv.open("w", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=["case", "pass", "generated_code"])
        writer.writeheader()
        writer.writerows(results)

    pass_count = sum(1 for r in results if r["pass"])
    total_count = len(results)
    accuracy = (pass_count / total_count * 100) if total_count > 0 else 0

    print(f"\n--- STAGE 2 COMPLETE ---")
    print(f"✅ Results saved to {out_csv}")
    print(f"   Raw generated code in {RAW_DIR}")
    print(f"\nAccuracy: {pass_count} / {total_count} ({accuracy:.2f}%)")
    print("------------------------")

if __name__ == "__main__":
    main()
