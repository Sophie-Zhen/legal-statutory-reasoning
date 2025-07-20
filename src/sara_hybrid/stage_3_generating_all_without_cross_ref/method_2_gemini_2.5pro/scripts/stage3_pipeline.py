"""
Stage 3 Method 2 Pipeline - Semantic Legal Fact Generation
Modified from Stage 2 pipeline to generate facts compatible with Method 2 codebase
Tests only on the 120 cases from sara_v3/splits/test
"""

import re
import os
import json
import logging
import subprocess
import time
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple, Set

# Import cache manager
from stage3_cache_manager import Stage3CacheManager

logger = logging.getLogger(__name__)


class Stage3Method2Pipeline:
    """
    Stage 3 pipeline coordinator for Method 2 semantic fact generation
    Modified from Stage 2 to work with test split cases and Method 2 codebase
    """
    
    def __init__(self, project_root: str):
        """Initialize pipeline with project configuration"""
        self.project_root = Path(project_root)
        self.data_path = self.project_root / "data" / "sara_v3"
        self.cases_path = self.data_path / "cases"
        self.test_split_path = self.data_path / "splits" / "test"
        self.method2_path = self.project_root / "src" / "sara_hybrid" / "stage_3_generating_all_without_cross_ref" / "method_2_gemini_2.5pro"
        self.prolog_codebase_path = self.method2_path / "prolog_codebase"
        
        # Create organized results directory structure
        self.results_base_dir = self.method2_path / "results" / "stage3_test_split"
        self.results_base_dir.mkdir(parents=True, exist_ok=True)
        
        # Create subdirectories for better organization
        self.prolog_dir = self.results_base_dir / "prolog"
        self.prolog_dir.mkdir(parents=True, exist_ok=True)
        
        self.run_llm_log_dir = self.results_base_dir / "run_llm_log"
        self.run_llm_log_dir.mkdir(parents=True, exist_ok=True)
        
        # For backward compatibility, keep results_dir pointing to base
        self.results_dir = self.results_base_dir
        
        # Cache directory and manager
        self.cache_dir = self.method2_path / "cache" / "stage3_test_split"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache_manager = Stage3CacheManager(self.cache_dir)
        
        # Components will be injected
        self.fact_extractor = None
        self.query_generator = None
        self.case_parser = None
        
        # Load test split cases
        self.test_cases = self._load_test_split()
        
        logger.info(f"Stage 3 Method 2 Pipeline initialized")
        logger.info(f"Test cases: {len(self.test_cases)}")
        logger.info(f"Results dir: {self.results_dir}")
        
    def _load_test_split(self) -> List[str]:
        """Load the 120 test split cases"""
        if not self.test_split_path.exists():
            raise FileNotFoundError(f"Test split file not found: {self.test_split_path}")
        
        with open(self.test_split_path, 'r') as f:
            cases = [line.strip() for line in f if line.strip()]
        
        logger.info(f"Loaded {len(cases)} test cases")
        return cases
    
    def get_method2_module_imports(self) -> str:
        """Get the required module imports for Method 2 codebase with correct paths"""
        # Calculate relative path from results/stage3_test_split/prolog/ to prolog_codebase
        # results/stage3_test_split/prolog/ -> ../../../prolog_codebase/
        codebase_rel_path = "../../../prolog_codebase"
        
        imports = [
            f":- use_module('{codebase_rel_path}/section1').",
            f":- use_module('{codebase_rel_path}/section2').", 
            f":- use_module('{codebase_rel_path}/section63').",
            f":- use_module('{codebase_rel_path}/section68').",
            f":- use_module('{codebase_rel_path}/section151').",
            f":- use_module('{codebase_rel_path}/section152').",
            f":- use_module('{codebase_rel_path}/section3306').",
            f":- use_module('{codebase_rel_path}/section7703').",
            f":- use_module('{codebase_rel_path}/helpers').",
            f":- use_module('{codebase_rel_path}/knowledge_base')."
        ]
        return "\n".join(imports)
    
    def process_case(self, case_id: str) -> Dict:
        """
        Process a single case: extract semantic facts and generate query
        
        Returns:
            Dictionary with facts, query, and execution results
        """
        logger.info(f"Processing case: {case_id}")
        
        # Check cache first (can be overridden by caller)
        if getattr(self, '_use_cache', True):
            cached_result = self.cache_manager.get_cached_result(case_id)
            if cached_result:
                logger.info(f"📦 Using cached result for {case_id}")
                return cached_result
        
        logger.info(f"🔄 Processing {case_id} (not in cache)")
        
        # Parse case to get text and question
        case_data = self.case_parser.parse_case_file(case_id)
        
        if not case_data['text'] or not case_data['question']:
            return {
                'case_id': case_id,
                'status': 'error',
                'error': 'Missing text or question',
                'facts': [],
                'query': ''
            }
        
        # Extract semantic facts using Method 2 prompts
        facts, fact_extraction_raw_responses = self.fact_extractor.extract_with_retries(
            text=case_data['text'],
            case_id=case_id
        )
        
        # Validate extraction quality
        if len(facts) < 2:
            logger.warning(f"Poor fact extraction for {case_id}: only {len(facts)} facts")
        
        # Generate query using Method 2 format
        query_data = {
            'case_id': case_id,
            'question': case_data['question'],
            'facts': '\n'.join(facts)
        }
        query, query_generation_raw_responses = self.query_generator.generate_with_retries(query_data)
        
        # Save generated Prolog file
        prolog_file = self.save_prolog_file(case_id, facts, query)
        
        # Test execution with Method 2 codebase
        execution_result = self.test_prolog_execution(case_id, prolog_file)
        
        result = {
            'case_id': case_id,
            'status': 'success',
            'text': case_data['text'],
            'question': case_data['question'],
            'facts': facts,
            'query': query,
            'expected_result': case_data.get('expected_result', 'unknown'),
            'execution_result': execution_result,
            'prolog_file': str(prolog_file),
            'raw_llm_responses': {
                'fact_extraction': fact_extraction_raw_responses,
                'query_generation': query_generation_raw_responses
            }
        }
        
        # Cache the successful result
        self.cache_manager.cache_result(case_id, result)
        
        return result
    
    def save_prolog_file(self, case_id: str, facts: List[str], query: str) -> Path:
        """Save generated facts and query to Prolog file compatible with Method 2"""
        file_path = self.prolog_dir / f"{case_id}.pl"
        
        # Validate facts before saving
        if not facts:
            logger.warning(f"No facts to save for {case_id}")
            facts = [f"% No facts extracted for {case_id}"]
        
        with open(file_path, 'w') as f:
            # Write header
            f.write(f"% {case_id} - Generated by Stage 3 Method 2 Pipeline\n")
            f.write(f"% Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"% Total facts extracted: {len([f for f in facts if f.startswith('fact(')])}\n\n")
            
            # Write module imports for Method 2 codebase
            f.write("% MODULE IMPORTS\n")
            f.write(self.get_method2_module_imports())
            f.write("\n\n")
            
            # Write facts
            f.write("% SEMANTIC FACTS (Generated from natural language text)\n")
            for fact in facts:
                if fact.strip():
                    f.write(f"{fact}\n")
            f.write("\n")
            
            # Write query with answer wrapper
            f.write("% QUERY (Generated from natural language question)\n")
            if not query.startswith('answer('):
                f.write(f"answer('{case_id}', Result) :- {query}.\n")
            else:
                f.write(f"{query}\n")
            
        logger.info(f"Saved {len(facts)} facts and query to: {file_path}")
        return file_path
    
    def test_prolog_execution(self, case_id: str, prolog_file: Path) -> Dict:
        """
        Test Prolog execution using SWI-Prolog with Method 2 codebase
        """
        try:
            # Create temporary consultation file
            temp_file = self.prolog_dir / f"temp_{case_id}.pl"
            
            with open(temp_file, 'w') as f:
                # Load the generated case file (which includes proper module imports)
                f.write(f":- consult('{prolog_file}').\n")
                
                # Query the answer predicate
                f.write(f":- answer('{case_id}', Result), write('RESULT: '), write(Result), nl, halt.\n")
                f.write(f":- write('ERROR: Failed to get result'), nl, halt(1).\n")
            
            # Execute with SWI-Prolog
            cmd = ['swipl', '-q', '-t', 'halt', '-s', str(temp_file)]
            
            start_time = time.time()
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=str(self.prolog_codebase_path)
            )
            execution_time = time.time() - start_time
            
            # Clean up temp file
            if temp_file.exists():
                temp_file.unlink()
            
            # Parse result
            if result.returncode == 0:
                output = result.stdout.strip()
                if 'RESULT:' in output:
                    actual_result = output.split('RESULT:')[1].strip()
                    return {
                        'status': 'success',
                        'result': actual_result,
                        'execution_time': execution_time,
                        'stdout': output,
                        'stderr': result.stderr
                    }
                else:
                    return {
                        'status': 'no_result',
                        'execution_time': execution_time,
                        'stdout': output,
                        'stderr': result.stderr
                    }
            else:
                return {
                    'status': 'error',
                    'returncode': result.returncode,
                    'execution_time': execution_time,
                    'stdout': result.stdout,
                    'stderr': result.stderr
                }
                
        except subprocess.TimeoutExpired:
            return {
                'status': 'timeout',
                'execution_time': 30.0,
                'error': 'Execution timed out after 30 seconds'
            }
        except Exception as e:
            return {
                'status': 'exception',
                'error': str(e),
                'execution_time': 0
            }
    
    def run_batch(self, case_ids: Optional[List[str]] = None, start_idx: int = 0, max_cases: int = None, use_cache: bool = True) -> Dict:
        """
        Run pipeline on a batch of cases
        
        Args:
            case_ids: Specific case IDs to process (if None, uses test split)
            start_idx: Starting index for processing
            max_cases: Maximum number of cases to process
            use_cache: Whether to use cached results (default: True)
        """
        if case_ids is None:
            case_ids = self.test_cases
        
        if max_cases:
            case_ids = case_ids[start_idx:start_idx + max_cases]
        else:
            case_ids = case_ids[start_idx:]
        
        # Show cache statistics
        cache_stats = self.cache_manager.get_cache_stats()
        logger.info(f"📊 Cache Statistics: {cache_stats['successful_entries']} cached, {cache_stats['cache_hit_rate']:.1%} hit rate")
        
        # Filter out cached cases if using cache
        if use_cache:
            cached_cases = self.cache_manager.get_cached_cases()
            uncached_cases = [case_id for case_id in case_ids if case_id not in cached_cases]
            logger.info(f"🔄 Processing {len(case_ids)} total cases: {len(cached_cases & set(case_ids))} cached, {len(uncached_cases)} need processing")
        else:
            logger.info(f"🔄 Processing {len(case_ids)} cases (cache disabled)")
        
        logger.info(f"Starting processing from index {start_idx}")
        
        # Set cache usage flag
        self._use_cache = use_cache
        
        results = {}
        summary = {
            'total_cases': len(case_ids),
            'successful': 0,
            'failed': 0,
            'execution_success': 0,
            'execution_failed': 0,
            'start_time': datetime.now().isoformat()
        }
        
        for i, case_id in enumerate(case_ids):
            logger.info(f"\n=== Processing {i+1}/{len(case_ids)}: {case_id} ===")
            
            try:
                result = self.process_case(case_id)
                results[case_id] = result
                
                if result['status'] == 'success':
                    summary['successful'] += 1
                    
                    # Check execution success
                    exec_result = result.get('execution_result', {})
                    if exec_result.get('status') == 'success':
                        summary['execution_success'] += 1
                        logger.info(f"✅ {case_id}: {exec_result.get('result', 'unknown')}")
                    else:
                        summary['execution_failed'] += 1
                        logger.warning(f"❌ {case_id}: {exec_result.get('status', 'unknown')}")
                else:
                    summary['failed'] += 1
                    logger.error(f"💥 {case_id}: {result.get('error', 'unknown')}")
                    
            except Exception as e:
                logger.error(f"Exception processing {case_id}: {e}")
                results[case_id] = {
                    'case_id': case_id,
                    'status': 'exception',
                    'error': str(e)
                }
                summary['failed'] += 1
            
            # Save intermediate results every 10 cases
            if (i + 1) % 10 == 0:
                self.save_batch_results(results, summary, f"intermediate_{i+1}")
        
        summary['end_time'] = datetime.now().isoformat()
        summary['success_rate'] = summary['successful'] / summary['total_cases'] if summary['total_cases'] > 0 else 0
        summary['execution_rate'] = summary['execution_success'] / summary['successful'] if summary['successful'] > 0 else 0
        
        # Add cache statistics to summary
        final_cache_stats = self.cache_manager.get_cache_stats()
        summary['cache_stats'] = final_cache_stats
        
        # Count how many results came from cache
        cached_results = sum(1 for result in results.values() if result.get('from_cache', False))
        summary['cached_results'] = cached_results
        summary['processed_results'] = summary['total_cases'] - cached_results
        
        # Save final results
        self.save_batch_results(results, summary, "final")
        
        logger.info(f"\n=== BATCH COMPLETE ===")
        logger.info(f"Success rate: {summary['success_rate']:.1%}")
        logger.info(f"Execution rate: {summary['execution_rate']:.1%}")
        
        return {
            'results': results,
            'summary': summary
        }
    
    def save_batch_results(self, results: Dict, summary: Dict, suffix: str = ""):
        """Save batch results to JSON files in organized structure"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Save detailed results in run_llm_log directory
        results_file = self.run_llm_log_dir / f"results_{suffix}_{timestamp}.json"
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        # Save summary in run_llm_log directory
        summary_file = self.run_llm_log_dir / f"summary_{suffix}_{timestamp}.json"
        with open(summary_file, 'w') as f:
            json.dump(summary, f, indent=2)
        
        # Save raw LLM responses in run_llm_log directory
        raw_responses_file = self.run_llm_log_dir / f"raw_llm_responses_{suffix}_{timestamp}.json"
        self.save_raw_llm_responses(results, raw_responses_file)
        
        logger.info(f"Saved results to: {results_file}")
        logger.info(f"Saved summary to: {summary_file}")
        logger.info(f"Saved raw LLM responses to: {raw_responses_file}")
    
    def save_raw_llm_responses(self, results: Dict, output_file: Path):
        """
        Extract and save raw LLM responses for debugging
        
        Args:
            results: Results dictionary containing raw_llm_responses
            output_file: Path to save the raw responses
        """
        raw_responses = {}
        
        for case_id, case_result in results.items():
            if case_result.get('status') == 'success' and 'raw_llm_responses' in case_result:
                raw_responses[case_id] = case_result['raw_llm_responses']
        
        with open(output_file, 'w') as f:
            json.dump(raw_responses, f, indent=2)
        
        logger.info(f"Extracted raw LLM responses for {len(raw_responses)} cases")
    
    def get_test_cases(self) -> List[str]:
        """Get the list of test split cases"""
        return self.test_cases.copy()
    
    def analyze_results(self, results_file: str) -> Dict:
        """Analyze results from a completed batch run"""
        with open(results_file, 'r') as f:
            results = json.load(f)
        
        analysis = {
            'total_cases': len(results),
            'by_status': {},
            'by_execution_status': {},
            'fact_extraction_stats': {},
            'performance_metrics': {}
        }
        
        # Analyze by status
        for case_id, result in results.items():
            status = result.get('status', 'unknown')
            analysis['by_status'][status] = analysis['by_status'].get(status, 0) + 1
            
            # Execution status
            exec_status = result.get('execution_result', {}).get('status', 'none')
            analysis['by_execution_status'][exec_status] = analysis['by_execution_status'].get(exec_status, 0) + 1
            
            # Fact count
            fact_count = len(result.get('facts', []))
            if 'fact_counts' not in analysis['fact_extraction_stats']:
                analysis['fact_extraction_stats']['fact_counts'] = []
            analysis['fact_extraction_stats']['fact_counts'].append(fact_count)
        
        # Calculate averages
        fact_counts = analysis['fact_extraction_stats']['fact_counts']
        if fact_counts:
            analysis['fact_extraction_stats']['avg_facts'] = sum(fact_counts) / len(fact_counts)
            analysis['fact_extraction_stats']['min_facts'] = min(fact_counts)
            analysis['fact_extraction_stats']['max_facts'] = max(fact_counts)
        
        return analysis
    
    def get_cache_stats(self) -> Dict:
        """Get cache statistics"""
        return self.cache_manager.get_cache_stats()
    
    def clean_cache(self) -> int:
        """Clean invalid cache entries"""
        return self.cache_manager.clean_invalid_cache()
    
    def clear_cache(self) -> int:
        """Clear all cache entries"""
        return self.cache_manager.clear_cache()
    
    def invalidate_cases(self, case_ids: List[str]) -> int:
        """Invalidate specific cases from cache"""
        count = 0
        for case_id in case_ids:
            self.cache_manager.invalidate_case(case_id)
            count += 1
        return count
    
    def get_cached_cases(self) -> Set[str]:
        """Get set of cached case IDs"""
        return self.cache_manager.get_cached_cases() 