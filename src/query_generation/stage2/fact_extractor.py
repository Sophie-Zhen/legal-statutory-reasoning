"""
Fact Extractor - LLM generates all facts based on SARA examples
Implements neuro-symbolic approach: LLM understanding + symbolic validation
"""

import re
import json
import logging
import time
from typing import List, Dict, Optional, Tuple
import google.generativeai as genai
from prompts import get_fact_extraction_prompt, EMERGENCY_EXTRACTION_PROMPT

logger = logging.getLogger(__name__)


class FactExtractor:
    """
    Uses LLM to extract SARA-format facts from natural language
    No hardcoding - LLM learns from examples
    """
    
    def __init__(self, api_key: str, prompt_mode: str = "full"):
        """Initialize Gemini 2.5 Pro"""
        genai.configure(api_key=api_key)
        
        # Safety settings
        safety_settings = [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"}
        ]
        
        # Initialize model
        self.model = genai.GenerativeModel(
            'gemini-2.5-pro',
            safety_settings=safety_settings
        )
        
        self.prompt_mode = prompt_mode
        logger.info(f"Initialized Gemini 2.5 Pro (mode: {prompt_mode})")
        
    def extract_facts(self, text: str, statutes: str, case_id: str) -> List[str]:
        """
        Extract facts using LLM - main neuro-symbolic interface
        
        Args:
            text: Natural language legal text
            statutes: Prolog statutes for context
            case_id: Case identifier
            
        Returns:
            List of SARA-format Prolog facts
        """
        logger.info(f"Extracting facts for: {case_id}")
        
        try:
            # Get prompt template
            prompt_template = get_fact_extraction_prompt(self.prompt_mode)
            
            # Create prompt with text
            prompt = prompt_template.format(text=text)
            
            # Call LLM
            response = self.model.generate_content(prompt)
            raw_response = response.text
            
            logger.debug(f"LLM response preview: {raw_response[:300]}...")
            
            # Parse response
            facts = self._parse_llm_response(raw_response)
            
            # Validate SARA format
            facts = self._validate_sara_format(facts, text)
            
            # Fix character positions
            facts = self._fix_character_positions(facts, text)
            
            logger.info(f"Extracted {len(facts)} facts for {case_id}")
            
            # Log sample facts for debugging
            if facts:
                logger.debug("Sample facts:")
                for fact in facts[:3]:
                    logger.debug(f"  {fact}")
            
            return facts
            
        except Exception as e:
            logger.error(f"Error in fact extraction: {e}")
            return []
    
    def _parse_llm_response(self, response: str) -> List[str]:
        """Parse LLM response to extract Prolog facts"""
        facts = []
        lines = response.strip().split('\n')
        
        for line in lines:
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('%') or line.startswith('#'):
                continue
            
            # Remove markdown
            line = re.sub(r'^[-*]\s*', '', line)
            line = re.sub(r'^\d+\.\s*', '', line)
            line = line.replace('```prolog', '').replace('```', '')
            
            # Check if it's a fact
            if line.endswith('.') and '(' in line and ')' in line:
                facts.append(line)
        
        return facts
    
    def _validate_sara_format(self, facts: List[str], text: str) -> List[str]:
        """Validate facts match SARA format"""
        valid_facts = []
        
        # Invalid predicates that don't exist in SARA
        invalid_predicates = [
            'filing_status_', 'takes_standard_deduction_', 
            'file_separately_', 'itemized_deduction_',
            'standard_deduction_applies_', 'deduction_'
        ]
        
        for fact in facts:
            # Skip invalid predicates
            if any(pred in fact for pred in invalid_predicates):
                logger.debug(f"Skipping invalid predicate: {fact}")
                continue
            
            # Validate basic structure
            if self._is_valid_prolog_fact(fact):
                valid_facts.append(fact)
            else:
                logger.warning(f"Invalid fact structure: {fact}")
        
        return valid_facts
    
    def _fix_character_positions(self, facts: List[str], text: str) -> List[str]:
        """Fix character positions in span objects"""
        fixed_facts = []
        
        for fact in facts:
            # Find all span objects
            span_pattern = r'span\(([^,)]+),(\d+),(\d+)\)'
            
            def fix_span(match):
                content = match.group(1).strip('"\'')
                old_start = int(match.group(2))
                old_end = int(match.group(3))
                
                # Find actual position in text
                pos = text.find(content)
                if pos != -1:
                    # Found exact match
                    start = pos
                    end = pos + len(content) - 1
                else:
                    # Try case-insensitive search
                    pos = text.lower().find(content.lower())
                    if pos != -1:
                        start = pos
                        end = pos + len(content) - 1
                    else:
                        # Keep original if not found
                        start = old_start
                        end = old_end
                
                # Format based on content type
                if content.isdigit():
                    # Numbers don't need quotes
                    return f'span({content},{start},{end})'
                else:
                    # Everything else needs quotes
                    return f'span("{content}",{start},{end})'
            
            fixed_fact = re.sub(span_pattern, fix_span, fact)
            fixed_facts.append(fixed_fact)
        
        return fixed_facts
    
    def _is_valid_prolog_fact(self, fact: str) -> bool:
        """Check if string is valid Prolog fact"""
        fact = fact.strip()
        
        # Must end with period
        if not fact.endswith('.'):
            return False
        
        # Must have predicate structure
        if '(' not in fact or ')' not in fact:
            return False
        
        # Balanced parentheses
        if fact.count('(') != fact.count(')'):
            return False
        
        return True
    
    def extract_with_retries(self, text: str, statutes: str, case_id: str, 
                           max_retries: int = 2) -> List[str]:
        """
        Extract with retry logic for quota management
        
        This implements the fault-tolerant part of our neuro-symbolic approach
        """
        for attempt in range(max_retries + 1):
            try:
                # Rate limiting
                if attempt > 0:
                    wait_time = 2 ** attempt  # Exponential backoff
                    logger.info(f"Waiting {wait_time}s before retry...")
                    time.sleep(wait_time)
                
                # Try extraction
                facts = self.extract_facts(text, statutes, case_id)
                
                # Validate we got enough facts
                if facts and len(facts) >= 3:
                    return facts
                
                logger.warning(f"Insufficient facts ({len(facts)}) on attempt {attempt + 1}")
                
            except Exception as e:
                error_str = str(e)
                if '429' in error_str or 'quota' in error_str.lower():
                    logger.warning(f"Quota exceeded on attempt {attempt + 1}")
                else:
                    logger.error(f"Error on attempt {attempt + 1}: {e}")
        
        # Emergency fallback
        logger.warning(f"Using emergency extraction for {case_id}")
        return self._emergency_extraction(text, case_id)
    
    def _emergency_extraction(self, text: str, case_id: str) -> List[str]:
        """Minimal extraction when quota is low"""
        try:
            prompt = EMERGENCY_EXTRACTION_PROMPT.format(text=text)
            response = self.model.generate_content(prompt)
            
            facts = self._parse_llm_response(response.text)
            facts = self._validate_sara_format(facts, text)
            facts = self._fix_character_positions(facts, text)
            
            if len(facts) < 3:
                facts.append(f'% WARNING: Emergency extraction - incomplete facts')
            
            return facts
            
        except Exception as e:
            logger.error(f"Emergency extraction failed: {e}")
            return [f'% ERROR: Complete extraction failure for {case_id}']