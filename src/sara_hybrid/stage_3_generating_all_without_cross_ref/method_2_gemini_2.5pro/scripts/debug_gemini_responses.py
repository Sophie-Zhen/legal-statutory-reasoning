#!/usr/bin/env python3
"""
Debug Utility for Gemini Response Analysis
Helps identify why gemini-2.5-pro responses are being blocked
"""

import os
import sys
import logging
from pathlib import Path
import google.generativeai as genai
from typing import Dict, Any, Optional

# Add current directory to path for imports
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

from model_config import ModelConfigManager
from dynamic_prompt_generator import get_fact_extraction_prompt, get_query_generation_prompt

logger = logging.getLogger(__name__)

class GeminiResponseDebugger:
    """Debug utility for analyzing Gemini API responses and blocking reasons"""
    
    def __init__(self, model_name: str = "gemini-2.5-pro"):
        self.model_name = model_name
        self.manager = ModelConfigManager()
        self.model = self.manager.create_model_instance(model_name)
        self.generation_config = self.manager.get_generation_config(model_name)
        
    def analyze_response(self, response, prompt_description: str = ""):
        """Analyze a Gemini response object for blocking reasons"""
        print(f"\n{'='*60}")
        print(f"RESPONSE ANALYSIS: {prompt_description}")
        print(f"{'='*60}")
        
        # Basic response info
        print(f"Model: {self.model_name}")
        print(f"Response object type: {type(response)}")
        
        # Check if response has text
        try:
            text = response.text
            print(f"Response text length: {len(text) if text else 0}")
            if text:
                print(f"Response preview: {text[:100]}...")
        except Exception as e:
            print(f"❌ Error accessing response.text: {e}")
        
        # Check prompt feedback
        print(f"\n--- PROMPT FEEDBACK ---")
        if hasattr(response, 'prompt_feedback'):
            feedback = response.prompt_feedback
            print(f"Block reason: {feedback.block_reason if feedback.block_reason else 'None'}")
            if hasattr(feedback, 'safety_ratings') and feedback.safety_ratings:
                print("Prompt safety ratings:")
                for rating in feedback.safety_ratings:
                    print(f"  {rating.category.name}: {rating.probability.name}")
        else:
            print("No prompt feedback available")
        
        # Check candidates
        print(f"\n--- CANDIDATES ---")
        if hasattr(response, 'candidates') and response.candidates:
            for i, candidate in enumerate(response.candidates):
                print(f"Candidate {i}:")
                print(f"  Finish reason: {candidate.finish_reason.name if candidate.finish_reason else 'None'}")
                
                if hasattr(candidate, 'safety_ratings') and candidate.safety_ratings:
                    print("  Safety ratings:")
                    for rating in candidate.safety_ratings:
                        print(f"    {rating.category.name}: {rating.probability.name}")
                
                if hasattr(candidate, 'content') and candidate.content:
                    if hasattr(candidate.content, 'parts') and candidate.content.parts:
                        total_text = "".join([part.text for part in candidate.content.parts if hasattr(part, 'text')])
                        print(f"  Content length: {len(total_text)}")
                    else:
                        print("  No content parts")
                else:
                    print("  No content")
        else:
            print("No candidates available")
        
        # Full response object (truncated)
        print(f"\n--- FULL RESPONSE OBJECT ---")
        response_str = str(response)
        if len(response_str) > 500:
            print(f"{response_str[:500]}...")
        else:
            print(response_str)
    
    def test_simple_prompt(self):
        """Test with a simple, safe prompt"""
        print(f"\n🧪 Testing simple prompt with {self.model_name}")
        
        prompt = "Hello, please respond with 'Hello world!'"
        
        try:
            response = self.model.generate_content(
                prompt,
                generation_config=self.generation_config
            )
            self.analyze_response(response, "Simple Hello Test")
            return True
        except Exception as e:
            print(f"❌ Simple prompt failed: {e}")
            return False
    
    def test_fact_extraction_prompt(self, case_id: str = "test_case"):
        """Test with actual fact extraction prompt"""
        print(f"\n🧪 Testing fact extraction prompt with {self.model_name}")
        
        # Get a sample case text
        sample_text = """Alice is entitled to an exemption under section 151(b) for the year 2015. 
        No other taxpayer is entitled to a deduction for Alice in 2015."""
        
        try:
            # Generate the prompt
            fact_prompt = get_fact_extraction_prompt(mode="fast")
            formatted_prompt = fact_prompt.format(
                text=sample_text,
                case_id=case_id,
                codebase="[Sample codebase content]"
            )
            
            print(f"Prompt length: {len(formatted_prompt)} characters")
            print(f"Prompt preview: {formatted_prompt[:200]}...")
            
            response = self.model.generate_content(
                formatted_prompt,
                generation_config=self.generation_config
            )
            
            self.analyze_response(response, "Fact Extraction Test")
            return True
            
        except Exception as e:
            print(f"❌ Fact extraction prompt failed: {e}")
            return False
    
    def test_query_generation_prompt(self, case_id: str = "test_case"):
        """Test with actual query generation prompt"""
        print(f"\n🧪 Testing query generation prompt with {self.model_name}")
        
        sample_facts = "fact(test_case, taxpayer(alice)).\nfact(test_case, exemption_amount(alice, 2015, 2000))."
        sample_question = "Alice's exemption amount under section 151(d)(1) is equal to $0. Contradiction"
        
        try:
            # Generate the prompt
            query_prompt = get_query_generation_prompt(mode="fast")
            formatted_prompt = query_prompt.format(
                facts=sample_facts,
                question=sample_question,
                case_id=case_id,
                codebase="[Sample codebase content]"
            )
            
            print(f"Prompt length: {len(formatted_prompt)} characters")
            print(f"Prompt preview: {formatted_prompt[:200]}...")
            
            response = self.model.generate_content(
                formatted_prompt,
                generation_config=self.generation_config
            )
            
            self.analyze_response(response, "Query Generation Test")
            return True
            
        except Exception as e:
            print(f"❌ Query generation prompt failed: {e}")
            return False
    
    def test_different_safety_settings(self):
        """Test with different safety settings"""
        print(f"\n🧪 Testing different safety settings with {self.model_name}")
        
        from google.generativeai.types import HarmCategory, HarmBlockThreshold
        
        # More permissive safety settings
        safety_settings = [
            {
                "category": HarmCategory.HARM_CATEGORY_HARASSMENT,
                "threshold": HarmBlockThreshold.BLOCK_NONE,
            },
            {
                "category": HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                "threshold": HarmBlockThreshold.BLOCK_NONE,
            },
            {
                "category": HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
                "threshold": HarmBlockThreshold.BLOCK_NONE,
            },
            {
                "category": HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                "threshold": HarmBlockThreshold.BLOCK_NONE,
            },
        ]
        
        prompt = "Generate a simple Prolog fact: fact(test, taxpayer(alice))."
        
        try:
            response = self.model.generate_content(
                prompt,
                generation_config=self.generation_config,
                safety_settings=safety_settings
            )
            
            self.analyze_response(response, "Relaxed Safety Settings Test")
            return True
            
        except Exception as e:
            print(f"❌ Relaxed safety settings failed: {e}")
            return False
    
    def run_full_diagnosis(self):
        """Run complete diagnosis of gemini-2.5-pro issues"""
        print(f"🔍 FULL DIAGNOSIS: {self.model_name}")
        print(f"{'='*80}")
        
        results = {}
        
        # Test 1: Simple prompt
        results['simple'] = self.test_simple_prompt()
        
        # Test 2: Fact extraction
        results['fact_extraction'] = self.test_fact_extraction_prompt()
        
        # Test 3: Query generation
        results['query_generation'] = self.test_query_generation_prompt()
        
        # Test 4: Different safety settings
        results['relaxed_safety'] = self.test_different_safety_settings()
        
        # Summary
        print(f"\n{'='*80}")
        print("DIAGNOSIS SUMMARY")
        print(f"{'='*80}")
        
        for test_name, success in results.items():
            status = "✅ PASSED" if success else "❌ FAILED"
            print(f"{test_name:<20}: {status}")
        
        # Recommendations
        print(f"\n--- RECOMMENDATIONS ---")
        if not results['simple']:
            print("❌ Basic model access is failing - check API key and model availability")
        elif not any([results['fact_extraction'], results['query_generation']]):
            print("❌ All complex prompts failing - likely safety filtering on prompt content")
            print("💡 Try: Shorter prompts, different phrasing, or relaxed safety settings")
        elif results['relaxed_safety']:
            print("✅ Relaxed safety settings work - use them in production")
        else:
            print("⚠️  Mixed results - investigate specific prompt content causing issues")
        
        return results


def main():
    """Main entry point for debugging"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Debug Gemini API responses")
    parser.add_argument('--model', default='gemini-2.5-pro', help='Model to test')
    parser.add_argument('--test', choices=['simple', 'fact', 'query', 'safety', 'all'], 
                       default='all', help='Which test to run')
    
    args = parser.parse_args()
    
    try:
        debugger = GeminiResponseDebugger(args.model)
        
        if args.test == 'simple':
            debugger.test_simple_prompt()
        elif args.test == 'fact':
            debugger.test_fact_extraction_prompt()
        elif args.test == 'query':
            debugger.test_query_generation_prompt()
        elif args.test == 'safety':
            debugger.test_different_safety_settings()
        else:
            debugger.run_full_diagnosis()
            
    except Exception as e:
        print(f"❌ Debugger failed to initialize: {e}")
        print("Check your API key and model availability")


if __name__ == "__main__":
    main() 