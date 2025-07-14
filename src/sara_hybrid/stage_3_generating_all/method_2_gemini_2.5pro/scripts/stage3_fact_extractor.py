"""
Stage 3 Method 2 Fact Extractor
Uses Gemini API with semantic prompts to generate Method 2 compatible facts
"""

import os
import re
import time
import logging
import google.generativeai as genai
from typing import List, Dict, Optional, Tuple
import sys
import os

# Import the prompts module from the same directory
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# Add import for dynamic prompt generator
from dynamic_prompt_generator import get_fact_extraction_prompt

logger = logging.getLogger(__name__)

class Stage3FactExtractor:
    """
    Fact extractor for Stage 3 Method 2 using Gemini API
    Generates semantic facts compatible with Method 2 codebase
    """
    
    def __init__(self, api_key: str, prompt_mode: str = "full", model_name: str = "gemini-2.0-flash-exp"):
        """
        Initialize fact extractor
        
        Args:
            api_key: Gemini API key
            prompt_mode: Prompt mode ('full', 'fast', 'emergency')
            model_name: Gemini model to use
        """
        self.api_key = api_key
        self.prompt_mode = prompt_mode
        self.model_name = model_name
        
        # Configure Gemini API
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel(model_name)
        
        # Import model config manager for better configuration
        from model_config import ModelConfigManager
        model_manager = ModelConfigManager(api_key)
        
        # Generation config for consistent output
        self.generation_config = model_manager.get_generation_config(model_name)
        
        # Safety settings for legal text processing
        self.safety_settings = model_manager.get_safety_settings(model_name)
        
        # Retry configuration
        self.max_retries = 3
        self.base_delay = 1.0
        
        # Load Method 2 codebase for LLM context
        self.method2_codebase = self._load_method2_codebase()
        
        logger.info(f"Stage 3 Fact Extractor initialized with {model_name}")
        
    def _load_method2_codebase(self) -> str:
        """Load the Method 2 prolog codebase predicate signatures for LLM context"""
        current_dir = os.path.dirname(os.path.abspath(__file__))
        codebase_dir = os.path.join(os.path.dirname(current_dir), "prolog_codebase")
        
        # Extract predicate signatures from core files
        predicate_signatures = []
        
        # Core files to scan for predicates
        core_files = [
            "helpers.pl",
            "knowledge_base.pl", 
            "section1.pl",
            "section2.pl",
            "section63.pl",
            "section68.pl",
            "section151.pl",
            "section152.pl",
            "section3301.pl",
            "section3306.pl", 
            "section7703.pl"
        ]
        
        for file in core_files:
            file_path = os.path.join(codebase_dir, file)
            if os.path.exists(file_path):
                try:
                    with open(file_path, 'r') as f:
                        content = f.read()
                        signatures = self._extract_predicate_signatures(content, file)
                        if signatures:
                            predicate_signatures.append(f"% === {file} predicates ===")
                            predicate_signatures.extend(signatures)
                except Exception as e:
                    logging.warning(f"Error reading {file}: {e}")
            else:
                logging.warning(f"Method 2 codebase file not found: {file}")
                
        return "\n".join(predicate_signatures)
    
    def _extract_predicate_signatures(self, content: str, filename: str) -> List[str]:
        """Extract predicate signatures from Prolog file content"""
        signatures = []
        lines = content.split('\n')
        
        for line in lines:
            line = line.strip()
            
            # Skip comments and empty lines
            if not line or line.startswith('%'):
                continue
                
            # Look for predicate definitions (rules and facts)
            if ':-' in line and not line.startswith(':-'):
                # This is a rule: predicate(args) :- body.
                head = line.split(':-')[0].strip()
                if '(' in head and ')' in head:
                    signatures.append(f"% {head}")
            elif line.endswith('.') and '(' in line and ')' in line and not line.startswith(':-'):
                # This is a fact: predicate(args).
                pred = line[:-1].strip()  # Remove the period
                if not any(char in pred for char in ['=', '<', '>', '+']):  # Filter out arithmetic
                    signatures.append(f"% {pred}")
        
        return signatures[:20]  # Limit to first 20 signatures per file
    
    def extract_facts(self, text: str, case_id: str) -> Tuple[List[str], Dict]:
        """
        Extract semantic facts from natural language text
        
        Args:
            text: Natural language case description
            case_id: Case identifier for fact generation
            
        Returns:
            Tuple of (List of Prolog facts in Method 2 format, raw response metadata)
        """
        # Get the appropriate prompt
        prompt_template = get_fact_extraction_prompt(mode=self.prompt_mode)
        
        # Format the prompt with Method 2 codebase context
        formatted_prompt = prompt_template.format(
            text=text,
            case_id=case_id,
            codebase=self.method2_codebase
        )
        
        logger.info(f"Extracting facts for {case_id} using {self.prompt_mode} mode")
        logger.debug(f"Text: {text[:100]}...")
        
        # Initialize raw response metadata
        raw_response_data = {
            'case_id': case_id,
            'prompt': formatted_prompt,
            'model': self.model_name,
            'timestamp': time.time(),
            'raw_response': None,
            'error': None
        }
        
        try:
            # Generate response
            response = self.model.generate_content(
                formatted_prompt,
                generation_config=self.generation_config,
                safety_settings=self.safety_settings
            )
            
            # Store raw response
            raw_response_data['raw_response'] = response.text if response.text else ""
            
            if not response.text:
                logger.warning(f"Empty response for {case_id}")
                raw_response_data['error'] = "Empty response from LLM"
                return [], raw_response_data
            
            # Parse the response into individual facts
            facts = self._parse_response(response.text, case_id)
            
            logger.info(f"Extracted {len(facts)} facts for {case_id}")
            return facts, raw_response_data
            
        except Exception as e:
            logger.error(f"Error extracting facts for {case_id}: {e}")
            raw_response_data['error'] = str(e)
            return [], raw_response_data
    
    def extract_with_retries(self, text: str, case_id: str) -> Tuple[List[str], List[Dict]]:
        """
        Extract facts with retry mechanism for robustness
        
        Args:
            text: Natural language case description
            case_id: Case identifier
            
        Returns:
            Tuple of (List of extracted facts, List of raw response metadata from all attempts)
        """
        all_raw_responses = []
        
        for attempt in range(self.max_retries):
            try:
                facts, raw_response_data = self.extract_facts(text, case_id)
                raw_response_data['attempt'] = attempt + 1
                all_raw_responses.append(raw_response_data)
                
                # Validate extraction quality
                if len(facts) >= 2:  # Minimum threshold
                    logger.info(f"Successfully extracted {len(facts)} facts for {case_id} (attempt {attempt + 1})")
                    return facts, all_raw_responses
                else:
                    logger.warning(f"Poor extraction for {case_id} attempt {attempt + 1}: only {len(facts)} facts")
                    if attempt < self.max_retries - 1:
                        time.sleep(self.base_delay * (2 ** attempt))
                        continue
                    else:
                        return facts, all_raw_responses  # Return whatever we got on final attempt
                        
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {case_id}: {e}")
                # Add error response data
                error_response_data = {
                    'case_id': case_id,
                    'attempt': attempt + 1,
                    'model': self.model_name,
                    'timestamp': time.time(),
                    'raw_response': None,
                    'error': str(e)
                }
                all_raw_responses.append(error_response_data)
                
                if attempt < self.max_retries - 1:
                    time.sleep(self.base_delay * (2 ** attempt))
                else:
                    return [], all_raw_responses
        
        return [], all_raw_responses
    
    def _parse_response(self, response_text: str, case_id: str) -> List[str]:
        """
        Parse Gemini response to extract individual Prolog facts
        
        Args:
            response_text: Raw response from Gemini
            case_id: Case identifier for validation
            
        Returns:
            List of cleaned Prolog facts
        """
        facts = []
        lines = response_text.strip().split('\n')
        
        for line in lines:
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('%') or line.startswith('#'):
                continue
            
            # Skip markdown code blocks
            if line.startswith('```'):
                continue
            
            # Look for fact patterns
            if self._is_valid_fact(line, case_id):
                # Clean up the fact
                cleaned_fact = self._clean_fact(line)
                if cleaned_fact:
                    facts.append(cleaned_fact)
            else:
                # Try to extract fact from natural language response
                extracted_fact = self._extract_fact_from_text(line, case_id)
                if extracted_fact:
                    facts.append(extracted_fact)
        
        # Remove duplicates while preserving order
        unique_facts = []
        seen = set()
        for fact in facts:
            if fact not in seen:
                unique_facts.append(fact)
                seen.add(fact)
        
        return unique_facts
    
    def _is_valid_fact(self, line: str, case_id: str) -> bool:
        """
        Check if a line contains a valid Method 2 fact
        
        Args:
            line: Line to check
            case_id: Expected case ID
            
        Returns:
            True if line contains valid fact
        """
        # Must start with fact(
        if not line.startswith('fact('):
            return False
        
        # Must contain the correct case_id
        if case_id not in line:
            return False
        
        # Must end with ).
        if not (line.endswith(').') or line.endswith(')')):
            return False
        
        # Basic syntax check
        try:
            # Count parentheses
            open_parens = line.count('(')
            close_parens = line.count(')')
            if open_parens != close_parens:
                return False
            
            return True
        except:
            return False
    
    def _clean_fact(self, fact: str) -> str:
        """
        Clean and standardize a fact
        
        Args:
            fact: Raw fact string
            
        Returns:
            Cleaned fact string
        """
        # Remove extra whitespace
        fact = ' '.join(fact.split())
        
        # Ensure proper ending
        if not fact.endswith('.'):
            if fact.endswith(')'):
                fact += '.'
            else:
                fact += ').'
        
        return fact
    
    def _extract_fact_from_text(self, text: str, case_id: str) -> Optional[str]:
        """
        Try to extract a fact from a natural language description
        This is a fallback for cases where Gemini doesn't format properly
        
        Args:
            text: Natural language text
            case_id: Case identifier
            
        Returns:
            Extracted fact or None
        """
        # Look for key patterns
        patterns = [
            r'taxpayer\s*\(\s*(\w+)\s*\)',
            r'gross_income\s*\(\s*(\w+)\s*,\s*(\d{4})\s*,\s*(\d+)\s*\)',
            r'spouse\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)',
            r'child_of\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                # Reconstruct as proper fact
                predicate = pattern.split('\\')[0].replace('\\s*', '').replace('(', '')
                args = ', '.join(match.groups())
                return f"fact({case_id}, {predicate}({args}))."
        
        return None
    
    def validate_extraction(self, facts: List[str], case_id: str) -> Dict:
        """
        Validate the quality of extracted facts
        
        Args:
            facts: List of extracted facts
            case_id: Case identifier
            
        Returns:
            Validation report
        """
        report = {
            'total_facts': len(facts),
            'valid_facts': 0,
            'invalid_facts': 0,
            'has_taxpayer': False,
            'has_income': False,
            'has_relationships': False,
            'predicate_counts': {},
            'errors': []
        }
        
        for fact in facts:
            if self._is_valid_fact(fact, case_id):
                report['valid_facts'] += 1
                
                # Extract predicate
                predicate_match = re.search(r'fact\([^,]+,\s*(\w+)\(', fact)
                if predicate_match:
                    predicate = predicate_match.group(1)
                    report['predicate_counts'][predicate] = report['predicate_counts'].get(predicate, 0) + 1
                    
                    # Check for important predicates
                    if predicate == 'taxpayer':
                        report['has_taxpayer'] = True
                    elif predicate in ['gross_income', 'adjusted_gross_income']:
                        report['has_income'] = True
                    elif predicate in ['spouse', 'child_of', 'sibling_of']:
                        report['has_relationships'] = True
            else:
                report['invalid_facts'] += 1
                report['errors'].append(f"Invalid fact: {fact}")
        
        # Overall quality score
        quality_score = 0
        if report['has_taxpayer']:
            quality_score += 30
        if report['has_income']:
            quality_score += 30
        if report['has_relationships']:
            quality_score += 20
        if report['valid_facts'] >= 5:
            quality_score += 20
        
        report['quality_score'] = quality_score
        
        return report 