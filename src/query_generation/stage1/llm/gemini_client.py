"""
A robust Gemini API client that gracefully handles safety blocks and
other API response issues without crashing.
"""

import os
import sys
from dotenv import load_dotenv, find_dotenv
import google.generativeai as genai

# Load .env file from the project root or current directory
load_dotenv(find_dotenv())

class GeminiClient:
    def __init__(self, model: str = "gemini-1.5-pro-latest"):
        """Initializes the Gemini client."""
        key = os.getenv("GEMINI_API_KEY")
        if not key:
            raise RuntimeError("GEMINI_API_KEY not found in environment. Please set it in a .env file.")
        
        genai.configure(api_key=key)
        
        # Use the modern GenerativeModel interface
        self.model = genai.GenerativeModel(model_name=model)

    def generate(
        self,
        prompt: str,
        *,
        temperature: float = 0.2,
        max_tokens: int = 8192,
    ) -> str:
        """
        Sends a prompt to the Gemini API and returns the response text.
        Handles API errors and blocked responses gracefully.
        """
        generation_config = genai.types.GenerationConfig(
            temperature=temperature,
            max_output_tokens=max_tokens,
        )
        
        try:
            resp = self.model.generate_content(
                contents=prompt,
                generation_config=generation_config
            )

            # --- ROBUST RESPONSE HANDLING ---
            # 1. Check for valid candidates and finish reason before accessing text
            if not resp.candidates:
                print("⚠️  Gemini Warning: Response received without candidates.", file=sys.stderr)
                return ""
            
            # If the model stopped for any reason other than "STOP", it was likely blocked.
            if resp.candidates[0].finish_reason.name != "STOP":
                reason = resp.candidates[0].finish_reason.name
                print(f"⚠️  Gemini Warning: Generation stopped. Reason: {reason}", file=sys.stderr)
                # You may want to inspect resp.prompt_feedback here as well
                return f"ERROR: Generation failed due to {reason}"

            # 2. Safely access the text content
            # The 'text' attribute is a convenient shortcut.
            if hasattr(resp, 'text'):
                return resp.text.strip()

        except Exception as e:
            # Catch other potential API errors (e.g., invalid key, billing issues)
            print(f"💥 Gemini API Error: {e}", file=sys.stderr)
            return f"ERROR: An API exception occurred: {e}"

        return "" # Default fallback

# Example of how to use this client
def main():
    """A simple test function to verify client functionality."""
    print("--- Running a simple test for GeminiClient ---")
    try:
        client = GeminiClient()
        test_prompt = "Hello, world! In one sentence, what is Prolog?"
        response = client.generate(test_prompt)
        
        if response:
            print(f"Test prompt: {test_prompt}")
            print(f"Gemini response: {response}")
        else:
            print("Test failed: No response or an error occurred.")
            
    except RuntimeError as e:
        print(f"Failed to initialize client: {e}", file=sys.stderr)

if __name__ == '__main__':
    main()
