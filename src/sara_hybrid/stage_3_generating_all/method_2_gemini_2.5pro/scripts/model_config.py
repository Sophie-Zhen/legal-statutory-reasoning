"""
Model Configuration System for Stage 3 Method 2 Pipeline
Provides flexible configuration for different Gemini models
"""

import os
import logging
from typing import Dict, Any, Optional
from dataclasses import dataclass
import google.generativeai as genai

logger = logging.getLogger(__name__)

@dataclass
class ModelConfig:
    """Configuration for a specific Gemini model"""
    name: str
    display_name: str
    temperature: float = 0.1
    top_p: float = 0.9
    top_k: int = 40
    max_output_tokens: int = 2048
    candidate_count: int = 1
    max_retries: int = 3
    base_delay: float = 1.0
    description: str = ""

class ModelConfigManager:
    """Manages different model configurations"""
    
    # Predefined model configurations
    MODELS = {
        "gemini-2.0-flash-exp": ModelConfig(
            name="gemini-2.0-flash-exp",
            display_name="Gemini 2.0 Flash Experimental",
            temperature=0.1,
            top_p=0.9,
            top_k=40,
            max_output_tokens=2048,
            candidate_count=1,
            max_retries=3,
            base_delay=1.0,
            description="Experimental flash model with fast response times"
        ),
        "gemini-2.5-pro": ModelConfig(
            name="gemini-2.5-pro",
            display_name="Gemini 2.5 Pro",
            temperature=0.1,
            top_p=0.9,
            top_k=40,
            max_output_tokens=4096,  # Increased token limit
            candidate_count=1,
            max_retries=3,
            base_delay=1.0,
            description="Pro model with enhanced reasoning capabilities"
        ),
        "gemini-1.5-pro": ModelConfig(
            name="gemini-1.5-pro",
            display_name="Gemini 1.5 Pro",
            temperature=0.1,
            top_p=0.9,
            top_k=40,
            max_output_tokens=2048,
            candidate_count=1,
            max_retries=3,
            base_delay=1.0,
            description="Stable pro model with good performance"
        ),
        "gemini-1.5-flash": ModelConfig(
            name="gemini-1.5-flash",
            display_name="Gemini 1.5 Flash",
            temperature=0.1,
            top_p=0.9,
            top_k=40,
            max_output_tokens=2048,
            candidate_count=1,
            max_retries=3,
            base_delay=1.0,
            description="Fast model with good cost-performance ratio"
        )
    }
    
    def __init__(self, api_key: Optional[str] = None):
        """Initialize model configuration manager"""
        self.api_key = api_key or self._load_api_key()
        genai.configure(api_key=self.api_key)
        
    def _load_api_key(self) -> str:
        """Load Gemini API key from environment"""
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")
        return api_key
    
    def get_model_config(self, model_name: str) -> ModelConfig:
        """Get configuration for a specific model"""
        if model_name not in self.MODELS:
            logger.warning(f"Unknown model {model_name}, using gemini-2.0-flash-exp as default")
            model_name = "gemini-2.0-flash-exp"
        
        return self.MODELS[model_name]
    
    def create_model_instance(self, model_name: str) -> genai.GenerativeModel:
        """Create a Gemini model instance"""
        config = self.get_model_config(model_name)
        logger.info(f"Creating model instance: {config.display_name}")
        return genai.GenerativeModel(config.name)
    
    def get_generation_config(self, model_name: str, **overrides) -> genai.types.GenerationConfig:
        """Get generation configuration for a model"""
        config = self.get_model_config(model_name)
        
        # Apply any overrides
        params = {
            'temperature': overrides.get('temperature', config.temperature),
            'top_p': overrides.get('top_p', config.top_p),
            'top_k': overrides.get('top_k', config.top_k),
            'max_output_tokens': overrides.get('max_output_tokens', config.max_output_tokens),
            'candidate_count': overrides.get('candidate_count', config.candidate_count)
        }
        
        return genai.types.GenerationConfig(**params)
    
    def get_safety_settings(self, model_name: str = None):
        """Get highly permissive safety settings for legal text processing"""
        from google.generativeai.types import HarmCategory, HarmBlockThreshold
        
        # Use highly permissive safety settings for legal text processing
        # Legal documents often contain language that can trigger safety filters
        return [
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
    
    def get_safety_settings_fallback(self, model_name: str = None):
        """Get fallback safety settings if primary settings fail"""
        from google.generativeai.types import HarmCategory, HarmBlockThreshold
        
        # Even more permissive fallback settings
        return [
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
    
    def list_available_models(self) -> Dict[str, str]:
        """List all available models with descriptions"""
        return {
            name: f"{config.display_name} - {config.description}"
            for name, config in self.MODELS.items()
        }
    
    def get_model_info(self, model_name: str) -> Dict[str, Any]:
        """Get detailed information about a model"""
        config = self.get_model_config(model_name)
        return {
            'name': config.name,
            'display_name': config.display_name,
            'description': config.description,
            'temperature': config.temperature,
            'top_p': config.top_p,
            'top_k': config.top_k,
            'max_output_tokens': config.max_output_tokens,
            'max_retries': config.max_retries,
            'base_delay': config.base_delay
        }
    
    def validate_model(self, model_name: str) -> bool:
        """Validate if a model is available and accessible"""
        try:
            model = self.create_model_instance(model_name)
            # Try a simple test to verify the model works
            response = model.generate_content("Hello", generation_config=self.get_generation_config(model_name))
            return response.text is not None
        except Exception as e:
            logger.error(f"Model validation failed for {model_name}: {e}")
            return False

# Global instance for easy access
_model_config_manager = None

def get_model_config_manager() -> ModelConfigManager:
    """Get the global model configuration manager"""
    global _model_config_manager
    if _model_config_manager is None:
        _model_config_manager = ModelConfigManager()
    return _model_config_manager

def create_model_components(model_name: str, api_key: Optional[str] = None, prompt_mode: str = "full"):
    """
    Factory function to create model components with specified model
    
    Args:
        model_name: Name of the Gemini model to use
        api_key: Optional API key (will use environment if not provided)
        prompt_mode: Prompt mode ('full', 'fast', 'emergency')
    
    Returns:
        Tuple of (fact_extractor, query_generator)
    """
    from stage3_fact_extractor import Stage3FactExtractor
    from stage3_query_generator import Stage3QueryGenerator
    
    # Validate model
    manager = ModelConfigManager(api_key)
    if not manager.validate_model(model_name):
        raise ValueError(f"Model {model_name} is not available or accessible")
    
    # Create components
    fact_extractor = Stage3FactExtractor(
        api_key=manager.api_key,
        prompt_mode=prompt_mode,
        model_name=model_name
    )
    
    query_generator = Stage3QueryGenerator(
        api_key=manager.api_key,
        prompt_mode=prompt_mode,
        model_name=model_name
    )
    
    logger.info(f"Created model components for {model_name}")
    return fact_extractor, query_generator 