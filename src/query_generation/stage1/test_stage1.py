#!/usr/bin/env python3
"""
Simple test script to verify Stage 1 setup
File: test_stage1.py
"""
import os
import sys
# Add current directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
# Test imports
try:
    from llm.gemini_client import GeminiClient
    print("✓ GeminiClient imported successfully")
except ImportError as e:
    print(f"✗ Failed to import GeminiClient: {e}")
    sys.exit(1)
try:
    from core.case_parser import CaseParser
    print("✓ CaseParser imported successfully")
except ImportError as e:
    print(f"✗ Failed to import CaseParser: {e}")
    sys.exit(1)
try:
    from core.query_generator import Stage1QueryGenerator
    print("✓ Stage1QueryGenerator imported successfully")
except ImportError as e:
    print(f"✗ Failed to import Stage1QueryGenerator: {e}")
    sys.exit(1)
# Test initialization
sara_path = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
print("\nTesting CaseParser...")
parser = CaseParser(sara_path)
test_cases = parser.load_test_cases()
print(f"Found {len(test_cases)} test cases")
print(f"First 5 test cases: {test_cases[:5]}")
print("\nTesting GeminiClient...")
try:
    # Load .env file manually
    env_path = os.path.join(sara_path, 'src', '.env')
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                if line.strip() and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value
        print(f"Loaded environment from: {env_path}")
    
    # Initialize Gemini client
    client = GeminiClient()
    print("✓ GeminiClient initialized successfully")
    
    # Test with a simple prompt
    response = client.generate("Say 'Hello from Gemini' and nothing else.")
    print(f"Gemini response: {response}")
    
except Exception as e:
    print(f"✗ Error with GeminiClient: {e}")
    print("Make sure your .env file contains GEMINI_API_KEY")
print("\nSetup test complete!")