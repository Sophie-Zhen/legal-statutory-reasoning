"""
Stage 2 Pipeline: Coordinates fact extraction and query generation
"""

import re
import os
import json
import logging
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple

logger = logging.getLogger(__name__)


class Stage2Pipeline:
    """
    Main pipeline coordinator for Stage 2
    Integrates fact extraction, query generation, and evaluation
    """
    
    def __init__(self, env_path: str):
        """Initialize pipeline with environment configuration"""
        self.env_path = Path(env_path)
        self.project_root = self.env_path.parent.parent
        self.data_path = self.project_root / "data" / "sara_v3"
        self.statutes_path = self.data_path / "statutes" / "prolog"
        
        # Components will be injected
        self.fact_extractor = None
        self.query_generator = None
        self.case_parser = None
        
        # Load statutes once
        self.statutes = self._load_statutes()
        
        logger.info("Stage 2 Pipeline initialized")
        
    def _load_statutes(self) -> str:
        """Load all statute files"""
        statute_files = [
            "section1.pl", "section2.pl", "section62.pl", 
            "section63.pl", "section68.pl", "section151.pl",
            "section152.pl", "section3301.pl", "section3306.pl",
            "section7703.pl", "events.pl", "utils.pl", "init.pl"
        ]
        
        combined_statutes = []
        for file in statute_files:
            file_path = self.statutes_path / file
            if file_path.exists():
                with open(file_path, 'r') as f:
                    content = f.read()
                    combined_statutes.append(f"% === {file} ===\n{content}")
            else:
                logger.warning(f"Statute file not found: {file}")
                
        return "\n\n".join(combined_statutes)
    
    def get_combined_statutes(self) -> str:
        """Get combined statute content"""
        return self.statutes
    
    def process_case(self, case_id: str) -> Dict:
        """
        Process a single case: extract facts and generate query
        
        Returns:
            Dictionary with facts, query, and metrics
        """
        logger.info(f"Processing case: {case_id}")
        
        # Parse case to get text and question
        case_data = self.case_parser.parse_case_file(case_id)
        
        # Extract facts
        facts = self.fact_extractor.extract_with_retries(
            text=case_data['text'],
            statutes=self.statutes,
            case_id=case_id
        )
        
        # Validate extraction quality
        if len(facts) < 3:
            logger.warning(f"Poor fact extraction for {case_id}: only {len(facts)} facts")
        
        # Generate query
        query_data = {
            'case_id': case_id,
            'question': case_data['question'],
            'facts': '\n'.join(facts)
        }
        query = self.query_generator.generate_query(query_data)
        
        # Evaluate fact quality
        fact_metrics = self.evaluate_fact_quality(
            generated_facts=facts,
            reference_facts=case_data.get('reference_facts', [])
        )
        
        return {
            'case_id': case_id,
            'facts': facts,
            'query': query,
            'fact_metrics': fact_metrics,
            'expected_result': case_data.get('expected_result', 'unknown')
        }
    
    def evaluate_fact_quality(self, generated_facts: List[str], 
                            reference_facts: List[str]) -> Dict:
        """
        Evaluate quality of generated facts against reference
        Enhanced to better handle different fact representations
        """
        if not reference_facts:
            return {
                'precision': 0.0,
                'recall': 0.0,
                'f1_score': 0.0,
                'reference_count': 0,
                'generated_count': len(generated_facts)
            }
        
        # Normalize facts for comparison
        gen_normalized = [self._normalize_fact(f) for f in generated_facts]
        ref_normalized = [self._normalize_fact(f) for f in reference_facts]
        
        # Calculate matches with more flexible matching
        exact_matches = 0
        partial_matches = 0
        semantic_matches = 0
        
        matched_refs = set()
        
        for gen_fact in gen_normalized:
            # Check exact match
            if gen_fact in ref_normalized:
                exact_matches += 1
                matched_refs.add(ref_normalized.index(gen_fact))
            else:
                # Check for semantic equivalence
                for i, ref_fact in enumerate(ref_normalized):
                    if i in matched_refs:
                        continue
                        
                    if self._semantically_equivalent(gen_fact, ref_fact):
                        semantic_matches += 1
                        matched_refs.add(i)
                        break
                    elif self._same_predicate(gen_fact, ref_fact):
                        partial_matches += 1
                        matched_refs.add(i)
                        break
        
        total_matches = exact_matches + semantic_matches
        
        # Calculate metrics
        precision = total_matches / len(generated_facts) if generated_facts else 0
        recall = total_matches / len(reference_facts) if reference_facts else 0
        f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
        
        return {
            'precision': precision,
            'recall': recall,
            'f1_score': f1_score,
            'exact_matches': exact_matches,
            'semantic_matches': semantic_matches,
            'partial_matches': partial_matches,
            'reference_count': len(reference_facts),
            'generated_count': len(generated_facts)
        }
    
    def _normalize_fact(self, fact: str) -> str:
        """Normalize a fact for comparison"""
        
        fact = ' '.join(fact.split())
       
        if fact.endswith('.'):
            fact = fact[:-1]
        
        fact = fact.replace('"', "'")
        # Normalize span positions to wildcards for comparison
        fact = re.sub(r'span\([^,]+,\d+,\d+\)', 'span(*,*,*)', fact)
        return fact.strip()
    
    def _same_predicate(self, fact1: str, fact2: str) -> bool:
        """Check if two facts have the same predicate"""
        pred1 = fact1.split('(')[0] if '(' in fact1 else fact1
        pred2 = fact2.split('(')[0] if '(' in fact2 else fact2
        return pred1.strip() == pred2.strip()
    
    def _semantically_equivalent(self, fact1: str, fact2: str) -> bool:
        """Check if two facts are semantically equivalent despite different syntax"""
        # Extract predicate and key arguments
        pred1 = fact1.split('(')[0]
        pred2 = fact2.split('(')[0]
        
        if pred1 != pred2:
            return False
        
        # For statutory predicates, check main arguments
        if pred1.startswith('s'):
            # Extract person and year/amount
            args1 = re.findall(r"'([^']+)'|\b(\d{4})\b|\b(\d+)\b", fact1)
            args2 = re.findall(r"'([^']+)'|\b(\d{4})\b|\b(\d+)\b", fact2)
            
            # Flatten and filter
            args1 = [a for group in args1 for a in group if a]
            args2 = [a for group in args2 for a in group if a]
            
            return set(args1) == set(args2)
        
        return False
    
    def save_results(self, output_dir: str, case_id: str, 
                     facts: List[str], query: str):
        """Save generated facts and query to file with validation"""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        file_path = output_path / f"{case_id}.pl"
        
        # Validate facts before saving
        if not facts:
            logger.warning(f"No facts to save for {case_id}")
            facts = ["% No facts extracted"]
        
        with open(file_path, 'w') as f:
            # Write header
            f.write(f"% {case_id} - Generated by Stage 2 Pipeline\n")
            f.write(f"% Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"% Total facts extracted: {len(facts)}\n\n")
            
            # I use absolute path to init.pl due to some issues with the relative path
            init_path = self.statutes_path / "init.pl"
            f.write(f":- ['{init_path}'].\n\n")
            
            # Write facts
            f.write("% FACTS (Generated from natural language text)\n")
            for fact in facts:
                f.write(f"{fact}\n")
            f.write("\n")
            
            # Write query with answer wrapper
            f.write("% QUERY (Generated from natural language question)\n")
            # Ensure query doesn't already have answer wrapper
            if not query.startswith('answer('):
                f.write(f"answer('{case_id}', Result) :- ({query} -> Result = true ; Result = false).\n")
            else:
                f.write(f"{query}\n")
            
        logger.info(f"Saved {len(facts)} facts and query to: {file_path}")