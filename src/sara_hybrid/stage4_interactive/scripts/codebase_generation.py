import json
import re
import subprocess
import os
import sys
from typing import List, Dict, Optional, Tuple
import google.generativeai as genai

class LLMClient:
    def __init__(self, model_name: str = "gemini-2.5-pro"):
        """
        Initialize the LLM client.
        
        Args:
            model_name: The model to use for generation
        """
        self.model_name = model_name
        
        # Initialize Gemini API
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel(model_name)
    
    def send_message(self, user_prompt: str, conversation_history: List[Dict], system_prompt: str) -> str:
        """
        Send a message to the LLM and get response.
        
        Args:
            user_prompt: The user's message
            conversation_history: List of previous conversation turns
            system_prompt: The system prompt/instructions
            
        Returns:
            The model's response text
        """
        try:
            # Convert conversation history to Gemini format
            chat_history = []
            for turn in conversation_history:
                if turn["role"] == "user":
                    chat_history.append({"role": "user", "parts": [turn["content"]]})
                elif turn["role"] == "model":
                    chat_history.append({"role": "model", "parts": [turn["content"]]})
            
            # Create chat session
            chat = self.model.start_chat(history=chat_history)
            
            # Combine system prompt and user prompt
            full_prompt = f"{system_prompt}\n\n{user_prompt}"
            
            # Send message
            response = chat.send_message(full_prompt)
            
            # Extract text from response
            response_text = response.text
            
            print(f"Sent message to {self.model_name}")
            print(f"System prompt length: {len(system_prompt)} chars")
            print(f"User prompt: {user_prompt[:100]}...")
            print(f"History length: {len(conversation_history)} turns")
            print(f"Response length: {len(response_text)} chars")
            
            return response_text
            
        except Exception as e:
            print(f"Error calling Gemini API: {e}")
            raise

