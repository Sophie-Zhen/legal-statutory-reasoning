#!/usr/bin/env python3
"""
Flexible Stage 3 Method 2 Runner - Multi-Model Support
Allows easy switching between different Gemini models for comparison testing
"""

import os
import sys
import json
import logging
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple

# Add current directory to path for imports
current_dir = Path(__file__).parent
project_root = current_dir.parent.parent.parent.parent.parent
sys.path.insert(0, str(current_dir))
sys.path.insert(0, str(project_root / "src" / "query_generation" / "stage1"))

from model_config import ModelConfigManager, create_model_components

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(name)s - %(message)s'
)
logger = logging.getLogger(__name__)


class FlexibleStage3Runner:
    """
    Flexible runner for Stage 3 Method 2 pipeline with multi-model support
    """
    
    def __init__(self, model_name: str = "gemini-2.0-flash-exp", prompt_mode: str = "full"):
        """
        Initialize runner with specified model
        
        Args:
            model_name: Name of the Gemini model to use
            prompt_mode: Prompt mode ('full', 'fast', 'emergency')
        """
        self.model_name = model_name
        self.prompt_mode = prompt_mode
        self.project_root = project_root
        self.method2_dir = current_dir.parent
        self.data_path = self.project_root / "data" / "sara_v3"
        
        # Initialize model configuration manager
        self.model_manager = ModelConfigManager()
        
        # Load API key
        self.api_key = self.model_manager.api_key
        
        # Initialize pipeline and components
        self._initialize_components()
        
        logger.info(f"Flexible Stage 3 Runner initialized with {self.model_name}")
        logger.info(f"Model: {self.model_manager.get_model_info(model_name)['display_name']}")
        logger.info(f"Test cases loaded: {len(self.pipeline.get_test_cases())}")
    
    def _initialize_components(self):
        """Initialize all pipeline components with specified model"""
        from stage3_pipeline import Stage3Method2Pipeline
        from stage3_case_parser import Stage3CaseParser
        
        # Initialize pipeline
        self.pipeline = Stage3Method2Pipeline(str(self.project_root))
        
        # Initialize case parser
        self.case_parser = Stage3CaseParser(str(self.data_path / "cases"))
        
        # Create model-specific components
        self.fact_extractor, self.query_generator = create_model_components(
            model_name=self.model_name,
            api_key=self.api_key,
            prompt_mode=self.prompt_mode
        )
        
        # Inject components into pipeline
        self.pipeline.case_parser = self.case_parser
        self.pipeline.fact_extractor = self.fact_extractor
        self.pipeline.query_generator = self.query_generator
        
        logger.info("All components initialized successfully")

    def get_tax_cases(self) -> List[str]:
        """Returns a hardcoded list of the 20 tax calculation test cases from the test split."""
        return [
            'tax_case_28', 'tax_case_30', 'tax_case_31', 'tax_case_34', 'tax_case_43',
            'tax_case_46', 'tax_case_48', 'tax_case_49', 'tax_case_53', 'tax_case_57',
            'tax_case_68', 'tax_case_69', 'tax_case_75', 'tax_case_77', 'tax_case_78',
            'tax_case_82', 'tax_case_85', 'tax_case_9', 'tax_case_90', 'tax_case_93'
        ]
    
    def switch_model(self, new_model_name: str):
        """
        Switch to a different model
        
        Args:
            new_model_name: Name of the new model to use
        """
        if new_model_name == self.model_name:
            logger.info(f"Already using {new_model_name}")
            return
        
        logger.info(f"Switching from {self.model_name} to {new_model_name}")
        
        # Update model name
        self.model_name = new_model_name
        
        # Re-create model-specific components
        self.fact_extractor, self.query_generator = create_model_components(
            model_name=self.model_name,
            api_key=self.api_key,
            prompt_mode=self.prompt_mode
        )
        
        # Re-inject components into pipeline
        self.pipeline.fact_extractor = self.fact_extractor
        self.pipeline.query_generator = self.query_generator
        
        logger.info(f"Successfully switched to {new_model_name}")
    
    def run_model_comparison(self, models: List[str], case_ids: Optional[List[str]] = None, 
                           num_cases: int = 5) -> Dict:
        """
        Run comparison between multiple models
        
        Args:
            models: List of model names to compare
            case_ids: Specific case IDs to test (optional)
            num_cases: Number of cases to test if case_ids not provided
        
        Returns:
            Dictionary with results for each model
        """
        logger.info(f"Running model comparison: {models}")
        
        # Get test cases
        if case_ids:
            test_cases = case_ids
        else:
            all_cases = self.pipeline.get_test_cases()
            test_cases = all_cases[:num_cases]
        
        logger.info(f"Testing {len(test_cases)} cases: {test_cases}")
        
        comparison_results = {}
        
        for model_name in models:
            logger.info(f"\n{'='*60}")
            logger.info(f"Testing model: {model_name}")
            logger.info(f"{'='*60}")
            
            try:
                # Switch to the model
                self.switch_model(model_name)
                
                # Run test cases
                results = self.pipeline.run_batch(
                    case_ids=test_cases,
                    use_cache=False  # Don't use cache for fair comparison
                )
                
                # Calculate summary statistics
                summary = self._calculate_model_summary(results, model_name)
                
                comparison_results[model_name] = {
                    'model_info': self.model_manager.get_model_info(model_name),
                    'results': results,
                    'summary': summary
                }
                
                logger.info(f"Model {model_name} completed: {summary['success_rate']:.1f}% success rate")
                
            except Exception as e:
                logger.error(f"Error testing model {model_name}: {e}")
                comparison_results[model_name] = {
                    'model_info': self.model_manager.get_model_info(model_name),
                    'error': str(e),
                    'results': {},
                    'summary': {'success_rate': 0.0, 'total_cases': 0}
                }
        
        # Save comparison results
        self._save_comparison_results(comparison_results, test_cases)
        
        return comparison_results
    
    def _calculate_model_summary(self, results: Dict, model_name: str) -> Dict:
        """Calculate summary statistics for a model"""
        case_results = results.get('results', {})
        
        total_cases = len(case_results)
        successful_cases = sum(1 for case_data in case_results.values() 
                             if case_data.get('execution_result', {}).get('success', False))
        
        success_rate = (successful_cases / total_cases * 100) if total_cases > 0 else 0.0
        
        return {
            'model_name': model_name,
            'total_cases': total_cases,
            'successful_cases': successful_cases,
            'success_rate': success_rate,
            'timestamp': datetime.now().isoformat()
        }
    
    def _save_comparison_results(self, comparison_results: Dict, test_cases: List[str]):
        """Save comparison results to file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        results_file = self.method2_dir / "results" / f"model_comparison_{timestamp}.json"
        
        # Create summary report
        summary_report = {
            'timestamp': timestamp,
            'test_cases': test_cases,
            'models_tested': list(comparison_results.keys()),
            'comparison_summary': {
                model: result['summary'] for model, result in comparison_results.items()
            },
            'full_results': comparison_results
        }
        
        # Save to file
        with open(results_file, 'w') as f:
            json.dump(summary_report, f, indent=2)
        
        logger.info(f"Comparison results saved to: {results_file}")
        
        # Print summary table
        self._print_comparison_summary(comparison_results)
    
    def _print_comparison_summary(self, comparison_results: Dict):
        """Print a formatted comparison summary"""
        print("\n" + "="*80)
        print("MODEL COMPARISON SUMMARY")
        print("="*80)
        
        print(f"{'Model':<25} {'Success Rate':<15} {'Cases':<10} {'Status':<20}")
        print("-"*80)
        
        for model_name, result in comparison_results.items():
            if 'error' in result:
                print(f"{model_name:<25} {'ERROR':<15} {'0':<10} {result['error'][:20]:<20}")
            else:
                summary = result['summary']
                success_rate = f"{summary['success_rate']:.1f}%"
                cases = f"{summary['successful_cases']}/{summary['total_cases']}"
                print(f"{model_name:<25} {success_rate:<15} {cases:<10} {'OK':<20}")
        
        print("="*80)
    
    def run_single_model_test(self, num_cases: int = 5, start_idx: int = 0) -> Dict:
        """
        Run test with current model
        
        Args:
            num_cases: Number of cases to test
            start_idx: Starting index for test cases
        
        Returns:
            Test results
        """
        logger.info(f"Running single model test with {self.model_name}")
        logger.info(f"Testing {num_cases} cases starting from index {start_idx}")
        
        return self.pipeline.run_batch(
            start_idx=start_idx,
            max_cases=num_cases,
            use_cache=True
        )
    
    def run_specific_cases(self, case_ids: List[str]) -> Dict:
        """Run test on specific cases"""
        logger.info(f"Running specific cases with {self.model_name}: {case_ids}")
        
        return self.pipeline.run_batch(
            case_ids=case_ids,
            use_cache=False
        )
    
    def list_available_models(self):
        """List all available models"""
        models = self.model_manager.list_available_models()
        
        print("\nAvailable Models:")
        print("="*60)
        for name, description in models.items():
            current = " (CURRENT)" if name == self.model_name else ""
            print(f"{name:<20} - {description}{current}")
        print("="*60)
    
    def get_model_info(self, model_name: Optional[str] = None) -> Dict:
        """Get detailed information about a model"""
        model_name = model_name or self.model_name
        return self.model_manager.get_model_info(model_name)


def main():
    """Main entry point with command line interface"""
    parser = argparse.ArgumentParser(description="Flexible Stage 3 Method 2 Runner")
    
    # Model selection
    parser.add_argument('--model', '-m', default='gemini-2.0-flash-exp',
                       help='Model to use (default: gemini-2.0-flash-exp)')
    parser.add_argument('--prompt-mode', default='full',
                       choices=['full', 'fast', 'emergency'],
                       help='Prompt mode (default: full)')
    
    # Test configuration
    parser.add_argument('--num-cases', '-n', type=int, default=5,
                       help='Number of test cases (default: 5)')
    parser.add_argument('--start-idx', type=int, default=0,
                       help='Starting index for test cases (default: 0)')
    parser.add_argument('--cases', nargs='+',
                       help='Specific case IDs to test')
    parser.add_argument('--tax-cases', action='store_true',
                        help='Run only the 20 tax calculation cases from the test split')
    
    # Commands
    parser.add_argument('--compare', nargs='+',
                       help='Compare multiple models (space-separated)')
    parser.add_argument('--list-models', action='store_true',
                       help='List available models')
    parser.add_argument('--model-info', metavar='MODEL',
                       help='Show detailed info about a model')
    
    args = parser.parse_args()
    
    # Handle list models command
    if args.list_models:
        manager = ModelConfigManager()
        models = manager.list_available_models()
        print("\nAvailable Models:")
        print("="*60)
        for name, description in models.items():
            print(f"{name:<20} - {description}")
        print("="*60)
        return
    
    # Handle model info command
    if args.model_info:
        manager = ModelConfigManager()
        info = manager.get_model_info(args.model_info)
        print(f"\nModel Information: {info['display_name']}")
        print("="*60)
        for key, value in info.items():
            print(f"{key:<20}: {value}")
        print("="*60)
        return
    
    # Initialize runner
    try:
        runner = FlexibleStage3Runner(
            model_name=args.model,
            prompt_mode=args.prompt_mode
        )
    except Exception as e:
        print(f"Error initializing runner: {e}")
        sys.exit(1)
    
    # Handle compare command
    if args.compare:
        print(f"Comparing models: {args.compare}")
        results = runner.run_model_comparison(
            models=args.compare,
            case_ids=args.cases,
            num_cases=args.num_cases
        )
        return
    
    # Handle single model test
    if args.tax_cases:
        print("Testing the 20 tax calculation cases from the test split")
        tax_cases = runner.get_tax_cases()
        results = runner.run_specific_cases(tax_cases)
    elif args.cases:
        print(f"Testing specific cases: {args.cases}")
        results = runner.run_specific_cases(args.cases)
    else:
        print(f"Testing {args.num_cases} cases starting from index {args.start_idx}")
        results = runner.run_single_model_test(
            num_cases=args.num_cases,
            start_idx=args.start_idx
        )
    
    # Print results summary
    summary = results.get('summary', {})
    print(f"\nTest completed!")
    print(f"Model: {runner.model_name}")
    print(f"Success rate: {summary.get('success_rate', 0):.1f}%")
    print(f"Cases: {summary.get('successful_cases', 0)}/{summary.get('total_cases', 0)}")


if __name__ == "__main__":
    main() 