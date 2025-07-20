#!/usr/bin/env python3
"""
Cache Management Utilities for Stage 3 Pipeline
Provides command-line tools for managing the cache
"""

import argparse
import json
import sys
import os
from pathlib import Path

# Add current directory to path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

from stage3_cache_manager import Stage3CacheManager


def show_cache_stats(cache_manager):
    """Show detailed cache statistics"""
    stats = cache_manager.get_cache_stats()
    
    print("📊 Cache Statistics")
    print("=" * 50)
    print(f"Cache Directory: {stats['cache_directory']}")
    print(f"Total Entries: {stats['total_entries']}")
    print(f"Successful Entries: {stats['successful_entries']}")
    print(f"Failed Entries: {stats['failed_entries']}")
    print(f"Missing Files: {stats['missing_files']}")
    print(f"Cache Hit Rate: {stats['cache_hit_rate']:.1%}")
    
    if stats['total_entries'] > 0:
        print(f"\n💾 Cache Efficiency:")
        print(f"  Valid: {stats['successful_entries']}/{stats['total_entries']} ({stats['successful_entries']/stats['total_entries']:.1%})")
        if stats['missing_files'] > 0:
            print(f"  ⚠️ Missing files: {stats['missing_files']}")


def list_cached_cases(cache_manager):
    """List all cached cases"""
    cached_cases = cache_manager.get_cached_cases()
    
    print(f"📦 Cached Cases ({len(cached_cases)})")
    print("=" * 50)
    
    if not cached_cases:
        print("No cases in cache")
        return
    
    # Sort for consistent output
    for case_id in sorted(cached_cases):
        print(f"  ✅ {case_id}")


def inspect_case(cache_manager, case_id):
    """Inspect a specific cached case"""
    if not cache_manager.is_cached(case_id):
        print(f"❌ Case {case_id} not found in cache")
        return
    
    cached_result = cache_manager.get_cached_result(case_id)
    
    print(f"🔍 Inspecting Case: {case_id}")
    print("=" * 50)
    print(f"Status: {cached_result.get('status', 'unknown')}")
    print(f"Cached At: {cached_result.get('cached_at', 'unknown')}")
    print(f"Facts Count: {len(cached_result.get('facts', []))}")
    print(f"Has Query: {'Yes' if cached_result.get('query') else 'No'}")
    
    exec_result = cached_result.get('execution_result', {})
    print(f"Execution Status: {exec_result.get('status', 'unknown')}")
    
    if 'raw_llm_responses' in cached_result:
        llm_responses = cached_result['raw_llm_responses']
        fact_attempts = len(llm_responses.get('fact_extraction', []))
        query_attempts = len(llm_responses.get('query_generation', []))
        print(f"LLM Attempts: Facts={fact_attempts}, Query={query_attempts}")
    
    print(f"\nQuery Preview:")
    query = cached_result.get('query', '')
    print(f"  {query[:100]}{'...' if len(query) > 100 else ''}")


def clean_cache(cache_manager):
    """Clean invalid cache entries"""
    print("🧹 Cleaning invalid cache entries...")
    cleaned_count = cache_manager.clean_invalid_cache()
    
    if cleaned_count > 0:
        print(f"✅ Cleaned {cleaned_count} invalid entries")
    else:
        print("✅ Cache is already clean")


def clear_cache(cache_manager):
    """Clear all cache entries"""
    stats = cache_manager.get_cache_stats()
    
    if stats['total_entries'] == 0:
        print("ℹ️ Cache is already empty")
        return
    
    print(f"⚠️ This will delete all {stats['total_entries']} cache entries")
    confirm = input("Are you sure? (yes/no): ").lower().strip()
    
    if confirm == 'yes':
        deleted_count = cache_manager.clear_cache()
        print(f"✅ Cleared cache: deleted {deleted_count} files")
    else:
        print("❌ Cache clear cancelled")


def invalidate_cases(cache_manager, case_ids):
    """Invalidate specific cases"""
    print(f"🗑️ Invalidating {len(case_ids)} cases...")
    
    for case_id in case_ids:
        if cache_manager.is_cached(case_id):
            cache_manager.invalidate_case(case_id)
            print(f"  ✅ Invalidated {case_id}")
        else:
            print(f"  ⚠️ {case_id} not in cache")


def export_cache_data(cache_manager, output_file):
    """Export cache data to JSON file"""
    cached_cases = cache_manager.get_cached_cases()
    
    if not cached_cases:
        print("❌ No cached cases to export")
        return
    
    export_data = {}
    
    for case_id in cached_cases:
        cached_result = cache_manager.get_cached_result(case_id)
        if cached_result:
            # Remove some metadata for cleaner export
            clean_result = cached_result.copy()
            clean_result.pop('from_cache', None)
            clean_result.pop('cache_retrieved_at', None)
            export_data[case_id] = clean_result
    
    with open(output_file, 'w') as f:
        json.dump(export_data, f, indent=2)
    
    print(f"✅ Exported {len(export_data)} cached cases to {output_file}")


def main():
    parser = argparse.ArgumentParser(description="Cache Management for Stage 3 Pipeline")
    parser.add_argument('--cache-dir', default='../cache/stage3_test_split', 
                       help='Cache directory path')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Stats command
    subparsers.add_parser('stats', help='Show cache statistics')
    
    # List command
    subparsers.add_parser('list', help='List all cached cases')
    
    # Inspect command
    inspect_parser = subparsers.add_parser('inspect', help='Inspect a specific case')
    inspect_parser.add_argument('case_id', help='Case ID to inspect')
    
    # Clean command
    subparsers.add_parser('clean', help='Clean invalid cache entries')
    
    # Clear command
    subparsers.add_parser('clear', help='Clear all cache entries')
    
    # Invalidate command
    invalidate_parser = subparsers.add_parser('invalidate', help='Invalidate specific cases')
    invalidate_parser.add_argument('case_ids', nargs='+', help='Case IDs to invalidate')
    
    # Export command
    export_parser = subparsers.add_parser('export', help='Export cache data to JSON')
    export_parser.add_argument('output_file', help='Output JSON file')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    # Initialize cache manager
    cache_dir = Path(args.cache_dir)
    cache_manager = Stage3CacheManager(cache_dir)
    
    # Execute command
    if args.command == 'stats':
        show_cache_stats(cache_manager)
    elif args.command == 'list':
        list_cached_cases(cache_manager)
    elif args.command == 'inspect':
        inspect_case(cache_manager, args.case_id)
    elif args.command == 'clean':
        clean_cache(cache_manager)
    elif args.command == 'clear':
        clear_cache(cache_manager)
    elif args.command == 'invalidate':
        invalidate_cases(cache_manager, args.case_ids)
    elif args.command == 'export':
        export_cache_data(cache_manager, args.output_file)


if __name__ == "__main__":
    main() 