class CodebaseGenerator:
    def __init__(self, output_dir: str = "../prolog_codebase"):
        """
        Initialize the codebase generator.
        
        Args:
            output_dir: Directory to save generated Prolog files
        """
        # Convert to absolute path to avoid working directory issues
        self.output_dir = os.path.abspath(output_dir)
        self.llm = LLMClient()
        self.conversation_history = []
        
        # Load the entire prompt plan into memory
        self.system_prompt, self.prompt_plan = self._load_and_parse_prompts()
        
        self.current_step = 1
        self.total_steps = len(self.prompt_plan)
        self.generated_files = []
        
        # Create output directory and response logging subdirectory
        os.makedirs(self.output_dir, exist_ok=True)
        self.responses_dir = "intermediate_texts/llm_responses"
        os.makedirs(self.responses_dir, exist_ok=True)
        
        # Initialize response counter
        self.response_counter = 0
        
    def _load_and_parse_prompts(self) -> Tuple[str, Dict[int, str]]:
        """Parses the prompt file into a system prompt and a dictionary of step-by-step user prompts."""
        prompt_file = "intermediate_texts/interactive_prompting.txt"
        try:
            with open(prompt_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except FileNotFoundError:
            raise FileNotFoundError(f"Prompt file not found: {prompt_file}. Please ensure the file exists.")

        # Strip BOM if present
        if content.startswith('\ufeff'):
            print("Stripping BOM from prompt file.")
            content = content[1:]

        # Debug: print first 200 chars
        print("First 200 chars of prompt file:", repr(content[:200]))

        # Extract System Prompt
        sys_match = re.search(r'%% SYSTEM_PROMPT_BEGIN %%\s*([\s\S]*?)\s*%% SYSTEM_PROMPT_END %%', content, re.DOTALL | re.MULTILINE)
        if not sys_match:
            # Fallback to old format
            if "SYSTEM PROMPT:" in content:
                system_start = content.find("SYSTEM PROMPT:")
                user_start = content.find("USER PROMPT 1:")
                if user_start == -1:
                    raise RuntimeError(f"USER PROMPT 1: not found in {prompt_file}. Please ensure the file contains both SYSTEM PROMPT: and USER PROMPT 1: sections.")
                system_prompt = content[system_start:user_start].strip()
            else:
                raise RuntimeError(f"SYSTEM PROMPT: not found in {prompt_file}. Please ensure the file contains a SYSTEM PROMPT: section.")
        else:
            system_prompt = sys_match.group(1).strip()

        # Extract User Prompts
        prompt_plan = {}
        user_matches = re.findall(r'%% USER_PROMPT_(\d+)_BEGIN %%\s*([\s\S]*?)\s*%% USER_PROMPT_\1_END %%', content, re.DOTALL | re.MULTILINE)
        for num_str, prompt_text in user_matches:
            prompt_plan[int(num_str)] = prompt_text.strip()

        # Debug: print loaded prompt keys
        print("Loaded user prompts:", sorted(prompt_plan.keys()))

        if not prompt_plan:
            raise ValueError("Could not find any user prompt blocks in prompt file.")
        return system_prompt, prompt_plan
    
    def _get_next_user_prompt(self) -> Optional[str]:
        """Gets the user prompt for the current step."""
        return self.prompt_plan.get(self.current_step)
    
    def _extract_prolog_files(self, response_text: str) -> List[Tuple[str, str]]:
        """
        Extract Prolog files from the response text.
        
        Args:
            response_text: The model's response containing Prolog code
            
        Returns:
            List of tuples (filename, content)
        """
        files = []
        
        # Improved regex for file markers
        file_pattern = r'%% BEGIN_FILE: (.*?)\n(.*?)%% END_FILE: \1'
        matches = re.findall(file_pattern, response_text, re.DOTALL)
        
        for filename, content in matches:
            files.append((filename.strip(), content.strip()))
        
        return files
    
    def _run_smoke_test(self, filename: str) -> Tuple[bool, str]:
        """
        Runs a simple smoke test on a generated Prolog file.
        The test succeeds if SWI-Prolog can load the file without syntax errors.
        Args:
            filename: Name of the file to test (relative to output_dir)
        Returns:
            Tuple of (passed, error_message)
        """
        filepath = os.path.join(self.output_dir, filename)
        
        # Check if file actually exists before testing
        if not os.path.exists(filepath):
            return False, f"File does not exist: {filepath}"
        
        command = [
            'swipl',
            '-q',
            '-g', f"load_files('{filepath}', [silent(true)])",
            '-g', 'halt'
        ]
        try:
            print(f"  Running smoke test: {' '.join(command)}")
            print(f"  File path: {filepath}")
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=self.output_dir  # Set working directory to output_dir
            )
            if result.returncode == 0 and not "ERROR:" in result.stderr:
                return True, ""
            else:
                error_output = result.stdout + "\n" + result.stderr
                return False, error_output.strip()
        except Exception as e:
            return False, f"Subprocess execution failed: {str(e)}"
    
    def _should_step_produce_files(self, step: int) -> bool:
        """
        Determine if a step should produce Prolog files based on prompt content analysis.
        
        Args:
            step: Current step number
            
        Returns:
            True if the step should produce files, False otherwise
        """
        prompt = self.prompt_plan.get(step, "")
        
        # Steps that should NOT produce files (JSON responses)
        json_steps = [1, 15]  # JSON mapping and final manifest
        
        # If it's a known JSON step, it doesn't produce files
        if step in json_steps:
            return False
        
        # Check if the prompt mentions generating files
        file_indicators = [
            "generate", "create", "produce", "write", "output",
            ".pl", "prolog", "file", "module", "knowledge_base", 
            "helpers", "section", "tests.pl", "facts", "predicates"
        ]
        
        prompt_lower = prompt.lower()
        has_file_indicators = any(indicator in prompt_lower for indicator in file_indicators)
        
        return has_file_indicators
    
    def _validate_non_file_response(self, response_text: str, step: int) -> bool:
        """
        Validate responses for steps that don't produce Prolog files.
        
        Args:
            response_text: The model's response
            step: Current step number
            
        Returns:
            True if response is valid, False otherwise
        """
        if step == 1:
            # Step 1 should produce JSON mapping
            return self._validate_json_mapping(response_text)
        elif step == 15:
            # Step 15 should produce final JSON manifest
            return self._validate_json_manifest(response_text)
        else:
            # For other non-file steps, just check if response is not empty
            return len(response_text.strip()) > 0
    
    def _validate_json_mapping(self, response_text: str) -> bool:
        """
        Validate that the response contains valid JSON mapping.
        This is more robust and handles markdown code blocks.
        """
        # First, try to find a markdown JSON block
        match = re.search(r'```json\n(.*?)\n```', response_text, re.DOTALL)
        if match:
            json_str = match.group(1)
        else:
            # If no markdown, fall back to finding the first '[' and last ']'
            json_start = response_text.find('[')
            json_end = response_text.rfind(']')
            if json_start == -1 or json_end == -1:
                return False
            json_str = response_text[json_start:json_end + 1]

        try:
            # Try to load the extracted string as JSON
            json_data = json.loads(json_str)
            # Optional: Add a check to ensure it's a list of objects
            if isinstance(json_data, list) and all(isinstance(item, dict) for item in json_data):
                # Save the valid JSON for later use!
                os.makedirs(self.output_dir, exist_ok=True)
                with open(os.path.join(self.output_dir, "statute_case_mapping.json"), 'w') as f:
                    json.dump(json_data, f, indent=2)
                print("Successfully validated and saved JSON mapping.")
                return True
            return False
        except json.JSONDecodeError:
            print("JSONDecodeError: Could not parse the extracted text as JSON.")
            return False
    
    def _validate_json_manifest(self, response_text: str) -> bool:
        """
        Validate that the response contains valid JSON manifest.
        
        Args:
            response_text: The model's response
            
        Returns:
            True if valid JSON manifest found, False otherwise
        """
        # Look for JSON object in the response
        json_start = response_text.find('{')
        json_end = response_text.rfind('}')
        
        if json_start == -1 or json_end == -1:
            return False
        
        try:
            json_str = response_text[json_start:json_end + 1]
            manifest = json.loads(json_str)
            # Check if it has the expected structure
            return "modules" in manifest and "test_suite" in manifest
        except json.JSONDecodeError:
            return False
    
    def _check_completion_marker(self, response_text: str) -> bool:
        """Check if the response contains the completion marker."""
        return "<<ALL DONE>>" in response_text
    
    def _save_llm_response(self, step: int, user_prompt: str, response_text: str, passed: bool, error_message: str = "", failed_file: str = "") -> None:
        """
        Save LLM response with detailed metadata for debugging.
        
        Args:
            step: Current step number
            user_prompt: The prompt sent to the LLM
            response_text: The LLM's response
            passed: Whether validation passed
            error_message: Error message if validation failed
            failed_file: Name of failed file if applicable
        """
        self.response_counter += 1
        
        # Create filename with step and attempt info
        status = "PASSED" if passed else "FAILED"
        filename = f"step_{step:02d}_attempt_{self.response_counter:02d}_{status.lower()}.txt"
        filepath = os.path.join(self.responses_dir, filename)
        
        # Create detailed response log
        log_content = f"""=== LLM RESPONSE LOG ===
Timestamp: {__import__('datetime').datetime.now().isoformat()}
Step: {step}/{self.total_steps}
Attempt: {self.response_counter}
Status: {status}

=== USER PROMPT ===
{user_prompt}

=== LLM RESPONSE ===
{response_text}

=== VALIDATION RESULTS ===
Passed: {passed}
Error Message: {error_message}
Failed File: {failed_file}

=== CONVERSATION HISTORY LENGTH ===
{len(self.conversation_history)} turns

=== SYSTEM PROMPT LENGTH ===
{len(self.system_prompt)} characters

=== RESPONSE STATISTICS ===
Response Length: {len(response_text)} characters
Prompt Length: {len(user_prompt)} characters
"""
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(log_content)
        
        print(f"Response saved: {filepath}")
        
        # Also save raw response for easy access
        raw_filename = f"step_{step:02d}_attempt_{self.response_counter:02d}_raw.txt"
        raw_filepath = os.path.join(self.responses_dir, raw_filename)
        with open(raw_filepath, 'w', encoding='utf-8') as f:
            f.write(response_text)
        
        print(f"Raw response saved: {raw_filepath}")

    def _save_generated_files(self, files: List[Tuple[str, str]]) -> None:
        """Save generated Prolog files to the output directory."""
        os.makedirs(self.output_dir, exist_ok=True)
        
        for filename, content in files:
            filepath = os.path.join(self.output_dir, filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.generated_files.append(filename)
            print(f"Saved: {filepath}")
    

    
    def _validate_response(self, response_text: str, step: int) -> Tuple[bool, str, str]:
        """
        Validate the response for the current step.
        
        Returns:
            Tuple of (passed, error_message, failed_file)
        """
        should_produce_files = self._should_step_produce_files(step)
        
        if should_produce_files:
            # Extract and validate Prolog files
            files = self._extract_prolog_files(response_text)
            if not files:
                return False, "No Prolog files extracted from response", ""
            
            # Each step should produce exactly one file
            if len(files) != 1:
                return False, f"Expected exactly 1 file, but got {len(files)} files", ""
            
            filename, content = files[0]
            print(f"Extracted file: {filename}")
            
            # Save the file so smoke test can access it
            filepath = os.path.join(self.output_dir, filename)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Saved file for testing: {filepath}")
            
            # Run smoke test on the saved file
            print(f"Running smoke test on {filename}...")
            passed, error = self._run_smoke_test(filename)
            
            if not passed:
                # Clean up failed file
                if os.path.exists(filepath):
                    os.remove(filepath)
                    print(f"Removed failed file: {filepath}")
                return False, error, filename
            else:
                # Test passed - add to generated files list
                self.generated_files.append(filename)
                print(f"Smoke test passed. File saved: {filename}")
                return True, "", ""
        else:
            # Validate non-file response
            print(f"Step {step} doesn't produce Prolog files - checking response validity...")
            passed = self._validate_non_file_response(response_text, step)
            error_message = "" if passed else "Invalid response format for this step"
            return passed, error_message, ""

    def run_generation_pipeline(self) -> None:
        """Run the complete codebase generation pipeline."""
        print("Starting Prolog codebase generation pipeline...")
        print(f"Output directory: {self.output_dir}")
        print(f"System prompt length: {len(self.system_prompt)} characters")
        print(f"Total steps planned: {self.total_steps}")

        user_prompt = self._get_next_user_prompt()
        if not user_prompt:
            print("Error: No prompt found for initial step 1 in the plan file.")
            return

        while self.current_step <= self.total_steps:
            print(f"\n--- Executing Step {self.current_step}/{self.total_steps} ---")
            response_text = self.llm.send_message(
                user_prompt,
                self.conversation_history,
                self.system_prompt
            )
            self.conversation_history.append({"role": "user", "content": user_prompt})
            self.conversation_history.append({"role": "model", "content": response_text})

            # Check for completion marker
            if self._check_completion_marker(response_text):
                print("\n🎉 Generation completed successfully!")
                print(f"Generated {len(self.generated_files)} files:")
                for filename in self.generated_files:
                    print(f"  - {filename}")
                break

            # Validate the response
            passed, error_message, failed_file = self._validate_response(response_text, self.current_step)

            # Save the response with detailed metadata
            self._save_llm_response(
                step=self.current_step,
                user_prompt=user_prompt,
                response_text=response_text,
                passed=passed,
                error_message=error_message,
                failed_file=failed_file
            )

            if passed:
                print(f"Step {self.current_step} PASSED.")
                self.current_step += 1  # Only increment on success
                user_prompt = self._get_next_user_prompt()
                if not user_prompt:
                    print("\n🎉 All planned steps completed successfully!")
                    break
            else:
                print(f"Step {self.current_step} FAILED.")
                user_prompt = (
                    f"The last attempt for the current task failed. The error was: `{error_message}`. "
                    f"Please try again to complete the task for Step {self.current_step}, "
                    "adhering strictly to all rules in the system prompt."
                )
                if failed_file:
                    user_prompt += f"\n\nThe file `{failed_file}` specifically failed validation."

        # Save conversation history
        os.makedirs(self.output_dir, exist_ok=True)
        history_file = os.path.join(self.output_dir, "conversation_history.json")
        with open(history_file, 'w', encoding='utf-8') as f:
            json.dump(self.conversation_history, f, indent=2)
        print(f"Conversation history saved to: {history_file}")

        # Save execution summary
        summary_file = "intermediate_texts/execution_summary.txt"
        with open(summary_file, 'w', encoding='utf-8') as f:
            f.write(f"""=== EXECUTION SUMMARY ===\nTimestamp: {__import__('datetime').datetime.now().isoformat()}\nTotal Steps: {self.total_steps}\nSteps Completed: {self.current_step - 1}\nTotal Responses: {self.response_counter}\nGenerated Files: {len(self.generated_files)}\n\n=== GENERATED FILES ===\n{chr(10).join(f"- {filename}" for filename in self.generated_files)}\n\n=== RESPONSE LOGS ===\nAll individual response logs saved in: {self.responses_dir}\n""")
        print(f"Execution summary saved to: {summary_file}")

def main():
    """Main function to run the codebase generation."""
    generator = CodebaseGenerator()
    generator.run_generation_pipeline()

if __name__ == "__main__":
    main() 