"""
Stage 3 Method 2 Case Parser
Modified from Stage 2 case parser to work with SARA dataset case files
Extracts natural language text and questions for semantic fact generation
"""

import re
import json
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple

logger = logging.getLogger(__name__)


class Stage3CaseParser:
    """
    Case parser for Stage 3 Method 2 that extracts natural language components
    from SARA dataset case files for semantic fact generation
    """
    
    def __init__(self, cases_dir: str):
        """
        Initialize parser with cases directory
        
        Args:
            cases_dir: Path to directory containing .pl case files
        """
        self.cases_dir = Path(cases_dir)
        
    def parse_case_file(self, case_id: str) -> Dict:
        """
        Parse a single case file to extract components needed for Stage 3
        
        Args:
            case_id: Case identifier (filename without .pl extension)
            
        Returns:
            Dictionary with:
            - text: Natural language description
            - question: Natural language question  
            - reference_facts: Original Prolog facts (for evaluation)
            - expected_result: Expected answer (true/false/value)
        """
        case_file = self.cases_dir / f"{case_id}.pl"
        
        if not case_file.exists():
            raise FileNotFoundError(f"Case file not found: {case_file}")
        
        with open(case_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse the file sections
        parsed_data = self._parse_case_content(content)
        
        # Extract natural language components
        text = self._extract_text_section(parsed_data.get('text', ''))
        question = self._extract_question_section(parsed_data.get('question', ''))
        
        # Extract reference facts for evaluation
        facts_section = parsed_data.get('facts', '')
        reference_facts = self._parse_facts_section(facts_section)
        
        # Determine expected result from test
        test = parsed_data.get('test', '')
        expected_result = self._determine_expected_result(case_id, test)
        
        # Validation
        if not text:
            logger.warning(f"No text found in {case_id}")
        if not question:
            logger.warning(f"No question found in {case_id}")
            
        return {
            "case_id": case_id,
            "text": text,
            "question": question,
            "reference_facts": reference_facts,
            "expected_result": expected_result,
            "test": test
        }
    
    def _parse_case_content(self, content: str) -> Dict:
        """
        Parse the case file content into sections
        
        Returns:
            Dictionary with sections: text, question, facts, test
        """
        sections = {
            'text': '',
            'question': '',
            'facts': '',
            'test': ''
        }
        
        # Split by section markers
        lines = content.split('\n')
        current_section = None
        
        for line in lines:
            line = line.strip()
            
            # Check for section markers (both with and without colons)
            if line.lower().startswith('% text'):
                current_section = 'text'
                # Extract text from the same line if present after colon
                if ':' in line:
                    text_part = line.split(':', 1)[1].strip()
                    if text_part:
                        sections['text'] = text_part
                continue
            elif line.lower().startswith('% question'):
                current_section = 'question'
                # Extract question from the same line if present after colon
                if ':' in line:
                    question_part = line.split(':', 1)[1].strip()
                    if question_part:
                        sections['question'] = question_part
                continue
            elif line.lower().startswith('% facts'):
                current_section = 'facts'
                continue
            elif line.lower().startswith('% test'):
                current_section = 'test'
                # Extract test from the same line if present after colon
                if ':' in line:
                    test_part = line.split(':', 1)[1].strip()
                    if test_part:
                        sections['test'] = test_part
                continue
            elif line.startswith('%') and any(keyword in line.lower() for keyword in ['answer', 'result', 'expected']):
                current_section = None
                continue
            
            # Add content to current section
            if current_section and line:
                # For text and question sections, include comment lines (strip the % prefix)
                if current_section in ['text', 'question'] and line.startswith('%'):
                    content = line[1:].strip()  # Remove % and whitespace
                    if content:  # Only add non-empty content
                        if sections[current_section]:
                            sections[current_section] += ' ' + content
                        else:
                            sections[current_section] = content
                # For facts and test sections, only include non-comment lines
                elif current_section in ['facts', 'test'] and not line.startswith('%'):
                    if sections[current_section]:
                        sections[current_section] += ' ' + line
                    else:
                        sections[current_section] = line
        
        return sections
    
    def _extract_text_section(self, text_raw: str) -> str:
        """
        Extract and clean the natural language text description
        """
        if not text_raw:
            return ''
        
        # Remove any remaining comment markers
        text = re.sub(r'^%\s*', '', text_raw)
        
        # Clean up whitespace
        text = ' '.join(text.split())
        
        return text.strip()
    
    def _extract_question_section(self, question_raw: str) -> str:
        """
        Extract and clean the natural language question
        """
        if not question_raw:
            return ''
        
        # Remove any remaining comment markers
        question = re.sub(r'^%\s*', '', question_raw)
        
        # Clean up whitespace
        question = ' '.join(question.split())
        
        return question.strip()
    
    def _parse_facts_section(self, facts_section: str) -> List[str]:
        """
        Parse the facts section to extract individual Prolog facts
        
        Args:
            facts_section: The facts section content
            
        Returns:
            List of Prolog facts
        """
        facts = []
        lines = facts_section.strip().split('\n')
        
        for line in lines:
            line = line.strip()
            
            # Skip empty lines and directives
            if not line or line.startswith(':- ') or line.startswith('%'):
                continue
                
            # Check if it looks like a Prolog fact
            if self._is_prolog_fact(line):
                facts.append(line)
                
        return facts
    
    def _is_prolog_fact(self, line: str) -> bool:
        """
        Check if a line is a Prolog fact
        Facts typically have the pattern: predicate(args).
        """
        # Basic pattern for Prolog facts
        fact_pattern = r'^\w+\([^)]*\)\.$'
        return bool(re.match(fact_pattern, line))
    
    def _determine_expected_result(self, case_id: str, test: str) -> str:
        """
        Determine the expected result based on the test and case type
        
        Args:
            case_id: Case identifier for type detection
            test: The test section content
            
        Returns:
            Expected result: 'true', 'false', specific value, or 'unknown'
        """
        if not test:
            return 'unknown'
        
        # For tax cases, try to extract the expected amount
        if case_id.startswith('tax_case_'):
            # Look for amount patterns in test or case_id context
            amount_match = re.search(r'\$?(\d+)', test)
            if amount_match:
                return amount_match.group(1)
            # Default expected result for tax cases
            return 'unknown'
        
        # For section cases, determine true/false based on pos/neg suffix
        if '_pos' in case_id:
            return 'true'
        elif '_neg' in case_id:
            return 'false'
        
        # Check for negation in test
        if test.startswith('\\+') or test.startswith('\\+ '):
            return 'false'
        elif test.strip():
            return 'true'
        else:
            return 'unknown'
    
    def validate_parsed_data(self, case_data: Dict) -> List[str]:
        """
        Validate that parsed data has required components for Stage 3
        
        Returns:
            List of validation errors (empty if valid)
        """
        errors = []
        
        if not case_data.get('text'):
            errors.append("Missing natural language text")
            
        if not case_data.get('question'):
            errors.append("Missing natural language question")
            
        return errors
    
    def parse_multiple_cases(self, case_ids: List[str]) -> Dict[str, Dict]:
        """
        Parse multiple case files
        
        Args:
            case_ids: List of case identifiers
            
        Returns:
            Dictionary mapping case_id to parsed data
        """
        results = {}
        
        for case_id in case_ids:
            try:
                case_data = self.parse_case_file(case_id)
                
                # Validate the parsed data
                errors = self.validate_parsed_data(case_data)
                if errors:
                    logger.warning(f"Validation errors for {case_id}: {errors}")
                    case_data['validation_errors'] = errors
                
                results[case_id] = case_data
                logger.info(f"Successfully parsed {case_id}")
                
            except Exception as e:
                logger.error(f"Error parsing {case_id}: {e}")
                results[case_id] = {
                    "case_id": case_id,
                    "error": str(e),
                    "text": "",
                    "question": "",
                    "reference_facts": [],
                    "expected_result": "unknown"
                }
                
        return results
    
    def get_case_statistics(self, case_ids: List[str]) -> Dict:
        """
        Get statistics about the cases
        
        Returns:
            Dictionary with statistics
        """
        stats = {
            "total_cases": len(case_ids),
            "tax_cases": 0,
            "section_cases": 0,
            "pos_cases": 0,
            "neg_cases": 0,
            "sections": set()
        }
        
        for case_id in case_ids:
            if case_id.startswith('tax_case_'):
                stats["tax_cases"] += 1
            else:
                stats["section_cases"] += 1
                # Extract section number
                section_match = re.match(r's(\d+)', case_id)
                if section_match:
                    stats["sections"].add(section_match.group(1))
            
            if case_id.endswith('_pos'):
                stats["pos_cases"] += 1
            elif case_id.endswith('_neg'):
                stats["neg_cases"] += 1
        
        stats["sections"] = sorted(list(stats["sections"]))
        
        return stats 