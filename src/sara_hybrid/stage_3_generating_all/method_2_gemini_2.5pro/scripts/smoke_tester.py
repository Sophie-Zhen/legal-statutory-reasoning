#!/usr/bin/env python3
"""
Smoke Tester for Method 2 Pipeline
Tests Prolog files for syntax errors using SWI-Prolog.
"""

import subprocess
import os
import tempfile
from pathlib import Path
from typing import Tuple, List, Optional


class SmokeTester:
    def __init__(self, base_dir: Optional[Path] = None):
        """
        Initialize the smoke tester.
        
        Args:
            base_dir: Base directory for the pipeline (defaults to parent of script)
        """
        if base_dir is None:
            self.base_dir = Path(__file__).parent.parent
        else:
            self.base_dir = Path(base_dir)
        
        self.prolog_dir = self.base_dir / "prolog_codebase"
        self.results_dir = self.base_dir / "results"
        
        # Create directories if they don't exist
        self.results_dir.mkdir(exist_ok=True)
    
    def test_prolog_file(self, filepath: Path) -> Tuple[bool, str]:
        """
        Test a single Prolog file for syntax errors.
        
        Args:
            filepath: Path to the Prolog file
            
        Returns:
            Tuple of (success, error_message)
        """
        try:
            # Convert to absolute path
            abs_filepath = filepath.resolve()
            
            if not abs_filepath.exists():
                return False, f"File not found: {abs_filepath}"
            
            print(f"Testing {filepath.name}...")
            
            # Create SWI-Prolog command to load and check syntax
            cmd = [
                "swipl",
                "-q",  # Quiet startup
                "-g", f"load_files('{abs_filepath}', [silent(true)])",
                "-g", "halt"
            ]
            
            # Run the command
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Check result
            if result.returncode == 0:
                print(f"✅ {filepath.name} passed smoke test")
                return True, "Smoke test passed"
            else:
                error_output = result.stderr.strip()
                if not error_output:
                    error_output = result.stdout.strip()
                
                print(f"❌ {filepath.name} failed smoke test")
                print(f"Error: {error_output}")
                return False, error_output
                
        except subprocess.TimeoutExpired:
            return False, "Smoke test timed out (30s)"
        except FileNotFoundError:
            return False, "SWI-Prolog not found. Please ensure swipl is installed and in PATH."
        except Exception as e:
            return False, f"Smoke test error: {str(e)}"
    
    def test_prolog_content(self, content: str, filename: str = "temp.pl") -> Tuple[bool, str]:
        """
        Test Prolog content by creating a temporary file.
        
        Args:
            content: Prolog content to test
            filename: Name for the temporary file
            
        Returns:
            Tuple of (success, error_message)
        """
        try:
            # Create temporary file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.pl', delete=False) as temp_file:
                temp_file.write(content)
                temp_filepath = Path(temp_file.name)
            
            # Test the temporary file
            success, error_message = self.test_prolog_file(temp_filepath)
            
            # Clean up
            temp_filepath.unlink()
            
            return success, error_message
            
        except Exception as e:
            return False, f"Error testing content: {str(e)}"
    
    def test_all_files(self, file_paths: List[Path]) -> Tuple[List[Path], List[Tuple[Path, str]]]:
        """
        Test multiple Prolog files.
        
        Args:
            file_paths: List of file paths to test
            
        Returns:
            Tuple of (successful_files, failed_files_with_errors)
        """
        successful_files = []
        failed_files = []
        
        print(f"\n--- Testing {len(file_paths)} Prolog files ---")
        
        for filepath in file_paths:
            success, error_message = self.test_prolog_file(filepath)
            
            if success:
                successful_files.append(filepath)
            else:
                failed_files.append((filepath, error_message))
        
        print(f"\n--- Smoke Test Results ---")
        print(f"✅ Passed: {len(successful_files)}")
        print(f"❌ Failed: {len(failed_files)}")
        
        if failed_files:
            print("\nFailed files:")
            for filepath, error in failed_files:
                print(f"  - {filepath.name}: {error[:100]}...")
        
        return successful_files, failed_files
    
    def test_directory(self, directory: Optional[Path] = None) -> Tuple[List[Path], List[Tuple[Path, str]]]:
        """
        Test all Prolog files in a directory.
        
        Args:
            directory: Directory to test (defaults to prolog_codebase)
            
        Returns:
            Tuple of (successful_files, failed_files_with_errors)
        """
        if directory is None:
            directory = self.prolog_dir
        
        # Find all .pl files
        pl_files = list(directory.glob("*.pl"))
        
        if not pl_files:
            print(f"No .pl files found in {directory}")
            return [], []
        
        return self.test_all_files(pl_files)
    
    def cleanup_failed_file(self, filepath: Path) -> bool:
        """
        Remove a failed Prolog file.
        
        Args:
            filepath: Path to the file to remove
            
        Returns:
            True if successfully removed
        """
        try:
            if filepath.exists():
                filepath.unlink()
                print(f"🗑️ Removed failed file: {filepath.name}")
                return True
            return False
        except Exception as e:
            print(f"Error removing file {filepath}: {e}")
            return False
    
    def save_test_results(self, successful_files: List[Path], failed_files: List[Tuple[Path, str]]):
        """
        Save test results to a file.
        
        Args:
            successful_files: List of successful file paths
            failed_files: List of failed files with error messages
        """
        results_file = self.results_dir / "smoke_test_results.txt"
        
        with open(results_file, 'w', encoding='utf-8') as f:
            f.write("=== Smoke Test Results ===\n\n")
            f.write(f"Total files tested: {len(successful_files) + len(failed_files)}\n")
            f.write(f"Successful: {len(successful_files)}\n")
            f.write(f"Failed: {len(failed_files)}\n\n")
            
            if successful_files:
                f.write("=== SUCCESSFUL FILES ===\n")
                for filepath in successful_files:
                    f.write(f"✅ {filepath.name}\n")
                f.write("\n")
            
            if failed_files:
                f.write("=== FAILED FILES ===\n")
                for filepath, error in failed_files:
                    f.write(f"❌ {filepath.name}\n")
                    f.write(f"   Error: {error}\n\n")
        
        print(f"Test results saved to: {results_file}")


def main():
    """Test the smoke tester."""
    tester = SmokeTester()
    
    # Test the prolog_codebase directory
    print("Testing all Prolog files in prolog_codebase...")
    successful, failed = tester.test_directory()
    
    # Save results
    tester.save_test_results(successful, failed)
    
    # Test with sample content
    print("\nTesting sample Prolog content...")
    sample_content = """
    :- module(test, [test_predicate/1]).
    
    test_predicate(X) :- 
        X > 0.
    """
    
    success, message = tester.test_prolog_content(sample_content)
    print(f"Sample test result: {success} - {message}")


if __name__ == "__main__":
    main() 