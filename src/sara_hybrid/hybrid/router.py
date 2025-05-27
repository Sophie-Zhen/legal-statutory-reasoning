# src/sara_hybrid/hybrid/router.py

import os
from pathlib import Path
from typing import Dict, Any, Tuple, List
import openai # Ensure openai is listed in pyproject.toml dependencies
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, AutoConfig # Ensure transformers is listed

# --- Constants ---
ENTAILMENT: str = "Entailment"
CONTRADICTION: str = "Contradiction"

# --- Configuration Keys for 'case' dictionary ---
STATUTE_NL_KEY: str = "statute_text"       # For T5 input & LLM prompt
SCENARIO_NL_KEY: str = "scenario_text"      # For LLM prompt
HYPOTHESIS_NL_KEY: str = "hypothesis_text"  # For LLM prompt
PROLOG_QUERY_KEY: str = "prolog_query"      # For symbolic.executor.exec_rules
PROLOG_FACTS_KEY: str = "prolog_facts"      # For symbolic.executor.exec_rules

# --- Model Paths & Global Instances ---
_MODEL_DIR = Path(__file__).resolve().parents[3] / "models" / "t5_statute2logic"

_t5_model = None
_t5_tokenizer = None
_openai_client = None

# --- Initialize T5 Model & Tokenizer ---
if not _MODEL_DIR.is_dir():
    print(f"WARNING: router.py: T5 model directory not found: {_MODEL_DIR}. Real translation will be unavailable.")
else:
    try:
        print(f"INFO: router.py: Attempting to load T5 model from {_MODEL_DIR}...")
        _t5_config = AutoConfig.from_pretrained(_MODEL_DIR, local_files_only=True)
        _t5_tokenizer = AutoTokenizer.from_pretrained(_MODEL_DIR, local_files_only=True)
        _t5_model = AutoModelForSeq2SeqLM.from_pretrained(_MODEL_DIR, config=_t5_config, local_files_only=True)
        print("INFO: router.py: T5 translator model and tokenizer loaded successfully.")
    except Exception as e:
        print(f"ERROR: router.py: Failed to load T5 model/tokenizer from {_MODEL_DIR}: {e}. Real translation will be unavailable.")
        _t5_model = None
        _t5_tokenizer = None

# --- Initialize OpenAI Client ---
_openai_api_key = os.getenv("OPENAI_API_KEY")
if not _openai_api_key:
    print("WARNING: router.py: OPENAI_API_KEY environment variable not set. LLM fallback will be unavailable.")
else:
    try:
        _openai_client = openai.OpenAI(api_key=_openai_api_key)
        print("INFO: router.py: OpenAI client initialized successfully.")
    except Exception as e:
        print(f"ERROR: router.py: Failed to initialize OpenAI client: {e}. LLM fallback will be unavailable.")
        _openai_client = None

# --- Symbolic Executor (tests monkey-patch exec_rules) ---
# This try-except block is from your working minimal router.py
try:
    # This assumes exec_rules is the correct callable from your symbolic executor
    from sara_hybrid.symbolic.executor import exec_rules  # type: ignore
    print("INFO: router.py: Successfully imported 'exec_rules' from symbolic.executor.")
except Exception as e_symbolic_import:  # pragma: no cover – SWI-Prolog may be absent
    print(f"WARNING: router.py: Failed to import 'exec_rules' from symbolic.executor (Error: {e_symbolic_import}). Using fallback stub.")
    def exec_rules(rules: str, facts: str, query: str) -> Tuple[bool, None]:  # type: ignore
        """Fallback stub for exec_rules that always indicates failure."""
        print("WARNING: router.py: Using STUB exec_rules. Symbolic path will likely result in Contradiction via this stub.")
        return False, None # Default to False (non-entailment) if symbolic executor is unavailable

# --- Default Translation Function (uses loaded T5 model) ---
def _default_translate_statute_to_prolog(statute_nl_text: str) -> str | None:
    if not _t5_model or not _t5_tokenizer:
        print("INFO: _default_translate_statute_to_prolog: T5 model/tokenizer not available. Cannot translate.")
        return None
    try:
        inputs = _t5_tokenizer(statute_nl_text, return_tensors="pt", truncation=True, max_length=512)
        # Ensure model and inputs are on the same device if GPU is ever used
        # For CPU, this is fine.
        outputs = _t5_model.generate(**inputs, max_length=512, num_beams=4, early_stopping=True)
        fol_rules = _t5_tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(f"INFO: _default_translate_statute_to_prolog: Translated to FOL: '{fol_rules[:100]}...'")
        return fol_rules
    except Exception as e:
        print(f"ERROR: _default_translate_statute_to_prolog: Translation failed: {e}")
        return None

# This is the function tests will monkey-patch. It defaults to our T5 implementation.
translate_statute_to_prolog = _default_translate_statute_to_prolog


