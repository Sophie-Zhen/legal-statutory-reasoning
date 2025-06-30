#!/usr/bin/env python3
"""
Check what methods CaseParser actually has
File: check_case_parser.py
"""

import inspect
from core.case_parser import CaseParser

print("CaseParser methods:")
for name, method in inspect.getmembers(CaseParser, predicate=inspect.ismethod):
    print(f"  {name}")

print("\nCaseParser attributes and methods (including inherited):")
for attr in dir(CaseParser):
    if not attr.startswith('_'):
        print(f"  {attr}")

# Try to instantiate and check
try:
    parser = CaseParser("/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts")
    print("\nInstance methods:")
    for attr in dir(parser):
        if not attr.startswith('_') and callable(getattr(parser, attr)):
            print(f"  {attr}")
except Exception as e:
    print(f"\nError creating instance: {e}")