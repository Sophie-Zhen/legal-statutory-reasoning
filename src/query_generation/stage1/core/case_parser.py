import os
import re
import json
from typing import Dict, List, Optional
from dataclasses import dataclass
from pathlib import Path

@dataclass
class TestCase:
    id: str
    text: str
    question: str
    question_type: str
    golden_query: str
    expected_value: Optional[str] = None
    facts: Optional[str] = None

class CaseParser:
    def __init__(self, sara_base_path: str):
        self.sara_base_path = sara_base_path
        self.cases_dir = os.path.join(sara_base_path, "data/sara_v3/cases")

    def _parse_golden_query(self, content: str) -> str:
        match = re.search(r'^:-\s*(.*)\.', content, re.MULTILINE)
        return match.group(1).strip() if match else "not_found."

    def load_test_cases(self, file_path: str) -> Dict[str, TestCase]:
        cases = {}
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"sara_parallel.jsonl not found at {file_path}")

        with open(file_path, 'r') as f:
            for line in f:
                if not line.strip(): continue
                data = json.loads(line)
                case_id = data['id']
                question_text = data['question']

                if "Entailment" in question_text:
                    question_type = "entailment"
                elif "Contradiction" in question_text:
                    question_type = "contradiction"
                else:
                    question_type = "tax_amount"

                expected_value_match = re.search(r'\$?(\d+)$', question_text)
                expected_value = expected_value_match.group(1) if expected_value_match else None
                
                case_file_path = os.path.join(self.cases_dir, f"{case_id}.pl")
                with open(case_file_path, 'r') as cf:
                    prolog_content = cf.read()
                
                facts = "\n".join([ln.strip() for ln in prolog_content.splitlines() if ln.strip() and not ln.strip().startswith(('%', ':-'))])
                golden_query = self._parse_golden_query(prolog_content)
                
                cases[case_id] = TestCase(
                    id=case_id, text=data['text'], question=question_text,
                    question_type=question_type, expected_value=expected_value,
                    facts=facts, golden_query=golden_query
                )
        return cases

    def parse_sara_parallel_file(self, file_path: str, filter_test_only: bool = False) -> Dict[str, TestCase]:
        """Parse sara_parallel.jsonl file - this is what run_stage1.py expects"""
        return self.load_test_cases(file_path)

    def load_statute_files(self) -> Dict[str, str]:
        """Load statute files from SARA data directory"""
        statute_files = {}
        statutes_dir = os.path.join(self.sara_base_path, "data/sara_v3/statutes/prolog")
        
        if not os.path.exists(statutes_dir):
            print(f"Warning: Statutes directory not found: {statutes_dir}")
            return statute_files
        
        for filename in os.listdir(statutes_dir):
            if filename.endswith('.pl'):
                file_path = os.path.join(statutes_dir, filename)
                try:
                    with open(file_path, 'r') as f:
                        statute_files[filename] = f.read()
                except Exception as e:
                    print(f"Warning: Could not load {filename}: {e}")
        
        print(f"Loaded {len(statute_files)} statute files")
        return statute_files

    def parse_prolog_case_files(self, cases_directory: str) -> Dict[str, TestCase]:
        """Parse all .pl case files from the SARA cases directory."""
        cases = {}
        cases_path = Path(cases_directory)
        
        if not cases_path.exists():
            print(f"Cases directory not found: {cases_directory}")
            return cases
        
        # Find all .pl files
        prolog_files = list(cases_path.glob("*.pl"))
        print(f"Found {len(prolog_files)} .pl case files")
        
        for prolog_file in prolog_files:
            try:
                case_id = prolog_file.stem  # filename without extension
                
                with open(prolog_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Parse the structured comment sections
                text = self._extract_section(content, "% Text")
                question = self._extract_section(content, "% Question") 
                
                if not text or not question:
                    print(f"Warning: Could not parse text/question from {prolog_file.name}")
                    continue
                
                # Determine question type
                question_type = self._determine_question_type(question)
                
                # Extract expected value for tax cases
                expected_value = self._extract_expected_value(question)
                
                # Extract facts section
                facts = self._extract_section(content, "% Facts", "% Test")
                
                # Extract the golden query (the :- line in Test section)
                golden_query = self._extract_golden_query(content)
                
                cases[case_id] = TestCase(
                    id=case_id,
                    text=text.strip(),
                    question=question.strip(), 
                    question_type=question_type,
                    expected_value=expected_value,
                    facts=facts.strip() if facts else None,
                    golden_query=golden_query
                )
                
            except Exception as e:
                print(f"Error parsing {prolog_file.name}: {e}")
                continue
        
        print(f"Successfully parsed {len(cases)} case files")
        return cases

    def _extract_section(self, content: str, start_marker: str, end_marker: str = None) -> str:
        """Extract text between comment markers."""
        lines = content.split('\n')
        extracting = False
        result_lines = []
        
        for line in lines:
            if line.strip() == start_marker:
                extracting = True
                continue
            elif end_marker and line.strip() == end_marker:
                break
            elif extracting and line.startswith('%'):
                if line.strip() == '%':
                    continue  # skip empty comment lines
                # Remove % and leading space
                text = line[1:].lstrip() if len(line) > 1 else ""
                result_lines.append(text)
            elif extracting and not line.startswith('%') and line.strip():
                # Hit non-comment content, stop extracting
                break
        
        return '\n'.join(result_lines)

    def _determine_question_type(self, question: str) -> str:
        """Determine question type from question text."""
        question_lower = question.lower()
        if "contradiction" in question_lower:
            return "contradiction"
        elif "entailment" in question_lower:
            return "entailment" 
        elif "$" in question or "tax" in question_lower:
            return "tax_amount"
        else:
            return "entailment"  # default

    def _extract_expected_value(self, question: str) -> str:
        """Extract expected dollar amount from question."""
        import re
        match = re.search(r'\$(\d+)', question)
        return match.group(1) if match else None

    def _extract_golden_query(self, content: str) -> str:
        """Extract the test query from the Test section.""" 
        lines = content.split('\n')
        in_test_section = False
        
        for line in lines:
            if line.strip() == "% Test":
                in_test_section = True
                continue
            elif in_test_section and line.startswith(':-'):
                # Found the test query
                return line.strip()
        
        return "not_found."