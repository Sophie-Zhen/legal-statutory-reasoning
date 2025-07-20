#!/usr/bin/env python3
"""
Demonstration of Flexible Model System
Shows how to use different models and compare them
"""

import sys
from pathlib import Path
from model_config import ModelConfigManager, create_model_components
from flexible_runner import FlexibleStage3Runner

def demo_model_info():
    """Demonstrate model information retrieval"""
    print("="*60)
    print("DEMO 1: Model Information")
    print("="*60)
    
    manager = ModelConfigManager()
    
    # List all available models
    print("\nAvailable Models:")
    models = manager.list_available_models()
    for name, description in models.items():
        print(f"  {name:<20} - {description}")
    
    # Get detailed info for a specific model
    print(f"\nDetailed Info for gemini-2.5-pro:")
    info = manager.get_model_info("gemini-2.5-pro")
    for key, value in info.items():
        print(f"  {key:<18}: {value}")

def demo_model_switching():
    """Demonstrate model switching"""
    print("\n" + "="*60)
    print("DEMO 2: Model Switching")
    print("="*60)
    
    try:
        # Initialize with one model
        print("\n1. Initializing with gemini-2.0-flash-exp...")
        runner = FlexibleStage3Runner(model_name="gemini-2.0-flash-exp")
        print(f"   Current model: {runner.model_name}")
        
        # Switch to another model
        print("\n2. Switching to gemini-2.5-pro...")
        runner.switch_model("gemini-2.5-pro")
        print(f"   Current model: {runner.model_name}")
        
        # Get model info
        print("\n3. Current model info:")
        info = runner.get_model_info()
        print(f"   Display Name: {info['display_name']}")
        print(f"   Description: {info['description']}")
        print(f"   Temperature: {info['temperature']}")
        
    except Exception as e:
        print(f"   Error: {e}")

def demo_component_creation():
    """Demonstrate component creation with different models"""
    print("\n" + "="*60)
    print("DEMO 3: Component Creation")
    print("="*60)
    
    try:
        # Create components for different models
        models_to_test = ["gemini-2.0-flash-exp", "gemini-2.5-pro"]
        
        for model_name in models_to_test:
            print(f"\n1. Creating components for {model_name}...")
            
            fact_extractor, query_generator = create_model_components(
                model_name=model_name,
                prompt_mode="fast"
            )
            
            print(f"   ✅ Fact Extractor: {fact_extractor.model_name}")
            print(f"   ✅ Query Generator: {query_generator.model_name}")
            
    except Exception as e:
        print(f"   Error: {e}")

def demo_model_comparison_setup():
    """Demonstrate how to set up model comparison"""
    print("\n" + "="*60)
    print("DEMO 4: Model Comparison Setup")
    print("="*60)
    
    try:
        runner = FlexibleStage3Runner()
        
        # Show available test cases
        test_cases = runner.pipeline.get_test_cases()[:5]  # First 5 cases
        print(f"\nSample test cases: {test_cases}")
        
        # Example comparison command
        print("\nTo compare models, you would run:")
        print("python flexible_runner.py --compare gemini-2.0-flash-exp gemini-2.5-pro --num-cases 3")
        
        print("\nTo test specific cases:")
        print("python flexible_runner.py --model gemini-2.5-pro --cases s151_d_1_pos s151_d_1_neg")
        
    except Exception as e:
        print(f"   Error: {e}")

def demo_usage_patterns():
    """Demonstrate common usage patterns"""
    print("\n" + "="*60)
    print("DEMO 5: Common Usage Patterns")
    print("="*60)
    
    print("\n1. Quick model testing:")
    print("   python flexible_runner.py --model gemini-2.5-pro --num-cases 3")
    
    print("\n2. Model comparison:")
    print("   python flexible_runner.py --compare gemini-2.0-flash-exp gemini-2.5-pro --num-cases 5")
    
    print("\n3. Specific case testing:")
    print("   python flexible_runner.py --cases s151_d_1_pos s151_d_3_A_neg")
    
    print("\n4. Model information:")
    print("   python flexible_runner.py --list-models")
    print("   python flexible_runner.py --model-info gemini-2.5-pro")
    
    print("\n5. Different prompt modes:")
    print("   python flexible_runner.py --model gemini-2.5-pro --prompt-mode fast")

def main():
    """Run all demonstrations"""
    print("🚀 Flexible Model System Demonstration")
    print("This demo shows how to use the flexible model system for Stage 3 Method 2")
    
    try:
        demo_model_info()
        demo_model_switching()
        demo_component_creation()
        demo_model_comparison_setup()
        demo_usage_patterns()
        
        print("\n" + "="*60)
        print("✅ DEMO COMPLETED SUCCESSFULLY")
        print("="*60)
        print("\nThe flexible model system is ready to use!")
        print("Try running the commands shown above to test different models.")
        
    except Exception as e:
        print(f"\n❌ Demo failed: {e}")
        print("Please check your API key and environment setup.")

if __name__ == "__main__":
    main() 