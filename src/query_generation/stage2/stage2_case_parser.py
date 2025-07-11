"""
Stage 2 Case Parser: I reused the Stage 1 case parser for natural language extraction
Parses. And used the SARA dataset case files to extract text, questions, and reference facts
"""

import re
import json
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from case_parser import CaseParser  

logger = logging.getLogger(__name__)


class Stage2CaseParser(CaseParser):
    """
    Extended parser for Stage 2 that extracts natural language components
    Inherits from Stage 1 CaseParser and adds text/question extraction
    """
    
    def __init__(self, cases_dir: str):
        """
        Initialize parser with cases directory
        
        Args:
            cases_dir: Path to directory containing .pl case files
        """
        super().__init__(Path(cases_dir))
        self.cases_dir = Path(cases_dir)
        
    def parse_case_file(self, case_id: str) -> Dict:
        """
        Parse a single case file to extract all components needed for Stage 2
        
        Args:
            case_id: Case identifier (filename without .pl extension)
            
        Returns:
            Dictionary with:
            - text: Natural language description
            - question: Natural language question
            - reference_facts: Original Prolog facts (for evaluation)
            - expected_result: Expected answer (true/false/value)
        """
        # First use parent class to get basic parsing
        case_data = self.parse_case(f"{case_id}.pl")
        
        # Extract natural language text and question
        text = case_data.get('text', '')
        question = case_data.get('question', '')
        
        # Extract reference facts from the facts section
        facts_section = case_data.get('facts', '')
        reference_facts = self._parse_facts_section(facts_section)
        
        # Determine expected result from test
        test = case_data.get('test', '')
        expected_result = self._determine_expected_result(test)
        
        # Additional validation for Stage 2
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
            "test": test  # Include original test for debugging
        }
    
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
            
            # Skip empty lines and the init directive
            if not line or line.startswith(':- '):
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
    
    def _determine_expected_result(self, test: str) -> str:
        """
        Determine the expected result based on the test
        
        Args:
            test: The test section content
            
        Returns:
            'true', 'false', or specific value
        """
        if not test:
            return 'unknown'
            
        # Check for negation
        if test.startswith('\\+') or test.startswith('\\+ '):
            return 'false'
        elif test.strip():
            return 'true'
        else:
            return 'unknown'
    
    def validate_parsed_data(self, case_data: Dict) -> List[str]:
        """
        Validate that parsed data has required components for Stage 2
        
        Returns:
            List of validation errors (empty if valid)
        """
        errors = []
        
        if not case_data.get('text'):
            errors.append("Missing natural language text")
            
        if not case_data.get('question'):
            errors.append("Missing natural language question")
            
        # this reference is good to have, but not necessary
        if not case_data.get('reference_facts'):
            # This is just a warning, not an error, so avoid it if you see it
            logger.debug(f"No reference facts found for {case_data.get('case_id')}")
            
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
            "cases_with_text": 0,
            "cases_with_question": 0,
            "cases_with_facts": 0,
            "avg_text_length": 0,
            "avg_facts_count": 0,
            "parse_errors": 0
        }
        
        text_lengths = []
        fact_counts = []
        
        for case_id in case_ids:
            try:
                case_data = self.parse_case_file(case_id)
                
                if case_data.get('text'):
                    stats['cases_with_text'] += 1
                    text_lengths.append(len(case_data['text']))
                    
                if case_data.get('question'):
                    stats['cases_with_question'] += 1
                    
                if case_data.get('reference_facts'):
                    stats['cases_with_facts'] += 1
                    fact_counts.append(len(case_data['reference_facts']))
                    
            except Exception as e:
                stats['parse_errors'] += 1
                logger.error(f"Error getting stats for {case_id}: {e}")
        
        if text_lengths:
            stats['avg_text_length'] = sum(text_lengths) / len(text_lengths)
        if fact_counts:
            stats['avg_facts_count'] = sum(fact_counts) / len(fact_counts)
            
        return stats
    
    def save_parsed_cases(self, parsed_cases: Dict[str, Dict], output_file: str):
        """
        Save parsed cases to JSON file for inspection
        """
        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Convert to serializable format
        serializable_cases = {}
        for case_id, case_data in parsed_cases.items():
            serializable_cases[case_id] = {
                "case_id": case_data.get("case_id", case_id),
                "text": case_data.get("text", ""),
                "question": case_data.get("question", ""),
                "reference_facts": case_data.get("reference_facts", []),
                "expected_result": case_data.get("expected_result", "unknown"),
                "facts_count": len(case_data.get("reference_facts", [])),
                "text_length": len(case_data.get("text", "")),
                "has_validation_errors": "validation_errors" in case_data,
                "validation_errors": case_data.get("validation_errors", [])
            }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(serializable_cases, f, indent=2, ensure_ascii=False)
            
        logger.info(f"Saved {len(parsed_cases)} parsed cases to {output_path}")


