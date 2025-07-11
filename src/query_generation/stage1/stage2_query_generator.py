"""
Stage 2 Query Generator - Generates both facts and queries from text
File: src/query_generation/stage1/stage2_query_generator.py
"""

import os
import json
import re
from typing import Dict, List, Tuple, Optional
from datetime import datetime
from stage2_case_parser import Stage2CaseParser, Stage2TestCase

class Stage2QueryGenerator:
    def __init__(self, sara_base_path: str, llm_client):
        self.sara_base_path = sara_base_path
        self.llm_client = llm_client
        self.parser = Stage2CaseParser(sara_base_path)
        self.results_dir = os.path.join(os.getcwd(), "stage2_results")
        os.makedirs(self.results_dir, exist_ok=True)
        
        # Import utilities
        import sys
        sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        from utils.prolog_executor import PrologExecutor
        
        self.prolog_executor = PrologExecutor(sara_base_path)

    def create_stage2_prompt(self, test_case: Stage2TestCase, statute_files: Dict[str, str]) -> str:
        """Create prompt for Stage 2 - generate facts AND query from text."""
        
        # Include relevant statute content (abbreviated for prompt length)
        statute_summary = self._create_statute_summary(statute_files)
        
        prompt = f"""You are an expert legal reasoning system that converts natural language legal text into Prolog facts and queries.

TASK: Convert the given text into Prolog facts, then generate a query to answer the question.

AVAILABLE STATUTES:
{statute_summary}

COMMON PROLOG PREDICATES:
- s7703(Person, Spouse, _, Year) - marriage status
- s63(Person, Year, Income) - taxable income  
- s1_a_i(Income, Tax) - tax calculation section 1(a)(i)
- s1_d_iv(Income, Tax) - tax calculation section 1(d)(iv)
- s3306_c_5([_, Employer, Employee, _], _, _, Year) - employment relations
- joint_return_(span(Text, Start, End)) - joint tax return filing
- agent_(span(Action, Start1, End1), span(Person, Start2, End2)) - action agents

CASE INFORMATION:
- Case ID: {test_case.id}
- Question Type: {test_case.question_type}

TEXT TO CONVERT:
{test_case.text}

QUESTION TO ANSWER:
{test_case.question}

INSTRUCTIONS:
1. Extract key entities (names, years, amounts, sections) from the text
2. Convert text into appropriate Prolog facts using the predicates above
3. Generate an answer/2 query to solve the question

OUTPUT FORMAT:
% Facts
[Generated Prolog facts here]

% Query
answer('{test_case.id}', Result) :- [your logic here].

EXAMPLES:
Text: "Alice is married under section 7703 for 2017. Income is $42876."
Question: "Alice pays $7208 in taxes. Contradiction"

% Facts
s7703("Alice", "spouse", _, 2017).
s63("Alice", 2017, 42876).

% Query  
answer('case_id', Result) :- 
    (s1_a_i(42876, 7208) -> Result = false ; Result = true).

Generate facts and query for the given case:
"""
        return prompt

    def _create_statute_summary(self, statute_files: Dict[str, str]) -> str:
        """Create abbreviated statute summary for prompt."""
        summary_lines = []
        for filename, content in statute_files.items():
            # Extract first few meaningful lines
            lines = content.split('\n')[:10]
            meaningful_lines = [line for line in lines if line.strip() and not line.startswith('%')][:3]
            if meaningful_lines:
                summary_lines.append(f"{filename}: {' '.join(meaningful_lines)}")
        
        return '\n'.join(summary_lines[:5])  # Limit to avoid prompt overflow

    def extract_facts_and_query(self, llm_response: str) -> Tuple[str, str]:
        """Extract generated facts and query from LLM response."""
        facts = ""
        query = ""
        
        lines = llm_response.split('\n')
        current_section = None
        facts_lines = []
        query_lines = []
        
        for line in lines:
            line = line.strip()
            if line == "% Facts" or "Facts" in line:
                current_section = "facts"
                continue
            elif line == "% Query" or "Query" in line:
                current_section = "query"
                continue
            elif line.startswith('%') or not line:
                continue
            
            if current_section == "facts":
                if line and not line.startswith('answer('):
                    facts_lines.append(line)
            elif current_section == "query":
                if 'answer(' in line:
                    query_lines.append(line)
        
        facts = '\n'.join(facts_lines)
        query = '\n'.join(query_lines)
        
        # Fallback: try to extract answer predicate anywhere
        if not query:
            for line in lines:
                if 'answer(' in line:
                    query = line.strip()
                    break
        
        return facts, query

    def test_stage2_output(self, case_id: str, facts: str, query: str) -> Tuple[bool, str, Optional[str]]:
        """Test the generated facts + query in Prolog."""
        # Combine facts and query into a complete Prolog program
        complete_program = f"""% Generated facts
{facts}

% Generated query
{query}
"""
        
        return self.prolog_executor.execute_query(case_id, complete_program, self.results_dir)

    def run_single_stage2_case(self, test_case: Stage2TestCase, statute_files: Dict[str, str]) -> Dict:
        """Run Stage 2 for a single test case."""
        print(f"\nStage 2 - Processing {test_case.id}...")
        
        try:
            # Generate prompt
            prompt = self.create_stage2_prompt(test_case, statute_files)
            
            # Get LLM response
            llm_response = self.llm_client.generate(prompt)
            
            # Extract facts and query
            generated_facts, generated_query = self.extract_facts_and_query(llm_response)
            
            # Save generated output
            output_file = os.path.join(self.results_dir, f"{test_case.id}_stage2.pl")
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(f"% Generated Facts\n{generated_facts}\n\n% Generated Query\n{generated_query}\n")
            
            # Test the generated facts + query
            success, result, error = self.test_stage2_output(test_case.id, generated_facts, generated_query)
            
            # Evaluate correctness (simplified for now)
            correct = self._evaluate_stage2_result(test_case, result, success)
            
            return {
                'case_id': test_case.id,
                'question_type': test_case.question_type,
                'success': success,
                'correct': correct,
                'result': result,
                'error': error,
                'generated_facts': generated_facts,
                'generated_query': generated_query,
                'golden_facts': test_case.golden_facts,
                'golden_query': test_case.golden_query,
                'llm_response': llm_response
            }
            
        except Exception as e:
            return {
                'case_id': test_case.id,
                'question_type': test_case.question_type,
                'success': False,
                'correct': False,
                'result': '',
                'error': str(e),
                'generated_facts': '',
                'generated_query': '',
                'golden_facts': test_case.golden_facts,
                'golden_query': test_case.golden_query,
                'llm_response': ''
            }

    def _evaluate_stage2_result(self, test_case: Stage2TestCase, prolog_result: str, success: bool) -> bool:
        """Evaluate Stage 2 result correctness."""
        if not success:
            return False
            
        result = prolog_result.strip().lower()
        
        if test_case.question_type in ["entailment", "contradiction"]:
            return result == "true"
        elif test_case.question_type == "tax_amount":
            try:
                result_amount = int(result)
                expected_amount = int(test_case.expected_value) if test_case.expected_value else 0
                return result_amount == expected_amount
            except:
                return False
        
        return False

    def run_all_stage2_cases(self) -> List[Dict]:
        """Run Stage 2 for all 26 target cases."""
        # Load statute files
        statute_files = self.parser.load_statute_files()
        
        # Parse Stage 2 test cases
        test_cases = self.parser.parse_stage2_cases()
        
        print(f"Running Stage 2 on {len(test_cases)} cases...")
        
        results = []
        for case_id, test_case in test_cases.items():
            result = self.run_single_stage2_case(test_case, statute_files)
            results.append(result)
            
            # Save progress
            with open(os.path.join(self.results_dir, 'stage2_progress.json'), 'w') as f:
                json.dump(results, f, indent=2)
        
        # Generate summary
        self.generate_stage2_summary(results)
        
        return results

    def generate_stage2_summary(self, results: List[Dict]):
        """Generate Stage 2 results summary."""
        total = len(results)
        if total == 0:
            print("No results to summarize")
            return
            
        successful = sum(1 for r in results if r['success'])
        correct = sum(1 for r in results if r['correct'])
        
        by_type = {}
        for r in results:
            qtype = r['question_type']
            if qtype not in by_type:
                by_type[qtype] = {'total': 0, 'success': 0, 'correct': 0}
            by_type[qtype]['total'] += 1
            if r['success']:
                by_type[qtype]['success'] += 1
            if r['correct']:
                by_type[qtype]['correct'] += 1
        
        summary = f"""Stage 2 Results Summary
======================
Total test cases: {total}
Successfully executed: {successful} ({successful/total*100:.1f}%)
Correct results: {correct} ({correct/total*100:.1f}%)

By Question Type:
"""
        
        for qtype, stats in by_type.items():
            summary += f"\n{qtype}:"
            summary += f"\n  Total: {stats['total']}"
            summary += f"\n  Success: {stats['success']} ({stats['success']/stats['total']*100:.1f}%)"
            summary += f"\n  Correct: {stats['correct']} ({stats['correct']/stats['total']*100:.1f}%)"
        
        # Save summary
        with open(os.path.join(self.results_dir, 'stage2_summary.txt'), 'w') as f:
            f.write(summary)
        
        print("\n" + summary)