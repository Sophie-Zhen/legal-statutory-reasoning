"""
Utility functions for Prolog integration with SARA dataset.
Handles translation of cases to Prolog, query execution, and logging.
"""

import logging
import tempfile
import re
from pathlib import Path
import janus_swi as janus
from typing import Dict, List, Optional

# Project-wide constants
REPO_ROOT = Path(__file__).parents[4].resolve()
DATA_ROOT = REPO_ROOT / "data" / "sara_v3"
CASES_DIR = DATA_ROOT / "cases"
SPLITS_DIR = DATA_ROOT / "splits"
STATUTES_DIR = DATA_ROOT / "statutes" / "prolog"
INIT_PL = STATUTES_DIR / "init.pl"

# Initialize logging
logger = logging.getLogger(__name__)

def setup_logging(log_dir: Optional[Path] = None) -> None:
    """Configure logging for the module.
    
    Args:
        log_dir: Optional directory for log files. If None, uses REPO_ROOT/logs.
    """
    if logging.root.handlers:
        return  # Already configured
        
    if log_dir is None:
        log_dir = REPO_ROOT / "logs"
    log_dir.mkdir(exist_ok=True)
    
    # Create a rotating file handler
    from logging.handlers import TimedRotatingFileHandler
    log_file = log_dir / "sara_prolog.log"
    file_handler = TimedRotatingFileHandler(
        str(log_file),
        when='midnight',
        interval=1,
        backupCount=7
    )
    
    # Configure formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(formatter)
    
    # Also log to console
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)
    
    # Add handlers
    logger.addHandler(file_handler)
    logger.setLevel(logging.INFO)
    return log_file

def clean_prolog_code(facts: str) -> str:
    """Clean and prepare Prolog code for execution."""
    # 1. Discover all referenced statute sections in the facts
    section_nums = set(re.findall(r's(\d+)_', facts))
    
    # 2. Build import directives for each section file
    imports = []
    for num in sorted(section_nums):
        sec_file = STATUTES_DIR / f"section{num}.pl"
        if sec_file.exists():
            imports.append(f":- ['{sec_file}'].")
    
    # 3. Always include utils.pl and init.pl
    utils_file = STATUTES_DIR / "utils.pl"
    if utils_file.exists():
        imports.append(f":- ['{utils_file}'].")
    imports.append(f":- ['{INIT_PL}'].")
    
    # 4. Remove any in-fact init.pl directives
    cleaned_lines = [
        line for line in facts.splitlines()
        if not re.match(r'\s*:-\s*\[.*init\.pl.*\]', line)
    ]
    
    # 5. Combine imports + cleaned facts
    return '\n'.join(imports + cleaned_lines)

def normalize_result(result: Dict) -> bool:
    """Normalize Janus query result to a boolean.
    
    Args:
        result: Raw result from Janus query
        
    Returns:
        True if the query succeeded, False otherwise
    """
    if isinstance(result, bool):
        return result
    if isinstance(result, dict):
        return result.get('truth', False)
    return False

def run_prolog_query(facts: str, query: str, case_id: str = None, normalize: bool = False) -> bool:
    """Run a Prolog query with the given facts.
    
    Args:
        facts (str): Prolog facts
        query (str): Prolog query
        case_id (str, optional): Case ID for logging. Defaults to None.
        normalize (bool, optional): Whether to normalize result to boolean. Defaults to False.
    
    Returns:
        bool or dict: Query result, normalized to bool if normalize=True
    """
    try:
        # Include both facts and the query in section detection
        cleaned_facts = clean_prolog_code(facts + "\n" + query)
        if case_id:
            logger.info(f"[{case_id}] Prolog code:\n{cleaned_facts}")
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.pl', delete=False) as temp_file:
            temp_file.write(cleaned_facts)
            temp_file_path = temp_file.name
        
        try:
            # Load the temporary file
            janus.consult(temp_file_path)
            
            # Execute the query
            if case_id:
                logger.info(f"[{case_id}] Query:\n{query}")
            
            result = janus.query_once(query)
            
            if case_id:
                logger.info(f"[{case_id}] Query result: {result}")
                if normalize:
                    normalized = normalize_result(result)
                    logger.info(f"[{case_id}] Result: {'correct' if normalized else 'incorrect'}")
                    return normalized
            
            return normalize_result(result) if normalize else result
            
        finally:
            # Clean up
            Path(temp_file_path).unlink(missing_ok=True)
        
    except Exception as e:
        if case_id:
            logger.error(f"Error processing case {case_id}: {str(e)}")
        else:
            logger.error(f"Error running Prolog query: {str(e)}")
        return False if normalize else None

def translate_and_query(case: Dict[str, str]) -> bool:
    """Execute a Prolog query for a given case."""
    facts = case["facts"]
    raw_test = case["test"]

    # First try to extract from goal :- structure
    goal_match = re.match(r'^\s*goal\s*:-\s*(.*?)(?:\s*:-.*)?\.\s*$', raw_test.strip(), re.DOTALL)
    if goal_match:
        goal_body = goal_match.group(1)
    else:
        # Fallback: try to extract from :- structure
        m = re.match(r'^\s*:-\s*(.*?)(?:\s*:-.*)?\.\s*$', raw_test.strip(), re.DOTALL)
        if m:
            goal_body = m.group(1)
        else:
            # Last resort: just clean up the query
            goal_body = raw_test.strip().lstrip(":-").rstrip(".")

    # Collapse whitespace (including newlines) into single spaces
    goal = ' '.join(goal_body.split())

    # Run the goal via Prolog and normalize the result
    return run_prolog_query(facts, goal, case_id=case['id'], normalize=True)

# Initialize Prolog with init.pl
try:
    janus.consult(str(INIT_PL))
except Exception as e:
    logger.error(f"Failed to initialize Prolog with init.pl: {str(e)}")