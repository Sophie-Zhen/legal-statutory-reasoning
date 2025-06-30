"""
Stage 2 Case Parser - Extracts text+question only (no existing Prolog facts)
File: src/query_generation/stage1/stage2_case_parser.py
"""

import os
import re
from typing import Dict, List, Optional
from dataclasses import dataclass
from pathlib import Path

@dataclass
class Stage2TestCase:
    id: str
    text: str
    question: str
    question_type: str
    expected_value: Optional[str] = None
    golden_facts: Optional[str] = None  # For comparison
    golden_query: Optional[str] = None  # For comparison

class Stage2CaseParser:
    def __init__(self, sara_base_path: str):
        self.sara_base_path = sara_base_path
        self.cases_dir = os.path.join(sara_base_path, "data/sara_v3/cases")
        
        # The exact 26 cases from Stage 1
        self.target_cases = [
            "s1_a_1_iii_neg", "s1_a_1_pos", "s1_b_iii_neg", "s1_c_i_neg", "s1_c_iv_pos",
            "s1_d_iv_neg", "s152_c_1_E_pos", "s152_d_2_F_pos", "s2_a_2_B_pos", "s3306_a_1_neg",
            "s3306_b_10_A_neg", "s3306_b_7_neg", "s3306_b_pos", "s3306_c_5_pos", "s63_c_2_B_neg",
            "s63_c_3_pos", "s68_b_1_A_neg", "s7703_b_1_pos", "tax_case_13", "tax_case_26",
            "tax_case_40", "tax_case_61", "tax_case_63", "tax_case_70", "tax_case_79", "tax_case_89"
        ]

    def parse_stage2_cases(self) -> Dict[str, Stage2TestCase]:
        """Parse the 26 target cases for Stage 2 (text + question only)."""
        cases = {}
        cases_path = Path(self.cases_dir)
        
        if not cases_path.exists():
            print(f"Cases directory not found: {self.cases_dir}")
            return cases
        
        print(f"Parsing 26 target cases for Stage 2...")
        
        for case_id in self.target_cases:
            prolog_file = cases_path / f"{case_id}.pl"
            
            if not prolog_file.exists():
                print(f"Warning: Case file not found: {prolog_file}")
                continue
                
            try:
                with open(prolog_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract text and question (Stage 2 input)
                text = self._extract_section(content, "% Text")
                question = self._extract_section(content, "% Question")
                
                if not text or not question:
                    print(f"Warning: Could not parse text/question from {case_id}")
                    continue
                
                # Extract golden facts and query for comparison
                golden_facts = self._extract_golden_facts(content)
                golden_query = self._extract_golden_query(content)
                
                # Determine question type and expected value
                question_type = self._determine_question_type(question)
                expected_value = self._extract_expected_value(question)
                
                cases[case_id] = Stage2TestCase(
                    id=case_id,
                    text=text.strip(),
                    question=question.strip(),
                    question_type=question_type,
                    expected_value=expected_value,
                    golden_facts=golden_facts.strip() if golden_facts else None,
                    golden_query=golden_query.strip() if golden_query else None
                )
                
            except Exception as e:
                print(f"Error parsing {case_id}: {e}")
                continue
        
        print(f"Successfully parsed {len(cases)} Stage 2 cases")
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

    def _extract_golden_facts(self, content: str) -> str:
        """Extract the existing Prolog facts for comparison."""
        lines = content.split('\n')
        in_facts_section = False
        facts_lines = []
        
        for line in lines:
            if line.strip() == "% Facts":
                in_facts_section = True
                continue
            elif line.strip() == "% Test":
                break
            elif in_facts_section and not line.startswith('%') and line.strip():
                # This is a Prolog fact
                facts_lines.append(line.strip())
        
        return '\n'.join(facts_lines)

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
        match = re.search(r'\$(\d+)', question)
        return match.group(1) if match else None

    def load_statute_files(self) -> Dict[str, str]:
        """Load statute files from SARA data directory."""
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