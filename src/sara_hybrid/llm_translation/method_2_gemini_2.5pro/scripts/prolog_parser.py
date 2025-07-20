#!/usr/bin/env python3
"""
Prolog File Parser for Method 2 Pipeline
Extracts and validates Prolog files from LLM responses.
"""

import re
import os
from pathlib import Path
from typing import List, Tuple, Optional


class PrologParser:
    def __init__(self, base_dir: Optional[Path] = None):
        """
        Initialize the Prolog parser.
        
        Args:
            base_dir: Base directory for the pipeline (defaults to parent of script)
        """
        if base_dir is None:
            self.base_dir = Path(__file__).parent.parent
        else:
            self.base_dir = Path(base_dir)
        
        self.prolog_dir = self.base_dir / "prolog_codebase"
        self.intermediate_dir = self.base_dir / "intermediate_files"
        
        # Create directories if they don't exist
        self.prolog_dir.mkdir(exist_ok=True)
        self.intermediate_dir.mkdir(exist_ok=True)
    
    def extract_prolog_files(self, response_text: str) -> List[Tuple[str, str]]:
        """
        Extract Prolog files from LLM response text.
        
        Args:
            response_text: The raw response from the LLM
            
        Returns:
            List of tuples (filename, content)
        """
        files = []
        
        # Pattern 1: Look for explicit file markers (method_3 style)
        file_pattern_1 = r'%% BEGIN_FILE: (.*?)\n(.*?)%% END_FILE: \1'
        matches_1 = re.findall(file_pattern_1, response_text, re.DOTALL)
        
        for filename, content in matches_1:
            files.append((filename.strip(), content.strip()))
        
        # Pattern 2: Look for code blocks with file extensions
        file_pattern_2 = r'```(?:prolog)?\s*(?:% |%)?\s*([a-zA-Z0-9_]+\.pl)\s*\n(.*?)```'
        matches_2 = re.findall(file_pattern_2, response_text, re.DOTALL | re.IGNORECASE)
        
        for filename, content in matches_2:
            if filename not in [f[0] for f in files]:  # Avoid duplicates
                files.append((filename.strip(), content.strip()))
        
        # Pattern 3: Look for section headers followed by code blocks
        section_pattern = r'(?:section|module|file)\s*[:=]\s*([a-zA-Z0-9_]+\.pl).*?```(?:prolog)?\s*\n(.*?)```'
        matches_3 = re.findall(section_pattern, response_text, re.DOTALL | re.IGNORECASE)
        
        for filename, content in matches_3:
            if filename not in [f[0] for f in files]:  # Avoid duplicates
                files.append((filename.strip(), content.strip()))
        
        # Pattern 4: Look for standalone .pl files mentioned
        standalone_pattern = r'([a-zA-Z0-9_]+\.pl):\s*\n((?:(?!```|[a-zA-Z0-9_]+\.pl:).)*)'
        matches_4 = re.findall(standalone_pattern, response_text, re.DOTALL | re.MULTILINE)
        
        for filename, content in matches_4:
            content = content.strip()
            if (len(content) > 50 and  # Must be substantial content
                filename not in [f[0] for f in files] and  # Avoid duplicates
                (':-' in content or 'fact(' in content or 'rule(' in content)):  # Looks like Prolog
                files.append((filename.strip(), content))
        
        print(f"Extracted {len(files)} Prolog files from response")
        for filename, _ in files:
            print(f"  - {filename}")
        
        return files
    
    def save_prolog_file(self, filename: str, content: str) -> Path:
        """
        Save a Prolog file to the prolog_codebase directory.
        
        Args:
            filename: Name of the file
            content: Prolog content
            
        Returns:
            Path to the saved file
        """
        filepath = self.prolog_dir / filename
        
        # Ensure the content has proper Prolog structure
        cleaned_content = self._clean_prolog_content(content)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(cleaned_content)
        
        print(f"Saved Prolog file: {filepath}")
        return filepath
    
    def _clean_prolog_content(self, content: str) -> str:
        """
        Clean and format Prolog content.
        
        Args:
            content: Raw Prolog content
            
        Returns:
            Cleaned Prolog content
        """
        # Remove any markdown artifacts
        content = re.sub(r'^```(?:prolog)?\s*', '', content, flags=re.MULTILINE)
        content = re.sub(r'```\s*$', '', content, flags=re.MULTILINE)
        
        # Remove extra whitespace at start/end
        content = content.strip()
        
        # Ensure it ends with a newline
        if not content.endswith('\n'):
            content += '\n'
        
        return content
    
    def parse_response_and_save(self, response_text: str) -> List[Path]:
        """
        Parse response and save all extracted Prolog files.
        
        Args:
            response_text: The LLM response text
            
        Returns:
            List of paths to saved files
        """
        files = self.extract_prolog_files(response_text)
        saved_paths = []
        
        for filename, content in files:
            try:
                filepath = self.save_prolog_file(filename, content)
                saved_paths.append(filepath)
            except Exception as e:
                print(f"Error saving {filename}: {e}")
        
        return saved_paths
    
    def check_completion_marker(self, response_text: str) -> bool:
        """
        Check if the response contains the exact completion marker.
        
        Args:
            response_text: The LLM response text
            
        Returns:
            True if the exact completion marker is found
        """
        # Look for the exact completion marker specified in the prompt
        if "<<ALL DONE>>" in response_text:
            print("✅ Exact completion marker found: '<<ALL DONE>>'")
            return True
        
        return False
    
    def validate_prolog_syntax(self, content: str) -> Tuple[bool, str]:
        """
        Basic validation of Prolog syntax.
        
        Args:
            content: Prolog content to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        # Basic syntax checks
        try:
            # Check for basic Prolog structure
            if not content.strip():
                return False, "Empty content"
            
            # Check for common Prolog patterns
            prolog_patterns = [
                r':-',  # Rules or directives
                r'\.',  # Fact/rule termination
                r'[a-zA-Z_][a-zA-Z0-9_]*\(',  # Predicate calls
            ]
            
            has_prolog_syntax = any(re.search(pattern, content) for pattern in prolog_patterns)
            
            if not has_prolog_syntax:
                return False, "No recognizable Prolog syntax found"
            
            # Check for unmatched parentheses
            paren_count = content.count('(') - content.count(')')
            if paren_count != 0:
                return False, f"Unmatched parentheses: {paren_count}"
            
            # Check for unmatched brackets
            bracket_count = content.count('[') - content.count(']')
            if bracket_count != 0:
                return False, f"Unmatched brackets: {bracket_count}"
            
            return True, "Basic syntax validation passed"
            
        except Exception as e:
            return False, f"Validation error: {e}"


def main():
    """Test the Prolog parser."""
    parser = PrologParser()
    
    # Test with sample response
    sample_response = """
    Here are the Prolog files:
    
    ```prolog
    % helpers.pl
    :- module(helpers, [calculate_tax/3]).
    
    calculate_tax(Income, Rate, Tax) :-
        Tax is Income * Rate.
    ```
    
    ```prolog
    % section1.pl
    :- module(section1, [tax_bracket/3]).
    
    tax_bracket(Income, single, Rate) :-
        Income =< 10000,
        Rate = 0.1.
    ```
    """
    
    print("Testing Prolog parser...")
    files = parser.extract_prolog_files(sample_response)
    
    print(f"\nExtracted {len(files)} files:")
    for filename, content in files:
        print(f"File: {filename}")
        print(f"Content length: {len(content)}")
        
        # Test validation
        is_valid, message = parser.validate_prolog_syntax(content)
        print(f"Valid: {is_valid} - {message}")
        print("-" * 40)


if __name__ == "__main__":
    main() 