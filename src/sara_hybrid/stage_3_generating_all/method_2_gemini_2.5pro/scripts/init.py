#!/usr/bin/env python3
"""
Master Runner for Method 2 Gemini 2.5 Pro Pipeline
Orchestrates the complete process from generation to analysis.
"""

import sys
import os
from pathlib import Path
from datetime import datetime

# Import our pipeline components
from run_pipeline import PipelineController
from method2_codebase_accuracy_runner import Method2CodebaseAccuracyRunner


def check_environment():
    """Check if the environment is properly set up."""
    print("🔍 Checking environment...")
    
    # Check API key
    if not os.getenv('GEMINI_API_KEY'):
        print("❌ Error: GEMINI_API_KEY environment variable not set")
        print("Please set your Gemini API key:")
        print("export GEMINI_API_KEY='your_api_key_here'")
        return False
    
    # Check SWI-Prolog installation
    try:
        import subprocess
        result = subprocess.run(['swipl', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ SWI-Prolog found")
        else:
            print("❌ SWI-Prolog not working properly")
            return False
    except FileNotFoundError:
        print("❌ SWI-Prolog not found. Please install SWI-Prolog and ensure 'swipl' is in PATH")
        return False
    
    # Check Python dependencies
    try:
        import google.generativeai as genai
        print("✅ Google Generative AI library found")
    except ImportError:
        print("❌ google-generativeai library not found")
        print("Please install it: pip install google-generativeai")
        return False
    
    print("✅ Environment check passed")
    return True


def check_input_files():
    """Check if required input files exist."""
    print("📁 Checking input files...")
    
    base_dir = Path(__file__).parent.parent
    
    required_files = [
        "intermediate_files/full_prompt.txt",
        "selected_cases.txt",
        "statutes.txt"
    ]
    
    missing_files = []
    for file_path in required_files:
        full_path = base_dir / file_path
        if not full_path.exists():
            missing_files.append(file_path)
        else:
            print(f"✅ Found: {file_path}")
    
    if missing_files:
        print(f"❌ Missing files: {missing_files}")
        return False
    
    print("✅ All input files found")
    return True


def print_banner():
    """Print the pipeline banner."""
    print("=" * 70)
    print("🚀 METHOD 2 GEMINI 2.5 PRO PIPELINE")
    print("   Automated Prolog Generation and Testing")
    print("=" * 70)
    print(f"Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()


def print_summary(generation_results, analysis_results):
    """Print final summary of the pipeline execution."""
    print("\n" + "=" * 70)
    print("🎯 PIPELINE EXECUTION SUMMARY")
    print("=" * 70)
    
    if generation_results:
        print(f"📝 Generation Phase:")
        print(f"   Total files generated: {generation_results.get('total_files', 'N/A')}")
        print(f"   Files passing smoke tests: {generation_results.get('successful_files', 'N/A')}")
        print(f"   Smoke test success rate: {generation_results.get('success_rate', 0):.1f}%")
    else:
        print("❌ Generation phase failed")
    
    if analysis_results and not analysis_results.get("error"):
        results = analysis_results.get('results', [])
        total_cases = len(results)
        passed_cases = len([r for r in results if r.get('success', False)])
        success_rate = (passed_cases / total_cases * 100) if total_cases > 0 else 0
        
        print(f"\n🧪 Accuracy Testing Phase:")
        print(f"   Total test cases: {total_cases}")
        print(f"   Passed test cases: {passed_cases}")
        print(f"   Test success rate: {success_rate:.1f}%")
        print(f"   Testing approach: Method 2 Codebase (tests.pl)")
    else:
        print("\n❌ Accuracy testing phase failed or incomplete")
    
    print(f"\nEnd time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)


def main():
    """Main entry point for the master runner."""
    print_banner()
    
    # Step 1: Environment checks
    if not check_environment():
        print("❌ Environment check failed. Please fix the issues above.")
        sys.exit(1)
    
    if not check_input_files():
        print("❌ Input file check failed. Please ensure all required files exist.")
        sys.exit(1)
    
    print("✅ All pre-flight checks passed. Starting pipeline...\n")
    
    generation_results = None
    analysis_results = None
    
    try:
        # Step 2: Run the generation pipeline
        print("🚀 Phase 1: Prolog Code Generation")
        print("-" * 50)
        
        controller = PipelineController()
        generation_results = controller.run()
        
        if not generation_results:
            print("❌ Generation phase failed. Aborting pipeline.")
            sys.exit(1)
        
        print(f"✅ Generation phase completed with {generation_results['success_rate']:.1f}% success rate")
        
        # Step 3: Run the accuracy analysis
        print("\n🧪 Phase 2: Accuracy Testing and Analysis")
        print("-" * 50)
        
        accuracy_runner = Method2CodebaseAccuracyRunner()
        analysis_results = accuracy_runner.run_accuracy_test()
        
        if analysis_results.get("error"):
            print(f"⚠️ Analysis completed with issues: {analysis_results['error']}")
        else:
            print(f"✅ Analysis completed successfully")
            # Print key metrics
            results = analysis_results.get('results', [])
            total_cases = len(results)
            passed_cases = len([r for r in results if r.get('success', False)])
            success_rate = (passed_cases / total_cases * 100) if total_cases > 0 else 0
            print(f"📊 Accuracy Results: {passed_cases}/{total_cases} cases passed ({success_rate:.1f}%)")
        
        # Step 4: Final summary
        print_summary(generation_results, analysis_results)
        
        # Determine overall success
        generation_success = generation_results and generation_results.get('success_rate', 0) > 0
        analysis_success = analysis_results and not analysis_results.get("error")
        
        if generation_success and analysis_success:
            print("🎉 Pipeline completed successfully!")
            sys.exit(0)
        elif generation_success:
            print("⚠️ Pipeline completed with testing issues.")
            sys.exit(0)
        else:
            print("❌ Pipeline completed with generation issues.")
            sys.exit(1)
    
    except KeyboardInterrupt:
        print("\n⏹️ Pipeline interrupted by user")
        print_summary(generation_results, analysis_results)
        sys.exit(1)
    
    except Exception as e:
        print(f"\n❌ Pipeline failed with unexpected error: {e}")
        import traceback
        traceback.print_exc()
        print_summary(generation_results, analysis_results)
        sys.exit(1)


if __name__ == "__main__":
    main() 