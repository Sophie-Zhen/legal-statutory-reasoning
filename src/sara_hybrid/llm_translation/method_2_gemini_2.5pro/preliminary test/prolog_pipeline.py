#!/usr/bin/env python3
import os
import subprocess
import sys
import time
import re
from datetime import datetime
from pathlib import Path

class PrologPipeline:
    def __init__(self, working_dir):
        """
        Initialize the Prolog pipeline.
        
        Args:
            working_dir: Directory containing all Prolog files and scripts
        """
        self.working_dir = Path(working_dir)
        self.log_file = self.working_dir / "pipeline_log.txt"
        self.prolog_output_file = self.working_dir / "prolog_execution.log"
        self.statistics_file = self.working_dir / "statistics_report.txt"
        
    def log_message(self, message):
        """Log a message with timestamp."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {message}"
        print(log_entry)
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_entry + '\n')
    
    def initialize_working_directory(self):
        """Initialize the working directory and verify all required files exist."""
        self.log_message("Initializing working directory...")
        
        # Check if we're in the correct directory
        required_files = [
            'tests.pl',
            'helpers.pl',
            'section1.pl',
            'section2.pl',
            'section63.pl',
            'section68.pl',
            'section151.pl',
            'section152.pl',
            'section7703.pl',
            'section3301.pl',
            'section3306.pl',
            'count_passed_cases.py'
        ]
        
        missing_files = []
        for file in required_files:
            if not (self.working_dir / file).exists():
                missing_files.append(file)
        
        if missing_files:
            self.log_message(f"ERROR: Missing required files: {missing_files}")
            return False
        
        self.log_message(f"Working directory initialized successfully. Found {len(required_files)} required files.")
        return True
    
    def run_prolog_tests(self, num_runs=1):
        """
        Run the Prolog tests and capture output.
        
        Args:
            num_runs: Number of times to run the tests (default: 1)
        """
        self.log_message(f"Starting Prolog test execution ({num_runs} run{'s' if num_runs > 1 else ''})...")
        
        # Clear previous output file
        if self.prolog_output_file.exists():
            self.prolog_output_file.unlink()
        
        all_output = []
        
        for run_num in range(1, num_runs + 1):
            self.log_message(f"Starting Run {run_num}/{num_runs}...")
            
            # Create run separator - simplified for single run
            if num_runs == 1:
                run_separator = f"\n{'='*25} Prolog Test Execution {'='*25}\n"
            else:
                run_separator = f"\n{'='*25} Run {run_num} {'='*25}\n"
            all_output.append(run_separator)
            
            try:
                # Run Prolog with tests.pl
                cmd = [
                    'swipl',
                    '-q',  # Quiet mode
                    '-f', str(self.working_dir / 'tests.pl'),
                    '-t', 'run_all_tests',
                    '-g', 'halt'
                ]
                
                self.log_message(f"Executing: {' '.join(cmd)}")
                
                # Run the command and capture output
                result = subprocess.run(
                    cmd,
                    cwd=self.working_dir,
                    capture_output=True,
                    text=True,
                    timeout=300  # 5 minute timeout
                )
                
                # Add command output
                run_output = f"Command: {' '.join(cmd)}\n"
                run_output += f"Return code: {result.returncode}\n"
                run_output += f"STDOUT:\n{result.stdout}\n"
                if result.stderr:
                    run_output += f"STDERR:\n{result.stderr}\n"
                
                all_output.append(run_output)
                
                if result.returncode == 0:
                    self.log_message(f"Run {run_num} completed successfully")
                else:
                    self.log_message(f"Run {run_num} completed with return code {result.returncode}")
                
            except subprocess.TimeoutExpired:
                error_msg = f"Run {run_num} timed out after 5 minutes"
                self.log_message(error_msg)
                all_output.append(f"ERROR: {error_msg}\n")
            except Exception as e:
                error_msg = f"Run {run_num} failed with exception: {str(e)}"
                self.log_message(error_msg)
                all_output.append(f"ERROR: {error_msg}\n")
            
            # Add a small delay between runs only if multiple runs
            if run_num < num_runs:
                time.sleep(2)
        
        # Write all output to file
        with open(self.prolog_output_file, 'w', encoding='utf-8') as f:
            f.write(''.join(all_output))
        
        self.log_message(f"Prolog execution completed. Output saved to {self.prolog_output_file}")
        return True
    
    def run_statistics_analysis(self):
        """Run the statistics analysis using count_passed_cases.py."""
        self.log_message("Running statistics analysis...")
        
        try:
            # Run the count_passed_cases.py script
            cmd = [
                sys.executable,
                str(self.working_dir / 'count_passed_cases.py')
            ]
            
            self.log_message(f"Executing: {' '.join(cmd)}")
            
            result = subprocess.run(
                cmd,
                cwd=self.working_dir,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            # Save statistics output
            with open(self.statistics_file, 'w', encoding='utf-8') as f:
                f.write("Prolog Pipeline Statistics Report\n")
                f.write("=" * 50 + "\n\n")
                f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                f.write("Command Output:\n")
                f.write("-" * 20 + "\n")
                f.write(result.stdout)
                if result.stderr:
                    f.write("\nErrors:\n")
                    f.write("-" * 10 + "\n")
                    f.write(result.stderr)
            
            self.log_message(f"Statistics analysis completed. Report saved to {self.statistics_file}")
            
            # Print summary to console
            print("\n" + "="*50)
            print("STATISTICS SUMMARY")
            print("="*50)
            print(result.stdout)
            if result.stderr:
                print("\nERRORS:")
                print(result.stderr)
            
            return True
            
        except subprocess.TimeoutExpired:
            self.log_message("Statistics analysis timed out")
            return False
        except Exception as e:
            self.log_message(f"Statistics analysis failed: {str(e)}")
            return False
    
    def generate_summary_report(self):
        """Generate a comprehensive summary report."""
        self.log_message("Generating summary report...")
        
        summary_file = self.working_dir / "pipeline_summary.txt"
        
        with open(summary_file, 'w', encoding='utf-8') as f:
            f.write("PROLOG PIPELINE SUMMARY REPORT\n")
            f.write("=" * 50 + "\n\n")
            f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Working Directory: {self.working_dir}\n\n")
            
            # File status
            f.write("FILE STATUS:\n")
            f.write("-" * 15 + "\n")
            prolog_files = [
                'tests.pl', 'helpers.pl', 'section1.pl', 'section2.pl',
                'section63.pl', 'section68.pl', 'section151.pl', 'section152.pl',
                'section7703.pl', 'section3301.pl', 'section3306.pl'
            ]
            
            for file in prolog_files:
                file_path = self.working_dir / file
                if file_path.exists():
                    size = file_path.stat().st_size
                    f.write(f"✓ {file} ({size:,} bytes)\n")
                else:
                    f.write(f"✗ {file} (MISSING)\n")
            
            f.write("\nEXECUTION LOGS:\n")
            f.write("-" * 15 + "\n")
            if self.prolog_output_file.exists():
                f.write(f"✓ Prolog execution log: {self.prolog_output_file}\n")
            else:
                f.write("✗ Prolog execution log: NOT FOUND\n")
                
            if self.statistics_file.exists():
                f.write(f"✓ Statistics report: {self.statistics_file}\n")
            else:
                f.write("✗ Statistics report: NOT FOUND\n")
            
            f.write(f"✓ Pipeline log: {self.log_file}\n")
        
        self.log_message(f"Summary report generated: {summary_file}")
        return summary_file
    
    def run_full_pipeline(self, num_runs=3):
        """
        Run the complete pipeline.
        
        Args:
            num_runs: Number of times to run the Prolog tests
        """
        self.log_message("=" * 60)
        self.log_message("STARTING PROLOG PIPELINE EXECUTION")
        self.log_message("=" * 60)
        
        # Step 1: Initialize working directory
        if not self.initialize_working_directory():
            self.log_message("Pipeline failed at initialization step")
            return False
        
        # Step 2: Run Prolog tests
        if not self.run_prolog_tests(num_runs):
            self.log_message("Pipeline failed at Prolog execution step")
            return False
        
        # Step 3: Run statistics analysis
        if not self.run_statistics_analysis():
            self.log_message("Pipeline failed at statistics analysis step")
            return False
        
        # Step 4: Generate summary report
        summary_file = self.generate_summary_report()
        
        self.log_message("=" * 60)
        self.log_message("PIPELINE EXECUTION COMPLETED SUCCESSFULLY")
        self.log_message("=" * 60)
        self.log_message(f"Summary report: {summary_file}")
        self.log_message(f"Prolog output: {self.prolog_output_file}")
        self.log_message(f"Statistics: {self.statistics_file}")
        self.log_message(f"Pipeline log: {self.log_file}")
        
        return True

def main():
    """Main function to run the pipeline."""
    # Get the directory of the current script
    script_dir = Path(__file__).parent
    
    # Create pipeline instance
    pipeline = PrologPipeline(script_dir)
    
    # Check command line arguments
    num_runs = 1  # default to single run
    if len(sys.argv) > 1:
        try:
            num_runs = int(sys.argv[1])
        except ValueError:
            print("Usage: python prolog_pipeline.py [num_runs]")
            print("  num_runs: Number of Prolog test runs (default: 1)")
            sys.exit(1)
    
    # Run the pipeline
    success = pipeline.run_full_pipeline(num_runs)
    
    if success:
        print("\nPipeline completed successfully!")
        sys.exit(0)
    else:
        print("\nPipeline failed!")
        sys.exit(1)

if __name__ == "__main__":
    main() 