#!/usr/bin/env python3
"""
example_selector.py - Selects relevant few-shot examples for LLM prompting
"""

from typing import List, Dict, Tuple
import random

class ExampleSelector:
    """Selects relevant examples for few-shot learning"""
    
    def __init__(self):
        self.examples = [
 
            # Examples to fix contradiction & complex logic


            # Example 1: Teaches how to handle a direct factual contradiction.
            {
                'question': "Section 7703(b)(1) applies to Alice for the year 2018. Contradiction",
                'facts_snippet': 'joint_return_(span("joint return",315,326)).\nagent_(span("joint return",315,326),span("Alice",294,298)).',
                'query': 'answer(\'s7703_b_1_neg\', Result) :- (s7703_b_1("Alice",_,_,2018) -> Result = true ; Result = false).',
                'explanation': 'The rule s7703(b) requires the person to NOT file a joint return. The facts state Alice DOES file a joint return. This is a contradiction, so the answer must be false. The query correctly tests the predicate, which is expected to fail.'
            },

            # Example 2: Teaches that a value mismatch means contradiction.
            {
                'question': "Alice's total exemption for 2015 under section 151(a) is equal to $6000. Contradiction",
                'facts_snippet': 's151_c("Alice",_,2000,2015).',
                'query': 'answer(\'s151_a_neg\', Result) :- (s151_a("Alice",6000,2015) -> Result = true ; Result = false).',
                'explanation': 'The facts state Alice gets one exemption of $2000. The question asks if the total is $6000. Since 2000 is not 6000, the assertion is false.'
            },
            
            # Example 3: Teaches how to map values into a complex predicate for an ENTAILMENT case.
            {
                'question': "Under section 151(d)(3)(A), Alice's exemption amount is reduced to $1800. Entailment",
                'facts_snippet': 's151_c("Alice",_,2000,2015).',
                'query': 'answer(\'s151_d_3_A_pos\', Result) :- (s151_d_3_A("Alice",_,_,_,2000,1800,2015) -> Result = true ; Result = false).',
                'explanation': 'This is a complex rule. The predicate s151_d_3_A needs the original exemption ($2000) and the reduced exemption ($1800) in the correct argument slots to succeed.'
            },

            # Example 4: Teaches contradiction for tax bracket calculations.
            {
                'question': "Alice and her spouse have to pay $7208 in taxes for the year 2017 under section 1(a)(i). Contradiction",
                'facts_snippet': 's63("Alice",2017,42876).',
                'query': 'answer(\'s1_a_1_i_neg\', Result) :- (s1_a_i(42876,7208) -> Result = true ; Result = false).',
                'explanation': 'The facts state the taxable income is $42876. The rule s1_a_i is for a different tax bracket. Therefore, the assertion that the tax is $7208 under this specific rule is false.'
            },

            # from original examples (Still useful)

            {
                'question': 'How much tax does Alice have to pay in 2020? $17399',
                'facts_snippet': 'income_(span("income",254,259)).\namount_(span("income",254,259),span(103272,283,288)).',
                'query': 'answer(\'tax_case_46\', Result) :- (tax("Alice",2020,17399) -> Result = true ; Result = false).',
                'explanation': 'For "How much tax" questions, use the tax predicate with (person, year, amount).'
            },
            {
                'question': 'Section 63(c)(6)(A) applies to Alice for 2017. Entailment',
                'facts_snippet': 'payment_(span("paid",19,22)).\npatient_(span("paid",19,22),span("Alice",9,13)).',
                'query': 'answer(\'s63_c_6_A_pos\', Result) :- (s63_c_6_A("Alice",_,_,2017) -> Result = true ; Result = false).',
                'explanation': 'For "Section X applies" questions, use the section predicate with appropriate arguments.'
            }
        ]
        
    def get_examples_for_question(self, question: str, n: int = 4) -> List[Dict]:
        """Get n most relevant examples for a question, ensuring diversity."""
        # Simple scoring heuristic based on keywords
        scored_examples = []
        
        for example in self.examples:
            score = 0
            q_lower = question.lower()
            ex_q_lower = example['question'].lower()
            
            if "contradiction" in q_lower and "contradiction" in ex_q_lower:
                score += 10
            if "entailment" in q_lower and "entailment" in ex_q_lower:
                score += 10
            if "tax" in q_lower and "tax" in ex_q_lower:
                score += 8
            if "applies" in q_lower and "applies" in ex_q_lower:
                score += 5
            if "exemption" in q_lower and "exemption" in ex_q_lower:
                score += 7
            
            # Boost score for matching section numbers (e.g., 's151' or '7703')
            import re
            q_sections = re.findall(r's\d+', q_lower)
            ex_sections = re.findall(r's\d+', ex_q_lower)
            if q_sections and ex_sections and q_sections[0] == ex_sections[0]:
                score += 6
            
            scored_examples.append((score, example))
        
        scored_examples.sort(key=lambda x: x[0], reverse=True)
        
        # Return the top n examples
        return [ex for score, ex in scored_examples[:n]]
    
    def format_examples_for_prompt(self, examples: List[Dict]) -> str:
        """Format examples for inclusion in prompt"""
        formatted = []
        for i, ex in enumerate(examples, 1):
            formatted.append(f"--- Example {i} ---")
            formatted.append(f"Question: {ex['question']}")
            formatted.append(f"Explanation: {ex['explanation']}")
            formatted.append(f"Query: {ex['query']}")
            formatted.append("")
        
        return "\n".join(formatted)