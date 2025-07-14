#!/usr/bin/env python3
"""
Gemini API Interface for Method 2 Pipeline
Handles LLM interactions for Prolog code generation.
"""

import os
import sys
import time
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional, Tuple

import google.generativeai as genai


class GeminiGenerator:
    def __init__(self, model_name: str = "gemini-2.5-pro"):
        """
        Initialize the Gemini API client.
        
        Args:
            model_name: The Gemini model to use
        """
        self.model_name = model_name
        
        # Initialize Gemini API
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel(model_name)
        
        # Initialize conversation tracking
        self.conversation_history = []
        self.response_count = 0
        
        # Setup directories
        self.base_dir = Path(__file__).parent.parent
        self.intermediate_dir = self.base_dir / "intermediate_files"
        self.prolog_dir = self.base_dir / "prolog_codebase"
        self.results_dir = self.base_dir / "results"
        
        # Create directories if they don't exist
        for dir_path in [self.intermediate_dir, self.prolog_dir, self.results_dir]:
            dir_path.mkdir(exist_ok=True)
    
    def load_initial_prompt(self) -> str:
        """Load the initial prompt from method_3."""
        prompt_file = self.intermediate_dir / "full_prompt.txt"
        
        if not prompt_file.exists():
            raise FileNotFoundError(f"Prompt file not found: {prompt_file}")
        
        with open(prompt_file, 'r', encoding='utf-8') as f:
            prompt_content = f.read()
        
        print(f"Loaded initial prompt: {len(prompt_content)} characters")
        return prompt_content
    
    def send_message(self, message: str, is_initial: bool = False) -> str:
        """
        Send a message to Gemini and get response.
        
        Args:
            message: The message to send
            is_initial: Whether this is the initial prompt
            
        Returns:
            The model's response text
        """
        try:
            # Create chat session with history
            chat = self.model.start_chat(history=self.conversation_history)
            
            # Send message
            print(f"\n--- Sending message to {self.model_name} ---")
            print(f"Message length: {len(message)} characters")
            if not is_initial:
                print(f"Message preview: {message[:100]}...")
            
            response = chat.send_message(message)
            response_text = response.text
            
            # Update conversation history
            self.conversation_history.append({"role": "user", "parts": [message]})
            self.conversation_history.append({"role": "model", "parts": [response_text]})
            
            # Increment response counter and save response
            self.response_count += 1
            self._save_response(message, response_text, is_initial)
            
            print(f"Response received: {len(response_text)} characters")
            
            return response_text
            
        except Exception as e:
            print(f"Error calling Gemini API: {e}")
            raise
    
    def _save_response(self, user_message: str, response_text: str, is_initial: bool):
        """Save the conversation turn to files."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Save raw response
        response_file = self.intermediate_dir / f"gemini_response_{self.response_count:03d}_{timestamp}.txt"
        with open(response_file, 'w', encoding='utf-8') as f:
            f.write("=== USER MESSAGE ===\n")
            f.write(user_message)
            f.write("\n\n=== GEMINI RESPONSE ===\n")
            f.write(response_text)
        
        # Save conversation log
        log_file = self.intermediate_dir / "conversation_log.json"
        log_entry = {
            "response_number": self.response_count,
            "timestamp": timestamp,
            "is_initial": is_initial,
            "user_message_length": len(user_message),
            "response_length": len(response_text),
            "response_file": str(response_file.name)
        }
        
        # Append to log file
        if log_file.exists():
            with open(log_file, 'r', encoding='utf-8') as f:
                log_data = json.load(f)
        else:
            log_data = {"conversation_log": []}
        
        log_data["conversation_log"].append(log_entry)
        
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, indent=2)
        
        print(f"Response saved: {response_file.name}")
    
    def generate_initial_response(self) -> str:
        """Generate the initial response using the full prompt."""
        print("Starting initial Prolog code generation...")
        
        # Load the initial prompt
        initial_prompt = self.load_initial_prompt()
        
        # Send to Gemini
        response = self.send_message(initial_prompt, is_initial=True)
        
        return response
    
    def request_continuation(self) -> str:
        """Request the LLM to continue generation."""
        continuation_prompt = "yes, continue the generation please."
        
        print("Requesting continuation...")
        response = self.send_message(continuation_prompt)
        
        return response
    
    def request_regeneration(self, error_message: str, failed_file: str) -> str:
        """
        Request regeneration of a failed file.
        
        Args:
            error_message: The error that occurred
            failed_file: The file that failed
            
        Returns:
            New response from Gemini
        """
        regen_prompt = f"""The file `{failed_file}` failed the smoke test with the following error:

{error_message}

Please regenerate this file with correct Prolog syntax."""
        
        print(f"Requesting regeneration for {failed_file}...")
        response = self.send_message(regen_prompt)
        
        return response
    
    def get_conversation_summary(self) -> Dict:
        """Get a summary of the conversation so far."""
        return {
            "total_responses": self.response_count,
            "conversation_turns": len(self.conversation_history) // 2,
            "model_used": self.model_name,
            "start_time": datetime.now().isoformat()
        }


def main():
    """Test the Gemini generator."""
    try:
        generator = GeminiGenerator()
        
        # Test initial generation
        response = generator.generate_initial_response()
        print(f"\nInitial response length: {len(response)}")
        print(f"First 200 characters: {response[:200]}...")
        
        # Show summary
        summary = generator.get_conversation_summary()
        print(f"\nConversation summary: {summary}")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main() 