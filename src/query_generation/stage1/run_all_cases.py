#!/usr/bin/env python3
"""
Run Stage 1 on all 368 case files
"""

import os
import sys
from datetime import datetime

# Add current directory to path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from llm.gemini_client import GeminiClient
from core.query_generator import Stage1QueryGenerator

def main():
    # Load environment variables
    sara_path = '/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts'
    env_path = os.path.join(sara_path, 'src', '.env')
    
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value
        print(f"Loaded environment from: {env_path}")
    
    # Initialize components
    print("Initializing Gemini client...")
    try:
        llm_client = GeminiClient()
        print("✓ Gemini client initialized successfully")
    except Exception as e:
        print(f"Error initializing Gemini client: {e}")
        sys.exit(1)
    
    # Initialize query generator
    generator = Stage1QueryGenerator(sara_path, llm_client)
    
    # Create timestamped results directory
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_dir = f"all_cases_results_{timestamp}"
    generator.results_dir = results_dir
    os.makedirs(results_dir, exist_ok=True)
    
    print(f"Results will be saved to: {results_dir}")
    print(f"Processing all 368 cases...")
    
    # Run all cases
    results = generator.run_all_prolog_cases()
    
    print(f"\n🎉 Completed processing all cases!")
    print(f"📁 Results saved in: {results_dir}")

if __name__ == "__main__":
    main()