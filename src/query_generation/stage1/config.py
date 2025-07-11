"""
Stage 1 Configuration Settings
File: src/query_generation/stage1/config.py
"""

import os

# Base paths
PROJECT_ROOT = "/Users/sawpu/Desktop/PrologLLM/2025-mcm-llms-applied-in-law-contexts"
SARA_DATA_PATH = os.path.join(PROJECT_ROOT, "data", "sara_v3")
STAGE1_PATH = os.path.join(PROJECT_ROOT, "src", "query_generation", "stage1")

# SARA dataset paths
CASES_DIR = os.path.join(SARA_DATA_PATH, "cases")
STATUTES_DIR = os.path.join(SARA_DATA_PATH, "statutes", "prolog")
SPLITS_DIR = os.path.join(SARA_DATA_PATH, "splits")
TEST_SPLIT_FILE = os.path.join(SPLITS_DIR, "test")
SARA_PARALLEL_FILE = os.path.join(PROJECT_ROOT, "data", "sara_parallel.jsonl")

# Results paths
RESULTS_BASE_DIR = os.path.join(STAGE1_PATH, "stage1_results")

# Prolog settings
SWIPL_COMMAND = "swipl"
PROLOG_TIMEOUT = 10  # seconds

# LLM settings
DEFAULT_MODEL = "gemini-1.5-flash"
MAX_RETRIES = 3
RETRY_DELAY = 1  # seconds

# Prompts directory
PROMPTS_DIR = os.path.join(STAGE1_PATH, "prompts")