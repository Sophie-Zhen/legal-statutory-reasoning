# Flexible Model System for Stage 3 Method 2 Pipeline

## Overview

The flexible model system allows easy switching between different Gemini models for comparison testing and experimentation. This system provides a unified interface for testing multiple models with the same pipeline configuration.

## Available Models

The system currently supports the following Gemini models:

| Model Name | Display Name | Description |
|------------|--------------|-------------|
| `gemini-2.0-flash-exp` | Gemini 2.0 Flash Experimental | Experimental flash model with fast response times |
| `gemini-2.5-pro` | Gemini 2.5 Pro | Pro model with enhanced reasoning capabilities |
| `gemini-1.5-pro` | Gemini 1.5 Pro | Stable pro model with good performance |
| `gemini-1.5-flash` | Gemini 1.5 Flash | Fast model with good cost-performance ratio |

## Key Components

### 1. ModelConfigManager (`model_config.py`)

Central configuration management for all models:
- **Model Configuration**: Stores model-specific parameters (temperature, top_p, etc.)
- **Model Creation**: Factory methods for creating model instances
- **Model Validation**: Tests if models are accessible and working
- **Configuration Management**: Centralized parameter management

### 2. FlexibleStage3Runner (`flexible_runner.py`)

Main runner with multi-model support:
- **Model Switching**: Easy switching between models at runtime
- **Model Comparison**: Side-by-side testing of multiple models
- **Command Line Interface**: Rich CLI for various testing scenarios
- **Results Management**: Automated saving and comparison of results

## Usage Examples

### 1. List Available Models

```bash
python flexible_runner.py --list-models
```

### 2. Get Model Information

```bash
python flexible_runner.py --model-info gemini-2.5-pro
```

### 3. Test with Specific Model

```bash
# Test with gemini-2.5-pro
python flexible_runner.py --model gemini-2.5-pro --num-cases 3

# Test with gemini-2.0-flash-exp
python flexible_runner.py --model gemini-2.0-flash-exp --num-cases 3
```

### 4. Compare Multiple Models

```bash
# Compare two models on 5 cases
python flexible_runner.py --compare gemini-2.0-flash-exp gemini-2.5-pro --num-cases 5

# Compare specific cases
python flexible_runner.py --compare gemini-2.0-flash-exp gemini-2.5-pro --cases s151_d_1_pos s151_d_1_neg
```

### 5. Test Specific Cases

```bash
# Test specific cases with a model
python flexible_runner.py --model gemini-2.5-pro --cases s151_d_1_pos s151_d_3_A_neg
```

## Command Line Interface

### Basic Options

- `--model, -m`: Select model to use (default: gemini-2.0-flash-exp)
- `--prompt-mode`: Choose prompt mode (full, fast, emergency)
- `--num-cases, -n`: Number of test cases (default: 5)
- `--start-idx`: Starting index for test cases (default: 0)
- `--cases`: Specific case IDs to test

### Commands

- `--compare`: Compare multiple models
- `--list-models`: List available models
- `--model-info`: Show detailed model information

## Model Comparison Output

When comparing models, the system provides:

### 1. Real-time Progress
```
============================================================
Testing model: gemini-2.5-pro
============================================================
Model gemini-2.5-pro completed: 80.0% success rate
```

### 2. Summary Table
```
================================================================================
MODEL COMPARISON SUMMARY
================================================================================
Model                     Success Rate    Cases      Status              
--------------------------------------------------------------------------------
gemini-2.0-flash-exp      60.0%          3/5        OK                  
gemini-2.5-pro            80.0%          4/5        OK                  
================================================================================
```

### 3. Detailed Results File
Results are saved to `results/model_comparison_YYYYMMDD_HHMMSS.json` with:
- Test configuration
- Per-model results
- Summary statistics
- Full execution details

## Programming Interface

### Basic Usage

```python
from flexible_runner import FlexibleStage3Runner

# Initialize with specific model
runner = FlexibleStage3Runner(model_name="gemini-2.5-pro")

# Run test cases
results = runner.run_single_model_test(num_cases=5)

# Switch models
runner.switch_model("gemini-2.0-flash-exp")
```

