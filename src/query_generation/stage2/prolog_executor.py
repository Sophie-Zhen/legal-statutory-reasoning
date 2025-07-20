#!/usr/bin/env python3
"""
prolog_executor.py - Execute Prolog queries and get results
"""

import subprocess
import tempfile
import os
from pathlib import Path
from typing import Dict, Tuple, Optional

class PrologExecutor:
    def __init__(self, statutes_dir: str):
        self.statutes_dir = Path(statutes_dir)
        
    def execute_query(self, case_data: Dict, generated_query: str, timeout: int = 10) -> Dict:
        """
        Execute a generated query with the case facts
        """
        # Create temporary Prolog file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.pl', delete=False) as f:
            # Write facts
            f.write(case_data['facts'])
            f.write('\n\n')
            
            # Write the generated query
            f.write(f"% Generated query for {case_data['case_id']}\n")
            f.write(generated_query)
            f.write('\n\n')
            
            # Write test execution
            f.write(f"test :- answer('{case_data['case_id']}', Result), ")
            f.write("write('RESULT: '), write(Result), nl, halt(0).\n")
            f.write(":- initialization(test).\n")
            
            temp_file = f.name
        
        try:
            # Execute with SWI-Prolog
            cmd = [
                'swipl',
                '-g', 'true',
                '-t', 'halt(1)',
                f'-s', temp_file
            ]
            
            # Add statute files to command
            for statute_file in ['init.pl', 'utils.pl', 'events.pl']:
                statute_path = self.statutes_dir / statute_file
                if statute_path.exists():
                    cmd.extend(['-s', str(statute_path)])
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=str(self.statutes_dir)
            )
            
            return {
                'success': result.returncode == 0,
                'output': result.stdout,
                'error': result.stderr,
                'result': self._extract_result(result.stdout)
            }
            
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'output': '',
                'error': 'Timeout',
                'result': None
            }
        finally:
            # Clean up
            if os.path.exists(temp_file):
                os.remove(temp_file)
    
    def _extract_result(self, output: str) -> Optional[str]:
        """Extract the result value from output"""
        if 'RESULT: ' in output:
            result_line = output.split('RESULT: ')[1].split('\n')[0]
            return result_line.strip()
        return None