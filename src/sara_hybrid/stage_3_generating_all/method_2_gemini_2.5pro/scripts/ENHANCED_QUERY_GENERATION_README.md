# Enhanced Query Generation with Question Classification

## Overview

This document describes the enhanced query generation system that adds explicit question type classification and type consistency validation to the Stage 3 Method 2 pipeline.

## Key Improvements

### 1. **Step 0: Question Classification**

The LLM now **first analyzes and classifies** the question type before generating queries:

#### Question Types:
- **CALCULATION**: Questions asking "how much", "what is the amount", "calculate" - seeking numerical results
- **LOGIC**: Questions testing truth/falsehood, containing "entailment", "contradiction", "applies"

#### Classification Process:
1. LLM analyzes the natural language question
2. Identifies keywords and patterns
3. Classifies as CALCULATION or LOGIC
4. Provides reasoning for the classification

### 2. **Enhanced Prompt Structure**

#### New Prompt Format:
```
**STEP 0: QUESTION CLASSIFICATION (MANDATORY FIRST STEP)**
[Classification rules and examples]

**STEP 1: QUERY GENERATION BASED ON CLASSIFICATION**
[Type-specific generation guidelines]

**REQUIRED OUTPUT FORMAT:**
Question Type: [CALCULATION or LOGIC]
Reasoning: [Brief explanation]
Query: answer(case_id, Result) :- [Prolog clause body].
```

### 3. **Type Consistency Validation**

The system validates that generated queries match the classified question type:

#### For CALCULATION Questions:
- ✅ Should use calculation predicates (`exemption_amount`, `tax_imposed`, etc.)
- ❌ Should NOT contain complex true/false conditional logic

#### For LOGIC Questions:
- ✅ Should contain conditional structures (`->`, `;`, comparisons)
- ✅ Should test conditions and return true/false
- ✅ Should handle contradiction/entailment patterns

### 4. **Regeneration with Feedback**

When type inconsistencies are detected:
1. System provides specific feedback about the mismatch
2. LLM gets a second chance with targeted guidance
3. Up to 3 attempts with exponential backoff

### 5. **Pure LLM Focus**

**Removed all rule-based fallback generation:**
- No manual query templates
- No hardcoded predicate patterns
- Pure test of LLM capability
- Either LLM succeeds or task fails (no hybrid rescue)

## Implementation Details

### Modified Files:

#### 1. `dynamic_prompt_generator.py`
- **Enhanced `_generate_full_query_prompt()`**: Added Step 0 classification instructions
- **Enhanced `_generate_fast_query_prompt()`**: Added classification for fast mode
- **New structured output format**: Question Type + Reasoning + Query

#### 2. `stage3_query_generator.py`
- **Enhanced `generate_query()`**: Parses structured response format
- **New `_parse_structured_response()`**: Extracts type, reasoning, and query
- **New `_validate_type_consistency()`**: Checks query matches question type
- **Enhanced `generate_with_retries()`**: Handles type feedback and regeneration
- **Removed fallback methods**: All rule-based query generation removed

### Sample Output:

```
Question Type: LOGIC
Reasoning: The question asks if Alice's exemption amount is equal to $0, which is a contradiction. This is a logic question that requires checking a condition and returning true if the condition is false (contradiction) and false if the condition is true.
Query: answer(s151_d_1_neg, Result) :- section151:exemption_amount(alice, s151_d_1_neg, 2015, Amount), (Amount =:= 0 -> Result = false ; Result = true).
```

## Test Results

### Successful Test Cases:

#### Test Case 1: LOGIC Question
- **Question**: "Alice's exemption amount under section 151(d)(1) is equal to $0. Contradiction"
- **Classified As**: LOGIC ✅
- **Generated Query**: Proper contradiction testing with conditional logic ✅
- **Type Consistency**: Valid ✅

#### Test Case 2: CALCULATION Question  
- **Question**: "How much tax does Alice have to pay in 2018?"
- **Classified As**: CALCULATION ✅
- **Generated Query**: Uses tax calculation predicates ✅
- **Type Consistency**: Valid ✅

## Benefits

### 1. **Improved Accuracy**
- **Systematic approach**: LLM understands context before generating
- **Type-aware generation**: Different strategies for different question types
- **Self-validation**: Built-in consistency checking

### 2. **Better Debugging**
- **Explicit reasoning**: Can see why LLM classified questions
- **Type mismatch detection**: Clear feedback when logic doesn't match
- **Structured logging**: Enhanced traceability

### 3. **Pure LLM Testing**
- **No rule assistance**: Tests actual LLM capability
- **No fallback rescue**: Clear success/failure metrics
- **Research focus**: Understanding LLM strengths/weaknesses

### 4. **Enhanced Reliability**
- **Multiple attempts**: Retry with targeted feedback
- **Validation layers**: Syntax + type consistency
- **Graceful degradation**: Clear error reporting

## Usage

### Testing Individual Components:
```bash
python test_enhanced_query_generation.py
```

### Testing Full Pipeline:
```bash
python test_enhanced_pipeline.py
```

### Running Production Pipeline:
```bash
python run_stage3_method2.py
```

## Monitoring

### New Logging Features:
- Question type classification
- Reasoning explanations
- Type consistency results
- Feedback attempts
- Enhanced error details

### Raw Response Data:
```json
{
  "question_type": "LOGIC",
  "reasoning": "Tests contradiction...",
  "type_consistency_check": {
    "is_consistent": true,
    "reason": "Query structure matches question type"
  }
}
```

## Future Enhancements

### Potential Improvements:
1. **Fine-grained type classification**: More specific question subtypes
2. **Dynamic validation rules**: Adaptive consistency checking
3. **Learning from patterns**: Improve prompts based on common mistakes
4. **Multi-step reasoning**: Break complex questions into sub-steps

## Conclusion

The enhanced query generation system provides:
- **Systematic question understanding** via explicit classification
- **Type-aware query generation** with consistency validation
- **Pure LLM capability testing** without rule-based assistance
- **Improved debugging and monitoring** for better development

This represents a significant step toward more reliable and interpretable LLM-based legal reasoning systems. 