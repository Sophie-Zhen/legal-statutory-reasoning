import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent.parent.parent
SARA_V3_DIR = PROJECT_ROOT / "data" / "sara_v3"
INIT_PL   = SARA_V3_DIR / "statutes" / "prolog" / "init.pl"
CASES_DIR = SARA_V3_DIR / "cases"
TRAIN     = SARA_V3_DIR / "splits" / "train"
TEST      = SARA_V3_DIR / "splits" / "test"
TRAIN_RESULTS   = PROJECT_ROOT / "results" / "train_split_shell_result.txt"
TEST_RESULTS   = PROJECT_ROOT / "results" / "test_split_shell_result.txt"


with open(TRAIN) as f:
    ids_train = [l.strip() for l in f if l.strip()]

passed_train = 0
lines_train  = []

for cid in ids_train:
    case_file = CASES_DIR / f"{cid}.pl"
    cmd = [
        "swipl", "-q",
        "-s", str(INIT_PL),
        "-s", str(case_file),
        "-g", "halt"
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    out  = proc.stdout.strip()    # e.g. "true." or "false."
    rc   = proc.returncode        # 0 on true, 1 on false

    if rc == 0:
        result = "PASS"
        passed_train += 1
    elif rc == 1:
        result = "FAIL"
    else:
        result = f"ERROR (exit {rc})"

    lines_train.append(f"{cid}: {result}  [{out}]")

accuracy_train = passed_train / len(ids_train) if ids_train else 0

with open(TRAIN_RESULTS, "w") as log:
    log.write(f"Total: {len(ids_train)}, Passed: {passed_train}, Accuracy: {accuracy_train:.2%}\n\n")
    log.write("\n".join(lines_train))

with open(TEST) as f:
    ids_test = [l.strip() for l in f if l.strip()]

passed_test = 0
lines_test  = []

for cid in ids_test:
    case_file = CASES_DIR / f"{cid}.pl"
    cmd = [
        "swipl", "-q",
        "-s", str(INIT_PL),
        "-s", str(case_file),
        "-g", "halt"
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    out  = proc.stdout.strip()    # e.g. "true." or "false."
    rc   = proc.returncode        # 0 on true, 1 on false

    if rc == 0:
        result = "PASS"
        passed_test += 1
    else:
        result = f"ERROR (exit {rc})"

    lines_test.append(f"{cid}: {result}  [{out}]")

accuracy_test = passed_test / len(ids_test) if ids_test else 0

with open(TEST_RESULTS, "w") as log:
    log.write(f"Total: {len(ids_test)}, Passed: {passed_test}, Accuracy: {accuracy_test:.2%}\n\n")
    log.write("\n".join(lines_test))

print(f"Results written to {TRAIN_RESULTS}")
print(f"Accuracy: {accuracy_train:.2%}")
print(f"Results written to {TEST_RESULTS}")
print(f"Accuracy: {accuracy_test:.2%}")