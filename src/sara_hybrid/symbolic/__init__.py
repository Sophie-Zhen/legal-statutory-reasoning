# src/sara_hybrid/symbolic/__init__.py
"""
Symbolic layer façade.

We expose the `exec_rules` function so that higher-level code (`hybrid.router`)
can import it directly from the package.
"""
from .executor import exec_rules  # noqa: F401

__all__ = ["exec_rules"]