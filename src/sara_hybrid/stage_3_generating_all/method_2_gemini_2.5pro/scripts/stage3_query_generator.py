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
from dynamic_prompt_generator import get_query_generation_prompt

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
        
        # Load Method 2 codebase for LLM context
        self.method2_codebase = self._load_method2_codebase()
        
        logger.info(f"Stage 3 Query Generator initialized with {model_name}")
        
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
        formatted_prompt = prompt_template.format(
            case_id=case_id,
            question=question,
            facts=facts,
            codebase=self.method2_codebase
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
            
            # Store raw response
            raw_response_data['raw_response'] = response.text if response.text else ""
            
            if not response.text:
                logger.warning(f"Empty response for {case_id}")
                raw_response_data['error'] = "Empty response from LLM"
                return "", raw_response_data
            
            # Parse structured response (question type + query)
            parsed_result = self._parse_structured_response(response.text, case_id)
            
            if not parsed_result['success']:
                logger.warning(f"Could not parse structured response for {case_id}: {parsed_result['error']}")
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
            logger.error(f"Error generating query for {case_id}: {e}")
            raw_response_data['error'] = str(e)
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
                    
                    if attempt < self.max_retries - 1:
                        # Add feedback for next attempt if it was a type inconsistency
                        if 'Type inconsistency' in error_reason:
                            self._add_type_feedback_to_next_attempt(query_data, raw_response_data)
                        time.sleep(self.base_delay * (2 ** attempt))
                        continue
                    else:
                        logger.error(f"All attempts failed for {query_data['case_id']}")
                        return "", all_raw_responses
                
                # Validate query syntax
                is_valid = self._is_valid_query(query, query_data['case_id'])
                logger.debug(f"Query validation result: {is_valid}")
                
                if is_valid:
                    logger.info(f"Successfully generated query for {query_data['case_id']} (attempt {attempt + 1})")
                    return query, all_raw_responses
                else:
                    logger.warning(f"Invalid query syntax for {query_data['case_id']} attempt {attempt + 1}: {query}")
                    if attempt < self.max_retries - 1:
                        time.sleep(self.base_delay * (2 ** attempt))
                        continue
                    else:
                        logger.error(f"All attempts failed for {query_data['case_id']} - invalid syntax")
                        return "", all_raw_responses
                        
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed for {query_data['case_id']}: {e}")
                # Add error response data
                error_response_data = {
                    'case_id': query_data['case_id'],
                    'attempt': attempt + 1,
                    'model': self.model_name,
                    'timestamp': time.time(),
                    'raw_response': None,
                    'error': str(e),
                    'question_type': None,
                    'reasoning': None,
                    'type_consistency_check': None
                }
                all_raw_responses.append(error_response_data)
                
                if attempt < self.max_retries - 1:
                    time.sleep(self.base_delay * (2 ** attempt))
                else:
                    logger.error(f"All attempts failed for {query_data['case_id']} due to exceptions")
                    return "", all_raw_responses
        
        # If we reach here, all attempts failed
        logger.error(f"All {self.max_retries} attempts failed for {query_data['case_id']}")
        return "", all_raw_responses
    
    def _add_type_feedback_to_next_attempt(self, query_data: Dict, failed_response: Dict):
        """
        Add feedback about type inconsistency to help the next attempt
        
        Args:
            query_data: Query generation data (will be modified)
            failed_response: Response data from failed attempt
        """
        consistency_check = failed_response.get('type_consistency_check', {})
        if consistency_check:
            feedback = f"\n\n**FEEDBACK FROM PREVIOUS ATTEMPT:**\n"
            feedback += f"Previous classification: {failed_response.get('question_type', 'Unknown')}\n"
            feedback += f"Issue: {consistency_check.get('reason', 'Type mismatch')}\n"
            feedback += f"Please reconsider the question type and ensure your query structure matches.\n"
            
            # Add feedback to the question for next attempt
            query_data['question'] = query_data['question'] + feedback
    
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
            
            # Parse structured format
            for i, line in enumerate(lines):
                line = line.strip()
                
                # Extract Question Type
                if line.startswith('Question Type:'):
                    question_type = line.replace('Question Type:', '').strip()
                    # Validate question type
                    if question_type not in ['CALCULATION', 'LOGIC']:
                        return {
                            'success': False,
                            'error': f"Invalid question type: {question_type}. Must be CALCULATION or LOGIC."
                        }
                
                # Extract Reasoning
                elif line.startswith('Reasoning:'):
                    reasoning = line.replace('Reasoning:', '').strip()
                
                # Extract Query
                elif line.startswith('Query:'):
                    query_part = line.replace('Query:', '').strip()
                    
                    # Check if query is on the same line or continues on next lines
                    if query_part.startswith('answer(') and query_part.endswith('.'):
                        query = query_part
                    else:
                        # Look for answer predicate in subsequent lines
                        for j in range(i + 1, len(lines)):
                            next_line = lines[j].strip()
                            if next_line.startswith('answer(') and case_id in next_line:
                                query = self._clean_query(next_line)
                                break
            
            # Validate that all components were found
            if not question_type:
                return {
                    'success': False,
                    'error': "Question Type not found in response"
                }
            
            if not reasoning:
                return {
                    'success': False,
                    'error': "Reasoning not found in response"
                }
            
            if not query:
                # Try fallback parsing if structured format failed
                query = self._parse_response(response_text, case_id)
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
            calculation_patterns = [
                'exemption_amount', 'tax_imposed', 'standard_deduction',
                'taxable_income', 'calculate_tax', 'gross_income'
            ]
            has_calculation_predicate = any(pattern in query for pattern in calculation_patterns)
            
            if question_type == 'CALCULATION':
                # For calculation questions, expect predicates that return values
                # Should NOT have complex conditional logic
                if has_conditional and has_true_false:
                    return {
                        'is_consistent': False,
                        'reason': 'CALCULATION question but query contains true/false logic'
                    }
                
                if not has_calculation_predicate:
                    return {
                        'is_consistent': False,
                        'reason': 'CALCULATION question but no calculation predicates found'
                    }
                
            elif question_type == 'LOGIC':
                # For logic questions, expect conditional structures
                # Should test conditions and return true/false
                if not (has_conditional or has_comparison):
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
                
                if 'entailment' in original_question.lower():
                    if '-> Result = true' not in query and '-> Result = false' not in query:
                        return {
                            'is_consistent': False,
                            'reason': 'Entailment question but no true/false result assignment found'
                        }
            
            return {
                'is_consistent': True,
                'reason': 'Query structure matches question type'
            }
            
        except Exception as e:
            return {
                'is_consistent': False,
                'reason': f"Validation error: {str(e)}"
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