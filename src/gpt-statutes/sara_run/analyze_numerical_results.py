import re

RESULTS_FILE = "sara_numerical_results.txt"
RESULTS_PATH = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/src/gpt-statutes/sara_run/results_num/" + RESULTS_FILE
OUTPUT_PATH = "/Users/sophie/code/2025-mcm-llms-applied-in-law_context/src/gpt-statutes/sara_run/results_num/numerical_analysis.txt"

def parse_results(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()

    correct = 0
    total = 0
    correct_questions = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("RUNNING:"):
            # Extract the question block
            question_lines = [line.strip()]
            i += 1
            while i < len(lines) and not lines[i].startswith("Groundtruth:"):
                question_lines.append(lines[i].strip())
                i += 1
            question = " ".join(question_lines)
            # Now, expect Groundtruth
            if i < len(lines) and lines[i].startswith("Groundtruth:"):
                gt_line = lines[i]
                gt_match = re.search(r"Groundtruth:\s*\$?([\d,.]+)", gt_line)
                gt_value = None
                if gt_match:
                    gt_value = float(gt_match.group(1).replace(",", ""))
                # Now, look for the RESULT line
                while i < len(lines) and not lines[i].startswith("RESULT"):
                    i += 1
                if i < len(lines) and lines[i].startswith("RESULT"):
                    result_line = lines[i]
                    result_match = re.search(r"RESULT gt\s+([\d,.]+) pred\s+([\d,.]+)", result_line)
                    if result_match:
                        gt = float(result_match.group(1).replace(",", ""))
                        pred = float(result_match.group(2).replace(",", ""))
                        total += 1
                        if abs(gt - pred) < 1e-2:  # Allow for floating point rounding
                            correct += 1
                            correct_questions.append(question)
                i += 1
            else:
                i += 1
        else:
            i += 1
    return correct, total, correct_questions

def main():
    correct, total, correct_questions = parse_results(RESULTS_PATH)
    output_lines = []
    output_lines.append(f"Total cases: {total}")
    output_lines.append(f"Correctly answered: {correct}")
    if total > 0:
        output_lines.append(f"Correctness percentage: {100.0 * correct / total:.2f}%")
    output_lines.append("\nQuestions with correct answers:")
    for q in correct_questions:
        output_lines.append(q)
    # Print to stdout
    for line in output_lines:
        print(line)
    # Save to file
    with open(OUTPUT_PATH, 'w') as f:
        for line in output_lines:
            f.write(line + '\n')

if __name__ == "__main__":
    main() 