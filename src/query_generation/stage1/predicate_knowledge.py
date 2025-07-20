#!/usr/bin/env python3
"""
predicate_knowledge.py - Enhanced database of predicate signatures and patterns
Built from analysis of SARA statute files
"""

from typing import List, Dict, Tuple

class PredicateKnowledge:
    """Knowledge base of predicate signatures and usage patterns"""
    
    def __init__(self):
        # Predicate signatures extracted from statute analysis
        self.signatures = {
            # General tax predicate (from utils.pl)
            'tax': ['person', 'year', 'amount'],
            
            # Section 1 - Tax imposed
            's1': ['person', 'year', 'taxable_income', 'tax_amount'],
            's1_a': ['person', 'year', 'taxable_income', 'tax_amount'],
            's1_a_1': ['person', '_', '_', 'year', 'taxable_income', 'tax_amount'],
            's1_a_2': ['person', 'year', 'taxable_income', 'tax_amount'],
            's1_a_i': ['taxable_income', 'tax_amount'],
            's1_a_ii': ['taxable_income', 'tax_amount'],
            's1_a_iii': ['taxable_income', 'tax_amount'],
            's1_a_iv': ['taxable_income', 'tax_amount'],
            's1_a_v': ['taxable_income', 'tax_amount'],
            's1_a_2_i': ['taxable_income', 'tax_amount'],  
            's1_a_2_ii': ['taxable_income', 'tax_amount'], 
            's1_b': ['person', 'year', 'taxable_income', 'tax_amount'],
            's1_b_i': ['taxable_income', 'tax_amount'],
            's1_b_ii': ['taxable_income', 'tax_amount'],
            's1_b_iii': ['taxable_income', 'tax_amount'],
            's1_b_iv': ['taxable_income', 'tax_amount'],
            's1_b_v': ['taxable_income', 'tax_amount'],
            's1_c': ['person', 'year', 'taxable_income', 'tax_amount'],
            's1_c_i': ['taxable_income', 'tax_amount'],
            's1_c_ii': ['taxable_income', 'tax_amount'],
            's1_c_iii': ['taxable_income', 'tax_amount'],
            's1_c_iv': ['taxable_income', 'tax_amount'],
            's1_c_v': ['taxable_income', 'tax_amount'],
            's1_d': ['person', 'spouse', 'year', 'taxable_income', 'tax_amount'],
            's1_d_i': ['taxable_income', 'tax_amount'],
            's1_d_ii': ['taxable_income', 'tax_amount'],
            's1_d_iii': ['taxable_income', 'tax_amount'],
            's1_d_iv': ['taxable_income', 'tax_amount'],
            's1_d_v': ['taxable_income', 'tax_amount'],
            
            # Section 2 - Definitions (surviving spouse, head of household)
            's2_a': ['person', '_', 'year'],
            's2_a_1_A': ['person', '_', 'year'],  
            's2_a_2_B': ['person', '_', 'year'],  
            's2_b': ['person', '_', 'year'],
            's2_b_1_A_i': ['person', '_', 'year'],
            
            # Section 63 - Taxable income defined
            's63': ['person', 'year', 'taxable_income'],
            's63_a': ['person', 'year', 'taxable_income', 'gross_income', 'deductions'],
            's63_b': ['person', 'year', 'taxable_income', 'gross_income'],
            's63_c': ['person', 'year', 'standard_deduction'],
            's63_c_1': ['person', 'year', 'standard_deduction'],  
            's63_c_2_A_ii': ['person', 'year'],
            's63_c_3': ['person', 'additional_amount', 'year'],  
            's63_c_5': ['person', '_', 'gross_income', 'year', 'basic_standard_deduction'],
            's63_c_6': ['person', 'year', 'standard_deduction'],
            's63_c_6_A': ['person', 'spouse', 'itemized_deduction', 'year'],
            's63_d': ['person', 'itemized_deduction', 'total_amount', 'year'],
            's63_d_2': ['person', 'deduction_151', 'year'],
            's63_f': ['person', 'additional_amounts', 'year'],
            
            # Section 68 - Overall limitation on itemised deductions
            's68': ['person', 'total_deduction', 'reduced_deduction', 'year'],
            's68_a': ['person', 'total_deduction', 'reduced_deduction', 'year'],
            's68_a_1': ['gross_income', 'applicable_amount', 'reduction'],
            's68_b': ['person', 'applicable_amount', 'year'],
            's68_b_1_B': ['person', 'year'],  
            
            # Section 151 - Personal exemptions
            's151': ['person', 'exemption_amount', '_', '_', 'year'],
            's151_b': ['person', 'spouse', 'exemption_amount', 'year'],
            's151_c': ['person', 'dependent', 'exemption_amount', 'year'],
            's151_d': ['person', 'exemption_amount', 'year'],
            's151_d_1': ['amount'], 
            's151_d_2': ['person', 'year', 'amount'], 
            's151_d_3': ['person', 'exemption_amount', 'year'],
            's151_d_3_A': ['person', '_', '_', '_', '_', 'reduced_amount', 'year'], 
            
            # Section 152 - Dependent defined
            's152_a': ['person', 'dependent', 'year'],
            's152_b_1': ['person', 'parent', 'year'],  
            's152_b_2': ['person', '_', 'year'],  
            's152_c_2': ['person', '_', 'year'],  
            's152_c_2_B': ['person', 'other_person', '_', '_', 'year'], 
            's152_d_1_B': ['person', '_', 'year'], 
            's152_d_2_A': ['person', 'other_person', 'year'],  
            's152_d_2_D': ['person', '_', 'year'],  
            's152_d_2_F': ['person', '_', 'year'], 
            's152_d_2_H': ['person', '_', 'year'],  
            
            # Section 3301 - Rate of tax
            's3301': ['person', 'year', 'rate'],
            's3301_a': ['person', 'year', 'rate'],
            
            # Section 3306 - Definitions
            's3306_a': ['employer', 'employee', 'service', 'year'],
            's3306_a_1_A': ['person', '_', 'year'],  
            's3306_a_2_B': ['person', '_', 'year'],  
            's3306_b': ['wages'],
            's3306_b_11': ['person', '_', 'year'],  
            's3306_b_2_A': ['person', 'wages', 'year'],
            's3306_b_2_C': ['purpose1', 'purpose2', 'payer', 'service_provider', 'beneficiary', 'benefit_type'],
            's3306_c': ['service', 'year'],  
            's3306_c_1': ['service', 'year'],  
            's3306_c_10_A_i': ['person', '_', 'year'],  
            's3306_c_21': ['person', '_', 'year'],  
            's3306_c_A': ['person', 'other_person', 'year'],
            
            # Section 7703 - Determination of marital status
            's7703': ['person', 'spouse', '_', 'year'],
        }
        
        # Enhanced question patterns
        self.question_patterns = {
            'how_much_tax': {
                'pattern': r'[Hh]ow much tax does? (\w+) (?:has|have) to pay in (\d{4})',
                'predicate': 'tax',
                'extract': ['person', 'year']
            },
            'pay_tax_under_section': {
                'pattern': r'(\w+) (?:has|have) to pay \$(\d+) in taxes? for(?: the year)? (\d{4}) under section ([0-9a-zA-Z()]+)',
                'predicate': 'section_specific',
                'extract': ['person', 'amount', 'year', 'section']
            },
            'section_applies': {
                'pattern': r'[Ss]ection ([0-9a-zA-Z()]+) applies to (\w+)',
                'predicate': 'section_specific',
                'extract': ['section', 'person']
            },
            'deduction_falls_under': {
                'pattern': r"(\w+)'s deduction for (\d{4}) falls under section ([0-9a-zA-Z()]+)",
                'predicate': 'section_specific',
                'extract': ['person', 'year', 'section']
            },
            'exemption_reduced': {
                'pattern': r"[Uu]nder section ([0-9a-zA-Z()]+), (\w+)'s exemption amount is reduced to \$(\d+)",
                'predicate': 'section_specific',
                'extract': ['section', 'person', 'amount']
            },
            'exemption_amount_equals': {
                'pattern': r"(\w+)'s exemption amount under section ([0-9a-zA-Z()]+) is equal to \$(\d+)",
                'predicate': 'section_specific',
                'extract': ['person', 'section', 'amount']
            },
            'additional_deduction': {
                'pattern': r"[Uu]nder section ([0-9a-zA-Z()]+), (\w+)'s additional standard deduction (?:in|for) (\d{4}) is equal to \$(\d+)",
                'predicate': 'section_specific',
                'extract': ['section', 'person', 'year', 'amount']
            },
            'can_claim_exemption': {
                'pattern': r"(\w+) can claim an exemption with (\w+) the dependent for (\d{4}) under section ([0-9a-zA-Z()]+)",
                'predicate': 'section_specific',
                'extract': ['person', 'dependent', 'year', 'section']
            },
            'section_applies_year': {
                'pattern': r'[Ss]ection ([0-9a-zA-Z()]+) applies to (\w+) in (\d{4})',
                'predicate': 'section_specific',
                'extract': ['section', 'person', 'year']
            },
            'section_applies_with_respect': {
                'pattern': r'[Ss]ection ([0-9a-zA-Z()]+) applies to (\w+) with respect to (\w+)',
                'predicate': 'section_specific',
                'extract': ['section', 'person1', 'person2']
            }
        }
        
    def get_signature(self, predicate: str) -> List[str]:
        """Get the signature for a predicate"""
        return self.signatures.get(predicate, [])
    
    def section_to_predicate(self, section: str) -> str:
        """Convert section reference to predicate name"""
        # Clean section reference
        section = section.strip()
        
        # Enhanced mappings
        mappings = {
            '1(a)(i)': 's1_a_i',
            '1(a)(ii)': 's1_a_ii',
            '1(a)(iii)': 's1_a_iii',
            '1(a)(iv)': 's1_a_iv',
            '1(a)(v)': 's1_a_v',
            '1(a)(2)(i)': 's1_a_2_i',
            '1(a)(2)(ii)': 's1_a_2_ii',
            '1(b)': 's1_b',
            '1(b)(i)': 's1_b_i',
            '1(b)(ii)': 's1_b_ii',
            '1(b)(iii)': 's1_b_iii',
            '1(b)(iv)': 's1_b_iv',
            '1(b)(v)': 's1_b_v',
            '1(c)': 's1_c',
            '1(c)(i)': 's1_c_i',
            '1(c)(ii)': 's1_c_ii',
            '1(c)(iii)': 's1_c_iii',
            '1(c)(iv)': 's1_c_iv',
            '1(c)(v)': 's1_c_v',
            '1(d)': 's1_d',
            '1(d)(i)': 's1_d_i',
            '2(a)': 's2_a',
            '2(a)(1)(A)': 's2_a_1_A',
            '2(a)(2)(B)': 's2_a_2_B',
            '2(b)': 's2_b',
            '2(b)(1)(A)(i)': 's2_b_1_A_i',
            '63': 's63',
            '63(a)': 's63_a',
            '63(b)': 's63_b',
            '63(c)': 's63_c',
            '63(c)(1)': 's63_c_1',
            '63(c)(2)(A)(ii)': 's63_c_2_A_ii',
            '63(c)(3)': 's63_c_3',
            '63(c)(5)': 's63_c_5',
            '63(c)(6)': 's63_c_6',
            '63(c)(6)(A)': 's63_c_6_A',
            '63(d)': 's63_d',
            '68(a)(1)': 's68_a_1',
            '68(b)(1)(B)': 's68_b_1_B',
            '151': 's151',
            '151(b)': 's151_b',
            '151(c)': 's151_c',
            '151(d)': 's151_d',
            '151(d)(1)': 's151_d_1',
            '151(d)(2)': 's151_d_2',
            '151(d)(3)': 's151_d_3',
            '151(d)(3)(A)': 's151_d_3_A',
            '152(a)': 's152_a',
            '152(b)(1)': 's152_b_1',
            '152(b)(2)': 's152_b_2',
            '152(c)(2)': 's152_c_2',
            '152(c)(2)(B)': 's152_c_2_B',
            '152(d)(1)(B)': 's152_d_1_B',
            '152(d)(2)(A)': 's152_d_2_A',
            '152(d)(2)(D)': 's152_d_2_D',
            '152(d)(2)(F)': 's152_d_2_F',
            '152(d)(2)(H)': 's152_d_2_H',
            '3306(a)(1)(A)': 's3306_a_1_A',
            '3306(a)(2)(B)': 's3306_a_2_B',
            '3306(b)(11)': 's3306_b_11',
            '3306(b)(2)(C)': 's3306_b_2_C',
            '3306(c)': 's3306_c',
            '3306(c)(1)': 's3306_c_1',
            '3306(c)(10)(A)(i)': 's3306_c_10_A_i',
            '3306(c)(21)': 's3306_c_21',
        }
        
        if section in mappings:
            return mappings[section]
        
        # Try to build predicate name
        # Remove parentheses and convert to underscore notation
        predicate = 's' + section.replace('(', '_').replace(')', '')
        return predicate
    
    def get_predicate_for_question(self, question: str) -> Tuple[str, Dict]:
        """Determine which predicate to use based on question pattern"""
        import re
        
        for pattern_name, pattern_info in self.question_patterns.items():
            match = re.search(pattern_info['pattern'], question, re.IGNORECASE)
            if match:
                extracted = {}
                for i, field in enumerate(pattern_info['extract']):
                    extracted[field] = match.group(i + 1)
                
                predicate = pattern_info['predicate']
                
                # Handle section-specific predicates
                if predicate == 'section_specific' and 'section' in extracted:
                    predicate = self.section_to_predicate(extracted['section'])
                
                return predicate, extracted
        
        return None, {}