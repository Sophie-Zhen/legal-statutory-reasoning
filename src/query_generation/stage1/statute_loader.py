#!/usr/bin/env python3
"""
statute_loader.py - Load SARA statute files for context
"""

from pathlib import Path
from typing import Dict, List

class StatuteLoader:
    def __init__(self, statutes_dir: str):
        self.statutes_dir = Path(statutes_dir)
        self.statute_files = [
            'section1.pl', 'section151.pl', 'section152.pl',
            'section2.pl', 'section3301.pl', 'section3306.pl',
            'section63.pl', 'section68.pl', 'section7703.pl',
            'events.pl', 'init.pl', 'utils.pl'
        ]
    
    def load_all_statutes(self) -> Dict[str, str]:
        """Load all statute files"""
        statutes = {}
        
        for file in self.statute_files:
            file_path = self.statutes_dir / file
            if file_path.exists():
                with open(file_path, 'r', encoding='utf-8') as f:
                    statutes[file] = f.read()
            else:
                print(f"Warning: Statute file not found: {file_path}")
                
        return statutes
    
    def get_statutes_summary(self) -> str:
        """Get a summary of key predicates from statutes"""
        statutes = self.load_all_statutes()
        summary = []
        
        for file, content in statutes.items():
            if file.startswith('section'):
                # Extract key predicates
                predicates = self._extract_predicates(content)
                if predicates:
                    summary.append(f"\n{file}:")
                    summary.append(f"Key predicates: {', '.join(predicates[:10])}")
                    
        return '\n'.join(summary)
    
    def _extract_predicates(self, content: str) -> List[str]:
        """Extract predicate names from Prolog code"""
        import re
        # Match predicate definitions like s1_a(...) :-
        matches = re.findall(r'^(\w+)\([^)]*\)\s*:-', content, re.MULTILINE)
        return list(set(matches))