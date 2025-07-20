#!/usr/bin/env python3
"""
entity_extractor.py - Specialised extraction for legal/tax entities
We added INCLUSIVE end positions to match golden facts
"""

import re
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass

@dataclass
class Entity:
    """Base class for entities with span information"""
    text: str
    start: int
    end: int
    
    def to_span(self) -> str:
        """Convert to Prolog span format"""
        return f'span("{self.text}",{self.start},{self.end})'

@dataclass
class Person(Entity):
    """Person entity"""
    name: str
    
    def __post_init__(self):
        self.text = self.name

@dataclass
class Amount(Entity):
    """Amount entity"""
    value: int
    original_text: str
    
    def __post_init__(self):
        self.text = self.original_text

@dataclass
class Date(Entity):
    """Date entity (year)"""
    year: int
    
    def __post_init__(self):
        self.text = str(self.year)

@dataclass
class Relationship:
    """Relationship between entities"""
    type: str  # spouse, dependent, employer, etc.
    subject: Entity
    object: Entity
    text_span: Tuple[int, int]

class EntityExtractor:
    """Advanced entity extraction for tax law scenarios"""
    
    def __init__(self):
        # Common person names in the dataset
        self.person_names = [
            'Alice', 'Bob', 'Charlie', 'Dorothy', 'Walter', 
            'Emily', 'Frank', 'Grace', 'Henry', 'Irene'
        ]
        
        # Compile patterns
        self.amount_pattern = re.compile(r'\$(\d{1,3}(?:,\d{3})*|\d+)')
        self.year_pattern = re.compile(r'\b(19\d{2}|20\d{2})\b')
        
        # Relationship patterns with groups
        self.relationship_patterns = {
            'spouse': [
                (r'(\w+) (?:is )?married to (\w+)', ['subject', 'object']),
                (r'(\w+) and (\w+) are married', ['subject', 'object']),
                (r'(\w+) is the spouse of (\w+)', ['subject', 'object']),
                (r'(\w+) and (?:his|her) spouse (\w+)', ['subject', 'object']),
                (r'(\w+), who is married to (\w+)', ['subject', 'object'])
            ],
            'dependent': [
                (r'(\w+) is a dependent of (\w+)', ['dependent', 'parent']),
                (r'(\w+) is (\w+)\'s dependent', ['dependent', 'parent']),
                (r'(\w+) claims (\w+) as a dependent', ['parent', 'dependent']),
                (r'(\w+) (?:has|have) (?:a )?dependent[s]? (?:named )?(\w+)', ['parent', 'dependent']),
                (r'dependent (\w+) of (\w+)', ['dependent', 'parent'])
            ],
            'employer': [
                (r'(\w+) works for ([\w\s]+?)(?:\.|,|$)', ['employee', 'employer']),
                (r'(\w+) is employed by ([\w\s]+?)(?:\.|,|$)', ['employee', 'employer']),
                (r'(\w+) is an employee of ([\w\s]+?)(?:\.|,|$)', ['employee', 'employer']),
                (r'([\w\s]+?) employs (\w+)', ['employer', 'employee'])
            ]
        }
        
        # Event patterns
        self.event_patterns = {
            'income': [
                r"(\w+)'s income",
                r"income of (\w+)",
                r"(\w+) earned",
                r"(\w+) received",
                r"(\w+) has income"
            ],
            'payment': [
                r"(\w+) paid",
                r"(\w+) spent",
                r"payment by (\w+)",
                r"(\w+) made a payment"
            ],
            'medical': [
                r"medical (?:care|expenses?|costs?)",
                r"health (?:care|expenses?|costs?)",
                r"doctor(?:'s)? (?:visits?|bills?)",
                r"hospital (?:bills?|expenses?)"
            ]
        }
    
    def extract_all(self, text: str) -> Dict[str, List]:
        """Extract all entities from text"""
        return {
            'persons': self.extract_people(text),
            'amounts': self.extract_amounts(text),
            'dates': self.extract_dates(text),
            'relationships': self.extract_relationships(text),
            'events': self.extract_events(text),
            'employment': self.extract_employment(text)
        }
    
    def extract_people(self, text: str) -> List[Person]:
        """Extract person entities with positions (FIXED: inclusive end)"""
        people = []
        seen = set()
        
        # First, look for known names
        for name in self.person_names:
            for match in re.finditer(r'\b' + name + r'\b', text):
                if name not in seen:
                    people.append(Person(
                        name=name,
                        start=match.start(),
                        end=match.end() - 1,  # INCLUSIVE end
                        text=name
                    ))
                    seen.add(name)
        
        # Look for Trust entities
        for match in re.finditer(r'([\w\s]+Trust[\w\s]*?)(?:\.|,|$|\s+and|\s+in|\s+for)', text):
            trust_name = match.group(1).strip()
            if trust_name not in seen:
                people.append(Person(
                    name=trust_name,
                    start=match.start(),
                    end=match.start() + len(trust_name) - 1,  
                    text=trust_name
                ))
                seen.add(trust_name)
        
        # Look for organisations/companies
        org_patterns = [
            r'([\w\s]+(?:Company|Corp|Corporation|Inc|LLC|Trust))',
            r'works for ([\w\s]+?)(?:\.|,|$|\s+and)',
            r'employed by ([\w\s]+?)(?:\.|,|$|\s+and)'
        ]
        
        for pattern in org_patterns:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                org_name = match.group(1).strip()
                if org_name not in seen and len(org_name) < 50:  # Sanity check
                    people.append(Person(
                        name=org_name,
                        start=match.start(1) if match.lastindex else match.start(),
                        end=(match.start(1) if match.lastindex else match.start()) + len(org_name) - 1,  
                        text=org_name
                    ))
                    seen.add(org_name)
        
        return sorted(people, key=lambda p: p.start)
    
    def extract_amounts(self, text: str) -> List[Amount]:
        """Extract monetary amounts with positions"""
        amounts = []
        
        for match in self.amount_pattern.finditer(text):
            amount_str = match.group(1).replace(',', '')
            amounts.append(Amount(
                value=int(amount_str),
                original_text=match.group(0),
                start=match.start(),
                end=match.end() - 1,  
                text=match.group(0)
            ))
        
        return sorted(amounts, key=lambda a: a.start)
    
    def extract_dates(self, text: str) -> List[Date]:
        """Extract dates (years) with positions"""
        dates = []
        
        for match in self.year_pattern.finditer(text):
            year = int(match.group(1))
            dates.append(Date(
                year=year,
                start=match.start(),
                end=match.end() - 1,  
                text=match.group(1)
            ))
        
        # Also look for date phrases
        date_phrases = [
            (r'(?:in|for) the year (\d{4})', 1),
            (r'(?:in|for) (\d{4})', 1),
            (r'year (\d{4})', 1)
        ]
        
        for pattern, group in date_phrases:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                year = int(match.group(group))
                # Checks if we already have this year at a nearby position
                year_start = match.start(group) 
                if not any(d.year == year and abs(d.start - year_start) < 5 for d in dates):
                    dates.append(Date(
                        year=year,
                        start=year_start,
                        end=match.end(group) - 1,  
                        text=match.group(group)
                    ))
        
        return sorted(dates, key=lambda d: d.start)
    
    def extract_relationships(self, text: str) -> List[Relationship]:
        """Extract relationships between people (FIXED: inclusive end)"""
        relationships = []
        people = self.extract_people(text)
        
        # Create a map of names to Person entities
        person_map = {p.name: p for p in people}
        
        for rel_type, patterns in self.relationship_patterns.items():
            for pattern, roles in patterns:
                for match in re.finditer(pattern, text, re.IGNORECASE):
                    # Extract the two entities
                    entity1_name = match.group(1).strip()
                    entity2_name = match.group(2).strip() if match.lastindex >= 2 else None
                    
                    if entity2_name:
                        # Find or create Person entities
                        person1 = person_map.get(entity1_name)
                        person2 = person_map.get(entity2_name)
                        
                        if not person1:
                            # Find position of person1 in the match
                            p1_start = match.start() + match.group(0).find(entity1_name)
                            person1 = Person(
                                name=entity1_name,
                                start=p1_start,
                                end=p1_start + len(entity1_name) - 1,  
                                text=entity1_name
                            )
                        
                        if not person2:
                            # Find position of person2 in the match
                            p2_start = match.start() + match.group(0).find(entity2_name)
                            person2 = Person(
                                name=entity2_name,
                                start=p2_start,
                                end=p2_start + len(entity2_name) - 1,  
                                text=entity2_name
                            )
                        
                        # Determine subject and object based on roles
                        if roles[0] in ['subject', 'employee', 'dependent']:
                            subject, object = person1, person2
                        else:
                            subject, object = person2, person1
                        
                        relationships.append(Relationship(
                            type=rel_type,
                            subject=subject,
                            object=object,
                            text_span=(match.start(), match.end() - 1) 
                        ))
        
        return relationships
    
    def extract_employment(self, text: str) -> List[Dict]:
        """Extract employment relationships"""
        employment = []
        
        # Employment patterns
        patterns = [
            r'(\w+) works for ([\w\s]+?)(?:\.|,|$|\s+and)',
            r'(\w+) is employed by ([\w\s]+?)(?:\.|,|$|\s+and)',
            r'(\w+) is an employee of ([\w\s]+?)(?:\.|,|$|\s+and)',
            r'([\w\s]+?) employs (\w+)'
        ]
        
        for pattern in patterns:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                if "employs" in pattern:
                    employer = match.group(1).strip()
                    employee = match.group(2).strip()
                else:
                    employee = match.group(1).strip()
                    employer = match.group(2).strip()
                
                employment.append({
                    'employee': employee,
                    'employer': employer,
                    'start': match.start(),
                    'end': match.end() - 1,  
                    'text': match.group(0)
                })
        
        return employment
    
    def extract_events(self, text: str) -> List[Dict]:
        """Extract events (income, payments, etc.) with INCLUSIVE spans"""
        events = []
        
        # Income events
        income_patterns = [
            (r"(\w+)'s income", 'income', 'subject'),
            (r"income of (\w+)", 'income', 'subject'),
            (r"(\w+) earned", 'earned', 'agent'),
            (r"(\w+) received", 'received', 'agent'),
            (r"(\w+) has income", 'income', 'agent')
        ]
        
        for pattern, event_type, role in income_patterns:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                person = match.group(1)
                
                # Find the event word
                if event_type in match.group(0):
                    event_start = match.start() + match.group(0).find(event_type)
                    event_end = event_start + len(event_type) - 1  
                else:
                    event_start = match.start()
                    event_end = match.end() - 1  
                
                events.append({
                    'type': 'income',
                    'event_word': event_type,
                    'person': person,
                    'role': role,
                    'start': event_start,
                    'end': event_end,
                    'full_match': match.group(0)
                })
        
        # Payment events
        payment_patterns = [
            (r"(\w+) paid", 'paid', 'agent'),
            (r"(\w+) spent", 'spent', 'agent'),
            (r"payment by (\w+)", 'payment', 'agent'),
            (r"(\w+) made a payment", 'payment', 'agent')
        ]
        
        for pattern, event_type, role in payment_patterns:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                person = match.group(1)
                
                # Find the event word
                if event_type in match.group(0):
                    event_start = match.start() + match.group(0).find(event_type)
                    event_end = event_start + len(event_type) - 1 
                else:
                    event_start = match.start()
                    event_end = match.end() - 1  
                
                events.append({
                    'type': 'payment',
                    'event_word': event_type,
                    'person': person,
                    'role': role,
                    'start': event_start,
                    'end': event_end,
                    'full_match': match.group(0)
                })
        
        return sorted(events, key=lambda e: e['start'])
    
    def find_associated_data(self, text: str, event: Dict) -> Dict:
        """Find amount, date, purpose associated with an event"""
        associated = {}
        
        # Look for amounts near the event (within 50 characters)
        amounts = self.extract_amounts(text)
        for amount in amounts:
            if abs(amount.start - event['start']) < 50:
                associated['amount'] = amount
                break
        
        # Look for dates near the event
        dates = self.extract_dates(text)
        for date in dates:
            if abs(date.start - event['start']) < 50:
                associated['date'] = date
                break
        
        # Look for purpose (for payments)
        if event['type'] == 'payment':
            purpose_patterns = [
                r'for ([\w\s]+?)(?:\.|,|$|\s+in|\s+to)',
                r'on ([\w\s]+?)(?:\.|,|$|\s+in)',
                r'toward[s]? ([\w\s]+?)(?:\.|,|$)'
            ]
            
            search_start = max(0, event['start'] - 10)
            search_end = min(len(text), event['end'] + 100)
            search_text = text[search_start:search_end]
            
            for pattern in purpose_patterns:
                match = re.search(pattern, search_text, re.IGNORECASE)
                if match:
                    purpose_text = match.group(1).strip()
                    purpose_start = search_start + match.start(1)
                    associated['purpose'] = {
                        'text': purpose_text,
                        'start': purpose_start,
                        'end': purpose_start + len(purpose_text) - 1  
                    }
                    break
        
        return associated