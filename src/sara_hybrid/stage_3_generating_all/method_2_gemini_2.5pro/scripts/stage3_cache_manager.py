"""
Stage 3 Cache Manager
Handles caching of processed cases to avoid duplicate LLM calls and enable resuming
"""

import json
import logging
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set

logger = logging.getLogger(__name__)


class Stage3CacheManager:
    """
    Cache manager for Stage 3 pipeline to avoid duplicate processing
    """
    
    def __init__(self, cache_dir: Path):
        """
        Initialize cache manager
        
        Args:
            cache_dir: Directory to store cache files
        """
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        self.cache_index_file = self.cache_dir / "cache_index.json"
        self.cache_index = self._load_cache_index()
        
        logger.info(f"Cache manager initialized: {len(self.cache_index)} cached cases")
        
    def _load_cache_index(self) -> Dict:
        """Load the cache index from disk"""
        if self.cache_index_file.exists():
            try:
                with open(self.cache_index_file, 'r') as f:
                    index = json.load(f)
                logger.info(f"Loaded cache index with {len(index)} entries")
                return index
            except Exception as e:
                logger.warning(f"Error loading cache index: {e}, starting fresh")
                return {}
        else:
            logger.info("No cache index found, starting fresh")
            return {}
    
    def _save_cache_index(self):
        """Save the cache index to disk"""
        try:
            with open(self.cache_index_file, 'w') as f:
                json.dump(self.cache_index, f, indent=2)
            logger.debug(f"Saved cache index with {len(self.cache_index)} entries")
        except Exception as e:
            logger.error(f"Error saving cache index: {e}")
    
    def is_cached(self, case_id: str) -> bool:
        """
        Check if a case is cached and valid
        
        Args:
            case_id: Case identifier
            
        Returns:
            True if case is cached and valid
        """
        if case_id not in self.cache_index:
            return False
        
        cache_entry = self.cache_index[case_id]
        cache_file = self.cache_dir / f"{case_id}.json"
        
        # Check if cache file exists and has valid status
        if not cache_file.exists():
            logger.warning(f"Cache file missing for {case_id}, removing from index")
            del self.cache_index[case_id]
            self._save_cache_index()
            return False
        
        # Check if status is success
        if cache_entry.get('status') != 'success':
            logger.debug(f"Cache entry for {case_id} has status: {cache_entry.get('status')}")
            return False
        
        return True
    
    def get_cached_result(self, case_id: str) -> Optional[Dict]:
        """
        Get cached result for a case
        
        Args:
            case_id: Case identifier
            
        Returns:
            Cached result dictionary or None if not cached
        """
        if not self.is_cached(case_id):
            return None
        
        cache_file = self.cache_dir / f"{case_id}.json"
        
        try:
            with open(cache_file, 'r') as f:
                cached_data = json.load(f)
            
            logger.info(f"Retrieved cached result for {case_id}")
            
            # Update the result with cache metadata
            cached_data['from_cache'] = True
            cached_data['cache_retrieved_at'] = datetime.now().isoformat()
            
            return cached_data
            
        except Exception as e:
            logger.error(f"Error reading cached result for {case_id}: {e}")
            return None
    
    def cache_result(self, case_id: str, result: Dict):
        """
        Cache a case result
        
        Args:
            case_id: Case identifier
            result: Result dictionary to cache
        """
        try:
            # Prepare cache data
            cache_data = result.copy()
            cache_data['cached_at'] = datetime.now().isoformat()
            cache_data['from_cache'] = False
            
            # Save individual cache file
            cache_file = self.cache_dir / f"{case_id}.json"
            with open(cache_file, 'w') as f:
                json.dump(cache_data, f, indent=2)
            
            # Update cache index
            self.cache_index[case_id] = {
                'cached_at': cache_data['cached_at'],
                'status': result.get('status', 'unknown'),
                'has_facts': len(result.get('facts', [])) > 0,
                'has_query': len(result.get('query', '')) > 0,
                'execution_status': result.get('execution_result', {}).get('status', 'unknown')
            }
            
            # Save updated index
            self._save_cache_index()
            
            logger.info(f"Cached result for {case_id}")
            
        except Exception as e:
            logger.error(f"Error caching result for {case_id}: {e}")
    
    def get_cached_cases(self) -> Set[str]:
        """
        Get set of successfully cached case IDs
        
        Returns:
            Set of case IDs that are successfully cached
        """
        cached_cases = set()
        
        for case_id, cache_entry in self.cache_index.items():
            if cache_entry.get('status') == 'success':
                cache_file = self.cache_dir / f"{case_id}.json"
                if cache_file.exists():
                    cached_cases.add(case_id)
        
        return cached_cases
    
    def get_cache_stats(self) -> Dict:
        """
        Get cache statistics
        
        Returns:
            Dictionary with cache statistics
        """
        total_entries = len(self.cache_index)
        successful_entries = 0
        failed_entries = 0
        missing_files = 0
        
        for case_id, cache_entry in self.cache_index.items():
            cache_file = self.cache_dir / f"{case_id}.json"
            
            if not cache_file.exists():
                missing_files += 1
                continue
                
            if cache_entry.get('status') == 'success':
                successful_entries += 1
            else:
                failed_entries += 1
        
        return {
            'total_entries': total_entries,
            'successful_entries': successful_entries,
            'failed_entries': failed_entries,
            'missing_files': missing_files,
            'cache_hit_rate': successful_entries / total_entries if total_entries > 0 else 0,
            'cache_directory': str(self.cache_dir)
        }
    
    def clean_invalid_cache(self):
        """
        Clean up invalid cache entries (missing files, failed cases)
        """
        cleaned_count = 0
        
        # Check each cache entry
        cases_to_remove = []
        for case_id, cache_entry in self.cache_index.items():
            cache_file = self.cache_dir / f"{case_id}.json"
            
            # Remove if file doesn't exist
            if not cache_file.exists():
                cases_to_remove.append(case_id)
                cleaned_count += 1
                continue
            
            # Remove if status is not success
            if cache_entry.get('status') != 'success':
                cases_to_remove.append(case_id)
                try:
                    cache_file.unlink()  # Delete the file
                    cleaned_count += 1
                except Exception as e:
                    logger.warning(f"Error deleting cache file for {case_id}: {e}")
        
        # Remove from index
        for case_id in cases_to_remove:
            del self.cache_index[case_id]
        
        if cleaned_count > 0:
            self._save_cache_index()
            logger.info(f"Cleaned {cleaned_count} invalid cache entries")
        
        return cleaned_count
    
    def invalidate_case(self, case_id: str):
        """
        Invalidate (remove) a specific case from cache
        
        Args:
            case_id: Case identifier to invalidate
        """
        if case_id in self.cache_index:
            # Delete cache file
            cache_file = self.cache_dir / f"{case_id}.json"
            if cache_file.exists():
                try:
                    cache_file.unlink()
                    logger.info(f"Deleted cache file for {case_id}")
                except Exception as e:
                    logger.warning(f"Error deleting cache file for {case_id}: {e}")
            
            # Remove from index
            del self.cache_index[case_id]
            self._save_cache_index()
            
            logger.info(f"Invalidated cache for {case_id}")
        else:
            logger.debug(f"Case {case_id} not in cache, nothing to invalidate")
    
    def clear_cache(self):
        """
        Clear all cache entries and files
        """
        # Delete all cache files
        deleted_count = 0
        for cache_file in self.cache_dir.glob("*.json"):
            if cache_file.name != "cache_index.json":
                try:
                    cache_file.unlink()
                    deleted_count += 1
                except Exception as e:
                    logger.warning(f"Error deleting {cache_file}: {e}")
        
        # Clear index
        self.cache_index.clear()
        self._save_cache_index()
        
        logger.info(f"Cleared cache: deleted {deleted_count} files")
        
        return deleted_count 