### Model Comparison

```python
# Compare multiple models
results = runner.run_model_comparison(
    models=["gemini-2.0-flash-exp", "gemini-2.5-pro"],
    num_cases=5
)
```

### Model Configuration

```python
from model_config import ModelConfigManager

manager = ModelConfigManager()

# Get model info
info = manager.get_model_info("gemini-2.5-pro")

# Create model instance
model = manager.create_model_instance("gemini-2.5-pro")

# Get generation config
config = manager.get_generation_config("gemini-2.5-pro")
```

## Configuration

### Model Parameters

Each model has configurable parameters:

```python
@dataclass
class ModelConfig:
    name: str
    display_name: str
    temperature: float = 0.1      # Randomness (0.0-1.0)
    top_p: float = 0.9           # Nucleus sampling
    top_k: int = 40              # Top-k sampling
    max_output_tokens: int = 2048 # Maximum response length
    candidate_count: int = 1      # Number of candidates
    max_retries: int = 3         # Retry attempts
    base_delay: float = 1.0      # Base delay for retries
    description: str = ""        # Model description
```

### Adding New Models

To add a new model, update the `MODELS` dictionary in `model_config.py`:

```python
MODELS = {
    "new-model-name": ModelConfig(
        name="new-model-name",
        display_name="New Model Display Name",
        temperature=0.1,
        # ... other parameters
        description="Description of the new model"
    ),
    # ... existing models
}
```

## Integration with Existing Pipeline

The flexible model system is fully compatible with the existing pipeline:

### 1. Backward Compatibility
- All existing scripts continue to work
- Default model is `gemini-2.0-flash-exp`
- Same API for fact extraction and query generation

### 2. Easy Migration
```python
# Old way
from stage3_fact_extractor import Stage3FactExtractor
fact_extractor = Stage3FactExtractor(api_key, model_name="gemini-2.5-pro")

# New way (same result)
from model_config import create_model_components
fact_extractor, query_generator = create_model_components("gemini-2.5-pro")
```

## Best Practices

### 1. Model Selection
- **gemini-2.0-flash-exp**: Fast testing, development
- **gemini-2.5-pro**: Production, complex reasoning
- **gemini-1.5-pro**: Stable baseline
- **gemini-1.5-flash**: Cost-effective testing

### 2. Testing Strategy
1. Start with small test sets (5-10 cases)
2. Compare models on same cases for fair comparison
3. Use `--compare` for systematic evaluation
4. Save results for analysis

### 3. Performance Monitoring
- Monitor success rates across models
- Track response times and costs
- Use model info to understand capabilities
- Validate models before large-scale testing

## Troubleshooting

### Common Issues

1. **Model Not Available**
   ```
   Error: Model gemini-x.x-pro is not available or accessible
   ```
   Solution: Check model name spelling and API access

2. **API Key Issues**
   ```
   ValueError: GEMINI_API_KEY environment variable not set
   ```
   Solution: Set environment variable or check conda environment

3. **Import Errors**
   ```
   ModuleNotFoundError: No module named 'model_config'
   ```
   Solution: Ensure you're running from the scripts directory

### Debug Commands

```bash
# Test model validation
python -c "from model_config import ModelConfigManager; print(ModelConfigManager().validate_model('gemini-2.5-pro'))"

# Check API key
python -c "import os; print('API Key:', 'SET' if os.getenv('GEMINI_API_KEY') else 'NOT SET')"
```

## Future Enhancements

### Planned Features
1. **Model Performance Metrics**: Response time, token usage tracking
2. **Custom Model Configurations**: User-defined parameter sets
3. **Batch Processing**: Large-scale model comparisons
4. **Result Analytics**: Statistical analysis of model performance
5. **Model Recommendations**: Automatic model selection based on task type

### Extension Points
- Add new model providers (Claude, GPT-4, etc.)
- Custom evaluation metrics
- Integration with MLflow for experiment tracking
- Automated hyperparameter tuning 