# --- LLM Fallback Function ---
def _get_llm_answer(case_data: Dict[str, Any]) -> str:
    case_id = case_data.get('id', 'N/A_LLM')
    print(f"INFO: Case ID {case_id}: Attempting LLM fallback.")
    if not _openai_client:
        print("ERROR: Case ID {case_id}: _get_llm_answer: OpenAI client not available. Returning default Contradiction.")
        return CONTRADICTION

    statute_nl = case_data.get(STATUTE_NL_KEY)
    scenario_nl = case_data.get(SCENARIO_NL_KEY)
    hypothesis_nl = case_data.get(HYPOTHESIS_NL_KEY)

    if not all([statute_nl, scenario_nl, hypothesis_nl]):
        missing_llm_keys = [k for k, v in {STATUTE_NL_KEY: statute_nl, SCENARIO_NL_KEY: scenario_nl, HYPOTHESIS_NL_KEY: hypothesis_nl}.items() if not v]
        print(f"ERROR: Case ID {case_id}: _get_llm_answer: Missing required NL data for LLM prompt ({', '.join(missing_llm_keys)}). Returning default Contradiction.")
        return CONTRADICTION

    prompt = (
        f'Analyze the following legal statute, factual scenario, and hypothesis.\n'
        f'Based *strictly* on the provided statute and facts, determine if the hypothesis is an "{ENTAILMENT}" or a "{CONTRADICTION}".\n'
        f'Your answer must be a single word: either "{ENTAILMENT}" or "{CONTRADICTION}".\n\n'
        f'Statute:\n{statute_nl}\n\n'
        f'Factual Scenario:\n{scenario_nl}\n\n'
        f'Hypothesis:\n{hypothesis_nl}\n\n'
        f'Answer ("{ENTAILMENT}" or "{CONTRADICTION}"):'
    )

    try:
        completion = _openai_client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": f"You are a precise legal reasoning assistant. Your answer must be only the word '{ENTAILMENT}' or '{CONTRADICTION}'."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.0,
            max_tokens=10  # "Entailment" or "Contradiction" are short
        )
        raw_answer = completion.choices[0].message.content.strip().lower().replace(".", "")
        
        if raw_answer == ENTAILMENT.lower():
            print(f"INFO: Case ID {case_id}: _get_llm_answer: LLM returned Entailment.")
            return ENTAILMENT
        elif raw_answer == CONTRADICTION.lower():
            print(f"INFO: Case ID {case_id}: _get_llm_answer: LLM returned Contradiction.")
            return CONTRADICTION
        else:
            print(f"WARNING: Case ID {case_id}: _get_llm_answer: LLM returned unexpected answer: '{raw_answer}'. Defaulting to Contradiction.")
            return CONTRADICTION
    except Exception as e:
        print(f"ERROR: Case ID {case_id}: _get_llm_answer: LLM API call failed: {e}. Returning default Contradiction.")
        return CONTRADICTION

# --- Public Entry-Point: `decide_case` ---
def decide_case(case: Dict[str, Any]) -> str:
    case_id = case.get('id', 'N/A')
    print(f"\nINFO: Case ID {case_id}: Processing case.")

    statute_nl: str | None = case.get(STATUTE_NL_KEY)
    prolog_query: str | None = case.get(PROLOG_QUERY_KEY)
    prolog_facts: str = case.get(PROLOG_FACTS_KEY, "") # Defaults to empty string if missing

    # Attempt symbolic path first
    if statute_nl and prolog_query: # prolog_facts can be empty
        print(f"INFO: Case ID {case_id}: Attempting symbolic path. Calling translate_statute_to_prolog...")
        # `translate_statute_to_prolog` is module-level, potentially patched by tests.
        # Default uses `_t5_model` and `_t5_tokenizer`.
        rules: str | None = translate_statute_to_prolog(statute_nl)

        if rules:
            print(f"INFO: Case ID {case_id}: Translation successful (or patched). Calling exec_rules...")
            # `exec_rules` is module-level, potentially patched by tests.
            # Default is from symbolic.executor or a stub.
            try:
                # The test mock for exec_rules returns (bool, list).
                # The actual exec_rules from symbolic.executor should also conform or be adapted.
                ok, _bindings = exec_rules(rules, prolog_facts, prolog_query)
                
                # Simple heuristic: if symbolic execution ran and gave a boolean, trust it.
                print(f"INFO: Case ID {case_id}: Symbolic execution 'exec_rules' completed. Result (ok): {ok}")
                return ENTAILMENT if ok else CONTRADICTION
            except Exception as e_exec:
                # This catches errors from the exec_rules call itself (e.g., Prolog engine error)
                print(f"WARNING: Case ID {case_id}: Symbolic execution 'exec_rules' raised an exception: {e_exec}. Falling back to LLM.")
                # Proceed to LLM fallback below
        else:
            # Translation failed (e.g., _t5_model not loaded, or actual translation error) or test patch returned None
            print(f"INFO: Case ID {case_id}: Translation failed or produced no rules. Falling back to LLM.")
            # Proceed to LLM fallback below
    else:
        missing_keys = []
        if not statute_nl: missing_keys.append(STATUTE_NL_KEY)
        if not prolog_query: missing_keys.append(PROLOG_QUERY_KEY)
        print(f"INFO: Case ID {case_id}: Essential data for symbolic path missing ({', '.join(missing_keys)}). Falling back to LLM.")
        # Proceed to LLM fallback below
    
    # If symbolic path didn't return, fall back to LLM
    return _get_llm_answer(case)

print(f"INFO: router.py: Module loaded. T5 available: {bool(_t5_model)}. OpenAI Client available: {bool(_openai_client)}. Symbolic 'exec_rules' points to: {exec_rules.__name__ if hasattr(exec_rules, '__name__') else str(exec_rules)}")