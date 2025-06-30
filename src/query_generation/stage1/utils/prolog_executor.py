
import os
import subprocess
import tempfile
from typing import Tuple, Optional
import logging

logger = logging.getLogger(__name__)

class PrologExecutor:
    def __init__(self, sara_base_path: str, swipl_command: str = "swipl", timeout: int = 10):
        self.sara_base_path = sara_base_path
        self.swipl_command = swipl_command
        self.timeout = timeout
        self.sara_data_path = os.path.join(sara_base_path, "data", "sara_v3")
        
    def execute_query(self, case_id: str, query_code: str, 
                     temp_dir: Optional[str] = None) -> Tuple[bool, str, Optional[str]]:
        """
        Execute a Prolog query for a specific case.
        
        Returns:
            Tuple of (success, result, error_message)
        """
        # Use temporary directory if not provided
        if temp_dir is None:
            temp_dir = tempfile.gettempdir()
            
        test_file = os.path.join(temp_dir, f"test_{case_id}.pl")
        
        try:
            # Create test file with proper initialization
            with open(test_file, 'w') as f:
                # Set working directory to SARA data path
                f.write(f":- working_directory(_, '{self.sara_data_path}').\n")
                
                # Load init file which loads all statutes
                f.write(":- consult('statutes/prolog/init.pl').\n")
                
                # Load the specific case file
                f.write(f":- consult('cases/{case_id}.pl').\n\n")
                
                # Add the query code
                f.write(query_code + "\n\n")
                
                # Add test predicate to run the query and output result
                f.write(f"test :- answer('{case_id}', Result), write(Result), nl, halt(0).\n")
                f.write(":- initialization(test).\n")
            
            # Run SWI-Prolog
            result = subprocess.run(
                [self.swipl_command, '-g', 'true', '-t', 'halt(1)', test_file],
                capture_output=True,
                text=True,
                timeout=self.timeout
            )
            
            if result.returncode == 0:
                output = result.stdout.strip()
                logger.info(f"Successfully executed query for {case_id}: {output}")
                return True, output, None
            else:
                error_msg = result.stderr or "Unknown error"
                logger.error(f"Failed to execute query for {case_id}: {error_msg}")
                return False, "", error_msg
                
        except subprocess.TimeoutExpired:
            logger.error(f"Timeout executing query for {case_id}")
            return False, "", "Query execution timeout"
        except Exception as e:
            logger.error(f"Exception executing query for {case_id}: {str(e)}")
            return False, "", str(e)
        finally:
            # Clean up temporary file
            if os.path.exists(test_file):
                try:
                    os.remove(test_file)
                except:
                    pass
    
    def validate_prolog_syntax(self, code: str) -> Tuple[bool, Optional[str]]:
        """
        Validate Prolog syntax without executing.
        
        Returns:
            Tuple of (is_valid, error_message)
        """
        temp_file = tempfile.NamedTemporaryFile(mode='w', suffix='.pl', delete=False)
        try:
            temp_file.write(code)
            temp_file.close()
            
            result = subprocess.run(
                [self.swipl_command, '-g', 'halt', '-t', 'halt', '-q', temp_file.name],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0:
                return True, None
            else:
                return False, result.stderr
                
        except Exception as e:
            return False, str(e)
        finally:
            if os.path.exists(temp_file.name):
                os.remove(temp_file.name)