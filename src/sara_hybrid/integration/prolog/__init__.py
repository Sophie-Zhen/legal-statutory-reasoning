"""
Integration module for Prolog-based testing of the SARA dataset.
This module provides functionality to test statutory reasoning using Prolog.
"""

from .test_sara import clean_prolog_code, run_prolog_query

__all__ = ['clean_prolog_code', 'run_prolog_query'] 