"""
Codebase Analyzer for Method 2 Prolog System
Extracts actual predicates from the Method 2 codebase to generate accurate prompts
"""

import os
import re
import json
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)

@dataclass
class PredicateInfo:
    """Information about a Prolog predicate"""
    name: str
    arity: int
    module: str
    signature: str
    description: str
    examples: List[str]
    is_exported: bool = False

class CodebaseAnalyzer:
    """Analyzes Method 2 Prolog codebase to extract predicate information"""
    
    def __init__(self, codebase_dir: str):
        self.codebase_dir = codebase_dir
        self.predicates: Dict[str, PredicateInfo] = {}
        self.modules: Dict[str, List[str]] = {}
        
    def analyze_codebase(self) -> Dict[str, PredicateInfo]:
        """Analyze the entire codebase and extract predicate information"""
        logger.info("Analyzing Method 2 codebase...")
        
        # Core files to analyze
        core_files = [
            "helpers.pl",
            "knowledge_base.pl",
            "statute_1.pl",
            "statute_2.pl",
            "statute_63.pl",
            "statute_68.pl",
            "statute_151.pl",
            "statute_152.pl",
            "statute_3301.pl",
            "statute_3306.pl",
            "statute_7703.pl"
        ]
        
        for file in core_files:
            file_path = os.path.join(self.codebase_dir, file)
            if os.path.exists(file_path):
                self._analyze_file(file_path)
            else:
                logger.warning(f"File not found: {file}")
        
        logger.info(f"Found {len(self.predicates)} predicates across {len(self.modules)} modules")
        return self.predicates
    
    def _analyze_file(self, file_path: str):
        """Analyze a single Prolog file"""
        module_name = os.path.basename(file_path).replace('.pl', '')
        logger.debug(f"Analyzing {module_name}")
        
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Extract module exports
            exports = self._extract_exports(content)
            self.modules[module_name] = exports
            
            # Extract predicate definitions
            predicates = self._extract_predicates(content, module_name)
            
            # Mark exported predicates
            for pred_key, pred_info in predicates.items():
                if pred_info.name in exports:
                    pred_info.is_exported = True
                self.predicates[pred_key] = pred_info
                
        except Exception as e:
            logger.error(f"Error analyzing {file_path}: {e}")
    
    def _extract_exports(self, content: str) -> List[str]:
        """Extract exported predicates from module declaration"""
        exports = []
        
        # Find module declaration
        module_match = re.search(r':- module\([^,]+,\s*\[(.*?)\]\)', content, re.DOTALL)
        if module_match:
            exports_text = module_match.group(1)
            
            # Extract individual exports
            export_matches = re.findall(r'([a-zA-Z_][a-zA-Z0-9_]*)/(\d+)', exports_text)
            for name, arity in export_matches:
                exports.append(name)
        
        return exports
    
    def _extract_predicates(self, content: str, module_name: str) -> Dict[str, PredicateInfo]:
        """Extract predicate definitions from file content"""
        predicates = {}
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            line = line.strip()
            
            # Skip comments and empty lines
            if not line or line.startswith('%'):
                continue
            
            # Look for predicate definitions (rules)
            if ':-' in line and not line.startswith(':-'):
                pred_info = self._parse_predicate_rule(line, module_name, lines, i)
                if pred_info:
                    key = f"{pred_info.name}/{pred_info.arity}"
                    predicates[key] = pred_info
            
            # Look for facts
            elif line.endswith('.') and '(' in line and ')' in line and not line.startswith(':-'):
                pred_info = self._parse_predicate_fact(line, module_name)
                if pred_info:
                    key = f"{pred_info.name}/{pred_info.arity}"
                    predicates[key] = pred_info
        
        return predicates
    
    def _parse_predicate_rule(self, line: str, module_name: str, lines: List[str], line_idx: int) -> Optional[PredicateInfo]:
        """Parse a predicate rule (head :- body)"""
        try:
            head = line.split(':-')[0].strip()
            
            # Extract predicate name and arity
            if '(' in head and ')' in head:
                name_match = re.match(r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', head)
                if name_match:
                    name = name_match.group(1)
                    arity = self._count_arity(head)
                    
                    # Get description from preceding comments
                    description = self._get_description(lines, line_idx)
                    
                    return PredicateInfo(
                        name=name,
                        arity=arity,
                        module=module_name,
                        signature=head,
                        description=description,
                        examples=[]
                    )
        except Exception as e:
            logger.debug(f"Error parsing rule: {line} - {e}")
        
        return None
    
    def _parse_predicate_fact(self, line: str, module_name: str) -> Optional[PredicateInfo]:
        """Parse a predicate fact"""
        try:
            fact = line[:-1].strip()  # Remove period
            
            # Skip arithmetic and complex expressions
            if any(char in fact for char in ['=', '<', '>', '+', '-', '*', '/', 'is']):
                return None
            
            # Extract predicate name and arity
            if '(' in fact and ')' in fact:
                name_match = re.match(r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', fact)
                if name_match:
                    name = name_match.group(1)
                    arity = self._count_arity(fact)
                    
                    return PredicateInfo(
                        name=name,
                        arity=arity,
                        module=module_name,
                        signature=fact,
                        description=f"Fact: {fact}",
                        examples=[fact]
                    )
        except Exception as e:
            logger.debug(f"Error parsing fact: {line} - {e}")
        
        return None
    
    def _count_arity(self, predicate: str) -> int:
        """Count the arity (number of arguments) of a predicate"""
        try:
            # Find the arguments part
            start = predicate.find('(')
            end = predicate.rfind(')')
            if start == -1 or end == -1:
                return 0
            
            args_part = predicate[start+1:end].strip()
            if not args_part:
                return 0
            
            # Count commas at the same parentheses level
            paren_level = 0
            comma_count = 0
            
            for char in args_part:
                if char == '(':
                    paren_level += 1
                elif char == ')':
                    paren_level -= 1
                elif char == ',' and paren_level == 0:
                    comma_count += 1
            
            return comma_count + 1
        except:
            return 0
    
    def _get_description(self, lines: List[str], line_idx: int) -> str:
        """Get description from preceding comments"""
        description = ""
        
        # Look backwards for comments
        for i in range(line_idx - 1, max(0, line_idx - 5), -1):
            line = lines[i].strip()
            if line.startswith('%'):
                comment = line[1:].strip()
                if comment:
                    description = comment + " " + description
            elif line:  # Non-empty, non-comment line
                break
        
        return description.strip()
    
    def generate_prompt_vocabulary(self) -> str:
        """Generate predicate vocabulary section for prompts"""
        sections = []
        
        # Group predicates by module
        by_module = {}
        for pred_info in self.predicates.values():
            if pred_info.module not in by_module:
                by_module[pred_info.module] = []
            by_module[pred_info.module].append(pred_info)
        
        # Generate sections
        for module_name, predicates in by_module.items():
            if not predicates:
                continue
                
            # Sort predicates by name
            predicates.sort(key=lambda p: p.name)
            
            section_lines = [f"**{module_name}** - {self._get_module_description(module_name)}:"]
            
            for pred in predicates:
                if pred.is_exported:  # Only include exported predicates
                    signature = f"{pred.name}/{pred.arity}"
                    desc = pred.description or "No description"
                    section_lines.append(f"- `{signature}` - {desc}")
            
            if len(section_lines) > 1:  # Only add if has exported predicates
                sections.append("\n".join(section_lines))
        
        return "\n\n".join(sections)
    
    def _get_module_description(self, module_name: str) -> str:
        """Get description for a module"""
        descriptions = {
            "helpers": "Utility functions for calculations",
            "knowledge_base": "Tax law constants and lookup tables",
            "statute_1": "Tax calculation from taxable income",
            "statute_2": "Filing status determination",
            "statute_63": "Standard deduction calculations",
            "statute_68": "Itemized deduction limitations",
            "statute_151": "Personal exemption calculations",
            "statute_152": "Dependency determination",
            "statute_3301": "FUTA tax definitions",
            "statute_3306": "FUTA employer determination",
            "statute_7703": "Marital status determination"
        }
        return descriptions.get(module_name, "Tax law provisions")
    
    def generate_examples(self) -> str:
        """Generate example queries based on actual predicates"""
        examples = []
        
        # Example 1: Section 151 exemption
        if "exemption_amount/2" in self.predicates:
            examples.append("""
**Example 1 - Section 151 exemption amount:**
Question: "What is the exemption amount for 2015?"
Generated:
answer({case_id}, Result) :-
    knowledge_base:exemption_amount(2015, Result).
""")
        
        # Example 2: Tax calculation
        if "calculate_tax_from_brackets/3" in self.predicates:
            examples.append("""
**Example 2 - Tax calculation:**
Question: "How much tax on $50000 income for single filer in 2019?"
Generated:
answer({case_id}, Result) :-
    knowledge_base:tax_brackets(2019, single, Brackets),
    helpers:calculate_tax_from_brackets(50000, Brackets, Result).
""")
        
        # Example 3: Standard deduction
        if "basic_standard_deduction_amount/3" in self.predicates:
            examples.append("""
**Example 3 - Standard deduction:**
Question: "What is the standard deduction for married filing jointly in 2019?"
Generated:
answer({case_id}, Result) :-
    knowledge_base:basic_standard_deduction_amount(2019, married_filing_jointly, Result).
""")
        
        return "\n".join(examples)
    
    def save_analysis(self, output_path: str):
        """Save analysis results to JSON file"""
        data = {
            "modules": self.modules,
            "predicates": {
                key: {
                    "name": pred.name,
                    "arity": pred.arity,
                    "module": pred.module,
                    "signature": pred.signature,
                    "description": pred.description,
                    "examples": pred.examples,
                    "is_exported": pred.is_exported
                }
                for key, pred in self.predicates.items()
            }
        }
        
        with open(output_path, 'w') as f:
            json.dump(data, f, indent=2)
        
        logger.info(f"Analysis saved to {output_path}")

def main():
    """Main function for testing"""
    current_dir = os.path.dirname(os.path.abspath(__file__))
    codebase_dir = os.path.join(current_dir, "../prolog_codebase")
    
    analyzer = CodebaseAnalyzer(codebase_dir)
    predicates = analyzer.analyze_codebase()
    
    print("=== PREDICATE VOCABULARY ===")
    print(analyzer.generate_prompt_vocabulary())
    
    print("\n=== EXAMPLES ===")
    print(analyzer.generate_examples())
    
    # Save analysis
    output_path = os.path.join(current_dir, "codebase_analysis.json")
    analyzer.save_analysis(output_path)

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main() 