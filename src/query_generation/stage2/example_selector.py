#!/usr/bin/env python3
"""
example_selector_stage2.py - Selects relevant few-shot examples for both fact and query generation
UPDATED: Fixed all span calculations to use exclusive end positions
"""

from typing import List, Dict, Tuple
import random

class ExampleSelector:
    """Selects relevant examples for few-shot learning in Stage 2"""
    
    def __init__(self):
        # Fact generation examples with the correct inclusive spans, lets see if this works
        self.fact_examples = [
            {
                'text': "Alice is a surviving spouse for the year 2017. Alice's taxable income for the year 2017 is $615572.",
                'facts': """:- discontiguous s63/3.
:- discontiguous s2_a/3.
:- ['statutes/prolog/init'].
s2_a("Alice",_,2017).
s63("Alice",2017,615572).""",
                'explanation': 'Generate computed predicates: s2_a for surviving spouse status, s63 for taxable income. Use discontiguous declarations.'
            },
            {
                'text': "Bob's gross income for the year 2018 is $123456. He is married to Alice and they file a joint return.",
                'facts': """:- discontiguous s63/3.
:- discontiguous s7703/4.
:- ['statutes/prolog/init'].
s63("Bob",2018,123456).
joint_return_(span("joint return",50,61)).
agent_(span("joint return",50,61),span("Bob",0,2)).
agent_(span("joint return",50,61),span("Alice",25,29)).
s7703("Bob","Alice",_,2018).""",
                'explanation': 'For married couples, generate s7703 predicate. For joint returns, use span objects with agent facts. INCLUSIVE spans!'
            },
            {
                'text': "In 2015, Charlie has income of $50000. He is not married, not a surviving spouse, and not a head of household.",
                'facts': """:- discontiguous s63/3.
:- ['statutes/prolog/init'].
s63("Charlie",2015,50000).
not_s2_a("Charlie",_,2015).
not_s2_b("Charlie",_,2015).
not_married("Charlie",2015).""",
                'explanation': 'For negative status (not married, not surviving spouse), generate not_ predicates.'
            },
            {
                'text': "Dorothy's adjusted gross income for 2016 is $200000. She claims one exemption of $4050.",
                'facts': """:- discontiguous s151_c/4.
:- discontiguous gross_income_/3.
:- ['statutes/prolog/init'].
gross_income_("Dorothy",200000,2016).
s151_c("Dorothy",_,4050,2016).""",
                'explanation': 'Use gross_income_ for AGI, s151_c for exemptions with 4 arguments (person, dependent, amount, year).'
            },
            {
                'text': "In 2017, Alice paid $5000 for medical care for her dependent Bob.",
                'facts': """:- discontiguous payment_/1.
:- ['statutes/prolog/init'].
payment_(span("paid",17,20)).
agent_(span("paid",17,20),span("Alice",9,13)).
amount_(span("paid",17,20),5000).
purpose_(span("paid",17,20),span("medical care",31,42)).
patient_(span("medical care",31,42),span("Bob",62,64)).
dependent_("Bob","Alice",2017).
date_(span("paid",17,20),2017).""",
                'explanation': 'Payment facts need span objects with INCLUSIVE end positions. Include purpose and patient for medical payments.'
            },
            {
                'text': "Bob is a dependent of Alice for the year 2015.",
                'facts': """:- discontiguous s152_a/3.
:- ['statutes/prolog/init'].
s152_a("Bob","Alice",2015).""",
                'explanation': 'For dependency relationships, use s152_a(dependent, parent, year).'
            },
            {
                'text': "Alice has a brother, Bob, who was born January 31st, 2014.",
                'facts': """:- ['statutes/prolog/init'].
brother_(span("brother",12,18)).
patient_(span("brother",12,18),span("Alice",0,4)).
agent_(span("brother",12,18),span("Bob",21,23)).
start_(span("brother",12,18),span(20140131,39,56)).
birth_(span("born",34,37)).
agent_(span("born",34,37),span("Bob",21,23)).
start_(span("born",34,37),span(20140131,39,56)).""",
                'explanation': 'Brother relationships need complete facts including birth events. Remember: spans are INCLUSIVE (end = start + length - 1)!'
            },
            {
                'text': "Bob is Alice's father since April 15th, 1994.",
                'facts': """:- ['statutes/prolog/init'].
father_(span("father",15,20)).
agent_(span("father",15,20),span("Bob",0,2)).
patient_(span("father",15,20),span("Alice",7,11)).
start_(span("father",15,20),span(19940415,28,43)).""",
                'explanation': 'Father relationships: "father" is 6 chars, so span is (15,20). "Alice" is 5 chars, so span is (7,11).'
            },
            {
                'text': "Alice and Bob started living together on April 15th, 2014. Alice and Bob are not married.",
                'facts': """:- ['statutes/prolog/init'].
residence_(span("living",22,27)).
agent_(span("living",22,27),span("Alice",0,4)).
agent_(span("living",22,27),span("Bob",10,12)).
patient_(span("living",22,27),span("living",22,27)).
start_(span("living",22,27),span(20140415,41,56)).""",
                'explanation': 'Living relationships: "living" is 6 chars. All spans use inclusive end positions.'
            }
        ]
        
        # Query generation examples (from Stage 1) - we kept them the same
        self.query_examples = [
            {
                'question': "Section 7703(b)(1) applies to Alice for the year 2018. Contradiction",
                'facts_snippet': 'joint_return_(span("joint return",315,326)).\nagent_(span("joint return",315,326),span("Alice",294,298)).',
                'query': 'answer(\'s7703_b_1_neg\', Result) :- (s7703_b_1("Alice",_,_,2018) -> Result = true ; Result = false).',
                'explanation': 'The rule s7703(b) requires the person to NOT file a joint return. The facts state Alice DOES file a joint return. This is a contradiction, so the answer must be false.'
            },
            {
                'question': "Alice's total exemption for 2015 under section 151(a) is equal to $6000. Contradiction",
                'facts_snippet': 's151_c("Alice",_,2000,2015).',
                'query': 'answer(\'s151_a_neg\', Result) :- (s151_a("Alice",6000,2015) -> Result = true ; Result = false).',
                'explanation': 'The facts state Alice gets one exemption of $2000. The question asks if the total is $6000. Since 2000 is not 6000, the assertion is false.'
            },
            {
                'question': "Under section 151(d)(3)(A), Alice's exemption amount is reduced to $1800. Entailment",
                'facts_snippet': 's151_c("Alice",_,2000,2015).',
                'query': 'answer(\'s151_d_3_A_pos\', Result) :- (s151_d_3_A("Alice",_,_,_,2000,1800,2015) -> Result = true ; Result = false).',
                'explanation': 'This is a complex rule. The predicate s151_d_3_A needs the original exemption ($2000) and the reduced exemption ($1800) in the correct argument slots to succeed.'
            },
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
    
    def get_fact_examples(self, text: str, n: int = 3) -> List[Dict]:
        """Get n most relevant fact generation examples"""
        scored_examples = []
        
        for example in self.fact_examples:
            score = 0
            
            # Score based on content similarity
            if "income" in text.lower() and "income" in example['text'].lower():
                score += 5
            if "married" in text.lower() and "married" in example['text'].lower():
                score += 5
            if "spouse" in text.lower() and "spouse" in example['text'].lower():
                score += 5
            if "dependent" in text.lower() and "dependent" in example['text'].lower():
                score += 5
            if "paid" in text.lower() and "paid" in example['text'].lower():
                score += 5
            if "medical" in text.lower() and "medical" in example['text'].lower():
                score += 5
            if "brother" in text.lower() and "brother" in example['text'].lower():
                score += 10  # Higher score for brother examples
            if "father" in text.lower() and "father" in example['text'].lower():
                score += 10  # Higher score for father examples
            if "living" in text.lower() and "living" in example['text'].lower():
                score += 8
            if "born" in text.lower() and "born" in example['text'].lower():
                score += 8
            if "works" in text.lower() and "works" in example['text'].lower():
                score += 5
            if "employment" in text.lower() and "employment" in example['text'].lower():
                score += 5
            if "joint" in text.lower() and "joint" in example['text'].lower():
                score += 5
            
            # Boost score for matching years
            import re
            text_years = set(re.findall(r'\b(19\d{2}|20\d{2})\b', text))
            example_years = set(re.findall(r'\b(19\d{2}|20\d{2})\b', example['text']))
            if text_years and example_years:
                score += 3
            
            scored_examples.append((score, example))
        
        # Sort by score and return top n
        scored_examples.sort(key=lambda x: x[0], reverse=True)
        selected = [ex for score, ex in scored_examples[:n]]
        
        # Ensures we have a good span example if needed
        needs_span = any(word in text.lower() for word in ['brother', 'father', 'living', 'born', 'paid', 'income'])
        has_span_example = any('span(' in ex['facts'] for ex in selected)
        
        if needs_span and not has_span_example and len(self.fact_examples) > n:
            # Replace the lowest scoring example with a good span example
            span_examples = [ex for ex in self.fact_examples if 'span(' in ex['facts']]
            if span_examples:
                selected[-1] = span_examples[0]
        
        return selected
    
    def get_query_examples_for_question(self, question: str, n: int = 4) -> List[Dict]:
        """Get n most relevant query generation examples"""
        scored_examples = []
        
        for example in self.query_examples:
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
            
            # Boost score for matching section numbers
            import re
            q_sections = re.findall(r's\d+|section \d+', q_lower)
            ex_sections = re.findall(r's\d+|section \d+', ex_q_lower)
            if q_sections and ex_sections:
                # Check if any sections match
                for q_sec in q_sections:
                    for ex_sec in ex_sections:
                        if q_sec in ex_sec or ex_sec in q_sec:
                            score += 6
                            break
            
            scored_examples.append((score, example))
        
        scored_examples.sort(key=lambda x: x[0], reverse=True)
        return [ex for score, ex in scored_examples[:n]]
    
    def format_fact_examples_for_prompt(self, examples: List[Dict]) -> str:
        """Format fact generation examples for inclusion in prompt"""
        formatted = []
        for i, ex in enumerate(examples, 1):
            formatted.append(f"Example {i}:")
            formatted.append(f'Text: "{ex["text"]}"')
            formatted.append("Facts:")
            formatted.append(ex['facts'])
            if 'explanation' in ex:
                formatted.append(f"Note: {ex['explanation']}")
            formatted.append("")
        
        return "\n".join(formatted)
    
    def format_query_examples_for_prompt(self, examples: List[Dict]) -> str:
        """Format query generation examples for inclusion in prompt"""
        formatted = []
        for i, ex in enumerate(examples, 1):
            formatted.append(f"--- Example {i} ---")
            formatted.append(f"Question: {ex['question']}")
            formatted.append(f"Explanation: {ex['explanation']}")
            formatted.append(f"Query: {ex['query']}")
            formatted.append("")
        
        return "\n".join(formatted)