# Utility functions for text processing
def preprocess_text(text: str) -> str:
    """
    Preprocess natural language text for better extraction
    """
    # Normalize whitespace
    text = ' '.join(text.split())
    
    # Fix common OCR/parsing errors
    text = text.replace(' , ', ', ')
    text = text.replace(' . ', '. ')
    
    # Ensure sentences end with periods
    if text and not text[-1] in '.!?':
        text += '.'
        
    return text


def extract_temporal_info(text: str) -> List[Tuple[str, str]]:
    """
    Extract temporal information from text
    Returns list of (event, date) tuples
    """
    temporal_info = []
    
    # Patterns for temporal expressions
    patterns = [
        (r'(\w+)\s+on\s+([A-Z][a-z]+\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{4})', 'event_on_date'),
        (r'(\w+)\s+in\s+(\d{4})', 'event_in_year'),
        (r'from\s+([A-Z][a-z]+\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{4})\s+to\s+([A-Z][a-z]+\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{4})', 'date_range'),
        (r'since\s+([A-Z][a-z]+\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{4})', 'since_date'),
        (r'until\s+([A-Z][a-z]+\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{4})', 'until_date'),
    ]
    
    for pattern, pattern_type in patterns:
        matches = re.finditer(pattern, text, re.IGNORECASE)
        for match in matches:
            if pattern_type == 'event_on_date':
                temporal_info.append((match.group(1), match.group(2)))
            elif pattern_type == 'event_in_year':
                temporal_info.append((match.group(1), match.group(2)))
            elif pattern_type == 'date_range':
                temporal_info.append(('start', match.group(1)))
                temporal_info.append(('end', match.group(2)))
            elif pattern_type in ['since_date', 'until_date']:
                temporal_info.append((pattern_type.split('_')[0], match.group(1)))
                
    return temporal_info


if __name__ == "__main__":
    # Test the parser
    cases_dir = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts/data/sara_v3/cases"
    parser = Stage2CaseParser(cases_dir)
    
    # Test on a few cases
    test_cases = ["tax_case_1", "s151_c_pos", "s3306_b_15_pos"]
    
    print("Testing Stage 2 Case Parser")
    print("=" * 60)
    
    for case_id in test_cases:
        try:
            result = parser.parse_case_file(case_id)
            print(f"\nCase: {case_id}")
            print(f"Text: {result['text'][:100]}..." if result['text'] else "No text")
            print(f"Question: {result['question']}")
            print(f"Reference facts: {len(result['reference_facts'])} facts")
            print(f"Expected result: {result['expected_result']}")
            
            # Show first few facts
            if result['reference_facts']:
                print("First 3 facts:")
                for fact in result['reference_facts'][:3]:
                    print(f"  {fact}")
                    
        except Exception as e:
            print(f"\nError parsing {case_id}: {e}")
    
    # Get statistics
    print("\n" + "=" * 60)
    print("Statistics for initial test cases:")
    test_cases_subset = ["s1_a_1_pos", "s1_a_2_pos", "s63_c_1_pos", "s151_c_pos", 
                         "tax_case_1", "tax_case_10", "tax_case_20", "tax_case_30"]
    stats = parser.get_case_statistics(test_cases_subset)
    for key, value in stats.items():
        print(f"{key}: {value}")