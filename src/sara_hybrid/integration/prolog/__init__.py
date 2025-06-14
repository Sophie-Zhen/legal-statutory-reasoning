"""SARA Prolog integration package.

This package provides utilities for integrating Python with Prolog for the SARA project.
It includes functions for loading and executing Prolog queries, managing statute files,
and running test cases.
"""

from .prolog_utils import (
    setup_logging,
    translate_and_query,
    REPO_ROOT,
    DATA_ROOT,
    CASES_DIR,
    SPLITS_DIR,
    STATUTES_DIR,
    INIT_PL
)

__all__ = [
    'setup_logging',
    'translate_and_query',
    'REPO_ROOT',
    'DATA_ROOT',
    'CASES_DIR',
    'SPLITS_DIR',
    'STATUTES_DIR',
    'INIT_PL'
] 