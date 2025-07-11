#!/usr/bin/env python3
"""
Stage 2 Runner - Fixed for SARA format
Implements neuro-symbolic approach: LLM extraction + Prolog verification
"""

import os
import sys
import json
import logging
import time
import re
import subprocess
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional

# Fix imports
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))
sys.path.insert(0, str(current_dir.parent / "stage1"))

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class Stage2Runner:
    """Fixed Stage 2 runner with SARA format"""
    
    def __init__(self):
        """Initialize all paths and components"""
        self.project_root = Path("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
        self.stage2_dir = self.project_root / "src" / "query_generation" / "stage2"
        self.data_path = self.project_root / "data" / "sara_v3"
        self.env_path = self.project_root / "src" / ".env"
        
        # Create output directory
        self.results_dir = self.stage2_dir / "results" / "stage2_sara_format"
        self.results_dir.mkdir(parents=True, exist_ok=True)
        
        # Create cache directory
        self.cache_dir = self.stage2_dir / "cache_sara"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Output: {self.results_dir}")
        logger.info(f"Cache: {self.cache_dir}")
        
        # Load API key
        self.api_key = self._load_api_key()
        
        # Initialize components
        self._initialize_components()
        
        # Load cache
        self.cache_index = self._load_cache_index()
        
    def _load_api_key(self) -> str:
        """Load Gemini API key"""
        with open(self.env_path, 'r') as f:
            for line in f:
                if line.startswith('GEMINI_API_KEY='):
                    return line.strip().split('=')[1]
        raise ValueError("GEMINI_API_KEY not found")
    
    def _initialize_components(self):
        """Initialize pipeline components"""
        # Import components
        from fact_extractor import FactExtractor
        from stage2_case_parser import Stage2CaseParser
        from stage2_pipeline import Stage2Pipeline
        
        # Import Stage 1 query generator
        from query_generator import QueryGeneratorLLM
        
        # Create instances
        self.fact_extractor = FactExtractor(self.api_key, prompt_mode="full")
        self.case_parser = Stage2CaseParser(str(self.data_path / "cases"))
        self.query_generator = QueryGeneratorLLM(self.api_key)
        
        # Load statutes
        self.statutes = self._load_statutes()
        
        logger.info("Components initialized")
    
    def _load_statutes(self) -> str:
        """Load all statute files"""
        statutes_dir = self.data_path / "statutes" / "prolog"
        statute_files = [
            "s1.pl", "s3306.pl", "s63.pl", "s68.pl", 
            "s151.pl", "s152.pl", "s2501.pl", "s7703.pl"
        ]
        
        combined = []
        for file in statute_files:
            path = statutes_dir / file
            if path.exists():
                with open(path, 'r') as f:
                    combined.append(f.read())
        
        return '\n'.join(combined)
    
    def _load_cache_index(self) -> Dict:
        """Load cache index"""
        cache_file = self.cache_dir / "cache_index.json"
        if cache_file.exists():
            with open(cache_file, 'r') as f:
                return json.load(f)
        return {}
    
    def _save_cache_index(self):
        """Save cache index"""
        cache_file = self.cache_dir / "cache_index.json"
        with open(cache_file, 'w') as f:
            json.dump(self.cache_index, f, indent=2)
    
    def _get_cached_result(self, case_id: str) -> Optional[Dict]:
        """Check cache for existing result"""
        if case_id in self.cache_index:
            cache_file = self.cache_dir / f"{case_id}.json"
            if cache_file.exists():
                with open(cache_file, 'r') as f:
                    logger.info(f"Using cached result for {case_id}")
                    return json.load(f)
        return None
    
    def _save_to_cache(self, case_id: str, result: Dict):
        """Save result to cache"""
        cache_file = self.cache_dir / f"{case_id}.json"
        with open(cache_file, 'w') as f:
            json.dump(result, f, indent=2)
        
        self.cache_index[case_id] = {
            "cached_at": datetime.now().isoformat(),
            "status": result.get("status", "unknown")
        }
        self._save_cache_index()
    
    def process_case(self, case_id: str) -> Dict:
        """Process a single case"""
        logger.info(f"\nProcessing: {case_id}")
        
        # Check cache
        cached = self._get_cached_result(case_id)
        if cached and cached.get("status") == "success":
            return cached
        
        try:
            # Parse case file
            case_data = self.case_parser.parse_case_file(case_id)
            
            if not case_data['text'] or not case_data['question']:
                raise ValueError("Missing text or question")
            
            logger.info(f"Text: {case_data['text'][:80]}...")
            logger.info(f"Question: {case_data['question']}")
            
            # Extract facts using LLM
            facts = self.fact_extractor.extract_with_retries(
                text=case_data['text'],
                statutes=self.statutes,
                case_id=case_id
            )
            
            # Validate extraction
            if len(facts) < 3:
                logger.warning(f"Poor extraction: only {len(facts)} facts")
                result = {
                    "case_id": case_id,
                    "status": "insufficient",
                    "facts_count": len(facts),
                    "facts": facts
                }
                self._save_to_cache(case_id, result)
                return result
            
            logger.info(f"Extracted {len(facts)} facts")
            
            # Generate query
            query_data = {
                'case_id': case_id,
                'question': case_data['question'],
                'facts': '\n'.join(facts)
            }
            query = self.query_generator.generate_query(query_data)
            
            logger.info(f"Generated query: {query}")
            
            # Save Prolog file
            self._save_prolog_file(case_id, facts, query)
            
            # Test execution
            test_result = self._test_prolog_execution(case_id)
            
            result = {
                "case_id": case_id,
                "status": "success",
                "facts_count": len(facts),
                "facts": facts,
                "query": query,
                "test_result": test_result
            }
            
            self._save_to_cache(case_id, result)
            return result
            
        except Exception as e:
            logger.error(f"Error processing {case_id}: {e}")
            result = {
                "case_id": case_id,
                "status": "error",
                "error": str(e)
            }
            self._save_to_cache(case_id, result)
            return result
    
    def _save_prolog_file(self, case_id: str, facts: List[str], query: str):
        """Save generated Prolog file"""
        content = f"""% {case_id} - Generated by Stage 2
% Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

:- ['init'].

% FACTS (LLM-generated from natural language)
{chr(10).join(facts)}

% QUERY (LLM-generated from question)
{query}
"""
        
        output_file = self.results_dir / f"{case_id}.pl"
        with open(output_file, 'w') as f:
            f.write(content)
    
    def _test_prolog_execution(self, case_id: str) -> Dict:
        """Test if generated Prolog executes correctly"""
        try:
            generated_file = str(self.results_dir / f"{case_id}.pl")
            
            # Run Prolog test
            cmd = [
                'swipl', '-g', f'answer(\'{case_id}\', Result), write(Result), halt.', 
                '-t', 'halt(1)', generated_file
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=10,
                cwd=str(self.data_path / "statutes" / "prolog")
            )
            
            if result.returncode == 0:
                output = result.stdout.strip()
                return {
                    "success": True,
                    "output": output,
                    "correct": output in ['true', 'false']
                }
            else:
                return {
                    "success": False,
                    "error": result.stderr[:200]
                }
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def run_batch(self, case_ids: List[str]) -> Dict:
        """Run on multiple cases"""
        logger.info(f"\nRunning Stage 2 on {len(case_ids)} cases")
        
        results = []
        for i, case_id in enumerate(case_ids):
            logger.info(f"\n[{i+1}/{len(case_ids)}] {case_id}")
            
            result = self.process_case(case_id)
            results.append(result)
            
            # Rate limiting
            if i < len(case_ids) - 1:
                time.sleep(1)
        
        # Calculate summary
        success_count = sum(1 for r in results if r['status'] == 'success')
        test_passed = sum(1 for r in results 
                         if r.get('test_result', {}).get('correct', False))
        
        summary = {
            "total_cases": len(case_ids),
            "successful_extractions": success_count,
            "tests_passed": test_passed,
            "accuracy": test_passed / len(case_ids) if case_ids else 0,
            "timestamp": datetime.now().isoformat(),
            "results": results
        }
        
        # Save summary
        summary_file = self.results_dir / "summary.json"
        with open(summary_file, 'w') as f:
            json.dump(summary, f, indent=2)
        
        # Print results
        logger.info("\n" + "="*60)
        logger.info("STAGE 2 RESULTS (SARA Format)")
        logger.info("="*60)
        logger.info(f"Total cases: {len(case_ids)}")
        logger.info(f"Successful extractions: {success_count}")
        logger.info(f"Tests passed: {test_passed}")
        logger.info(f"Accuracy: {summary['accuracy']:.1%}")
        logger.info(f"\nResults saved to: {self.results_dir}")
        
        return summary


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Stage 2 - SARA Format")
    parser.add_argument('--cases', nargs='+', help='Specific case IDs')
    parser.add_argument('--test', action='store_true', help='Run test cases')
    parser.add_argument('--all', action='store_true', help='Run all cases')
    
    args = parser.parse_args()
    
    runner = Stage2Runner()
    
    # Test cases that should work with SARA format
    test_cases = [
        "tax_case_1",      # Simple tax case
        "tax_case_31",     # Payment and marriage
        "tax_case_34",     # Income case
        "s1_a_1_pos",      # Section 1 test
        "s3306_c_10_A_i_neg"  # University case
    ]
    
    # Determine cases
    if args.cases:
        case_ids = args.cases
    elif args.test:
        case_ids = test_cases
    elif args.all:
        cases_dir = runner.data_path / "cases"
        case_ids = [f.stem for f in cases_dir.glob("*.pl")]
        case_ids.sort()
    else:
        case_ids = test_cases[:3]  # Default: first 3 test cases
    
    # Run pipeline
    runner.run_batch(case_ids)


if __name__ == "__main__":
    main()