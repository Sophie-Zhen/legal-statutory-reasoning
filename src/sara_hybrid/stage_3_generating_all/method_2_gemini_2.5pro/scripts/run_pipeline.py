#!/usr/bin/env python3
"""
Main Pipeline Controller for Method 2 Gemini 2.5 Pro
Orchestrates the complete Prolog generation and testing process.
"""

import sys
import time
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Tuple, Optional

# Import our custom modules
from gemini_generator import GeminiGenerator
from prolog_parser import PrologParser
from smoke_tester import SmokeTester


class PipelineController:
    def __init__(self):
        """Initialize the pipeline controller."""
        
        # Setup paths
        self.base_dir = Path(__file__).parent.parent
        self.prolog_dir = self.base_dir / "prolog_codebase"
        self.intermediate_dir = self.base_dir / "intermediate_files"
        self.results_dir = self.base_dir / "results"
        
        # Initialize components
        self.generator = GeminiGenerator()
        self.parser = PrologParser()
        self.tester = SmokeTester()
        
        # Pipeline state
        self.iteration_count = 0
        self.total_files_generated = 0
        self.total_files_passed = 0
        self.max_iterations = 50  # Prevent infinite loops
        self.max_regeneration_attempts = 3  # Max attempts to fix a single file
        
        # Results tracking
        self.pipeline_log = []
        self.successful_files = []
        self.failed_files = []
        
        print("🚀 Method 2 Gemini 2.5 Pro Pipeline Initialized")
        print(f"Base directory: {self.base_dir}")
        print(f"Max iterations: {self.max_iterations}")
    
    def clean_prolog_directory(self):
        """Clean the prolog_codebase directory before starting."""
        print("\n🧹 Cleaning prolog_codebase directory...")
        
        if self.prolog_dir.exists():
            for file in self.prolog_dir.glob("*.pl"):
                file.unlink()
                print(f"Removed: {file.name}")
        
        # Recreate directory
        self.prolog_dir.mkdir(exist_ok=True)
        print("✅ Directory cleaned")
    
    def process_response(self, response_text: str) -> Tuple[List[Path], List[Tuple[Path, str]]]:
        """
        Process a Gemini response: parse files, save them, and run smoke tests.
        
        Args:
            response_text: Raw response from Gemini
            
        Returns:
            Tuple of (successful_files, failed_files_with_errors)
        """
        print(f"\n📄 Processing response ({len(response_text)} characters)...")
        
        # Parse and save Prolog files
        saved_files = self.parser.parse_response_and_save(response_text)
        
        if not saved_files:
            print("⚠️ No Prolog files found in response")
            return [], []
        
        print(f"💾 Saved {len(saved_files)} files")
        
        # Run smoke tests on all saved files
        successful_files, failed_files = self.tester.test_all_files(saved_files)
        
        # Update counters
        self.total_files_generated += len(saved_files)
        self.total_files_passed += len(successful_files)
        
        # Log this iteration
        iteration_data = {
            "iteration": self.iteration_count,
            "response_length": len(response_text),
            "files_found": len(saved_files),
            "files_passed": len(successful_files),
            "files_failed": len(failed_files),
            "successful_files": [f.name for f in successful_files],
            "failed_files": [(f.name, err[:100]) for f, err in failed_files],
            "timestamp": datetime.now().isoformat()
        }
        
        self.pipeline_log.append(iteration_data)
        
        # Save intermediate JSON results (similar to Phase 0)
        self._save_intermediate_json(iteration_data)
        
        # Save raw response JSON for debugging
        self._save_raw_response_json(response_text, iteration_data)
        
        return successful_files, failed_files
    
    def _save_intermediate_json(self, iteration_data: Dict):
        """
        Save intermediate JSON results for each response (Phase 0 style).
        
        Args:
            iteration_data: Data from the current iteration
        """
        # Save current iteration data
        iteration_file = self.results_dir / f"response_{self.iteration_count:03d}_results.json"
        with open(iteration_file, 'w', encoding='utf-8') as f:
            json.dump(iteration_data, f, indent=2)
        
        # Save cumulative results (similar to Phase 1's stage1_results.json)
        cumulative_file = self.results_dir / "cumulative_results.json"
        cumulative_data = {
            "total_iterations": self.iteration_count,
            "total_files_generated": self.total_files_generated,
            "total_files_passed": self.total_files_passed,
            "total_llm_responses": self.generator.response_count,
            "iterations": self.pipeline_log,
            "last_updated": datetime.now().isoformat()
        }
        
        with open(cumulative_file, 'w', encoding='utf-8') as f:
            json.dump(cumulative_data, f, indent=2)
        
        print(f"📊 Intermediate results saved: {iteration_file.name}")
        print(f"📊 Cumulative results saved: {cumulative_file.name}")
    
    def _save_raw_response_json(self, response_text: str, iteration_data: Dict):
        """
        Save raw response content to JSON for debugging and analysis.
        
        Args:
            response_text: Raw response from LLM
            iteration_data: Current iteration data
        """
        # Create response data with raw content
        response_data = {
            "iteration": self.iteration_count,
            "timestamp": datetime.now().isoformat(),
            "response_length": len(response_text),
            "raw_response": response_text,
            "files_found": iteration_data["files_found"],
            "files_passed": iteration_data["files_passed"],
            "files_failed": iteration_data["files_failed"],
            "successful_files": iteration_data["successful_files"],
            "failed_files": iteration_data["failed_files"]
        }
        
        # Save raw response JSON
        raw_response_file = self.results_dir / f"raw_response_{self.iteration_count:03d}.json"
        with open(raw_response_file, 'w', encoding='utf-8') as f:
            json.dump(response_data, f, indent=2)
        
        print(f"📄 Raw response saved: {raw_response_file.name}")
    
    def handle_failed_files(self, failed_files: List[Tuple[Path, str]]) -> bool:
        """
        Handle failed files by requesting regeneration.
        
        Args:
            failed_files: List of failed files with error messages
            
        Returns:
            True if regeneration was requested, False if giving up
        """
        if not failed_files:
            return False
        
        print(f"\n🔧 Handling {len(failed_files)} failed files...")
        
        # Try to regenerate each failed file
        for filepath, error_message in failed_files:
            
            # Remove the failed file
            self.tester.cleanup_failed_file(filepath)
            
            # Count regeneration attempts for this file
            file_attempts = sum(1 for log in self.pipeline_log 
                              if filepath.name in [f[0] for f in log.get("failed_files", [])])
            
            if file_attempts >= self.max_regeneration_attempts:
                print(f"❌ Giving up on {filepath.name} after {file_attempts} attempts")
                continue
            
            print(f"🔄 Requesting regeneration for {filepath.name} (attempt {file_attempts + 1})")
            
            try:
                # Request regeneration from Gemini
                response = self.generator.request_regeneration(error_message, filepath.name)
                
                # Process the regeneration response
                new_successful, new_failed = self.process_response(response)
                
                # Check if the specific file was fixed
                if any(f.name == filepath.name for f in new_successful):
                    print(f"✅ Successfully regenerated {filepath.name}")
                else:
                    print(f"⚠️ {filepath.name} still failing after regeneration")
                
            except Exception as e:
                print(f"❌ Error during regeneration of {filepath.name}: {e}")
        
        return True
    
    def check_completion(self, response_text: str) -> bool:
        """
        Check if the generation process is complete.
        
        Args:
            response_text: Latest response from Gemini
            
        Returns:
            True if generation appears complete
        """
        # Only check for explicit completion marker
        if self.parser.check_completion_marker(response_text):
            print("🎯 Found explicit completion marker: <<ALL DONE>>")
            return True
        
        return False
    
    def run_final_tests(self) -> Dict:
        """
        Run final comprehensive tests on the generated codebase.
        
        Returns:
            Dictionary with test results
        """
        print("\n🧪 Running final comprehensive tests...")
        
        # Test all files in the prolog_codebase
        successful_files, failed_files = self.tester.test_directory()
        
        # Save test results
        self.tester.save_test_results(successful_files, failed_files)
        
        # TODO: Add integration tests here if needed
        # This could include running actual tax calculations
        
        results = {
            "total_files": len(successful_files) + len(failed_files),
            "successful_files": len(successful_files),
            "failed_files": len(failed_files),
            "success_rate": len(successful_files) / (len(successful_files) + len(failed_files)) * 100 if (len(successful_files) + len(failed_files)) > 0 else 0,
            "successful_file_names": [f.name for f in successful_files],
            "failed_file_names": [(f.name, err[:100]) for f, err in failed_files]
        }
        
        print(f"📊 Final Test Results:")
        print(f"   Total files: {results['total_files']}")
        print(f"   Successful: {results['successful_files']}")
        print(f"   Failed: {results['failed_files']}")
        print(f"   Success rate: {results['success_rate']:.1f}%")
        
        return results
    
    def save_pipeline_summary(self, final_results: Dict):
        """
        Save a comprehensive summary of the pipeline execution.
        
        Args:
            final_results: Results from final testing
        """
        summary_file = self.results_dir / "pipeline_summary.json"
        
        summary = {
            "pipeline_info": {
                "method": "method_2_gemini_2.5pro",
                "model_used": self.generator.model_name,
                "start_time": self.pipeline_log[0]["timestamp"] if self.pipeline_log else None,
                "end_time": datetime.now().isoformat(),
                "total_iterations": self.iteration_count,
                "max_iterations": self.max_iterations
            },
            "generation_stats": {
                "total_files_generated": self.total_files_generated,
                "total_files_passed_smoke_test": self.total_files_passed,
                "total_llm_responses": self.generator.response_count,
                "conversation_turns": len(self.generator.conversation_history) // 2
            },
            "final_results": final_results,
            "iteration_log": self.pipeline_log,
            "conversation_summary": self.generator.get_conversation_summary()
        }
        
        with open(summary_file, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2)
        
        print(f"📄 Pipeline summary saved: {summary_file}")
        
        # Also save a human-readable summary
        text_summary_file = self.results_dir / "pipeline_summary.txt"
        with open(text_summary_file, 'w', encoding='utf-8') as f:
            f.write("=== Method 2 Gemini 2.5 Pro Pipeline Summary ===\n\n")
            f.write(f"Model: {self.generator.model_name}\n")
            f.write(f"Total iterations: {self.iteration_count}\n")
            f.write(f"Total LLM responses: {self.generator.response_count}\n")
            f.write(f"Total files generated: {self.total_files_generated}\n")
            f.write(f"Files passing smoke tests: {self.total_files_passed}\n")
            f.write(f"Final success rate: {final_results['success_rate']:.1f}%\n\n")
            
            f.write("=== Final Successful Files ===\n")
            for filename in final_results['successful_file_names']:
                f.write(f"✅ {filename}\n")
            
            if final_results['failed_file_names']:
                f.write("\n=== Final Failed Files ===\n")
                for filename, error in final_results['failed_file_names']:
                    f.write(f"❌ {filename}: {error}\n")
        
        print(f"📄 Human-readable summary saved: {text_summary_file}")
    
    def run(self):
        """Run the complete pipeline."""
        print("\n🎯 Starting Method 2 Gemini 2.5 Pro Pipeline")
        
        try:
            # Step 1: Clean workspace
            self.clean_prolog_directory()
            
            # Step 2: Generate initial response
            print("\n📝 Step 1: Initial Prolog generation")
            self.iteration_count += 1
            initial_response = self.generator.generate_initial_response()
            
            # Process initial response
            successful, failed = self.process_response(initial_response)
            
            # Step 3: Continue generation until complete
            # Stop when either: 1) <<ALL DONE>> marker found, or 2) max_iterations (50) reached
            while (self.iteration_count < self.max_iterations and 
                   not self.check_completion(initial_response if self.iteration_count == 1 else response)):
                
                # Handle any failed files first
                if failed:
                    self.handle_failed_files(failed)
                
                # Request continuation
                print(f"\n📝 Step {self.iteration_count + 1}: Continuing generation")
                self.iteration_count += 1
                
                response = self.generator.request_continuation()
                successful, failed = self.process_response(response)
                
                # Add delay to avoid rate limits
                time.sleep(2)
            
            # Log why the pipeline completed
            if self.iteration_count >= self.max_iterations:
                print(f"\n⚠️ Pipeline stopped: Reached maximum iterations ({self.max_iterations})")
            else:
                print(f"\n✅ Pipeline completed: Found <<ALL DONE>> marker after {self.iteration_count} iterations")
                
                # Check answer predicate count for information
                tests_file = self.prolog_dir / "tests.pl"
                if tests_file.exists():
                    with open(tests_file, 'r', encoding='utf-8') as f:
                        tests_content = f.read()
                    answer_count = tests_content.count("answer(")
                    print(f"📊 Final answer predicate count: {answer_count}")
                else:
                    print("⚠️ tests.pl file not found in final check")
                
            # Step 4: Final testing and results
            print("\n🏁 Generation phase complete")
            final_results = self.run_final_tests()
            
            # Step 5: Save summary
            self.save_pipeline_summary(final_results)
            
            print("\n🎉 Pipeline completed successfully!")
            print(f"Generated {final_results['total_files']} files with {final_results['success_rate']:.1f}% success rate")
            
            return final_results
            
        except KeyboardInterrupt:
            print("\n⏹️ Pipeline interrupted by user")
            return None
        except Exception as e:
            print(f"\n❌ Pipeline failed with error: {e}")
            import traceback
            traceback.print_exc()
            return None


def main():
    """Main entry point."""
    print("🚀 Method 2 Gemini 2.5 Pro Pipeline")
    print("=" * 50)
    
    # Check environment
    import os
    if not os.getenv('GEMINI_API_KEY'):
        print("❌ Error: GEMINI_API_KEY environment variable not set")
        print("Please set your Gemini API key before running the pipeline")
        sys.exit(1)
    
    # Run pipeline
    controller = PipelineController()
    results = controller.run()
    
    if results:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main() 