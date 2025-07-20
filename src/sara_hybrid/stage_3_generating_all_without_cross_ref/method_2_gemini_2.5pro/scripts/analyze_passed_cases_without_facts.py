#!/usr/bin/env python3
"""
Passed Cases Without Facts Analyzer
Analyzes how many cases that passed accuracy testing had no facts extracted in their Prolog files.
This helps understand how often the system succeeded without semantic fact extraction.
"""

import os
import re
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Set, Tuple
import json


class PassedCasesWithoutFactsAnalyzer:
    """
    Analyzer for identifying passed cases with no facts extracted
    """
    
    def __init__(self):
        """Initialize the analyzer with project paths"""
        self.base_dir = Path(__file__).parent.parent
        self.accuracy_results_path = self.base_dir / "results" / "acc_analysis" / "stage3_individual_accuracy.txt"
        self.prolog_files_dir = self.base_dir / "results" / "stage3_test_split" / "prolog"
        self.output_dir = self.base_dir / "results" / "acc_analysis"
        
        # Create output directory if it doesn't exist
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"📁 Accuracy results: {self.accuracy_results_path}")
        print(f"📁 Prolog files: {self.prolog_files_dir}")
        print(f"📁 Output directory: {self.output_dir}")
    
    def extract_passed_cases(self) -> Set[str]:
        """
        Extract the list of passed cases from the accuracy results file
        
        Returns:
            Set of case IDs that passed accuracy testing
        """
        print("\n🔍 Extracting passed cases from accuracy results...")
        
        if not self.accuracy_results_path.exists():
            raise FileNotFoundError(f"Accuracy results file not found: {self.accuracy_results_path}")
        
        passed_cases = set()
        
        with open(self.accuracy_results_path, 'r') as f:
            content = f.read()
        
        # Find the PASSED section and extract case names
        passed_section_match = re.search(r'PASSED \(\d+ cases\):(.*?)(?=FAILED|TAX CALCULATION|$)', content, re.DOTALL)
        
        if passed_section_match:
            passed_section = passed_section_match.group(1)
            
            # Extract case IDs using regex pattern for case names
            case_pattern = r'- (s\d+[^(]*|\w+_case_\d+) \('
            matches = re.findall(case_pattern, passed_section)
            
            for match in matches:
                case_id = match.strip()
                passed_cases.add(case_id)
        
        print(f"✅ Found {len(passed_cases)} passed cases")
        print(f"Sample cases: {list(passed_cases)[:5]}...")
        
        return passed_cases
    
    def check_facts_in_prolog_file(self, case_id: str) -> Tuple[bool, List[str]]:
        """
        Check if a Prolog file has facts extracted or contains "No facts extracted"
        
        Args:
            case_id: Case identifier
            
        Returns:
            Tuple of (has_no_facts, fact_lines) where:
            - has_no_facts: True if the file contains "No facts extracted"
            - fact_lines: List of actual fact lines found (if any)
        """
        prolog_file = self.prolog_files_dir / f"{case_id}.pl"
        
        if not prolog_file.exists():
            print(f"⚠️ Prolog file not found for case: {case_id}")
            return False, []
        
        with open(prolog_file, 'r') as f:
            content = f.read()
        
        # Check for "No facts extracted" comment
        has_no_facts_comment = "% No facts extracted" in content
        
        # Extract actual fact lines (lines starting with "fact(")
        fact_lines = []
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('fact(') and not line.startswith('% fact('):
                fact_lines.append(line)
        
        # A case has no facts if either:
        # 1. Contains "No facts extracted" comment, OR
        # 2. Has no actual fact(...) lines
        has_no_facts = has_no_facts_comment or len(fact_lines) == 0
        
        return has_no_facts, fact_lines
    
    def analyze_passed_cases_without_facts(self) -> Dict:
        """
        Main analysis: find passed cases with no facts extracted
        
        Returns:
            Analysis results dictionary
        """
        print("\n🧪 Starting analysis of passed cases without facts...")
        
        # Step 1: Get passed cases
        passed_cases = self.extract_passed_cases()
        
        # Step 2: Analyze each passed case for facts
        passed_without_facts = []
        passed_with_facts = []
        missing_files = []
        
        for case_id in passed_cases:
            print(f"🔄 Checking {case_id}...")
            
            try:
                has_no_facts, fact_lines = self.check_facts_in_prolog_file(case_id)
                
                if has_no_facts:
                    passed_without_facts.append({
                        'case_id': case_id,
                        'fact_count': len(fact_lines),
                        'facts': fact_lines
                    })
                    print(f"  ❌ No facts: {case_id}")
                else:
                    passed_with_facts.append({
                        'case_id': case_id,
                        'fact_count': len(fact_lines),
                        'facts': fact_lines[:3]  # Sample first 3 facts
                    })
                    print(f"  ✅ Has facts: {case_id} ({len(fact_lines)} facts)")
                    
            except Exception as e:
                missing_files.append(case_id)
                print(f"  ⚠️ Error processing {case_id}: {e}")
        
        # Step 3: Calculate statistics
        total_passed = len(passed_cases)
        count_without_facts = len(passed_without_facts)
        count_with_facts = len(passed_with_facts)
        count_missing = len(missing_files)
        
        proportion_without_facts = count_without_facts / total_passed if total_passed > 0 else 0
        proportion_with_facts = count_with_facts / total_passed if total_passed > 0 else 0
        
        # Step 4: Compile results
        results = {
            'analysis_date': datetime.now().isoformat(),
            'summary': {
                'total_passed_cases': total_passed,
                'passed_without_facts': count_without_facts,
                'passed_with_facts': count_with_facts,
                'missing_prolog_files': count_missing,
                'proportion_without_facts': proportion_without_facts,
                'proportion_with_facts': proportion_with_facts
            },
            'cases_without_facts': passed_without_facts,
            'cases_with_facts': passed_with_facts,
            'missing_files': missing_files
        }
        
        print(f"\n📊 Analysis Complete!")
        print(f"Total passed cases: {total_passed}")
        print(f"Passed without facts: {count_without_facts} ({proportion_without_facts:.1%})")
        print(f"Passed with facts: {count_with_facts} ({proportion_with_facts:.1%})")
        print(f"Missing Prolog files: {count_missing}")
        
        return results
    
    def save_results(self, results: Dict):
        """
        Save analysis results to files
        
        Args:
            results: Analysis results dictionary
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Save detailed JSON results
        json_file = self.output_dir / f"passed_cases_without_facts_analysis_{timestamp}.json"
        with open(json_file, 'w') as f:
            json.dump(results, f, indent=2)
        
        # Save human-readable summary
        summary_file = self.output_dir / f"passed_cases_without_facts_summary_{timestamp}.txt"
        with open(summary_file, 'w') as f:
            f.write("PASSED CASES WITHOUT FACTS ANALYSIS\n")
            f.write("=" * 50 + "\n")
            f.write(f"Analysis Date: {results['analysis_date']}\n\n")
            
            # Summary statistics
            summary = results['summary']
            f.write("SUMMARY STATISTICS:\n")
            f.write(f"Total passed cases: {summary['total_passed_cases']}\n")
            f.write(f"Passed without facts: {summary['passed_without_facts']}\n")
            f.write(f"Passed with facts: {summary['passed_with_facts']}\n")
            f.write(f"Missing Prolog files: {summary['missing_prolog_files']}\n")
            f.write(f"Proportion without facts: {summary['proportion_without_facts']:.1%}\n")
            f.write(f"Proportion with facts: {summary['proportion_with_facts']:.1%}\n\n")
            
            # Key finding
            if summary['proportion_without_facts'] > 0:
                f.write("KEY FINDING:\n")
                f.write(f"🎯 {summary['passed_without_facts']} out of {summary['total_passed_cases']} ")
                f.write(f"passed cases ({summary['proportion_without_facts']:.1%}) succeeded WITHOUT semantic fact extraction.\n")
                f.write("This suggests the system can rely on built-in knowledge base rules for some cases.\n\n")
            
            # Cases without facts
            if results['cases_without_facts']:
                f.write("CASES THAT PASSED WITHOUT FACTS:\n")
                f.write("-" * 30 + "\n")
                for case in results['cases_without_facts']:
                    f.write(f"• {case['case_id']}\n")
                f.write("\n")
            
            # Cases with facts (sample)
            if results['cases_with_facts']:
                f.write("CASES THAT PASSED WITH FACTS (Sample):\n")
                f.write("-" * 30 + "\n")
                for case in results['cases_with_facts'][:10]:  # Show first 10
                    f.write(f"• {case['case_id']} ({case['fact_count']} facts)\n")
                if len(results['cases_with_facts']) > 10:
                    f.write(f"... and {len(results['cases_with_facts']) - 10} more\n")
                f.write("\n")
            
            # Missing files
            if results['missing_files']:
                f.write("MISSING PROLOG FILES:\n")
                f.write("-" * 30 + "\n")
                for case_id in results['missing_files']:
                    f.write(f"• {case_id}\n")
        
        print(f"\n💾 Results saved:")
        print(f"📄 Detailed results: {json_file}")
        print(f"📄 Summary report: {summary_file}")


def main():
    """Main entry point for the passed cases without facts analyzer"""
    print("🔍 PASSED CASES WITHOUT FACTS ANALYZER")
    print("=" * 60)
    print("Analyzing how many passed cases had no semantic facts extracted...")
    
    try:
        analyzer = PassedCasesWithoutFactsAnalyzer()
        results = analyzer.analyze_passed_cases_without_facts()
        analyzer.save_results(results)
        
        print(f"\n✅ Analysis completed successfully!")
        
        # Print key findings
        summary = results['summary']
        print(f"\n🎯 KEY FINDINGS:")
        print(f"• {summary['passed_without_facts']}/{summary['total_passed_cases']} passed cases had no facts")
        print(f"• That's {summary['proportion_without_facts']:.1%} of all passed cases")
        print(f"• This suggests the system can succeed using built-in rules without semantic extraction")
        
    except Exception as e:
        print(f"❌ Error during analysis: {e}")
        raise


if __name__ == "__main__":
    main() 