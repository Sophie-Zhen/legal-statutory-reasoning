#!/usr/bin/env python3
"""
case_parser.py - Parse .pl case files to extract components
"""

import re
from pathlib import Path
from typing import Dict, Optional

class CaseParser:
    def __init__(self, cases_dir: Path):
        self.cases_dir = Path(cases_dir)
    
    def parse_case(self, case_file: str) -> Dict:
        """Parse a case file and extract its components"""
        case_path = self.cases_dir / case_file
        case_id = case_file.replace('.pl', '')
        
        with open(case_path, 'r') as f:
            content = f.read()
        
        # Extract components using regex
        text = self._extract_section(content, "Text")
        question = self._extract_section(content, "Question")
        facts = self._extract_section(content, "Facts", end_marker="Test")
        test = self._extract_section(content, "Test")
        
        # Clean up
        text = self._clean_text(text)
        question = self._clean_text(question)
        facts = self._clean_facts(facts)
        test = self._clean_test(test)
        
        return {
            'case_id': case_id,
            'text': text,
            'question': question,
            'facts': facts,
            'test': test,
            'file_path': str(case_path)
        }
    
    def _extract_section(self, content: str, section: str, end_marker: Optional[str] = None) -> str:
        """Extract a section from the content"""
        # Pattern to match % Section
        pattern = rf'%\s*{section}\s*\n(.*?)(?=\n%\s*(?:{end_marker if end_marker else "\w+"})|$)'
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        
        if match:
            return match.group(1).strip()
        return ""
    
    def _clean_text(self, text: str) -> str:
        """Clean text by removing extra whitespace"""
        # Remove comment markers
        text = re.sub(r'^%\s*', '', text, flags=re.MULTILINE)
        # Collapse whitespace
        text = ' '.join(text.split())
        return text.strip()
    
    def _clean_facts(self, facts: str) -> str:
        """Clean facts section"""
        # Remove comment lines but keep Prolog facts
        lines = []
        for line in facts.split('\n'):
            line = line.strip()
            if line and not line.startswith('%'):
                lines.append(line)
        return '\n'.join(lines)
    
    def _clean_test(self, test: str) -> str:
        """Clean test section"""
        # Remove :- if present and clean
        test = test.strip()
        if test.startswith(':-'):
            test = test[2:].strip()
        return test