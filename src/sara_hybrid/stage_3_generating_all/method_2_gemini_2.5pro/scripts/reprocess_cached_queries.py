#!/usr/bin/env python3
"""
Reprocess Cached Queries Script
Reprocesses cached LLM responses with fixed parsing logic to generate correct Prolog files
without making new API calls.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List
import logging

# Add the scripts directory to the path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from stage3_query_generator import Stage3QueryGenerator
from stage3_cache_manager import Stage3CacheManager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CachedQueryReprocessor:
    """Reprocesses cached LLM responses with fixed parsing logic"""
    
    def __init__(self):
        self.cache_dir = current_dir.parent / "cache" / "stage3_test_split"
        self.results_dir = current_dir.parent / "results" / "stage3_test_split" / "prolog"
        self.results_dir.mkdir(parents=True, exist_ok=True)
        
        # Create a dummy query generator just to use its parsing methods
        self.query_generator = Stage3QueryGenerator("dummy_key", "full", "gemini-2.5-pro")
        
    def get_tax_cases(self) -> List[str]:
        """Get the 20 tax calculation cases from the test split"""
        return [
            'tax_case_28', 'tax_case_30', 'tax_case_31', 'tax_case_34', 'tax_case_43',
            'tax_case_46', 'tax_case_48', 'tax_case_49', 'tax_case_53', 'tax_case_57',
            'tax_case_68', 'tax_case_69', 'tax_case_75', 'tax_case_77', 'tax_case_78',
            'tax_case_82', 'tax_case_85', 'tax_case_9', 'tax_case_90', 'tax_case_93'
        ]
    
    def load_cached_response(self, case_id: str) -> Dict:
        """Load cached response for a case"""
        cache_file = self.cache_dir / f"{case_id}.json"
        if not cache_file.exists():
            logger.warning(f"No cache file found for {case_id}")
            return None
        
        with open(cache_file, 'r') as f:
            return json.load(f)
    
    def reprocess_query(self, case_id: str, raw_response: str) -> str:
        """Reprocess a raw LLM response with fixed parsing logic"""
        try:
            # Use the fixed parsing logic from the query generator
            parsed_result = self.query_generator._parse_structured_response(raw_response, case_id)
            
            if parsed_result['success']:
                return parsed_result['query']
            else:
                logger.warning(f"Failed to parse {case_id}: {parsed_result['error']}")
                return ""
        except Exception as e:
            logger.error(f"Error reprocessing {case_id}: {e}")
            return ""
    
    def generate_prolog_file(self, case_id: str, facts: List[str], query: str, 
                           text: str, question: str) -> str:
        """Generate a complete Prolog file"""
        prolog_content = []
        
        # Add header
        prolog_content.append(f"% Generated Prolog file for {case_id}")
        prolog_content.append(f"% Original text: {text}")
        prolog_content.append(f"% Question: {question}")
        prolog_content.append("")
        
        # Add module imports using the same pattern as stage3_pipeline.py
        prolog_content.append("% MODULE IMPORTS")
        codebase_rel_path = "../../../prolog_codebase"
        prolog_content.append(f":- use_module('{codebase_rel_path}/section1').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section2').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section63').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section68').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section151').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section152').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section3306').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/section7703').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/helpers').")
        prolog_content.append(f":- use_module('{codebase_rel_path}/knowledge_base').")
        prolog_content.append("")
        
        # Add facts
        prolog_content.append("% FACTS (Generated from natural language text)")
        for fact in facts:
            prolog_content.append(fact)
        prolog_content.append("")
        
        # Add query
        prolog_content.append("% QUERY (Generated from natural language question)")
        prolog_content.append(query)
        
        return "\n".join(prolog_content)
    
    def reprocess_case(self, case_id: str) -> bool:
        """Reprocess a single case"""
        logger.info(f"Reprocessing {case_id}...")
        
        # Load cached data
        cached_data = self.load_cached_response(case_id)
        if not cached_data:
            return False
        
        # Extract the raw LLM response for query generation
        query_responses = cached_data.get('raw_llm_responses', {}).get('query_generation', [])
        if not query_responses:
            logger.warning(f"No query generation responses found for {case_id}")
            return False
        
        # Get the first successful response
        raw_response = query_responses[0].get('raw_response', '')
        if not raw_response:
            logger.warning(f"No raw response found for {case_id}")
            return False
        
        # Reprocess the query with fixed parsing
        query = self.reprocess_query(case_id, raw_response)
        if not query:
            logger.warning(f"Failed to reprocess query for {case_id}")
            return False
        
        # Generate the Prolog file
        facts = cached_data.get('facts', [])
        text = cached_data.get('text', '')
        question = cached_data.get('question', '')
        
        prolog_content = self.generate_prolog_file(case_id, facts, query, text, question)
        
        # Write to file
        output_file = self.results_dir / f"{case_id}.pl"
        with open(output_file, 'w') as f:
            f.write(prolog_content)
        
        logger.info(f"✅ Successfully reprocessed {case_id}")
        logger.info(f"   Query: {query[:100]}...")
        return True
    
    def reprocess_all_tax_cases(self):
        """Reprocess all tax calculation cases"""
        tax_cases = self.get_tax_cases()
        
        logger.info(f"Reprocessing {len(tax_cases)} tax calculation cases...")
        
        success_count = 0
        for case_id in tax_cases:
            if self.reprocess_case(case_id):
                success_count += 1
        
        logger.info(f"✅ Successfully reprocessed {success_count}/{len(tax_cases)} cases")
        
        if success_count < len(tax_cases):
            failed_cases = [case_id for case_id in tax_cases 
                          if not self.reprocess_case(case_id)]
            logger.warning(f"Failed cases: {failed_cases}")

def main():
    """Main entry point"""
    reprocessor = CachedQueryReprocessor()
    reprocessor.reprocess_all_tax_cases()

if __name__ == "__main__":
    main() 