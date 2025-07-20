"""
Stage 3 Method 2 Query Generator
Uses Gemini API to generate answer/2 predicates compatible with Method 2 codebase
"""

import re
import time
import logging
import google.generativeai as genai
from typing import Dict, Optional, List, Tuple
import sys
import os

# Import the prompts module from the same directory
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# Add import for dynamic prompt generator
from dynamic_prompt_generator import get_query_generation_prompt, DynamicPromptGenerator

logger = logging.getLogger(__name__)


class Stage3QueryGenerator:
    """
    Query generator for Stage 3 Method 2 using Gemini API
    Generates answer/2 predicates compatible with Method 2 codebase
    """
    
    def __init__(self, api_key: str, prompt_mode: str = "full", model_name: str = "gemini-2.0-flash-exp"):
        """
        Initialize query generator
        
        Args:
            api_key: Gemini API key
            prompt_mode: Prompt mode ('full', 'fast')
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
        
        # Instantiate DynamicPromptGenerator to get access to the predicate vocabulary
        current_dir = os.path.dirname(os.path.abspath(__file__))
        codebase_dir = os.path.join(os.path.dirname(current_dir), "prolog_codebase")
        self.prompt_generator = DynamicPromptGenerator(codebase_dir)
        self.predicate_vocab = self.prompt_generator.analyzer.generate_prompt_vocabulary()
        
        logger.info(f"Stage 3 Query Generator initialized with {model_name}")
        
    def generate_query(self, query_data: Dict) -> Tuple[str, Dict]:
        """
        Generate answer/2 predicate from question and facts with question type classification
        
        Args:
            query_data: Dictionary with:
                - case_id: Case identifier
                - question: Natural language question
                - facts: Generated facts (string)
                
        Returns:
            Tuple of (Generated answer/2 predicate, raw response metadata with classification)
        """
        case_id = query_data['case_id']
        question = query_data['question']
        facts = query_data['facts']
        
        # Get the appropriate prompt
        prompt_template = get_query_generation_prompt(mode=self.prompt_mode)
        
        # Format the prompt with Method 2 codebase context
        # Convert facts list to string if needed
        facts_str = facts if isinstance(facts, str) else "\n".join(facts)
        
        formatted_prompt = prompt_template.format(
            case_id=case_id,
            question=question,
            facts=facts_str,
            predicate_vocab=self.predicate_vocab
        )
        
        logger.info(f"Generating query for {case_id}")
        logger.debug(f"Question: {question}")
        
        # Initialize raw response metadata
        raw_response_data = {
            'case_id': case_id,
            'prompt': formatted_prompt,
            'model': self.model_name,
            'timestamp': time.time(),
            'raw_response': None,
            'error': None,
            'question_type': None,
            'reasoning': None,
            'type_consistency_check': None
        }
        
        try:
            # Generate response
            response = self.model.generate_content(
                formatted_prompt,
                generation_config=self.generation_config,
                safety_settings=self.safety_settings
            )
            
            # Check for safety filter blocking
            if hasattr(response, 'candidates') and response.candidates:
                finish_reason = response.candidates[0].finish_reason
                if finish_reason == 2:  # SAFETY_BLOCK
                    logger.warning(f"Safety filter blocked response for {case_id}")
                    raw_response_data['error'] = "Safety filter blocked response (finish_reason: 2)"
                    return "", raw_response_data
            
            # Store raw response
            raw_response_data['raw_response'] = response.text if response.text else ""
            
            if not response.text:
                logger.warning(f"Empty response for {case_id}")
                raw_response_data['error'] = "Empty response from LLM"
                return "", raw_response_data
            
            # Add comprehensive logging to debug the parsing issue
            logger.info(f"LLM response length for {case_id}: {len(response.text)} characters")
            logger.info(f"First 200 chars of response: {response.text[:200]}")
            
            # Parse structured response (question type + query)
            parsed_result = self._parse_structured_response(response.text, case_id)
            
            if not parsed_result['success']:
                logger.warning(f"Could not parse structured response for {case_id}: {parsed_result['error']}")
                # Add debug logging to see what the LLM actually returned
                logger.debug(f"Raw LLM response for {case_id}: {response.text}")
                
                # Try emergency fallback parsing - just look for any answer predicate
                fallback_query = self._emergency_fallback_parsing(response.text, case_id)
                if fallback_query:
                    logger.info(f"Emergency fallback found query for {case_id}: {fallback_query}")
                    return fallback_query, raw_response_data
                
                raw_response_data['error'] = f"Parse error: {parsed_result['error']}"
                return "", raw_response_data
            
            # Extract components
            question_type = parsed_result['question_type']
            reasoning = parsed_result['reasoning']
            query = parsed_result['query']
            
            # Store classification info
            raw_response_data['question_type'] = question_type
            raw_response_data['reasoning'] = reasoning
            
            # Validate type consistency
            consistency_check = self._validate_type_consistency(question_type, query, question)
            raw_response_data['type_consistency_check'] = consistency_check
            
            if not consistency_check['is_consistent']:
                logger.warning(f"Type inconsistency for {case_id}: {consistency_check['reason']}")
                raw_response_data['error'] = f"Type inconsistency: {consistency_check['reason']}"
                return "", raw_response_data
            
            logger.info(f"Generated {question_type} query for {case_id}: {query[:100]}...")
            return query, raw_response_data
            
        except Exception as e:
            error_msg = str(e)
            logger.error(f"Error generating query for {case_id}: {error_msg}")
            
            # Check if it's a safety filter block
            if "finish_reason" in error_msg and "2" in error_msg:
                logger.warning(f"Safety filter blocked response for {case_id}")
                raw_response_data['error'] = f"Safety filter blocked: {error_msg}"
            else:
                raw_response_data['error'] = error_msg
            
            return "", raw_response_data
    
    def generate_with_retries(self, query_data: Dict) -> Tuple[str, List[Dict]]:
        """
        Generate query with retry mechanism for robustness and type consistency validation
        
        Args:
            query_data: Query generation data
            
        Returns:
            Tuple of (Generated query, List of raw response metadata from all attempts)
        """
        all_raw_responses = []
        
        for attempt in range(self.max_retries):
            try:
                query, raw_response_data = self.generate_query(query_data)
                raw_response_data['attempt'] = attempt + 1
                all_raw_responses.append(raw_response_data)
                
                # Debug logging
                logger.debug(f"Generated query attempt {attempt + 1}: {query}")
                
                # Check if we got a valid query
                if not query:
                    error_reason = raw_response_data.get('error', 'Unknown error')
                    logger.warning(f"Empty query for {query_data['case_id']} attempt {attempt + 1}: {error_reason}")
                    
                    # If it's a safety filter block, try with a simpler prompt mode
                    if "Safety filter blocked" in error_reason and attempt < self.max_retries - 1:
                        logger.info(f"Trying fallback prompt mode for {query_data['case_id']}")
                        # Switch to emergency mode for next attempt
                        if self.prompt_mode == "full":
                            self.prompt_mode = "fast"
                        elif self.prompt_mode == "fast":
                            self.prompt_mode = "emergency"
                        continue
                    
                    # Add feedback for next attempt if there's a type inconsistency
                    if 'Type inconsistency' in error_reason:
                        self._add_correction_feedback(query_data, raw_response_data)
                        
                    time.sleep(self.base_delay * (2 ** attempt))
                    continue
                
                # If we got a valid query, return it
                return query, all_raw_responses
            
            except Exception as e:
                logger.error(f"Unhandled exception in generate_with_retries for {query_data['case_id']}: {e}")
                raw_response_data['error'] = str(e)
                raw_response_data['attempt'] = attempt + 1
                all_raw_responses.append(raw_response_data)
                
                time.sleep(self.base_delay * (2 ** attempt))
        
        logger.error(f"All attempts failed for {query_data['case_id']}")
        return "", all_raw_responses

    def _add_correction_feedback(self, query_data: Dict, failed_response: Dict):
        """Add correction feedback to the prompt for the next retry attempt."""
        
        # Get the reason for failure
        error_reason = failed_response.get('error', 'Unknown error')
        
        # Prepare a correction message - use standard concatenation to avoid f-string evaluation issues
        correction = (
            '\n**CORRECTION:**\n'
            'Your previous attempt failed with the following error: "' + error_reason + '".\n'
            'Please analyze the original question again and ensure your response matches the required type.\n'
            '- For CALCULATION questions, the query must produce a number.\n'
            '- For LOGIC questions, the query must produce a boolean.\n'
        )
        
        # Prepend the correction to the question for the next attempt
        query_data['question'] = correction + "\n" + query_data['question']
        logger.info(f"Added correction feedback for next attempt on {query_data['case_id']}")

    def _emergency_fallback_parsing(self, response_text: str, case_id: str) -> Optional[str]:
        """
        Emergency fallback parsing when structured parsing fails.
        Just looks for any answer predicate in the response.
        """
        try:
            lines = response_text.strip().split('\n')
            
            # Look for any line that contains an answer predicate
            for line in lines:
                line = line.strip()
                
                # Skip empty lines, comments, and markdown
                if not line or line.startswith('%') or line.startswith('#') or line.startswith('```'):
                    continue
                
                # Look for answer predicate patterns
                if 'answer(' in line and case_id in line:
                    # Try to extract a complete answer predicate
                    if line.endswith('.'):
                        return self._clean_query(line)
                    else:
                        # Try to find the end of the predicate
                        for i, next_line in enumerate(lines[lines.index(line):], start=lines.index(line)):
                            if next_line.strip().endswith('.'):
                                # Combine lines to form complete predicate
                                combined = ' '.join(lines[lines.index(line):i+1])
                                if 'answer(' in combined:
                                    return self._clean_query(combined)
                                break
            
            return None
            
        except Exception as e:
            logger.error(f"Emergency fallback parsing failed for {case_id}: {e}")
            return None

    def _parse_response(self, response_text: str, case_id: str) -> str:
        """
        Parse Gemini response to extract the answer/2 predicate
        
        Args:
            response_text: Raw response from Gemini
            case_id: Case identifier for validation
            
        Returns:
            Cleaned answer/2 predicate
        """
        lines = response_text.strip().split('\n')
        
        for line in lines:
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('%') or line.startswith('#'):
                continue
            
            # Skip markdown code blocks
            if line.startswith('```'):
                continue
            
            # Look for answer predicate
            if line.startswith('answer(') and case_id in line:
                return self._clean_query(line)
        
        # If no direct answer predicate found, try to extract from the response
        return self._extract_query_from_text(response_text, case_id)
    
    def _parse_structured_response(self, response_text: str, case_id: str) -> Dict:
        """
        Parse structured response containing question type, reasoning, and query
        
        Args:
            response_text: Raw response from Gemini with structured format
            case_id: Case identifier for validation
            
        Returns:
            Dictionary with parsing results
        """
        try:
            lines = response_text.strip().split('\n')
            
            question_type = None
            reasoning = None
            query = None
            
            # Parse structured format with flexible matching
            for i, line in enumerate(lines):
                line = line.strip()
                
                # Extract Question Type - flexible matching
                if re.search(r'question\s*type\s*[::\-]?\s*(calculation|logic)', line, re.IGNORECASE):
                    match = re.search(r'(calculation|logic)', line, re.IGNORECASE)
                    if match:
                        question_type = match.group(1).upper()
                
                # Extract Reasoning - flexible matching
                elif re.search(r'reasoning\s*[::\-]?\s*(.+)', line, re.IGNORECASE):
                    match = re.search(r'reasoning\s*[::\-]?\s*(.+)', line, re.IGNORECASE)
                    if match:
                        reasoning = match.group(1).strip()
                
                # Extract Query - flexible matching
                elif re.search(r'query\s*[::\-]?\s*', line, re.IGNORECASE):
                    query_part = re.sub(r'query\s*[::\-]?\s*', '', line, flags=re.IGNORECASE).strip()
                    
                    # Check if query is on the same line or continues on next lines
                    if query_part.startswith('answer(') and query_part.endswith('.'):
                        query = query_part
                    else:
                        # Look for answer predicate in subsequent lines and extract complete multi-line query
                        query_lines = []
                        in_query = False
                        in_code_block = False
                        
                        for j in range(i + 1, len(lines)):
                            next_line = lines[j].strip()
                            
                            # Handle markdown code blocks
                            if next_line.startswith('```'):
                                if next_line == '```prolog' or next_line == '```':
                                    in_code_block = not in_code_block
                                continue
                            
                            # Skip empty lines
                            if not next_line:
                                continue
                            
                            # Start collecting query lines when we find answer(
                            if next_line.startswith('answer(') and case_id in next_line:
                                in_query = True
                                query_lines.append(next_line)
                                continue
                            
                            # If we're in a query, collect lines until we find the end
                            if in_query:
                                query_lines.append(next_line)
                                # Check if this line ends the query (contains a period and proper nesting)
                                if next_line.endswith('.'):
                                    # Simple check: if we have balanced parentheses, this might be the end
                                    full_query = ' '.join(query_lines)
                                    if full_query.count('(') == full_query.count(')'):
                                        query = self._clean_query(full_query)
                                        break
                        
                        # If we didn't find a complete query, try to use what we have
                        if not query and query_lines:
                            query = self._clean_query(' '.join(query_lines))
            
            # Fallback: if structured parsing failed, try to extract from the full response
            if not question_type:
                # Look for question type anywhere in the response
                calc_match = re.search(r'calculation', response_text, re.IGNORECASE)
                logic_match = re.search(r'logic', response_text, re.IGNORECASE)
                if calc_match and not logic_match:
                    question_type = 'CALCULATION'
                elif logic_match and not calc_match:
                    question_type = 'LOGIC'
                elif calc_match and logic_match:
                    # If both found, use the first one
                    if calc_match.start() < logic_match.start():
                        question_type = 'CALCULATION'
                    else:
                        question_type = 'LOGIC'
            
            if not reasoning:
                reasoning = "Extracted from response"
            
            if not query:
                # Try to find any answer predicate in the response
                for line in lines:
                    line = line.strip()
                    if line.startswith('answer(') and case_id in line:
                        query = self._clean_query(line)
                        break
            
            # Validate that we found at least question type and query
            if not question_type:
                return {
                    'success': False,
                    'error': "Question Type not found in response"
                }
            
            if not query:
                return {
                    'success': False,
                    'error': "Query not found in response"
                }
            
            return {
                'success': True,
                'question_type': question_type,
                'reasoning': reasoning,
                'query': query
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f"Parsing exception: {str(e)}"
            }
    
    def _validate_type_consistency(self, question_type: str, query: str, original_question: str) -> Dict:
        """
        Validate that the generated query matches the classified question type
        
        Args:
            question_type: Classified question type (CALCULATION or LOGIC)
            query: Generated Prolog query
            original_question: Original natural language question
            
        Returns:
            Dictionary with consistency check results
        """
        try:
            # Basic validation patterns
            has_comparison = any(op in query for op in ['=:=', '=\\=', '>', '<', '>=', '=<'])
            has_conditional = '->' in query and ';' in query
            has_true_false = 'true' in query and 'false' in query
            
            # Extract predicates that typically return numerical values
            # Enhanced list to include all calculation-related predicates
            calculation_patterns = [
                'exemption_amount', 'tax_imposed', 'standard_deduction',
                'taxable_income', 'calculate_tax', 'gross_income',
                'personal_exemption_deduction', 'basic_standard_deduction',
                'additional_standard_deduction', 'filing_status',
                'futa_tax', 'total_wages', 'limited_itemized_deductions'
            ]
            has_calculation_predicate = any(pattern in query for pattern in calculation_patterns)
            
            # Check for module-prefixed predicates (e.g., section1:tax_imposed)
            has_module_calculation = any(f':{pattern}' in query for pattern in calculation_patterns)
            
            if question_type == 'CALCULATION':
                # For calculation questions, expect predicates that return values
                # Should NOT have complex conditional logic for true/false
                if has_conditional and has_true_false and '=:=' in query:
                    return {
                        'is_consistent': False,
                        'reason': 'CALCULATION question but query contains true/false conditional logic'
                    }
                
                # Accept if has calculation predicates OR module-prefixed calculation predicates
                if not (has_calculation_predicate or has_module_calculation):
                    # Additional check: if it's a simple query that just calls predicates, it might be valid
                    # Check if the query body contains at least one predicate call
                    if '(' in query and ')' in query:
                        # This is likely a valid calculation query even if specific patterns weren't found
                        return {
                            'is_consistent': True,
                            'reason': 'CALCULATION query with predicate calls'
                        }
                    else:
                        return {
                            'is_consistent': False,
                            'reason': 'CALCULATION question but no calculation predicates found'
                        }
                
            elif question_type == 'LOGIC':
                # For logic questions, expect conditional structures
                # Should test conditions and return true/false
                if not (has_conditional or has_comparison or has_true_false):
                    return {
                        'is_consistent': False,
                        'reason': 'LOGIC question but no conditional logic or comparisons found'
                    }
                
                # Additional check: contradiction/entailment questions should have specific patterns
                if 'contradiction' in original_question.lower():
                    if '-> Result = false' not in query and '-> Result = true' not in query:
                        return {
                            'is_consistent': False,
                            'reason': 'Contradiction question but no true/false result assignment found'
                        }
                
            return {
                'is_consistent': True,
                'reason': f'{question_type} question with appropriate query structure'
            }
            
        except Exception as e:
            return {
                'is_consistent': False,
                'reason': f'Validation error: {str(e)}'
            }
    
    def _clean_query(self, query: str) -> str:
        """
        Clean and standardize a query
        
        Args:
            query: Raw query string
            
        Returns:
            Cleaned query string
        """
        # Remove extra whitespace
        query = ' '.join(query.split())
        
        # Ensure proper ending
        if not query.endswith('.'):
            query += '.'
        
        return query
    
    def _extract_query_from_text(self, text: str, case_id: str) -> str:
        """
        Try to extract a query from natural language response
        This is a fallback for cases where Gemini doesn't format properly
        
        Args:
            text: Natural language text
            case_id: Case identifier
            
        Returns:
            Extracted or constructed query
        """
        # Look for key patterns
        if 'get_taxable_income' in text and 's1_calculate_tax_from_ti' in text:
            # Tax calculation query
            return f"answer('{case_id}', Result) :- get_taxable_income({case_id}, _Person, _Year, TaxableIncome), section1:s1_calculate_tax_from_ti({case_id}, _Person, _Year, TaxableIncome, Result)."
        
        if 'evaluate_statement_truth' in text:
            # Entailment/contradiction query
            return f"answer('{case_id}', Result) :- _SomeStatutePredicate({case_id}, _Person, _Year, StatementTruth), evaluate_statement_truth(StatementTruth, _Type, Result)."
        
        # Try to find any predicate calls
        predicate_match = re.search(r'(\w+:\w+\([^)]+\))', text)
        if predicate_match:
            predicate_call = predicate_match.group(1)
            return f"answer('{case_id}', Result) :- ({predicate_call} -> Result = true ; Result = false)."
        
        # No fallback - return empty string
        return ""
    
    def _is_valid_query(self, query: str, case_id: str) -> bool:
        """
        Validate that a query is properly formatted
        
        Args:
            query: Query string to validate
            case_id: Expected case ID
            
        Returns:
            True if query is valid
        """
        # Must start with answer(
        if not query.startswith('answer('):
            return False
        
        # Must contain the correct case_id
        if case_id not in query:
            return False
        
        # Must end with .
        if not query.endswith('.'):
            return False
        
        # Must contain ':-'
        if ':-' not in query:
            return False
        
        # Check that there's meaningful content after ':-'
        parts = query.split(':-')
        if len(parts) != 2:
            return False
        
        # Extract the body (everything after ':-')
        body = parts[1].strip()
        # Remove the final period and check if there's content
        body_content = body.rstrip('.').strip()
        if not body_content:
            # Empty body after ':-' - this is invalid
            return False
        
        # Basic syntax check
        try:
            # Count parentheses
            open_parens = query.count('(')
            close_parens = query.count(')')
            if open_parens != close_parens:
                return False
            
            return True
        except:
            return False
    
    def analyze_query_type(self, query: str) -> Dict:
        """
        Analyze the type and components of a generated query
        
        Args:
            query: Query string to analyze
            
        Returns:
            Analysis report
        """
        analysis = {
            'query_type': 'unknown',
            'uses_tax_calculation': False,
            'uses_statute_predicate': False,
            'uses_evaluation_helper': False,
            'complexity': 'simple',
            'predicates_called': []
        }
        
        # Detect tax calculation queries
        if 'get_taxable_income' in query and 's1_calculate_tax_from_ti' in query:
            analysis['query_type'] = 'tax_calculation'
            analysis['uses_tax_calculation'] = True
            analysis['complexity'] = 'complex'
        
        # Detect statute predicate usage
        section_predicates = re.findall(r'section\d+:\w+', query)
        if section_predicates:
            analysis['uses_statute_predicate'] = True
            analysis['predicates_called'].extend(section_predicates)
            if analysis['query_type'] == 'unknown':
                analysis['query_type'] = 'statutory_test'
        
        # Detect evaluation helper usage
        if 'evaluate_statement_truth' in query:
            analysis['uses_evaluation_helper'] = True
            if analysis['query_type'] == 'unknown':
                analysis['query_type'] = 'entailment_test'
        
        # Extract all predicate calls
        all_predicates = re.findall(r'\w+\([^)]*\)', query)
        analysis['predicates_called'].extend(all_predicates)
        
        # Determine complexity
        if len(analysis['predicates_called']) > 3:
            analysis['complexity'] = 'complex'
        elif len(analysis['predicates_called']) > 1:
            analysis['complexity'] = 'medium'
        
        return analysis 