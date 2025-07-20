#!/usr/bin/env python3
"""
fact_templates.py - Templates for common fact patterns in tax law
we based it on the analysis of Stage 1 cases
"""

from typing import Dict, List, Optional
from dataclasses import dataclass

@dataclass
class FactTemplate:
    """Template for generating Prolog facts"""
    name: str
    template: str
    required_fields: List[str]
    optional_fields: List[str] = None
    
    def __post_init__(self):
        if self.optional_fields is None:
            self.optional_fields = []
    
    def generate(self, data: Dict[str, str]) -> str:
        """Generate fact from template with data"""
        # Check required fields
        for field in self.required_fields:
            if field not in data:
                raise ValueError(f"Missing required field: {field}")
        
        # Fill template
        return self.template.format(**data)

class FactTemplates:
    """Collection of fact templates for tax scenarios"""
    
    def __init__(self):
        self.templates = {
            # Person declaration
            'person': FactTemplate(
                name='person',
                template='person_(span("{name}",{start},{end})).',
                required_fields=['name', 'start', 'end']
            ),
            
            # Income facts
            'income': FactTemplate(
                name='income',
                template='income_(span("{event_text}",{event_start},{event_end})).',
                required_fields=['event_text', 'event_start', 'event_end']
            ),
            
            'income_agent': FactTemplate(
                name='income_agent',
                template='agent_(span("{event_text}",{event_start},{event_end}),span("{person}",{person_start},{person_end})).',
                required_fields=['event_text', 'event_start', 'event_end', 'person', 'person_start', 'person_end']
            ),
            
            'income_amount': FactTemplate(
                name='income_amount',
                template='amount_(span("{event_text}",{event_start},{event_end}),{amount}).',
                required_fields=['event_text', 'event_start', 'event_end', 'amount']
            ),
            
            'income_date': FactTemplate(
                name='income_date',
                template='date_(span("{event_text}",{event_start},{event_end}),{year}).',
                required_fields=['event_text', 'event_start', 'event_end', 'year']
            ),

            'payment': FactTemplate(
                name='payment',
                template='payment_(span("{event_text}",{event_start},{event_end})).',
                required_fields=['event_text', 'event_start', 'event_end']
            ),
            
            'payment_agent': FactTemplate(
                name='payment_agent',
                template='agent_(span("{event_text}",{event_start},{event_end}),span("{person}",{person_start},{person_end})).',
                required_fields=['event_text', 'event_start', 'event_end', 'person', 'person_start', 'person_end']
            ),
            
            'payment_amount': FactTemplate(
                name='payment_amount',
                template='amount_(span("{event_text}",{event_start},{event_end}),{amount}).',
                required_fields=['event_text', 'event_start', 'event_end', 'amount']
            ),
            
            'payment_date': FactTemplate(
                name='payment_date',
                template='date_(span("{event_text}",{event_start},{event_end}),{year}).',
                required_fields=['event_text', 'event_start', 'event_end', 'year']
            ),
            
            'payment_purpose': FactTemplate(
                name='payment_purpose',
                template='purpose_(span("{event_text}",{event_start},{event_end}),span("{purpose}",{purpose_start},{purpose_end})).',
                required_fields=['event_text', 'event_start', 'event_end', 'purpose', 'purpose_start', 'purpose_end']
            ),

            'medical_patient': FactTemplate(
                name='medical_patient',
                template='patient_(span("{care_text}",{care_start},{care_end}),span("{patient}",{patient_start},{patient_end})).',
                required_fields=['care_text', 'care_start', 'care_end', 'patient', 'patient_start', 'patient_end']
            ),

            'spouse': FactTemplate(
                name='spouse',
                template='spouse_(span("{person1}",{p1_start},{p1_end}),span("{person2}",{p2_start},{p2_end})).',
                required_fields=['person1', 'p1_start', 'p1_end', 'person2', 'p2_start', 'p2_end']
            ),
            
            'dependent': FactTemplate(
                name='dependent',
                template='dependent_(span("{dependent}",{dep_start},{dep_end}),span("{parent}",{parent_start},{parent_end})).',
                required_fields=['dependent', 'dep_start', 'dep_end', 'parent', 'parent_start', 'parent_end']
            ),

            'employment': FactTemplate(
                name='employment',
                template='employment_(span("{event_text}",{event_start},{event_end})).',
                required_fields=['event_text', 'event_start', 'event_end']
            ),
            
            'employment_agent': FactTemplate(
                name='employment_agent',
                template='agent_(span("{event_text}",{event_start},{event_end}),span("{employee}",{emp_start},{emp_end})).',
                required_fields=['event_text', 'event_start', 'event_end', 'employee', 'emp_start', 'emp_end']
            ),
            
            'employer': FactTemplate(
                name='employer',
                template='employer_(span("{event_text}",{event_start},{event_end}),span("{employer}",{employer_start},{employer_end})).',
                required_fields=['event_text', 'event_start', 'event_end', 'employer', 'employer_start', 'employer_end']
            ),

            'joint_return': FactTemplate(
                name='joint_return',
                template='joint_return_(span("joint return",{start},{end})).',
                required_fields=['start', 'end']
            ),
            
            'joint_return_agent': FactTemplate(
                name='joint_return_agent',
                template='agent_(span("joint return",{jr_start},{jr_end}),span("{filer}",{filer_start},{filer_end})).',
                required_fields=['jr_start', 'jr_end', 'filer', 'filer_start', 'filer_end']
            ),

            's63_taxable_income': FactTemplate(
                name='s63_taxable_income',
                template='s63("{person}",{year},{amount}).',
                required_fields=['person', 'year', 'amount']
            ),

            'receive': FactTemplate(
                name='receive',
                template='receive_("{recipient}",span("{benefit}",{benefit_start},{benefit_end}),{year}).',
                required_fields=['recipient', 'benefit', 'benefit_start', 'benefit_end', 'year']
            ),
            
            'gross_income': FactTemplate(
                name='gross_income',
                template='gross_income_("{person}",{amount},{year}).',
                required_fields=['person', 'amount', 'year']
            ),
            
            'deduction': FactTemplate(
                name='deduction',
                template='deduction_("{person}",{amount},{deduction_type},{year}).',
                required_fields=['person', 'amount', 'deduction_type', 'year']
            ),

            'marriage': FactTemplate(
                name='marriage',
                template='marriage_(span("{person1}",{p1_start},{p1_end}),span("{person2}",{p2_start},{p2_end}),span("marriage",{m_start},{m_end}),{year}).',
                required_fields=['person1', 'p1_start', 'p1_end', 'person2', 'p2_start', 'p2_end', 'm_start', 'm_end', 'year']
            ),

            'service': FactTemplate(
                name='service',
                template='service_(span("{service_desc}",{start},{end})).',
                required_fields=['service_desc', 'start', 'end']
            ),

            'start_date': FactTemplate(
                name='start_date',
                template='start_(span("{event}",{event_start},{event_end}),{date}).',
                required_fields=['event', 'event_start', 'event_end', 'date']
            ),
            
            'end_date': FactTemplate(
                name='end_date',
                template='end_(span("{event}",{event_start},{event_end}),{date}).',
                required_fields=['event', 'event_start', 'event_end', 'date']
            )
        }
    
    def get_template(self, name: str) -> Optional[FactTemplate]:
        """Get a template by name"""
        return self.templates.get(name)
    
    def generate_fact(self, template_name: str, data: Dict[str, str]) -> str:
        """Generate a fact using a template"""
        template = self.get_template(template_name)
        if not template:
            raise ValueError(f"Unknown template: {template_name}")
        return template.generate(data)
    
    def generate_income_facts(self, event_data: Dict) -> List[str]:
        """Generate all facts related to an income event"""
        facts = []

        facts.append(self.generate_fact('income', {
            'event_text': event_data['event_text'],
            'event_start': event_data['event_start'],
            'event_end': event_data['event_end']
        }))

        if 'person' in event_data:
            facts.append(self.generate_fact('income_agent', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'person': event_data['person'],
                'person_start': event_data['person_start'],
                'person_end': event_data['person_end']
            }))

        if 'amount' in event_data:
            facts.append(self.generate_fact('income_amount', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'amount': event_data['amount']
            }))

        if 'year' in event_data:
            facts.append(self.generate_fact('income_date', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'year': event_data['year']
            }))
        
        return facts
    
    def generate_payment_facts(self, event_data: Dict) -> List[str]:
        """Generate all facts related to a payment event"""
        facts = []

        facts.append(self.generate_fact('payment', {
            'event_text': event_data['event_text'],
            'event_start': event_data['event_start'],
            'event_end': event_data['event_end']
        }))

        if 'person' in event_data:
            facts.append(self.generate_fact('payment_agent', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'person': event_data['person'],
                'person_start': event_data['person_start'],
                'person_end': event_data['person_end']
            }))

        if 'amount' in event_data:
            facts.append(self.generate_fact('payment_amount', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'amount': event_data['amount']
            }))

        if 'year' in event_data:
            facts.append(self.generate_fact('payment_date', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'year': event_data['year']
            }))

        if 'purpose' in event_data:
            facts.append(self.generate_fact('payment_purpose', {
                'event_text': event_data['event_text'],
                'event_start': event_data['event_start'],
                'event_end': event_data['event_end'],
                'purpose': event_data['purpose'],
                'purpose_start': event_data['purpose_start'],
                'purpose_end': event_data['purpose_end']
            }))
        
        return facts
    
    def generate_relationship_facts(self, rel_type: str, person1_data: Dict, person2_data: Dict) -> List[str]:
        """Generate relationship facts (bidirectional for spouse)"""
        facts = []
        
        if rel_type == 'spouse':
            # Spouse relationship is bidirectional
            facts.append(self.generate_fact('spouse', {
                'person1': person1_data['name'],
                'p1_start': person1_data['start'],
                'p1_end': person1_data['end'],
                'person2': person2_data['name'],
                'p2_start': person2_data['start'],
                'p2_end': person2_data['end']
            }))
            
            facts.append(self.generate_fact('spouse', {
                'person1': person2_data['name'],
                'p1_start': person2_data['start'],
                'p1_end': person2_data['end'],
                'person2': person1_data['name'],
                'p2_start': person1_data['start'],
                'p2_end': person1_data['end']
            }))
        
        elif rel_type == 'dependent':
            # Dependent relationship is directional
            facts.append(self.generate_fact('dependent', {
                'dependent': person1_data['name'],
                'dep_start': person1_data['start'],
                'dep_end': person1_data['end'],
                'parent': person2_data['name'],
                'parent_start': person2_data['start'],
                'parent_end': person2_data['end']
            }))
        
        return facts